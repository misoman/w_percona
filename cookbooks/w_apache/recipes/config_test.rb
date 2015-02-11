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

  redirect_dir = '/websites/' + dir + '/redierct_test'
  directory redirect_dir
  %w[ old new ].each do |filename|
    file redirect_dir + "/#{filename}file.html" do
      content "<html><body>this is #{filename} file</body></html>"
    end
  end

  access_file_content = <<-eos
    RewriteEngine ON
    Redirect 301 /redierct_test/oldfile.html /redierct_test/newfile.html
  eos
  file redirect_dir + "/#{node['apache']['access_file_name']}" do
    content access_file_content
  end
end