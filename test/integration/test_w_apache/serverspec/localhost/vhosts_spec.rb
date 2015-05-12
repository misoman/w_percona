require 'spec_helper'

describe 'w_apache::vhosts' do

	describe file('/websites') do
	  it { should be_directory }
	  it { should be_owned_by 'www-data' }
	  it { should be_grouped_into 'www-data' }
	end

	%w( examplewebsite.com examplewebsite.com/admin ).each do |docroot|
		describe file("/websites/#{docroot}") do
		  it { should be_directory }
		  it { should be_owned_by 'www-data' }
		  it { should be_grouped_into 'www-data' }
		end
	end

	[
		{'main_domain'=> 'examplewebsite.com', 'docroot'=> 'examplewebsite.com', 'aliases'=> ['www.examplewebsite.com'] },
		{'main_domain'=> 'admin.examplewebsite.com', 'docroot'=> 'examplewebsite.com/admin', 'aliases'=> ['admin.examplewebsite.com'] }
	].each do |vhost|

	 	describe file("/etc/apache2/sites-available/#{vhost['main_domain']}.conf") do
	     it { should be_file }
	     it { should contain('AllowOverride All').from("<Directory /websites/#{vhost['docroot']}>").to('</Directory>') }
	     it { should contain("ServerName #{vhost['main_domain']}").before("DocumentRoot /websites/#{vhost['docroot']}") }
	     it { should contain("ServerAlias #{vhost['aliases']}").after("ServerName #{vhost['main_domain']}") }
	     it { should contain('DirectoryIndex index.html index.htm index.php') }
	   end

	   describe file("/etc/apache2/sites-enabled/#{vhost['main_domain']}.conf") do
	     it { should be_linked_to "../sites-available/#{vhost['main_domain']}.conf" }
	   end

	 end

end
