db_credentials = data_bag_item('w_percona', 'db_credential')

node.override['percona']['server']['root_password'] = db_credentials['root_password']
node.override['percona']['backup']['password'] = db_credentials['backup_password']

cluster_ips = []
unless Chef::Config[:zero]
  search(:node, 'role:percona').each do |other_node|
    next if other_node['private_ipaddress'] == node['private_ipaddress']
    Chef::Log.info "Found Percona XtraDB cluster peer: #{other_node['private_ipaddress']}"
    cluster_ips << other_node['private_ipaddress']
  end
end

cluster_address = "gcomm://#{cluster_ips.join(',')}"
Chef::Log.info "Using Percona XtraDB cluster address of: #{cluster_address}"
node.override["percona"]["cluster"]["wsrep_cluster_address"] = cluster_address
node.override["percona"]["cluster"]["wsrep_node_name"] = node['hostname']

include_recipe 'percona::cluster'
include_recipe 'percona::backup'
include_recipe 'percona::toolkit'
include_recipe 'w_percona::database'
include_recipe 'w_percona::xinetd' if node['percona']['xinetd_enabled']

firewall 'ufw' do
  action :enable
end

[3306, 4444, 4567, 4568, 9200].each do |percona_port|
  firewall_rule "percona port #{percona_port.to_s}" do
    port     percona_port
    protocol :tcp
    action   :allow
  end
end