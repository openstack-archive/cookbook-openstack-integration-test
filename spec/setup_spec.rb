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
        image_name: 'cirros',
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
        image_name: 'cirros',
        image_url: 'http://download.cirros-cloud.net/0.3.4/cirros-0.3.4-x86_64-disk.img'
      )
    end

    it 'runs ruby_block for image1' do
      expect(chef_run).to run_ruby_block("Get and set image1's ID")
    end

    it 'runs ruby_block for image2' do
      expect(chef_run).to run_ruby_block("Get and set image2's ID")
    end

    it 'sets attribute when ruby_block is run for for image1' do
      # run actual ruby_block resource
      chef_run.find_resource(:ruby_block, "Get and set image1's ID").old_run_action(:create)
      image_id = chef_run.node['openstack']['integration-test']['image1']['id']
      expect(image_id).to eq('5d1ff378-e9c1-4db7-97c1-d35f07824595')
    end

    it 'sets attribute when ruby_block is run for for image2' do
      # run actual ruby_block resource
      chef_run.find_resource(:ruby_block, "Get and set image2's ID").old_run_action(:create)
      image_id = chef_run.node['openstack']['integration-test']['image2']['id']
      expect(image_id).to eq('5d1ff378-e9c1-4db7-97c1-d35f07824595')
    end

    it 'does not run ruby_block for image1 when id already set' do
      image_id = '5F7D0C44-F60E-404C-A28A-62140ADF1412'
      node.set['openstack']['integration-test']['image1']['id'] = image_id
      expect(chef_run).to_not run_ruby_block("Get and set image1's ID")
    end

    it 'does not run ruby_block for image2 when id already set' do
      image_id = '5F7D0C44-F60E-404C-A28A-62140ADF1413'
      node.set['openstack']['integration-test']['image2']['id'] = image_id
      expect(chef_run).to_not run_ruby_block("Get and set image2's ID")
    end

    it 'runs ruby_block for nano flavor' do
      expect(chef_run).to run_ruby_block('Create nano flavor 99')
    end

    describe 'tempest.conf' do
      let(:file) { chef_run.template('/opt/tempest/etc/tempest.conf') }

      it 'creates tempest.conf' do
        expect(chef_run).to create_template(file.name).with(
          user: 'root',
          group: 'root',
          mode: 00600
        )
      end

      it 'has a populated entry for image_ref' do
        # run actual ruby_block resource
        chef_run.find_resource(:ruby_block, "Get and set image1's ID").old_run_action(:create)
        expect(chef_run).to render_file(file.name).with_content(
          'image_ref = 5d1ff378-e9c1-4db7-97c1-d35f07824595'
        )
      end

      it 'has a populated entry for image_ref_alt' do
        # run actual ruby_block resource
        chef_run.find_resource(:ruby_block, "Get and set image2's ID").old_run_action(:create)
        expect(chef_run).to render_file(file.name).with_content(
          'image_ref_alt = 5d1ff378-e9c1-4db7-97c1-d35f07824595'
        )
      end
    end
  end
end
