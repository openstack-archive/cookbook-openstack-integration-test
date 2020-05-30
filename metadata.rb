name             'openstack-integration-test'
maintainer       'openstack-chef'
maintainer_email 'openstack-discuss@lists.openstack.org'
license          'Apache-2.0'
description      'Installs and configures the Tempest Integration Test Suite'
version          '20.0.0'

%w(ubuntu redhat centos).each do |os|
  supports os
end

depends 'bind', '~> 2.3.1'
depends 'openstackclient'
depends 'openstack-common', '>= 20.0.0'
depends 'openstack-dns', '>= 20.0.0'
depends 'openstack-image', '>= 20.0.0'
depends 'resolver'

issues_url 'https://launchpad.net/openstack-chef'
source_url 'https://opendev.org/openstack/cookbook-openstack-integration-test'
chef_version '>= 15.8'
