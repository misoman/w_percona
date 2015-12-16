#root_password   = node['percona']['server']['root_password']
db_credentials = data_bag_item('w_percona', 'db_credential')
root_password   = db_credentials['root_password']
backup_password   = db_credentials['backup_password']
db_host         = node['hostname'].downcase

## security config
# clean up empty user
[db_host, 'localhost'].each do |empty_user_host|
  execute "delete default anonymous user @#{empty_user_host}" do
    command "mysql -uroot -p'#{root_password}' -e \"DELETE FROM mysql.user WHERE user='' AND host='#{empty_user_host}';\""
    action :run
  end
end

# apply root password on all hosts
[db_host, '192.168.33.1', '127.0.0.1', '::1'].each do |root_host|
  execute "apply root password on @#{root_host}" do
    command "mysql -uroot -p'#{root_password}' -e \"UPDATE mysql.user SET password=password('#{root_password}') WHERE user='root' AND host='#{root_host}';\""
    action :run
  end
end

sst = node['percona']['cluster']['wsrep_sst_auth'].split(':')
sst_user = sst[0]
sst_password = sst[1]

%w( localhost % ).each do |sst_user_host|
  execute "create user for sst for #{sst_user_host}" do
    command "mysql -uroot -p'#{root_password}' -e \"GRANT RELOAD, LOCK TABLES, REPLICATION CLIENT ON *.* TO '#{sst_user}'@'#{sst_user_host}' IDENTIFIED BY '#{sst_password}';\""
    action :run
  end
end

if node['w_percona']['xinetd_enabled']
  execute "creates clustercheck with process privilege" do
    command "mysql -uroot -p'#{root_password}' -e \"INSERT into mysql.user (host,user,password,Process_priv) VALUES ('localhost','clustercheck',password('#{backup_password}'),'Y');\""
    action :run
    not_if "mysql -uroot -p'#{root_password}' -e \"SELECT user FROM mysql.user where host='localhost' and user='clustercheck';\" | grep -c \"clustercheck\""
  end
end

node['w_common']['web_apps'].each do |web_app|

  vhost = web_app['vhost']['main_domain']
  webapp_host     = web_app['connection_domain']['webapp_domain']

  Chef::Log.info("web_app['mysql'].class: #{web_app['mysql'].class}")

  if web_app['mysql'].instance_of?(Chef::Node::ImmutableArray) then
    Chef::Log.info("web_app['mysql'] is detected as Array #{web_app['mysql']}")
    databases = web_app['mysql']
  else
    Chef::Log.info("web_app['mysql'] is detected as non Array #{web_app['mysql']}")
    databases = []
    databases << web_app['mysql']
  end

  Chef::Log.info("databases.inspect: #{databases.inspect}")

  databases.each do |database|

    ## attributes
    webapp_db       = database['db']
    webapp_username = database['user']
    webapp_password = database['password']

    ## webapp related config
    execute "Create a mysql database #{webapp_db} for webapp #{vhost}" do
      command "mysql -uroot -p'#{root_password}' -e \"CREATE DATABASE IF NOT EXISTS #{webapp_db};\""
      action :run
    end

    webapp_hosts = []

    node['dbhosts']['webapp_ip'].each do |webapp_ip|
      webapp_hosts << webapp_ip
    end
    
    node['dbhosts']['webapp_ip'].each_index do |index|
      webapp_hosts << index.to_s + web_app['connection_domain']['webapp_domain']
    end

    webapp_hosts << 'localhost'

    webapp_hosts.each do |webapp_user_host|
      execute "Create a mysql user for webapp if not exist, and grant access of #{webapp_db} to user #{webapp_username} at host #{webapp_user_host} for vhost #{vhost}" do
        command "mysql -uroot -p'#{root_password}' -e \"GRANT ALL ON #{webapp_db}.* TO '#{webapp_username}'@'#{webapp_user_host}' IDENTIFIED BY '#{webapp_password}';\""
        action :run
      end
    end
  end
end

execute 'flush privileges' do
  command "mysqladmin -uroot -p'#{root_password}' reload"
  action :run
end