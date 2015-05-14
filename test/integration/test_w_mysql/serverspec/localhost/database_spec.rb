require 'spec_helper'

describe 'w_mysql::database' do
	
	root_password = 'ilikerandompasswords'
	db_host = host_inventory['ec2']['hostname'].nil? ? host_inventory['hostname'] : host_inventory['ec2']['hostname'] 
	
	[db_host, 'localhost', '%'].each do |empty_user_host|
		describe command("MYSQL_PWD=#{root_password} mysql -u root -h #{db_host} -Bse \"SELECT User FROM mysql.user WHERE user='' AND host='#{empty_user_host}';\" ") do
	      its(:exit_status) { should eq 0 }
	  end
  end
  
  describe command("MYSQL_PWD=#{root_password} mysql -u root -h #{db_host} -Bse \"SELECT User FROM mysql.user WHERE user='root' AND host='%';\" ") do
	      its(:exit_status) { should eq 0 }
  end
  
  ['ex_user', 'ex_admin_user_1', 'ex_admin_user_2'].each do |webapp_username|
		describe command("MYSQL_PWD=#{root_password} mysql -u root -h #{db_host} -Bse \"SELECT User FROM mysql.user;\" ") do
	      its(:stdout) { should contain("#{webapp_username}") }
	  end
  end

	['ex_db', 'ex_admin_db_1', 'ex_admin_db_2'].each do |webapp_db|
		describe command("MYSQL_PWD=#{root_password} mysql -u root -h #{db_host} -Bse \"SELECT db FROM mysql.db;\" ") do
	      its(:stdout) { should contain("#{webapp_db}") }
	  end		
	end
		
end