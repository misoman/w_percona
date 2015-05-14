# -*- mode: ruby -*-
# vi: set ft=ruby :
source 'https://supermarket.chef.io'

cookbook 'ubuntu'
cookbook 'apt'
cookbook 'apt-repo', git: 'https://github.com/sometimesfood/chef-apt-repo.git'
cookbook 'git'
cookbook 'monit', git: 'https://github.com/phlipper/chef-monit.git'
cookbook 'firewall', "~> 1.1.1"
cookbook 'ntp'
cookbook 'sudo'
cookbook 'timezone-ii'
cookbook 'vmware-tools', git: 'https://github.com/tamucookbooks/vmware-tools.git'

cookbook 'varnish'
cookbook 's3_file'
cookbook 'apache2', git: 'https://github.com/svanzoest-cookbooks/apache2.git', ref: '4ac713294d21c7f9f800bf9b64859ecba29f1552'
cookbook 'php', git: 'https://github.com/maxwellshim/chef-php.git'
cookbook 'php-fpm', git: 'https://github.com/yevgenko/cookbook-php-fpm.git'
cookbook 'xdebug', git: 'https://github.com/joelhandwell/xdebug.git'
cookbook 'phpmyadmin', git: 'https://github.com/priestjim/chef-phpmyadmin.git', ref: '9985cc1b7915ce07a2e8d3d240635d6c86d1e6d1'
cookbook 'memcached'
cookbook 'mysql'
cookbook 'percona', git: 'https://github.com/joelhandwell/chef-percona.git', branch: "dedup_logdir"
cookbook 'xinetd', git: 'https://github.com/joelhandwell/cookbook-xinetd.git'

group :wrapper do
  cookbook 'w_common', path: 'cookbooks/w_common'
  cookbook 'w_varnish', path: 'cookbooks/w_varnish'
  cookbook 'w_apache', path: 'cookbooks/w_apache'
  cookbook 'w_memcached', path: 'cookbooks/w_memcached'
  cookbook 'w_percona', path: 'cookbooks/w_percona'
  cookbook 'w_mysql', path: 'cookbooks/w_mysql'
end
