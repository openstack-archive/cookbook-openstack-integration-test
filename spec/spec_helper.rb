# encoding: UTF-8
require 'chefspec'
require 'chefspec/berkshelf'

ChefSpec::Coverage.start! { add_filter 'openstack-integration-test' }

require 'chef/application'

LOG_LEVEL = :fatal
REDHAT_OPTS = {
  platform: 'redhat',
  version: '7.1',
  log_level: LOG_LEVEL
}.freeze
UBUNTU_OPTS = {
  platform: 'ubuntu',
  version: '14.04',
  log_level: LOG_LEVEL
}.freeze

shared_context 'tempest-stubs' do
  before do
    env =
      {
        'OS_USERNAME'    => 'admin',
        'OS_PASSWORD'    => 'admin',
        'OS_PROJECT_NAME' => 'admin',
        'OS_AUTH_URL' => 'http://127.0.0.1:35357/v3'
      }

    allow_any_instance_of(Chef::Recipe).to receive(:get_password)
      .with('token', 'openstack_identity_bootstrap_token')
      .and_return('bootstrap-token')
    allow_any_instance_of(Chef::Recipe).to receive(:get_password)
      .with('user', 'admin')
      .and_return('admin')
    allow_any_instance_of(Chef::Resource::RubyBlock).to receive(:image_id)
      .with('cirros', env)
      .and_return('5d1ff378-e9c1-4db7-97c1-d35f07824595')
    allow_any_instance_of(Chef::Resource::RubyBlock).to receive(:openstack_command_env)
      .with('admin', 'admin')
      .and_return(env)
    allow(Chef::Application).to receive(:fatal!)
  end
end
