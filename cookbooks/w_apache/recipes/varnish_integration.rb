#
# Cookbook Name:: w_apache
# Recipe:: varnish_integration
#
# Copyright 2014, Joel Handwell
#
# license apachev2
#
#

file 'Varnish healthcheck script generated at default site document root' do
  path "#{node['apache']['docroot_dir']}/ping.php"
  content '<html><body>website is healthy</body></html>'
end

node['w_common']['web_apps'].each do |web_app|

  if web_app.has_key? 'varnish' then

    if web_app['varnish'].has_key? 'purge_target' then

      if web_app['varnish']['purge_target'] == true then

        Chef::Log.info "Generating hosts file entries for varnish purge target domains for #{web_app['vhost']['main_domain']}"

        node['w_varnish']['node_ipaddress_list'].each do |varnish_node_ip|

          hostsfile_entry varnish_node_ip do
            hostname web_app['vhost']['main_domain']
            action :append
            unique true
          end

          if web_app['vhost']['aliases'].length > 0 then

            web_app['vhost']['aliases'].each do |alias_domain|

              hostsfile_entry varnish_node_ip do
                hostname alias_domain
                action :append
                unique true
              end
            end
          end
        end
      end
    end
  end
end