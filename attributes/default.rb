# encoding: UTF-8
#
# Cookbook Name:: openstack-integration-test
# Attributes:: default
#
# Copyright 2014, Rackspace US, Inc.
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
  'tenant_isolation' => true,
  'tenant_reuse' => true,
  'alt_ssh_user' => 'cirros',
  'ssh_user' => 'cirros',
  'user1' => {
    'user_name' => 'tempest_user1',
    'password' => 'tempest_user1_pass',
    'tenant_name' => 'tempest_tenant1'
  },
  'user2' => {
    'user_name' => 'tempest_user2',
    'password' => 'tempest_user2_pass',
    'tenant_name' => 'tempest_tenant2'
  },
  'image1' => {
    'name' => 'cirros',
    'id' => nil,
    'flavor' => 1,
    'source' => 'http://download.cirros-cloud.net/0.3.2/cirros-0.3.2-x86_64-disk.img'
  },
  'image2' => {
    'name' => 'cirros',
    'id' => nil,
    'flavor' => 1,
    'source' => 'http://download.cirros-cloud.net/0.3.2/cirros-0.3.2-x86_64-disk.img'
  }
}

# platform-specific settings
case platform_family
when 'fedora', 'rhel' # :pragma-foodcritic: ~FC024 - won't fix this
  default['openstack']['integration-test']['platform'] = {
    'tempest_packages' => %w(git python-virtualenv libxslt-devel
                             libxml2-devel python-testrepository
                             libffi-devel),
    'package_overrides' => ''
  }
when 'debian'
  default['openstack']['integration-test']['platform'] = {
    'tempest_packages' => %w(git libxml2-dev libxslt-dev testrepository
                             python-dev libffi-dev),
    'package_overrides' => "-o Dpkg::Options::='--force-confold' -o Dpkg::Options::='--force-confdef'"
  }
end
