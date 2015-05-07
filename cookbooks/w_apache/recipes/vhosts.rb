directory '/websites' do
    owner 'www-data'
    group 'www-data'
end

node['w_common']['web_apps'].each do |web_app|

  vhost = web_app['vhost']
  dir = vhost['docroot'] ? vhost['docroot'] : vhost['main_domain']
  dir = '/websites/' + dir
  directory dir do
    owner 'www-data'
    group 'www-data'
  end

  web_app vhost['main_domain'] do
    server_name vhost['main_domain']
    server_aliases vhost['aliases']
    docroot dir
    cookbook 'apache2'
    allow_override 'All'
    directory_index ["index.html", "index.htm", "index.php"]
  end

end