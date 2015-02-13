include_recipe 'ubuntu'

apt_repository 'multiverse' do
  uri 'http://archive.ubuntu.com/ubuntu'
  distribution 'precise'
  components ['multiverse']
end

apt_repository 'updates-multiverse' do
  uri 'http://archive.ubuntu.com/ubuntu'
  distribution 'precise-updates'
  components ['multiverse']
end

apt_repository 'security-multiverse-src' do
  uri 'http://security.ubuntu.com/ubuntu'
  distribution 'precise-security'
  components ['multiverse']
  deb_src true
end

include_recipe 'apache2'
include_recipe 'w_apache::vhosts'
include_recipe 'w_apache::apache2_module_fastcgi'
include_recipe 'w_apache::php-fpm'
include_recipe 'w_apache::php'

firewall_rule 'http' do
  port     80
  protocol :tcp
  action   :allow
end

include_recipe 'w_apache::xdebug' if node['w_apache']['xdebug_enabled']
include_recipe 'w_apache::config_test' if node['w_apache']['config_test_enabled']
include_recipe 'w_apache::monit' if node['monit_enabled']