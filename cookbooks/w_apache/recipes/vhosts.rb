node['w_common']['web_apps'].each do |web_app|

  vhost = web_app['vhost']
  dir = '/websites/' + vhost['main_domain']

  directory dir

  web_app vhost['main_domain'] do
    server_name vhost['main_domain']
    server_aliases vhost['aliases']
    docroot dir
    cookbook 'apache2'
  end

end