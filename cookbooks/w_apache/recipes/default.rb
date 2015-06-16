apt_repository 'multiverse' do
  uri 'http://archive.ubuntu.com/ubuntu'
  distribution node["lsb"]["codename"]
  components ['multiverse']
  deb_src true
end

apt_repository 'updates-multiverse' do
  uri 'http://archive.ubuntu.com/ubuntu'
  distribution "#{node["lsb"]["codename"]}-updates"
  components ['multiverse']
  deb_src true
end

apt_repository 'security-multiverse-src' do
  uri 'http://security.ubuntu.com/ubuntu'
  distribution "#{node["lsb"]["codename"]}-security"
  components ['multiverse']
  deb_src true
end

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

firewall 'ufw' do
  action :enable
end

node['apache']['listen_ports'].each do |listen_port|
	firewall_rule 'http' do
	  port     listen_port.to_i
	  protocol :tcp
	  action   :allow
	end
end

include_recipe 'w_apache::config_test' if node['w_apache']['config_test_enabled']
include_recipe 'w_apache::monit' if node['monit_enabled']
include_recipe 'w_apache::varnish_integration' if node['w_apache']['varnish_enabled']
include_recipe 'w_apache::deploy' if node['w_apache']['deploy']['enabled']
include_recipe 'w_apache::phpmyadmin' if node['w_apache']['phpmyadmin']['enabled']
include_recipe 'w_nfs::client' if node['w_apache']['nfs']['enabled']