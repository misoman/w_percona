include_recipe 'xdebug'

if node['w_apache']['xdebug_enabled'] then
  firewall_rule 'xdebug' do
    port     9000
    protocol :tcp
    action   :allow
  end
end