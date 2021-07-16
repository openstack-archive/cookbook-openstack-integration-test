name             'openstack-integration-test'
maintainer       'openstack-chef'
maintainer_email 'openstack-discuss@lists.openstack.org'
license          'Apache-2.0'
description      'Installs and configures the Tempest Integration Test Suite'
version          '19.2.0'

%w(ubuntu redhat centos).each do |os|
  supports os
end

depends 'bind', '~> 3.1.0'
depends 'openstackclient'
depends 'openstack-common', '>= 19.0.0'
depends 'openstack-dns', '>= 19.0.0'
depends 'openstack-image', '>= 19.0.0'
depends 'resolver', '>= 3.0.0'

issues_url 'https://launchpad.net/openstack-chef'
source_url 'https://opendev.org/openstack/cookbook-openstack-integration-test'
chef_version '>= 15.0'
