include_recipe 'php-fpm'
include_recipe 'php'

php_fpm_pool 'www' do
  enable false
end

php_fpm 'php-fpm' do
  action :add
  user 'www-data'
  group 'www-data'
  socket true
  socket_path '/var/run/php-fpm-www.sock'
  socket_perms '0666'
  start_servers 5
  min_spare_servers 5
  max_spare_servers 10
  max_children 50
  terminate_timeout (node['php']['ini_settings']['max_execution_time'].to_i + 20)
  valid_extensions %w( .php .htm .php3 .html .inc .tpl .cfg )
  value_overrides({
    :error_log => "#{node['php']['fpm_log_dir']}/php-fpm.log"
  })
end

template '/etc/php5/fpm/php.ini' do
  source 'php.ini.erb'
  mode 00644
  owner 'root'
  group 'root'
  cookbook 'php'
  notifies :restart, 'service[php-fpm]'
end
