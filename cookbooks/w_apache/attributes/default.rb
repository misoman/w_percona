default['apache']['version'] = '2.4'
default['apache']['pid_file'] = '/var/run/apache2/apache2.pid'
default['apache']['default_modules'] = %w(
  status alias auth_basic authn_core authn_file authz_core authz_groupfile
  authz_host authz_user autoindex dir env mime negotiation setenvif actions fastcgi expires
)
default['php']['ext_conf_dir'] = '/etc/php5/mods-available'
default['w_apache']['xdebug_enabled'] = false
default['xdebug']['config_file'] = '/etc/php5/mods-available/xdebug.ini'
default['xdebug']['execute_php5enmod'] = true
default['xdebug']['web_server']['service_name'] = 'php-fpm'
default['xdebug']['directives'] = {
  'remote_enable' => 'on',
  'idekey' => 'vagrant',
  'remote_handler' => 'dbgp',
  'remote_mode' => 'req',
  'remote_host' => '192.168.33.1',
  'remote_port' => '9000'
  }