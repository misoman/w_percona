require 'spec_helper'

describe 'w_apache::monit' do

	describe package('monit') do
	  it { should be_installed }
	end
				
	describe service('monit') do
		it { should be_enabled }
		it { should be_running }
	end
	
	describe service('apache2') do
  	it { should be_monitored_by('monit') }
	end

#	describe service('haproxy') do
#  	it { should be_monitored_by('monit') }
#	end

	describe file('/etc/monit/monitrc') do
	  it { should be_file }
	  it { should contain 'username "alert@example.com"' }
	end
	
end