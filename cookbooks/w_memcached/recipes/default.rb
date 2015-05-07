#
# Cookbook Name:: w_memcached
# Recipe:: default
#
# Copyright 2014, Joel Handwell
#
# license apachev2

include_recipe 'memcached'

firewall 'ufw' do
  action :enable
end

firewall_rule 'memcached' do
  port     11211
  protocol :tcp
  action   :allow
end

include_recipe 'w_memcached::monit' if node['monit_enabled']