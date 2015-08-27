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

identity_admin_endpoint = admin_endpoint 'identity-admin'
# Since this is testing things from the user's perspective,
# use the public identity endpoint
identity_api_endpoint   = public_endpoint 'identity-api'
bootstrap_token         = get_password 'token', 'openstack_identity_bootstrap_token'
auth_uri                = ::URI.decode identity_admin_endpoint.to_s
admin_pass              = get_password 'user', node['openstack']['identity']['admin_user']

%w(user1 user2).each_with_index do |user, i|
  i += 1

  openstack_identity_register "Register tempest tenant #{i}" do
    auth_uri auth_uri
    bootstrap_token bootstrap_token
    tenant_name node['openstack']['integration-test'][user]['tenant_name']
    tenant_description "Tempest tenant #{i}"

    action :create_tenant
  end

  openstack_identity_register "Register tempest user #{i}" do
    auth_uri auth_uri
    bootstrap_token bootstrap_token
    tenant_name node['openstack']['integration-test'][user]['tenant_name']
    user_name node['openstack']['integration-test'][user]['user_name']
    user_pass node['openstack']['integration-test'][user]['password']

    action :create_user
  end

  openstack_identity_register "Create tempest role #{i}" do
    auth_uri auth_uri
    bootstrap_token bootstrap_token
    tenant_name node['openstack']['integration-test'][user]['tenant_name']
    user_name node['openstack']['integration-test'][user]['user_name']
    user_pass node['openstack']['integration-test'][user]['password']
    role_name 'Member'

    action :create_role
  end

  openstack_identity_register "Grant 'member' Role to tempest user for tempest tenant ##{i}" do
    auth_uri auth_uri
    bootstrap_token bootstrap_token
    tenant_name node['openstack']['integration-test'][user]['tenant_name']
    user_name node['openstack']['integration-test'][user]['user_name']
    role_name 'Member'

    action :grant_role
  end
end

git '/opt/tempest' do
  repository 'https://github.com/openstack/tempest'
  reference 'master'
  depth 1
  action :sync
end

%w(image1 image2).each do |img|
  image_name = node['openstack']['integration-test'][img]['name']
  admin_user = node['openstack']['identity']['admin_user']
  admin_tenant = node['openstack']['identity']['admin_tenant_name']

  openstack_image_image img do
    identity_user admin_user
    identity_pass admin_pass
    identity_tenant admin_tenant
    identity_uri auth_uri
    image_name image_name
    image_url node['openstack']['integration-test'][img]['source']
  end

  # NOTE: This has to be done in a ruby_block so it gets executed at execution
  #       time and not compile time (when glance does not yet exist).
  ruby_block "Get and set #{img}'s ID" do
    block do
      begin
        env = openstack_command_env admin_user, admin_tenant
        id = image_id image_name, env
        node.set['openstack']['integration-test'][img]['id'] = id
      rescue RuntimeError => e
        Chef::Log.error("UUID not found for Glance image #{image_name}. Error was #{e.message}")
      end
    end
    not_if { node['openstack']['integration-test'][img]['id'] }
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
    'identity_endpoint_host' => identity_api_endpoint.host,
    'identity_endpoint_port' => identity_api_endpoint.port,
    'tempest_tenant_isolation' => node['openstack']['integration-test']['tenant_isolation'],
    'tempest_tenant_reuse' => node['openstack']['integration-test']['tenant_reuse'],
    'tempest_user1' => node['openstack']['integration-test']['user1']['user_name'],
    'tempest_user1_pass' => node['openstack']['integration-test']['user1']['password'],
    'tempest_user1_tenant' => node['openstack']['integration-test']['user1']['tenant_name'],
    'tempest_img_flavor1' => node['openstack']['integration-test']['image1']['flavor'],
    'tempest_img_flavor2' => node['openstack']['integration-test']['image2']['flavor'],
    'tempest_admin' => node['openstack']['identity']['admin_user'],
    'tempest_admin_tenant' => node['openstack']['identity']['admin_tenant_name'],
    'tempest_admin_pass' => admin_pass,
    'tempest_alt_ssh_user' => node['openstack']['integration-test']['alt_ssh_user'],
    'tempest_ssh_user' => node['openstack']['integration-test']['ssh_user'],
    'tempest_user2' => node['openstack']['integration-test']['user2']['user_name'],
    'tempest_user2_pass' => node['openstack']['integration-test']['user2']['password'],
    'tempest_user2_tenant' => node['openstack']['integration-test']['user2']['tenant_name']
  )
end
