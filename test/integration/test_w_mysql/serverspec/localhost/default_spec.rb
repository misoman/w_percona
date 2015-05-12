require 'spec_helper'

describe 'w_mysql::default' do

	describe service('mysql-default') do
	  it { should be_enabled }
	  it { should be_running }
	end
  
  describe command("cat /etc/mysql-default/my.cnf") do
    its(:stdout) { should_not match /bind-address[\s*]=[\s*]0.0.0.0/ }
  end
  
  describe file('/data/db') do
 	 it { should be_directory }
	end

	describe command("/usr/bin/mysql --version") do
	  its(:exit_status) { should eq 0 }
	  its(:stdout) { should match(/Distrib 5.5/) }
	end
		
end