package 'php-pear'
package 'php5-dev'
include_recipe 'php::fpm'

begin
  r = resources(template: "#{node['apache']['dir']}/mods-available/fastcgi.conf")
  r.cookbook 'w_apache'
  r.source 'fastcgi.conf.erb'
  r.owner 'root'
  r.group 'root'
rescue Chef::Exceptions::ResourceNotFound
  Chef::Log.warn 'could not find template to override!'
end

php_fpm 'php-fpm' do
  action :add
  user 'www-data'
  group 'www-data'
  socket true
  socket_path '/var/run/php-fpm-www.sock'
  terminate_timeout (node['php']['ini_settings']['max_execution_time'].to_i + 20)
  valid_extensions %w( .php .htm .php3 .html .inc .tpl .cfg )
  value_overrides({
    :error_log => "#{node['php']['fpm_log_dir']}/php-fpm.log"
  })
end

package 'php5-mysql'
package 'php5-memcached'
package 'php5-gd'
package 'php5-pspell'
package 'php5-curl'

if node['w_apache']['xdebug_enabled'] then

  include_recipe 'xdebug'

	firewall 'ufw' do
	  action :enable
	end

  firewall_rule 'xdebug' do
    port     9000
    protocol :tcp
    action   :allow
  end
end