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

class Chef::Recipe # rubocop:disable Documentation
  include ::Openstack
end

class Chef::Resource::RubyBlock # rubocop:disable Documentation
  include ::Openstack
end

platform_options = node['openstack']['integration-test']['platform']

platform_options['tempest_packages'].each do |pkg|
  package pkg do
    options platform_options['package_overrides']

    action :upgrade
  end
end

package 'curl'

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
  openstack_domain_name:    admin_domain
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

  openstack_role service_role do
    connection_params connection_params
  end

  openstack_user service_user do
    project_name service_project
    role_name service_role
    password service_pass
    connection_params connection_params
  end

  openstack_user service_user do
    role_name service_role
    project_name service_project
    connection_params connection_params
    action :grant_role
  end

  openstack_user service_user do
    domain_name service_domain
    role_name service_role
    user_name service_user
    connection_params connection_params
    action :grant_domain
  end
end

heat_stack_user_role = node['openstack']['integration-test']['heat_stack_user_role']
openstack_role heat_stack_user_role do
  connection_params connection_params
end

git '/opt/tempest' do
  repository 'https://github.com/openstack/tempest'
  reference 'master'
  depth 1
  action :sync
end

%w(image1 image2).each do |img|
  image_name = node['openstack']['integration-test'][img]['name']
  openstack_image_image img do
    identity_user admin_user
    identity_pass admin_pass
    identity_tenant admin_project
    identity_uri auth_url
    identity_user_domain_name admin_domain
    identity_project_domain_name admin_project_domain_name
    image_name image_name
    image_url node['openstack']['integration-test'][img]['source']
  end

  # NOTE: This has to be done in a ruby_block so it gets executed at execution
  #       time and not compile time (when glance does not yet exist).
  ruby_block "Get and set #{img}'s ID" do
    block do
      begin
        env = openstack_command_env admin_user, admin_project
        id = image_id image_name, env
        node.set['openstack']['integration-test'][img]['id'] = id
      rescue RuntimeError => e
        Chef::Log.error("UUID not found for Glance image #{image_name}. Error was #{e.message}")
      end
    end
    not_if { node['openstack']['integration-test'][img]['id'] }
  end
end

# NOTE: This has to be done in a ruby_block so it gets executed at execution
#       time and not compile time (when nova does not yet exist).
ruby_block 'Create nano flavor 99' do
  block do
    begin
      env = openstack_command_env(admin_user, admin_project)
      output = openstack_command('nova', 'flavor-list', env)
      unless output.include? 'm1.nano'
        openstack_command('nova', 'flavor-create m1.nano 99 64 0 1', env)
      end
    rescue RuntimeError => e
      Chef::Log.error("Could not create flavor m1.nano. Error was #{e.message}")
    end
  end
end

template '/opt/tempest/etc/tempest.conf' do
  source 'tempest.conf.erb'
  owner 'root'
  group 'root'
  mode 00600
  # NOTE: We do not pass the image1/image2 node attributes above to the
  #       template but embed directly in the template itself instead to work
  #       around the variables being evaluated at compile time (prior to
  #       get_image_id being executed).
  variables(
    'tempest_disable_ssl_validation' => node['openstack']['integration-test']['disable_ssl_validation'],
    'identity_endpoint_host' => identity_public_endpoint.host,
    'identity_endpoint_port' => identity_public_endpoint.port,
    'identity_endpoint_scheme' => identity_public_endpoint.scheme,
    'tempest_use_dynamic_credentials' => node['openstack']['integration-test']['use_dynamic_credentials'],
    'tempest_user1' => node['openstack']['integration-test']['user1']['user_name'],
    'tempest_user1_pass' => node['openstack']['integration-test']['user1']['password'],
    'tempest_user1_project' => node['openstack']['integration-test']['user1']['project_name'],
    'tempest_img_flavor1' => node['openstack']['integration-test']['image1']['flavor'],
    'tempest_img_flavor2' => node['openstack']['integration-test']['image2']['flavor'],
    'tempest_admin' => node['openstack']['identity']['admin_user'],
    'tempest_admin_project' => admin_project,
    'tempest_admin_pass' => admin_pass,
    'tempest_alt_ssh_user' => node['openstack']['integration-test']['alt_ssh_user'],
    'tempest_ssh_user' => node['openstack']['integration-test']['ssh_user'],
    'tempest_user2' => node['openstack']['integration-test']['user2']['user_name'],
    'tempest_user2_pass' => node['openstack']['integration-test']['user2']['password'],
    'tempest_user2_tenant' => node['openstack']['integration-test']['user2']['project_name'],
    'tempest_fixed_network' => node['openstack']['integration-test']['fixed_network']
  )
end
