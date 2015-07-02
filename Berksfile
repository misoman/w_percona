# -*- mode: ruby -*-
# vi: set ft=ruby :
source 'https://supermarket.chef.io'

cookbook 'ubuntu'
cookbook 'apt'
cookbook 'apt-repo', git: 'https://github.com/sometimesfood/chef-apt-repo.git'
cookbook 'git'
cookbook 'monit', git: 'https://github.com/phlipper/chef-monit.git'
cookbook 'firewall', "~> 1.4.0"
cookbook 'ntp'
cookbook 'sudo'
cookbook 'timezone-ii'
cookbook 'vmware-tools', git: 'https://github.com/tamucookbooks/vmware-tools.git'
cookbook 'windows', git: 'https://github.com/opscode-cookbooks/windows.git', ref: '0e5d9338b75ac3c56112788b0f111c4d2bed3d9a'

cookbook 'haproxy', git: 'https://github.com/fulloflilies/haproxy.git', ref: '27a1e4646c2a83bb94be3b7b32cd4865f28b010f'
cookbook 'keepalived'
cookbook 'varnish'
cookbook 's3_file'
cookbook 'apache2', git: 'https://github.com/svanzoest-cookbooks/apache2.git', ref: '4ac713294d21c7f9f800bf9b64859ecba29f1552'
cookbook 'php', git: 'https://github.com/maxwellshim/chef-php.git'
cookbook 'php-fpm', git: 'https://github.com/yevgenko/cookbook-php-fpm.git'
cookbook 'xdebug', git: 'https://github.com/joelhandwell/xdebug.git'
cookbook 'phpmyadmin', git: 'https://github.com/priestjim/chef-phpmyadmin.git', ref: '9985cc1b7915ce07a2e8d3d240635d6c86d1e6d1'
cookbook 'memcached'
cookbook 'mysql'
cookbook 'percona', '~> 0.16.1'
cookbook 'xinetd', git: 'https://github.com/joelhandwell/cookbook-xinetd.git'
cookbook 'nfs'
cookbook 'cron'

group :wrapper do
  cookbook 'w_common', path: 'cookbooks/w_common'
  cookbook 'w_haproxy', path: 'cookbooks/w_haproxy'
  cookbook 'w_varnish', path: 'cookbooks/w_varnish'
  cookbook 'w_apache', path: 'cookbooks/w_apache'
  cookbook 'w_memcached', path: 'cookbooks/w_memcached'
  cookbook 'w_percona', path: 'cookbooks/w_percona'
  cookbook 'w_mysql', path: 'cookbooks/w_mysql'
  cookbook 'w_nfs', path: 'cookbooks/w_nfs'
end
