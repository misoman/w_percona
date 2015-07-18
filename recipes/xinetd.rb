include_recipe 'xinetd'

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
