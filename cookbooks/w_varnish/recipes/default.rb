#
# Cookbook Name:: w_varnish
# Recipe:: default
#
# Copyright 2014, Joel Handwell
#
# license apachev2
#

include_recipe 'varnish::repo'

package 'varnish'

cookbook_file '/etc/varnish/devicedetect.vcl' do
  source 'devicedetect.vcl'
  mode '0755'
  owner 'root'
  group 'root'
end

if node['w_varnish']['geoip']['enabled'] == true
  include_recipe 'git'
  if node['varnish']['version'].start_with?('4')
    include_recipe 'w_varnish::geoip_varnish4'
  else
    raise 'Geoip is supported with Varnish version 4 in this wrapper cookbook, you specified the version not 4'
  end
end

include_recipe 'w_varnish::multi_cookie' if node['w_varnish']['multi_cookie_enabled']

template "#{node['varnish']['dir']}/#{node['varnish']['vcl_conf']}" do
  source node['varnish']['vcl_source']
  cookbook node['varnish']['vcl_cookbook']
  owner 'root'
  group 'root'
  mode 0644
  notifies :reload, 'service[varnish]', :immediately
  only_if { node['varnish']['vcl_generated'] == true }
end

template node['varnish']['default'] do
  source node['varnish']['conf_source']
  cookbook node['varnish']['conf_cookbook']
  owner 'root'
  group 'root'
  mode 0644
  notifies 'restart', 'service[varnish]'
end

service 'varnish' do
  supports restart: true, reload: true
  action %w(enable start)
end

service 'varnishlog' do
  supports restart: true, reload: true
  action %w(enable start)
end

firewall 'ufw' do
  action :enable
end

[node['varnish']['backend_port'], node['varnish']['listen_port'], node['varnish']['admin_listen_port']].each do |varnish_port|
  firewall_rule "listen port #{varnish_port}" do
    port     varnish_port.to_i
    protocol :tcp
    action   :allow
  end
end

include_recipe 'w_varnish::monit' if node['monit_enabled']