#
# Cookbook Name:: w_varnish
# Recipe:: monit
#
# Copyright 2014, Joel Handwell
#
# license apachev2
#
#

include_recipe  'monit'

monit_monitrc 'varnish'