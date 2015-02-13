source 'https://supermarket.chef.io'

cookbook 'ubuntu'
cookbook 'apt'
cookbook 'apt-repo', git: 'https://github.com/sometimesfood/chef-apt-repo.git'
cookbook 'git'
cookbook 'monit', git: 'https://github.com/phlipper/chef-monit.git'
cookbook 'firewall'
cookbook 'ntp'
cookbook 'sudo'
cookbook 'vmware-tools', git: 'https://github.com/tamucookbooks/vmware-tools.git'

cookbook 'varnish'
cookbook 'apache2', git: 'https://github.com/joelhandwell/apache2.git'
cookbook 'php', git: 'https://github.com/priestjim/chef-php.git'
cookbook 'php-fpm', git: 'https://github.com/yevgenko/cookbook-php-fpm.git'
#cookbook 'xdebug'
cookbook 'xdebug', path: '../oss/xdebug'
cookbook 'memcached'
cookbook 'percona'

group :wrapper do
  cookbook 'w_common', path: 'cookbooks/w_common'
  cookbook 'w_varnish', path: 'cookbooks/w_varnish'
  cookbook 'w_apache', path: 'cookbooks/w_apache'
  cookbook 'w_memcached', path: 'cookbooks/w_memcached'
  cookbook 'w_percona', path: 'cookbooks/w_percona'
end