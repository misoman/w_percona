# Setup the Percona XtraDB Cluster
cluster_ips = []
unless Chef::Config[:zero]
  search(:node, 'role:percona').each do |other_node|
    next if other_node['private_ipaddress'] == node['private_ipaddress']
    Chef::Log.info "Found Percona XtraDB cluster peer: #{other_node['private_ipaddress']}"
    cluster_ips << other_node['private_ipaddress']
  end
end

cluster_ips.each do |ip|
  firewall_rule "allow Percona group communication to peer #{ip}" do
    source ip
    port 4567
    action :allow
  end

  firewall_rule "allow Percona state transfer to peer #{ip}" do
    source ip
    port 4444
    action :allow
  end

  firewall_rule "allow Percona incremental state transfer to peer #{ip}" do
    source ip
    port 4568
    action :allow
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

[3306, 4444, 4567, 4568, 9200].each do |percona_port|
  firewall_rule 'percona' do
    port     percona_port
    protocol :tcp
    action   :allow
  end
end