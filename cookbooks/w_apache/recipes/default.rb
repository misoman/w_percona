apt_repository "php55" do
  uri 'ppa:ondrej/php5'
  distribution node["lsb"]["codename"]
end

apt_repository "apache2" do
  uri 'ppa:ondrej/apache2'
  distribution node["lsb"]["codename"]
end

include_recipe 'apache2'
package 'apache2-mpm-worker'
include_recipe 'w_apache::php'
include_recipe 'w_apache::vhosts'

firewall_rule 'http' do
  port     80
  protocol :tcp
  action   :allow
end

include_recipe 'w_apache::config_test' if node['w_apache']['config_test_enabled']
include_recipe 'w_apache::monit' if node['monit_enabled']
include_recipe 'w_apache::varnish_healthcheck' if node['w_apache']['varnish_healthcheck']