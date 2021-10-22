#
# Cookbook:: openstack-integration-test
# Attributes:: default
#
# Copyright:: 2014-2021, Rackspace US, Inc.
# Copyright:: 2017-2021, Oregon State University
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

default['openstack']['integration-test'] = {
  'branch' => nil,
  'disable_ssl_validation' => false,
  'use_dynamic_credentials' => true,
  'alt_ssh_user' => 'cirros',
  'ssh_user' => 'cirros',
  'fixed_network' => 'local_net',
  'heat_stack_user_role' => 'heat_stack_owner',
  'nova_user' => 'nova',
  'nova_group' => 'nova',
  'blacklist_regex' => [
    # TODO(ramereth): iSCSI service needs to be fixed in block-storage
    # due to missing tgtadm executable and functioning iscsid service.
    'tempest.api.compute.servers.test_create_server.ServersTestBootFromVolume',
  ],
  'user1' => {
    'user_name' => 'tempest_user1',
    'password' => 'tempest_user1_pass',
    'project_name' => 'tempest_project1',
    'role' => 'Member',
    'domain_name' => 'Default',
  },
  'user2' => {
    'user_name' => 'tempest_user2',
    'password' => 'tempest_user2_pass',
    'project_name' => 'tempest_project2',
    'role' => 'Member',
    'domain_name' => 'Default',
  },
  'image1' => {
    'name' => 'cirros-test1',
    'id' => '1ac790f6-903a-4833-979f-a38f1819e3b1',
    'flavor' => 99,
    'source' => 'http://download.cirros-cloud.net/0.4.0/cirros-0.4.0-x86_64-disk.img',
  },
  'image2' => {
    'name' => 'cirros-test2',
    'id' => 'f7c2ac6d-0011-499f-a9ec-ca71348bf2e4',
    'flavor' => 99,
    'source' => 'http://download.cirros-cloud.net/0.4.0/cirros-0.4.0-x86_64-disk.img',
  },
}

# platform-specific settings
case node['platform_family']
when 'rhel'
  case node['platform_version'].to_i
  when 8
    default['openstack']['integration-test']['platform'] = {
      tempest_packages:
        %w(
          curl
          git
          libffi-devel
          libxml2-devel
          libxslt-devel
          python3-ddt
          python3-gabbi
          python3-testrepository
          python3-testscenarios
          python36-devel
        ),
      package_overrides: '',
    }
  when 7
    default['openstack']['integration-test']['platform'] = {
      tempest_packages:
        %w(
          curl
          git
          libffi-devel
          libxml2-devel
          libxslt-devel
          python-ddt
          python-devel
          python-gabbi
          python-testrepository
          python-testscenarios
        ),
      package_overrides: '',
    }
  end
when 'debian'
  default['openstack']['integration-test']['platform'] = {
    'tempest_packages' =>
      %w(
        curl
        git
        libffi-dev
        libffi-dev
        libpq-dev
        libssl-dev
        libxml2-dev
        libxml2-dev
        libxslt1-dev
        libxslt-dev
        python-ddt
        python-dev
        python-dev
        python-gabbi
        python-testscenarios
        testrepository
      ),
    'package_overrides' => '',
  }
end
