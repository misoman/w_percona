include_recipe 'xinetd'

db_credentials = data_bag_item('w_percona', 'db_credential')
node.override['percona']['server']['backup_password'] = db_credentials['backup_password']
password = node['percona']['server']['backup_password']

# define access grants
template '/etc/xinetd.d/mysqlchk' do
  source 'mysqlchk.erb'
  variables(
    backup_password: password
  )
  notifies :reload, 'service[xinetd]', :immediately
end

execute 'create mysqlchk service' do
  command 'echo "mysqlchk 9200/tcp # mysqlchk" >> /etc/services'
  notifies :reload, 'service[xinetd]', :immediately
  not_if 'grep 9200/tcp /etc/services'
end
