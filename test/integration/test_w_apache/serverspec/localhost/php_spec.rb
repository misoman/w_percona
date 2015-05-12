require 'spec_helper'

describe 'w_apache::php' do

	['php5-fpm', 'php-pear', 'php5-dev', 'php5-mysql', 'php5-memcached', 'php5-gd', 'php5-pspell', 'php5-curl'].each do |package|	
		describe package("#{package}") do
	  	it { should be_installed }
		end
	end
		
	describe service('php5-fpm') do
		it { should be_enabled }
		it { should be_running }
	end

  describe file('/etc/php5/fpm/pool.d/php-fpm.conf') do
    it { should be_file }
  end

  describe file('/var/run/php-fpm-www.sock') do
    it { should be_socket }
  end

#	describe port(9000) do
#	  it { should be_listening.with('tcp') }
#	end
  	
end