include_recipe 'apache2'
include_recipe 'w_apache::php'

firewall_rule 'http' do
  port     80
  protocol :tcp
  action   :allow
end

include_recipe 'w_apache::monit' if node['monit_enabled']