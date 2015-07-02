#
# Cookbook Name:: w_haproxy
# Recipe:: keepalived
#

include_recipe 'keepalived'

node.default[:keepalived][:check_scripts][:chk_haproxy] = {
  :script => 'killall -0 haproxy',
  :interval => 2,
  :weight => 2
}

node.default[:keepalived][:instances][:vi_1] = {
  :track_script => 'chk_haproxy',
  :nopreempt => false,
  :advert_int => 1
}

# This is to add host ip and hostname in /etc/hosts and can be used as needed
#if node[:keepalived][:instances][:vi_1][:interface] == 'eth0' then
#  ip = node['ipaddress'] 
#else
#  ip = node[:network][:interfaces][:eth1][:addresses].detect{|k,v| v[:family] == "inet" }.first
#end
#  
#hostsfile_entry ip do
#  hostname node['hostname']
#  action :append
#  unique true
#end

firewall 'ufw' do
  action :enable
end

firewall_rule 'vrrp' do
  provider    Chef::Provider::FirewallRuleIptables
  protocol    112
  action      :allow
end
