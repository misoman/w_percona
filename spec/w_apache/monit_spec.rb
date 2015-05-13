require_relative '../spec_helper'

describe 'w_apache::monit' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new do |node|
    	node.set['w_memcached']['ips'] = ['127.0.0.1']
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

  it 'includes recipe monit' do
    expect(chef_run).to include_recipe('monit')
  end

  it 'run resource monit_monitrc' do
    expect(chef_run).to add_monit_config('apache2')
  end

#  it 'run resource monit_monitrc' do
#    expect(chef_run).to add_monit_config('haproxy')
#  end
  
end