# encoding: UTF-8
#
# Cookbook Name:: openstack-integration-test
# Recipe:: create_network
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

# Purpose: For use in kitchen tempest tests, create network/subnet identical to
#          openstack-chef-repo/Rakefile _setup_local_network

class Chef::Recipe
  include ::Openstack
end

class Chef::Resource::RubyBlock
  include ::Openstack
end

admin_user = node['openstack']['identity']['admin_user']
admin_project = node['openstack']['identity']['admin_project']
netname = node['openstack']['integration-test']['fixed_network']
subnetname = 'local_subnet'

# NOTE: This has to be done in a ruby_block so it gets executed at execution
#       time and not compile time (when nova does not yet exist).
ruby_block 'create_shared_network_for_testing' do
  block do
    begin
      env = openstack_command_env(admin_user, admin_project, 'Default', 'Default')
      output = openstack_command('openstack', 'network list', env)
      unless output.include? netname
        openstack_command('openstack', "network create --share #{netname}", env)
      end
      output = openstack_command('openstack', 'subnet list', env)
      unless output.include? subnetname
        openstack_command('openstack', "subnet create --network #{netname} --subnet-range 192.168.180.0/24 #{subnetname}", env)
      end
    rescue RuntimeError => e
      Chef::Log.error("Could not create network/subnet. Error was #{e.message}")
    end
  end
end
