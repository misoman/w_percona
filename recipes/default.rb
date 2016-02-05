db_credentials = data_bag_item('w_percona', 'db_credential')

node.override['percona']['server']['root_password'] = db_credentials['root_password']
node.override['percona']['backup']['password'] = db_credentials['backup_password']

include_recipe('firewall')

[3306, 4444, 4567, 4568, 9200].each do |percona_port|
  firewall_rule "percona port #{percona_port.to_s}" do
    port percona_port
    protocol :tcp
  end
end

cluster_ips = node['percona']['cluster']['cluster_ips']
cluster_address = "gcomm://#{cluster_ips.join(',')}"
Chef::Log.info "Using Percona XtraDB cluster address of: #{cluster_address}"
node.override["percona"]["cluster"]["wsrep_cluster_address"] = cluster_address
node.override["percona"]["cluster"]["wsrep_node_name"] = node['hostname']

include_recipe 'percona::cluster'
include_recipe 'percona::backup'
include_recipe 'percona::toolkit'
include_recipe 'w_percona::database'
include_recipe 'w_percona::xinetd' if node['w_percona']['xinetd_enabled']
