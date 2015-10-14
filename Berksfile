# -*- mode: ruby -*-
# vi: set ft=ruby :
source 'https://supermarket.chef.io'

cookbook 'ubuntu'
cookbook 'apt'
cookbook 'apt-repo', git: 'https://github.com/sometimesfood/chef-apt-repo.git'
cookbook 'git'
cookbook 'monit', git: 'https://github.com/phlipper/chef-monit.git'
cookbook 'firewall', '~> 2.0.2'
cookbook 'ntp'
cookbook 'sudo'
cookbook 'timezone-ii'

cookbook 'percona', '~> 0.16.1'
cookbook 'xinetd', git: 'https://github.com/joelhandwell/cookbook-xinetd.git'

group :wrapper do
  cookbook 'w_common', git: 'https://github.com/haapp/w_common.git'
  cookbook 'w_percona', path: './'
end
