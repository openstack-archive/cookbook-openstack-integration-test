require_relative 'spec_helper'

describe 'openstack-integration-test::dns' do
  describe 'redhat' do
    let(:runner) { ChefSpec::SoloRunner.new(REDHAT_OPTS) }
    let(:node) { runner.node }
    cached(:chef_run) do
      runner.converge(described_recipe)
    end

    include_context 'tempest-stubs'

    [
      /^nameserver 1.0.0.1$/,
      /^nameserver 8.8.8.8$/,
    ].each do |line|
      it do
        expect(chef_run).to render_file('/etc/resolv.conf').with_content(line)
      end
    end

    it do
      expect(chef_run).to disable_service('unbound')
    end

    it do
      expect(chef_run).to stop_service('unbound')
    end

    it do
      expect(chef_run).to create_bind_service('default')
      expect(chef_run).to start_bind_service('default')
    end

    it do
      expect(chef_run).to create_template('/etc/named/rndc.key').with(
        source: 'rndc.key.erb',
        owner: 'named',
        group: 'named',
        mode: '440',
        sensitive: true,
        variables: {
          secret: 'rndc-key',
        }
      )
    end

    it do
      expect(chef_run.template('/etc/named/rndc.key')).to notify('bind_service[default]').to(:restart)
    end

    it do
      expect(chef_run).to create_template('/etc/named/named.designate').with(
        owner: 'named',
        group: 'named',
        variables: {
          bind_sysconfig: '/etc/named',
        }
      )
    end

    it do
      expect(chef_run.template('/etc/named/named.designate')).to notify('bind_service[default]').to(:restart)
    end

    it do
      expect(chef_run).to create_bind_config('default').with(
        options: [
          'allow-new-zones yes',
        ],
        additional_config_files: %w(named.designate)
      )
    end
  end
end
