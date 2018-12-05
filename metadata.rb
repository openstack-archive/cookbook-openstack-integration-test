name             'openstack-integration-test'
maintainer       'openstack-chef'
maintainer_email 'openstack-discuss@lists.openstack.org'
license          'Apache-2.0'
description      'Installs and configures the Tempest Integration Test Suite'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '18.0.0'

recipe 'openstack-integration-test::setup', 'Installs and configures Tempest'

%w(ubuntu redhat centos).each do |os|
  supports os
end

depends 'openstack-common', '>= 18.0.0'
depends 'openstack-identity', '>= 18.0.0'
depends 'openstack-image', '>= 18.0.0'
depends 'openstack-compute', '>= 18.0.0'
depends 'openstack-block-storage', '>= 18.0.0'
depends 'openstackclient'

depends 'poise-python'

issues_url 'https://launchpad.net/openstack-chef' if respond_to?(:issues_url)
source_url 'https://github.com/openstack/cookbook-openstack-integration-test' if respond_to?(:source_url)
chef_version '>= 12.5' if respond_to?(:chef_version)
