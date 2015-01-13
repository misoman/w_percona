source 'https://supermarket.chef.io'

cookbook 'apt-repo', git: 'https://github.com/sometimesfood/chef-apt-repo.git'
cookbook 'git'
cookbook 'monit', git: 'https://github.com/phlipper/chef-monit.git'
cookbook 'firewall'
cookbook 'ntp'
cookbook 'varnish'
cookbook 'apache2'
cookbook 'php'
cookbook 'percona'
cookbook 'sudo'
cookbook 'vmware-tools', git: 'https://github.com/tamucookbooks/vmware-tools.git'

group :wrapper do
  cookbook 'w_common', path: 'cookbooks/w_common'
  cookbook 'w_apache', path: 'cookbooks/w_apache'
  cookbook 'w_varnish', path: 'cookbooks/w_varnish'
  cookbook 'w_percona', path: 'cookbooks/w_percona'
end