include_recipe 'sudo'
include_recipe 'ntp'
include_recipe 'timezone'

include_recipe 'vmware-tools::default' if node['w_common']['vmware-tools_enabled']
include_recipe 'w_common::hosts'

firewall 'ufw' do
  action :enable
end

firewall_rule 'ssh' do
  port     22
  protocol :tcp
  action   :allow
end