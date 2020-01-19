source 'https://supermarket.chef.io'

solver :ruby, :required

%w(
  client
  -common
  -dns
  -identity
  -image
  -network
  -ops-database
  -ops-messaging
).each do |cookbook|
  if Dir.exist?("../cookbook-openstack#{cookbook}")
    cookbook "openstack#{cookbook}", path: "../cookbook-openstack#{cookbook}"
  else
    cookbook "openstack#{cookbook}", git: "https://opendev.org/openstack/cookbook-openstack#{cookbook}"
  end
end

# TODO(ramereth): Remove after this PR is merged
# https://github.com/joyofhex/cookbook-bind/pull/60
cookbook 'bind', github: 'ramereth/cookbook-bind', branch: 'fix-notifies-with-delayed-actions'

metadata
