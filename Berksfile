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
cookbook 'newrelic', '~> 2.18.0'

cookbook 'percona', '~> 0.16.1'
cookbook 'xinetd', git: 'https://github.com/stevendanna/cookbook-xinetd.git', ref: "62ccdd0457710a66a4c213f2c5b0f8c859633b3e"

group :wrapper do
  cookbook 'w_common', '~> 0.4.0', git: 'https://github.com/haapp/w_common.git'
  cookbook 'w_percona', path: './'
end
