# encoding: UTF-8
require_relative 'spec_helper'

describe 'openstack-integration-test::setup' do
  describe 'redhat' do
    let(:runner) { ChefSpec::SoloRunner.new(REDHAT_OPTS) }
    let(:node) { runner.node }
    let(:chef_run) do
      runner.converge(described_recipe)
    end

    include_context 'tempest-stubs'

    it 'installs tempest dependencies' do
      packages = %w(git python-virtualenv libxslt-devel libxml2-devel
                    python-testrepository libffi-devel)

      packages.each do |pkg|
        expect(chef_run).to upgrade_package(pkg)
      end
    end
  end
end
