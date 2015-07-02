#
# Cookbook Name:: w_varnish
# Recipe:: monit
#

include_recipe  'monit'

monit_monitrc 'haproxy'

monit_monitrc 'keepalived'