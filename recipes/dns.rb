#
# Cookbook:: openstack-integration-test
# Recipe:: dns
#
# Copyright:: 2020, Oregon State University
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

class ::Chef::Recipe
  include ::Openstack
  include BindCookbook::Helpers
end

class ::Chef::Resource
  include BindCookbook::Helpers
end

service 'systemd-resolved' do
  action [:stop, :disable]
end

# Match what opendev/base-jobs uses for unbound:
# https://opendev.org/opendev/base-jobs/src/branch/master/roles/configure-unbound/defaults/main.yaml#L1-L7
node.default['resolver']['search'] = []
node.default['resolver']['nameservers'] = %w(1.0.0.1 8.8.8.8)

include_recipe 'resolver'

# Disable and stop unbound so we can properly test Designate
service 'unbound' do
  action [:disable, :stop]
end

bind_service 'default' do
  action [:create, :start]
end

rndc_secret = get_password 'token', 'designate_rndc'

template "#{default_property_for(:sysconfdir, false)}/rndc.key" do
  source 'rndc.key.erb'
  cookbook 'openstack-dns'
  owner default_property_for(:run_user, false)
  group default_property_for(:run_group, false)
  mode '440'
  sensitive true
  variables(
    secret: rndc_secret
  )
  notifies :restart, 'bind_service[default]'
end

template "#{default_property_for(:sysconfdir, false)}/named.designate" do
  owner default_property_for(:run_user, false)
  group default_property_for(:run_group, false)
  variables(
    bind_sysconfig: default_property_for(:sysconfdir, false)
  )
  notifies :restart, 'bind_service[default]'
end

bind_config 'default' do
  options [
    'allow-new-zones yes',
  ]
  additional_config_files %w(named.designate)
end
