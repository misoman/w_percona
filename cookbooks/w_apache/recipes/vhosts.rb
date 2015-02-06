node['w_common']['web_apps'].each do |web_app|

  vhost = web_app['vhost']
  dir = vhost['docroot'] ? vhost['docroot'] : vhost['main_domain']
  dir = '/websites/' + dir
  directory dir

  web_app vhost['main_domain'] do
    server_name vhost['main_domain']
    server_aliases vhost['aliases']
    docroot dir
    cookbook 'apache2'
  end

end