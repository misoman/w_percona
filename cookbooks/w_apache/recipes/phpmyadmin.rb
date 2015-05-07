execute 'pkill -u phpmyadmin' do
  only_if 'lsof -u phpmyadmin | grep phpmyadmin'
end

include_recipe 'phpmyadmin'

if node.chef_environment == 'development' then

  Chef::Log.info('Enviroment is Detected as development, phpmyadmin will be installed for anydomain.com/mygoodadmin without apache authentication')

  # this resource will create config file from template w_apache/templates/default/phpmyadmin.conf.php.erb
  apache_conf 'phpmyadmin' do
    cookbook 'w_apache'
  end

end
