require 'chefspec'
require 'chefspec/berkshelf'
require 'chef/application'

RSpec.configure do |config|
  config.color = true
  config.formatter = :documentation
  config.log_level = :warn
end

REDHAT_7 = {
  platform: 'redhat',
  version: '7',
}.freeze

REDHAT_8 = {
  platform: 'redhat',
  version: '8',
}.freeze

ALL_RHEL = [
  REDHAT_7,
  REDHAT_8,
].freeze

UBUNTU_OPTS = {
  platform: 'ubuntu',
  version: '18.04',
}.freeze

shared_context 'tempest-stubs' do
  before do
    env =
      {
        'OS_USERNAME' => 'admin',
        'OS_PASSWORD' => 'admin',
        'OS_PROJECT_NAME' => 'admin',
        'OS_AUTH_URL' => 'http://127.0.0.1:5000/v3',
        'OS_USER_DOMAIN_NAME' => 'default',
        'OS_PROJECT_DOMAIN_NAME' => 'default',
        'OS_IDENTITY_API_VERSION' => 3,
      }

    allow_any_instance_of(Chef::Recipe).to receive(:get_password)
      .with('token', 'openstack_identity_bootstrap_token')
      .and_return('bootstrap-token')
    allow_any_instance_of(Chef::Recipe).to receive(:get_password)
      .with('user', 'admin')
      .and_return('admin')
    allow_any_instance_of(Chef::Recipe).to receive(:get_password)
      .with('openstack_user', 'tempest_user1')
      .and_return('tempest_user1_pass')
    allow_any_instance_of(Chef::Recipe).to receive(:get_password)
      .with('openstack_user', 'tempest_user2')
      .and_return('tempest_user2_pass')
    allow_any_instance_of(Chef::Resource::RubyBlock).to receive(:openstack_command_env)
      .with('admin', 'admin', 'Default', 'Default')
      .and_return(env)
    allow_any_instance_of(Chef::Recipe).to receive(:get_password)
      .with('token', 'designate_rndc')
      .and_return('rndc-key')
    allow(Chef::Application).to receive(:fatal!)
  end
end
