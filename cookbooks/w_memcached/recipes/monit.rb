#
# Cookbook Name:: w_memcached
# Recipe:: monit
#
# Copyright 2014, Joel Handwell
#
# license apachev2
#
#

include_recipe  'monit'

monit_monitrc 'memcached'