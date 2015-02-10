root_password   = node['percona']['server']['root_password']
db_host         = node['hostname'].downcase

node['w_common']['web_apps'].each do |web_app|

  ## attributes
  webapp_db       = web_app['mysql']['db']
  webapp_username = web_app['mysql']['user']
  webapp_password = web_app['mysql']['password']
  webapp_host     = web_app['webapp_db_connection']['webapp_domain']

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

  ## webapp related config
  execute "Create a mysql database for webapp" do
    command "mysql -uroot -p'#{root_password}' -e \"CREATE DATABASE IF NOT EXISTS #{webapp_db};\""
    action :run
  end

  [webapp_host, 'localhost'].each do |webapp_user_host|
    execute "Create a mysql user for webapp if not exist, and grant access to the user" do
      command "mysql -uroot -p'#{root_password}' -e \"GRANT ALL ON #{webapp_db}.* TO '#{webapp_username}'@'#{webapp_user_host}' IDENTIFIED BY '#{webapp_password}';\""
      action :run
    end
  end

  execute 'flush privileges' do
    command "mysqladmin -uroot -p'#{root_password}' reload"
    action :run
  end

end