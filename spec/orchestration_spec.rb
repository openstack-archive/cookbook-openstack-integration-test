require_relative 'spec_helper'

describe 'openstack-integration-test::orchestration' do
  describe 'ubuntu' do
    let(:runner) { ChefSpec::SoloRunner.new(UBUNTU_OPTS) }
    let(:node) { runner.node }
    cached(:chef_run) do
      runner.converge(described_recipe)
    end

    before do
      stub_command('bash -c "source /root/openrc && openstack flavor show m1.small"').and_return(false)
    end

    it do
      expect(chef_run).to \
        run_execute('bash -c "source /root/openrc && openstack keypair create heat_key > /tmp/heat_key.priv"')
        .with(creates: '/tmp/heat_key.priv')
    end
    it do
      expect(chef_run).to \
        run_execute('bash -c "source /root/openrc && openstack flavor create --ram 1024 --disk 15 --vcpus 1 m1.small"')
    end
    context 'flavor already exists' do
      cached(:chef_run) do
        runner.converge(described_recipe)
      end
      before do
        stub_command('bash -c "source /root/openrc && openstack flavor show m1.small"').and_return(true)
      end
      it do
        expect(chef_run).to_not \
          run_execute('bash -c "source /root/openrc && openstack flavor create --ram 1024 --disk 15 --vcpus 1 m1.small"')
      end
    end
    it do
      expect(chef_run).to create_cookbook_file('/tmp/heat.yml')
    end
  end
end
