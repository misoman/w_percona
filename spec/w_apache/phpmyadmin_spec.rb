require_relative '../spec_helper'

describe 'w_apache::phpmyadmin' do

  before do
    stub_command("lsof -u phpmyadmin | grep phpmyadmin").and_return(false)
    stub_command("/usr/sbin/apache2 -t").and_return(true)
  end

# this context should be uncommented when production environment is available in environments/production.json
#  context 'not in development environment' do
#
#    let(:chef_run) do
#      ChefSpec::SoloRunner.new do |node|
#        node.automatic['memory']['total'] = '4049656kB'
#        node.automatic['memory']['swap']['total'] = '1024kB'
#        allow(node).to receive(:chef_environment).and_return('staging02')
#        varnish = {
#           "purge_target" => true
#        }
#
#        node.set['w_common']['web_apps'] = [
#          {"vhost" => {
#                  "main_domain" => "example.com",
#                  "aliases" => ['www.example.com', 'ex.com'],
#                  "docroot" => "www"
#                  },
#           "connection_domain" => {
#                   "db_domain" => "db.example.com",
#                   "webapp_domain" => "webapp.example.com",
#                   "varnish_domain" => "varnish.example.com"
#                  },
#           "mysql" =>  [
#                   {"db" => "dbname", "user" => "username", "password" => "password"},
#                   {"db" => "dbname2", "user" => "username2", "password" => "password2"}
#                   ],
#           "varnish" => varnish
#          }
#        ]
#      end.converge(described_recipe)
#    end
#
#    it 'kills process executed by user phpmyadmin' do
#      expect(chef_run).to run_execute('pkill -u phpmyadmin')
#    end
#  end

  context 'in development environment' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new do |node|
        node.automatic['memory']['total'] = '4049656kB'
        node.automatic['memory']['swap']['total'] = '1024kB'
        allow(node).to receive(:chef_environment).and_return('development')
        varnish = {
           "purge_target" => true
        }

        node.set['w_common']['web_apps'] = [
          {"vhost" => {
                  "main_domain" => "example.com",
                  "aliases" => ['www.example.com', 'ex.com'],
                  "docroot" => "www"
                  },
           "connection_domain" => {
                   "db_domain" => "db.example.com",
                   "webapp_domain" => "webapp.example.com",
                   "varnish_domain" => "varnish.example.com"
                  },
           "mysql" =>  [
                   {"db" => "dbname", "user" => "username", "password" => "password"},
                   {"db" => "dbname2", "user" => "username2", "password" => "password2"}
                   ],
           "varnish" => varnish
          }
        ]
      end.converge(described_recipe)
    end
    
    it 'does not kill process executed by user phpmyadmin' do
      expect(chef_run).to_not run_execute('pkill -u phpmyadmin')
    end
    
    it 'includes apache2::default recipe' do
      expect(chef_run).to include_recipe('apache2::default')
    end

    it 'create template phpmyadmin.conf' do
      expect(chef_run).to render_file('/etc/apache2/conf-available/phpmyadmin.conf')
    end

    it 'reloads apache after updating phpmyadmin.conf' do
      conf_template = chef_run.template('/etc/apache2/conf-available/phpmyadmin.conf')
      expect(conf_template).to notify('service[apache2]').to(:reload).delayed
    end

  end
end