class ::Chef::Recipe
  include ::Openstack
  include BindCookbook::Helpers
end

class ::Chef::Resource
  include BindCookbook::Helpers
end

# Match what opendev/base-jobs uses for unbound:
# https://opendev.org/opendev/base-jobs/src/branch/master/roles/configure-unbound/defaults/main.yaml#L1-L7
node.default['resolver']['search'] = []
node.default['resolver']['nameservers'] = %w(1.0.0.1 8.8.8.8)

include_recipe 'resolver'

# Disable and stop unbound so we can properly test Designate
service 'unbound' do
  action [:disable, :stop]
end

bind_service 'default' do
  action [:create, :start]
end

rndc_secret = get_password 'token', 'designate_rndc'

template "#{default_property_for(:sysconfdir, false)}/rndc.key" do
  source 'rndc.key.erb'
  cookbook 'openstack-dns'
  owner default_property_for(:run_user, false)
  group default_property_for(:run_group, false)
  mode 00440
  sensitive true
  variables(
    secret: rndc_secret
  )
  notifies :restart, 'bind_service[default]'
end

template "#{default_property_for(:sysconfdir, false)}/named.designate" do
  owner default_property_for(:run_user, false)
  group default_property_for(:run_group, false)
  variables(
    bind_sysconfig: default_property_for(:sysconfdir, false)
  )
  notifies :restart, 'bind_service[default]'
end

bind_config 'default' do
  options [
    'allow-new-zones yes',
  ]
  additional_config_files %w(named.designate)
end
