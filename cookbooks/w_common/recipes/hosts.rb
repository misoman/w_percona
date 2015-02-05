
node['w_common']['web_apps'].each do |web_app|

  hostsfile_entry node['dbhosts']['webapp_ip'] do
    hostname web_app['webapp_db_connection']['webapp_domain']
    action :append
    unique true
  end

  hostsfile_entry node['dbhosts']['db_ip'] do
    hostname web_app['webapp_db_connection']['db_domain']
    action :append
    unique true
  end

end

hostsfile_entry '127.0.0.1' do
  hostname 'localhost'
  action :append
  unique true
end