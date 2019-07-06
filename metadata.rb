name             'openstack-integration-test'
maintainer       'openstack-chef'
maintainer_email 'openstack-dev@lists.openstack.org'
license          'Apache-2.0'
description      'Installs and configures the Tempest Integration Test Suite'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '17.0.0'

recipe 'openstack-integration-test::setup', 'Installs and configures Tempest'

%w(ubuntu redhat centos).each do |os|
  supports os
end

depends 'openstack-common', '>= 17.0.0'
depends 'openstack-identity', '>= 17.0.0'
depends 'openstack-image', '>= 17.0.0'
depends 'openstack-compute', '>= 17.0.0'
depends 'openstack-block-storage', '>= 17.0.0'
depends 'openstackclient'

issues_url 'https://launchpad.net/openstack-chef' if respond_to?(:issues_url)
source_url 'https://github.com/openstack/cookbook-openstack-integration-test' if respond_to?(:source_url)
chef_version '>= 12.5' if respond_to?(:chef_version)
