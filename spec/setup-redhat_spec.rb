require_relative 'spec_helper'

describe 'openstack-integration-test::setup' do
  describe 'redhat' do
    let(:runner) { ChefSpec::SoloRunner.new(REDHAT_OPTS) }
    let(:node) { runner.node }
    cached(:chef_run) do
      runner.converge(described_recipe)
    end

    include_context 'tempest-stubs'

    it 'installs tempest dependencies' do
      expect(chef_run).to upgrade_package %w(git curl libxslt-devel libxml2-devel python-testrepository libffi-devel python-devel python-gabbi python-testscenarios python-ddt)
    end
  end
end
