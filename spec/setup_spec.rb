require_relative 'spec_helper'

describe 'openstack-integration-test::setup' do
  describe 'ubuntu' do
    let(:runner) { ChefSpec::SoloRunner.new(UBUNTU_OPTS) }
    let(:node) { runner.node }
    cached(:chef_run) do
      runner.converge(described_recipe)
    end

    include_context 'tempest-stubs'

    connection_params = {
      openstack_auth_url: 'http://127.0.0.1:5000/v3',
      openstack_username: 'admin',
      openstack_api_key: 'admin',
      openstack_project_name: 'admin',
      openstack_domain_name: 'default',
      openstack_endpoint_type: 'internalURL',
    }

    it 'installs tempest dependencies' do
      expect(chef_run).to upgrade_package %w(git curl libssl-dev libffi-dev python-dev libxml2-dev libxslt1-dev libpq-dev libxml2-dev libxslt-dev testrepository python-dev libffi-dev python-gabbi python-testscenarios python-ddt)
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
        domain_name: 'Default',
        role_name: 'Member',
        project_name: 'tempest_project1',
        password: 'tempest_user1_pass',
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
        domain_name: 'Default',
        role_name: 'Member',
        project_name: 'tempest_project2',
        password: 'tempest_user2_pass',
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

    it do
      expect(chef_run).to run_execute('create virtualenv for tempest').with(creates: '/opt/tempest-venv')
    end

    it do
      expect(chef_run).to nothing_execute('install tempest')
        .with(
          command: '/opt/tempest-venv/bin/pip install -c https://opendev.org/openstack/requirements/raw/branch/stable/train/upper-constraints.txt tempest==22.1.0',
          cwd: '/opt/tempest'
        )
    end

    it 'syncs /opt/tempest from github' do
      expect(chef_run).to sync_git(
        '/opt/tempest'
      ).with(
        repository: 'https://opendev.org/openstack/tempest',
        reference: '22.1.0',
        depth: 1
      )
    end

    it do
      expect(chef_run.git('/opt/tempest')).to notify('execute[install tempest]').to(:run).immediately
    end

    it 'uploads image1' do
      expect(chef_run).to upload_openstack_image_image('image1').with(
        identity_user: 'admin',
        identity_pass: 'admin',
        identity_tenant: 'admin',
        identity_uri: 'http://127.0.0.1:5000/v3',
        identity_user_domain_name: 'default',
        identity_project_domain_name: 'default',
        image_name: 'cirros-test1',
        image_id: '1ac790f6-903a-4833-979f-a38f1819e3b1',
        image_url: 'http://download.cirros-cloud.net/0.4.0/cirros-0.4.0-x86_64-disk.img'
      )
    end

    it 'uploads image2' do
      expect(chef_run).to upload_openstack_image_image('image2').with(
        identity_user: 'admin',
        identity_pass: 'admin',
        identity_tenant: 'admin',
        identity_uri: 'http://127.0.0.1:5000/v3',
        identity_user_domain_name: 'default',
        identity_project_domain_name: 'default',
        image_name: 'cirros-test2',
        image_id: 'f7c2ac6d-0011-499f-a9ec-ca71348bf2e4',
        image_url: 'http://download.cirros-cloud.net/0.4.0/cirros-0.4.0-x86_64-disk.img'
      )
    end

    it do
      expect(chef_run).to create_template('/opt/tempest/etc/tempest-blacklist')
    end

    [
      /^tempest.api.compute.servers.test_create_server.ServersTestBootFromVolume$/,
    ].each do |line|
      it do
        expect(chef_run).to render_file('/opt/tempest/etc/tempest-blacklist').with_content(line)
      end
    end

    describe 'tempest.conf default' do
      let(:file) { chef_run.template('/opt/tempest/etc/tempest.conf') }

      it 'creates tempest.conf' do
        expect(chef_run).to create_template(file.name).with(
          user: 'root',
          group: 'root',
          mode: '600'
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

      it 'has a v3 auth URI with the default scheme' do
        expect(chef_run).to render_file(file.name).with_content(
          'uri_v3 = http://127.0.0.1:5000/v3'
        )
      end

      it 'has a v3 endpoint type matching the default value' do
        expect(chef_run).to render_file(file.name).with_content(
          'v3_endpoint_type = internalURL'
        )
      end

      it 'discovers compute hosts' do
        expect(chef_run).to run_execute('discover_hosts')
          .with(user: 'nova',
                group: 'nova')
      end
    end
    it 'Create role for heat user' do
      expect(chef_run).to create_openstack_role('heat_stack_owner')
    end
    it do
      expect(chef_run).to run_ruby_block('Create nano flavor 99')
    end
    context 'Disable services to test' do
      cached(:chef_run) do
        runner.node.override['openstack']['integration-test']['conf']['service_available']['heat'] = false
        runner.node.override['openstack']['integration-test']['conf']['service_available']['glance'] = false
        runner.node.override['openstack']['integration-test']['conf']['service_available']['nova'] = false
        runner.converge(described_recipe)
      end
      it do
        expect(chef_run).to_not create_openstack_role('heat_stack_owner')
      end
      it do
        expect(chef_run).to_not upload_openstack_image_image('image1')
      end
      it do
        expect(chef_run).to_not upload_openstack_image_image('image2')
      end
      it do
        expect(chef_run).to_not run_ruby_block('Create nano flavor 99')
      end
      it do
        expect(chef_run).to_not run_execute('discover_hosts')
      end
    end

    context 'tempest.conf with HTTPS' do
      cached(:chef_run) do
        runner.node.override['openstack']['endpoints']['internal']['identity']['scheme'] = 'https'
        runner.converge(described_recipe)
      end
      let(:file) { chef_run.template('/opt/tempest/etc/tempest.conf') }

      it 'has a v3 auth URI with the secure scheme' do
        expect(chef_run).to render_file(file.name).with_content(
          'uri_v3 = https://127.0.0.1:5000/v3'
        )
      end
    end
  end
end
