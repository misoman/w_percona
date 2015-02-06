node['w_common']['web_apps'].each do |web_app|
  dir = web_app['vhost']['docroot'] ? web_app['vhost']['docroot'] : web_app['vhost']['main_domain']
  template  '/websites/' + dir + '/config_test.php' do
    source 'config_test.php.erb'
    variables(
      :db_domain => web_app['webapp_db_connection']['db_domain'],
      :user => web_app['mysql']['user'],
      :password => web_app['mysql']['password']
    )
  end
end