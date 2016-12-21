# encoding: UTF-8
require_relative 'spec_helper'

describe 'openstack-integration-test::setup' do
  describe 'ubuntu' do
    let(:runner) { ChefSpec::SoloRunner.new(UBUNTU_OPTS) }
    let(:node) { runner.node }
    let(:chef_run) do
      runner.converge(described_recipe)
    end

    include_context 'tempest-stubs'

    connection_params = {
      openstack_auth_url: 'http://127.0.0.1:35357/v3/auth/tokens',
      openstack_username: 'admin',
      openstack_api_key: 'admin',
      openstack_project_name: 'admin',
      openstack_domain_name: 'default'
    }

    it 'installs tempest dependencies' do
      packages = %w(git libxml2-dev libxslt-dev testrepository python-dev
                    libffi-dev)

      packages.each do |pkg|
        expect(chef_run).to upgrade_package(pkg)
      end
    end

    it 'registers tempest_project1 Project' do
      expect(chef_run).to create_openstack_project(
        'tempest_project1'
      ).with(
        connection_params: connection_params
      )
    end

    it 'registers service user' do
      expect(chef_run).to create_openstack_user(
        'tempest_user1'
      ).with(
        project_name: 'tempest_project1',
        role_name: 'Member',
        password: 'tempest_user1_pass',
        connection_params: connection_params
      )
    end

    it 'create service role' do
      expect(chef_run).to create_openstack_role(
        'Member'
      ).with(
        connection_params: connection_params
      )
    end

    it do
      expect(chef_run).to grant_domain_openstack_user(
        'tempest_user1'
      ).with(
        domain_name: 'Default',
        role_name: 'Member',
        connection_params: connection_params
      )
    end

    it do
      expect(chef_run).to grant_role_openstack_user(
        'tempest_user1'
      ).with(
        project_name: 'tempest_project1',
        role_name: 'Member',
        password: 'tempest_user1_pass',
        connection_params: connection_params
      )
    end

    it 'registers tempest_project2 Project' do
      expect(chef_run).to create_openstack_project(
        'tempest_project2'
      ).with(
        connection_params: connection_params
      )
    end

    it 'registers service user' do
      expect(chef_run).to create_openstack_user(
        'tempest_user2'
      ).with(
        project_name: 'tempest_project2',
        role_name: 'Member',
        password: 'tempest_user2_pass',
        connection_params: connection_params
      )
    end

    it do
      expect(chef_run).to grant_domain_openstack_user(
        'tempest_user2'
      ).with(
        domain_name: 'Default',
        role_name: 'Member',
        connection_params: connection_params
      )
    end

    it do
      expect(chef_run).to grant_role_openstack_user(
        'tempest_user2'
      ).with(
        project_name: 'tempest_project2',
        role_name: 'Member',
        password: 'tempest_user2_pass',
        connection_params: connection_params
      )
    end

    it 'create service role' do
      expect(chef_run).to create_openstack_role(
        'heat_stack_owner'
      ).with(
        connection_params: connection_params
      )
    end

    it 'syncs /opt/tempest from github' do
      expect(chef_run).to sync_git(
        '/opt/tempest'
      ).with(
        repository: 'https://github.com/openstack/tempest',
        reference: 'master',
        depth: 1
      )
    end

    it 'uploads image1' do
      expect(chef_run).to upload_openstack_image_image('image1').with(
        identity_user: 'admin',
        identity_pass: 'admin',
        identity_tenant: 'admin',
        identity_uri: 'http://127.0.0.1:35357/v3',
        identity_user_domain_name: 'default',
        identity_project_domain_name: 'default',
        image_name: 'cirros-test1',
        image_id: '1ac790f6-903a-4833-979f-a38f1819e3b1',
        image_url: 'http://download.cirros-cloud.net/0.3.4/cirros-0.3.4-x86_64-disk.img'
      )
    end

    it 'uploads image2' do
      expect(chef_run).to upload_openstack_image_image('image2').with(
        identity_user: 'admin',
        identity_pass: 'admin',
        identity_tenant: 'admin',
        identity_uri: 'http://127.0.0.1:35357/v3',
        identity_user_domain_name: 'default',
        identity_project_domain_name: 'default',
        image_name: 'cirros-test2',
        image_id: 'f7c2ac6d-0011-499f-a9ec-ca71348bf2e4',
        image_url: 'http://download.cirros-cloud.net/0.3.4/cirros-0.3.4-x86_64-disk.img'
      )
    end

    describe 'tempest.conf default' do
      let(:file) { chef_run.template('/opt/tempest/etc/tempest.conf') }

      it 'creates tempest.conf' do
        expect(chef_run).to create_template(file.name).with(
          user: 'root',
          group: 'root',
          mode: 00600
        )
      end

      it 'has a populated entry for image_ref' do
        expect(chef_run).to render_file(file.name).with_content(
          'image_ref = 1ac790f6-903a-4833-979f-a38f1819e3b1'
        )
      end

      it 'has a populated entry for image_ref_alt' do
        expect(chef_run).to render_file(file.name).with_content(
          'image_ref_alt = f7c2ac6d-0011-499f-a9ec-ca71348bf2e4'
        )
      end

      it 'has a v2 auth URI with the default scheme' do
        expect(chef_run).to render_file(file.name).with_content(
          'uri = http://127.0.0.1:5000/v2.0'
        )
      end

      it 'has a v3 auth URI with the default scheme' do
        expect(chef_run).to render_file(file.name).with_content(
          'uri_v3 = http://127.0.0.1:5000/v3'
        )
      end
    end

    describe 'tempest.conf with HTTPS' do
      let(:runner) { ChefSpec::SoloRunner.new(UBUNTU_OPTS) }
      let(:chef_run) do
        runner.node.normal['openstack']['endpoints']['public']['identity']['scheme'] = 'https'
        runner.converge(described_recipe)
      end
      let(:file) { chef_run.template('/opt/tempest/etc/tempest.conf') }

      it 'has a v2 auth URI with the secure scheme' do
        expect(chef_run).to render_file(file.name).with_content(
          'uri = https://127.0.0.1:5000/v2.0'
        )
      end

      it 'has a v3 auth URI with the secure scheme' do
        expect(chef_run).to render_file(file.name).with_content(
          'uri_v3 = https://127.0.0.1:5000/v3'
        )
      end
    end
  end
end
