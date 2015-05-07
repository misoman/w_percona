require_relative '../spec_helper'

describe 'w_common::hosts' do

  context 'default configuration' do

	  let(:chef_run) do
	    ChefSpec::SoloRunner.new do |node|
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
				node.set['dbhosts'] = {
	        "db_ip" => ["2.2.2.2"],
	        "webapp_ip" => ["1.1.1.1"]
				}
	    end.converge(described_recipe)
	  end
	  
	  it 'generates /etc/hosts file entries to enable communication btw web and db server' do
	  	expect(chef_run).to append_hostsfile_entry('1.1.1.1').with_hostname('0webapp.example.com').with_unique(true)
	  	expect(chef_run).to append_hostsfile_entry('2.2.2.2').with_hostname('0db.example.com').with_unique(true)
	  	expect(chef_run).to append_hostsfile_entry('127.0.0.1').with_hostname('localhost').with_unique(true)
	  end

	end

end