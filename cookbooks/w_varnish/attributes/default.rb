
default['varnish']['health_check_uri'] = '/ping.php'
default['varnish']['health_check_timeout_seconds'] = '5'

default['varnish']['listen_port'] = '80'
default['varnish']['backend_hosts'] = ["localhost"
#, "second.host"
#, "10.4.12.11"
]
default['varnish']['backend_port'] = '80'
default['varnish']['admin_listen_port'] = '6082'
default['varnish']['X-Varnish-IP'] = node['ipaddress']

default['varnish']['conf_cookbook'] = 'w_varnish'
default['varnish']['conf_source'] = 'varnish.erb'

default['varnish']['vcl_cookbook'] = 'w_varnish'
default['varnish']['vcl_source'] = 'default.vcl.erb'

default['varnish']['memory_limit'] = '1G'

default['w_varnish']['vmod_build_dir'] = '/tmp'
default['w_varnish']['device_detect']['enabled'] = false
default['w_varnish']['geoip']['enabled'] = false
default['w_varnish']['geoip']['auto_update'] = false
default['w_varnish']['geoip']['db_file_url'] = "http://geolite.maxmind.com/download/geoip/database/GeoLite2-City.mmdb.gz"
default['w_varnish']['multi_cookie_enabled'] = false
