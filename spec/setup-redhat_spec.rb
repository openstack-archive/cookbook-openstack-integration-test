# encoding: UTF-8
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
      ).each do |pkg|
        expect(chef_run).to upgrade_package(pkg)
      end
    end
  end
end
