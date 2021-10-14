#
# Cookbook:: openstack-integration-test
# Recipe:: orchestration
#
# Copyright:: 2020-2021, Oregon State University
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at                                                                              #
#     http://www.apache.org/licenses/LICENSE-2.0                                                                       #
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

execute 'bash -c "source /root/openrc && openstack keypair create heat_key > /tmp/heat_key.priv"' do
  creates '/tmp/heat_key.priv'
end

execute 'bash -c "source /root/openrc && openstack flavor create --ram 1024 --disk 15 --vcpus 1 m1.small"' do
  not_if 'bash -c "source /root/openrc && openstack flavor show m1.small"'
end

cookbook_file '/tmp/heat.yml'
