require_relative '../spec_helper'

describe 'w_common::default' do

  context 'with vmware tools disabled' do

  	let(:bash_code) do
 <<-EOH
      apt-get update
      touch #{first_run_file}
 EOH
  	end

  	let(:first_run_file) do
  		'/var/chef/cache/apt_compile_time_update_first_run'
  	end

	  let(:chef_run) do
	    ChefSpec::SoloRunner.new(file_cache_path: '/var/chef/cache') do |node|
	      node.set['w_common']['vmware-tools_enabled'] = false
	      node.set['tz'] = 'America/Los_Angeles'
	      node.set['apt']['compile_time_update'] = true
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

	  before do
    	stub_data_bag('w_common').and_return(['charlie'])
    	stub_data_bag_item('w_common', 'charlie').and_return('id' => 'charlie', 'admin' => true, 'ssh_public_key' => 'ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA4tcgfvo5E7HG3u+Bl1zDHmW+L4vbCE41PlCzPnUA+1iLfb6Sv1x/ibzhVsFXALP0LON5lL2/3wf6B+qH7t6JpsmYo8qsWpmKy2J7pygQYrmHsxhxxaVU2NEhZT/2hWLKzF40yJ74/of5yBxwutoESYEl1YIilPiGJaWMmQhFUlCiHa7iZQ0Rx7w+A/waxnslA1cajwb3T4PdmLK5zPd8c+089BiCXzJgrKsGSJQ0Ea/EemoU2LIwvs75P3e6necmMSpj5aZGr9s87orbKq1pNyh3/QWzn4C3OKj8QX1m/g53YkUvzTSJzLeJMZygrhSCEU4KoqmwMWW8yUmLMs2xLQ== user@USER-PC')
    	stub_command("which sudo").and_return(true)
		end

		it 'excute apt-get update' do
			expect(chef_run).to include_recipe('apt')
			expect(chef_run).to run_bash('apt-get-update at compile time').with(
				code: bash_code,
				ignore_failure: true
			)
		end

		it 'upgrads bash' do
			expect(chef_run).to upgrade_package('bash')
		end

	  it 'runs following recipes: sudo, ntp, timezone' do
	    expect(chef_run).to include_recipe('sudo')
	    expect(chef_run).to include_recipe('ntp')
	    expect(chef_run).to include_recipe('timezone-ii')
	  end

	  it 'enable ufw and open port 22 for ssh' do
	  	expect(chef_run).to enable_firewall('ufw')
	  	expect(chef_run).to allow_firewall_rule('ssh').with_port(22)
	  end

		it 'renders /etc/timezone' do
			expect(chef_run).to render_file('/etc/timezone').with_content('America/Los_Angeles')
		end
	end
end
