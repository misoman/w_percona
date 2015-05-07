node['w_common']['web_apps'].each do |web_app|
  dir = web_app['vhost']['docroot'] ? web_app['vhost']['docroot'] : web_app['vhost']['main_domain']
  if web_app['mysql'].instance_of?(Chef::Node::ImmutableArray) then
    databases = web_app['mysql']
  else
    databases = []
    databases << web_app['mysql']
  end

  template  '/websites/' + dir + '/config_test.php' do
    source 'config_test.php.erb'
    variables(
      :db_domain => web_app['connection_domain']['db_domain'],
      :databases => databases
    )
  end

  file '/websites/' + dir + '/info.php' do
    content '<?php phpinfo(); ?>'
  end

  redirect_dir = '/websites/' + dir + '/redirect_test'
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