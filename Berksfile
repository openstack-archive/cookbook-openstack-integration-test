source 'https://supermarket.chef.io'

%w(block-storage common compute identity image network).each do |cookbook|
  if Dir.exist?("../cookbook-openstack-#{cookbook}")
    cookbook "openstack-#{cookbook}", path: "../cookbook-openstack-#{cookbook}"
  else
    cookbook "openstack-#{cookbook}",
      git: "https://opendev.org/openstack/cookbook-openstack-#{cookbook}",
      branch: 'stable/rocky'
  end
end

if Dir.exist?('../cookbook-openstackclient')
  cookbook 'openstackclient',
    path: '../cookbook-openstackclient'
else
  cookbook 'openstackclient',
    git: 'https://opendev.org/openstack/cookbook-openstackclient',
    branch: 'stable/rocky'
end

metadata
