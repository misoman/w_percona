#
# Cookbook Name:: w_apache
# Recipe:: monit
#
# Copyright 2014, Joel Handwell
#
# license apachev2
#
#

include_recipe  'monit'

monit_monitrc 'apache2'
#monit_monitrc 'haproxy'