execute 'bash -c "source /root/openrc && openstack keypair create heat_key > /tmp/heat_key.priv"' do
  creates '/tmp/heat_key.priv'
end

execute 'bash -c "source /root/openrc && openstack flavor create --ram 1024 --disk 15 --vcpus 1 m1.small"' do
  not_if 'bash -c "source /root/openrc && openstack flavor show m1.small"'
end

cookbook_file '/tmp/heat.yml'
