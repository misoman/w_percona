include_recipe 'apache2::mod_actions'
include_recipe 'apache2::mod_fastcgi'

begin
  r = resources(template: "#{node['apache']['dir']}/mods-available/fastcgi.conf")
  r.cookbook 'w_apache'
  r.source 'fastcgi.conf.erb'
  r.owner 'root'
  r.group 'root'
rescue Chef::Exceptions::ResourceNotFound
  Chef::Log.warn 'could not find template to override!'
end