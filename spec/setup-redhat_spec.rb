require_relative 'spec_helper'

describe 'openstack-integration-test::setup' do
  ALL_RHEL.each do |p|
    context "redhat #{p[:version]}" do
      let(:runner) { ChefSpec::SoloRunner.new(p) }
      let(:node) { runner.node }
      cached(:chef_run) do
        runner.converge(described_recipe)
      end

      include_context 'tempest-stubs'

      case p
      when REDHAT_7
        it 'installs tempest dependencies' do
          expect(chef_run).to upgrade_package %w(curl git libffi-devel libxml2-devel libxslt-devel python-ddt python-devel python-gabbi python-testrepository python-testscenarios)
        end
      when REDHAT_8
        it 'installs tempest dependencies' do
          expect(chef_run).to upgrade_package %w(curl git libffi-devel libxml2-devel libxslt-devel python3-ddt python3-gabbi python3-testrepository python3-testscenarios python36-devel)
        end
      end
    end
  end
end
