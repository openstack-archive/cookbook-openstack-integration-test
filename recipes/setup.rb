# encoding: UTF-8
#
# Cookbook Name:: openstack-integration-test
# Recipe:: setup
#
# Copyright 2014, Rackspace US, Inc.
#
# Licensed under the Apache License, Version 2.0 (the 'License');
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an 'AS IS' BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

class Chef::Recipe
  include ::Openstack
end

class Chef::Resource::RubyBlock
  include ::Openstack
end

platform_options = node['openstack']['integration-test']['platform']

python_runtime 'tempest' do
  version '2'
  provider :system
end

platform_options['tempest_packages'].each do |pkg|
  package pkg do
    options platform_options['package_overrides']

    action :upgrade
  end
end

identity_admin_endpoint = admin_endpoint 'identity'
identity_public_endpoint = public_endpoint 'identity'
auth_url = ::URI.decode identity_admin_endpoint.to_s

admin_user = node['openstack']['identity']['admin_user']
admin_pass = get_password 'user', admin_user
admin_project = node['openstack']['identity']['admin_project']
admin_domain = node['openstack']['identity']['admin_domain_name']
admin_project_domain_name = node['openstack']['identity']['admin_project_domain']

connection_params = {
  openstack_auth_url:     "#{auth_url}/auth/tokens",
  openstack_username:     admin_user,
  openstack_api_key:      admin_pass,
  openstack_project_name: admin_project,
  openstack_domain_name:    admin_domain,
}

%w(user1 user2).each_with_index do |user|
  service_user = node['openstack']['integration-test'][user]['user_name']
  service_project = node['openstack']['integration-test'][user]['project_name']
  service_role = node['openstack']['integration-test'][user]['role']
  service_domain = node['openstack']['integration-test'][user]['domain_name']
  service_pass = node['openstack']['integration-test'][user]['password']

  openstack_project service_project do
    connection_params connection_params
  end

  openstack_user service_user do
    role_name service_role
    project_name service_project
    domain_name service_domain
    password service_pass
    connection_params connection_params
    action [:create, :grant_role, :grant_domain]
  end

  heat_stack_user_role = node['openstack']['integration-test']['heat_stack_user_role']
  openstack_role heat_stack_user_role do
    connection_params connection_params
  end
end

tempest_path = '/opt/tempest'
venv_path = '/opt/tempest-venv'

python_virtualenv venv_path do
  python 'tempest'
  system_site_packages true
end

python_execute 'install tempest' do
  action :nothing
  command '-m pip install .'
  cwd tempest_path
  virtualenv venv_path
end

git tempest_path do
  repository 'https://github.com/openstack/tempest'
  reference '17.2.0'
  depth 1
  action :sync
  notifies :run, 'python_execute[install tempest]', :immediately
end

template "#{venv_path}/tempest.sh" do
  source 'tempest.sh.erb'
  user 'root'
  group 'root'
  mode 0o755
  variables(
    venv_path: venv_path
  )
end

%w(image1 image2).each do |img|
  image_name = node['openstack']['integration-test'][img]['name']
  image_id = node['openstack']['integration-test'][img]['id']
  openstack_image_image img do
    identity_user admin_user
    identity_pass admin_pass
    identity_tenant admin_project
    identity_uri auth_url
    identity_user_domain_name admin_domain
    identity_project_domain_name admin_project_domain_name
    image_name image_name
    image_id image_id
    image_url node['openstack']['integration-test'][img]['source']
  end
end

# NOTE: This has to be done in a ruby_block so it gets executed at execution
#       time and not compile time (when nova does not yet exist).
ruby_block 'Create nano flavor 99' do
  block do
    begin
      env = openstack_command_env(admin_user, admin_project, 'Default', 'Default')
      output = openstack_command('nova', 'flavor-list', env)
      unless output.include? 'm1.nano'
        openstack_command('nova', 'flavor-create m1.nano 99 64 0 1', env)
      end
    rescue RuntimeError => e
      Chef::Log.error("Could not create flavor m1.nano. Error was #{e.message}")
    end
  end
end

node.default['openstack']['integration-test']['conf'].tap do |conf|
  conf['compute']['image_ref'] = node['openstack']['integration-test']['image1']['id']
  conf['compute']['image_ref_alt'] = node['openstack']['integration-test']['image2']['id']
  conf['identity']['uri'] = "#{identity_public_endpoint.scheme}://#{identity_public_endpoint.host}:#{identity_public_endpoint.port}/v2.0/"
  conf['identity']['uri_v3'] = "#{identity_public_endpoint.scheme}://#{identity_public_endpoint.host}:#{identity_public_endpoint.port}/v3/"
end

node.default['openstack']['integration-test']['conf_secrets'].tap do |conf_secrets|
  conf_secrets['auth']['admin_username'] = admin_user
  conf_secrets['auth']['admin_password'] = admin_pass
  conf_secrets['auth']['admin_project_name'] = admin_project
end

# merge all config options and secrets to be used in the nova.conf.erb
integration_test_conf_options = merge_config_options 'integration-test'

nova_user = node['openstack']['compute']['user']
nova_group = node['openstack']['compute']['group']

# create the keystone.conf from attributes
template '/opt/tempest/etc/tempest.conf' do
  source 'openstack-service.conf.erb'
  cookbook 'openstack-common'
  owner 'root'
  group 'root'
  mode 0o0600
  variables(
    service_config: integration_test_conf_options
  )
end

directory '/opt/tempest/logs' do
  owner 'root'
  group 'root'
  mode 0755
  action :create
end

# execute discover_hosts again before running tempest
execute 'discover_hosts' do
  user nova_user
  group nova_group
  command 'nova-manage cell_v2 discover_hosts'
  action :run
end

# delete all secrets saved in the attribute
# node['openstack']['identity']['conf_secrets'] after creating the keystone.conf
ruby_block "delete all attributes in node['openstack']['integration-test']['conf_secrets']" do
  block do
    node.rm(:openstack, :'integration-test', :conf_secrets)
  end
end
