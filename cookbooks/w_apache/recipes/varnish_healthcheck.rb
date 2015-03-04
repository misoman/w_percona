#
# Cookbook Name:: w_apache
# Recipe:: varnish_healthcheck
#
# Copyright 2014, Joel Handwell
#
# license apachev2
#
#

file '/var/www/html/ping.php' do
  content '<html><body>website is healthy</body></html>'
end