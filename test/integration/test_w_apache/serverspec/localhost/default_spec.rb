require 'spec_helper'

describe 'w_apache::default' do

  describe file('/etc/apt/sources.list.d/multiverse.list') do
    it { should be_file }
  end
  
  describe file('/etc/apt/sources.list.d/updates-multiverse.list') do
    it { should be_file }
  end
  
  describe file('/etc/apt/sources.list.d/security-multiverse-src.list') do
    it { should be_file }
  end
    
	['ondrej/php5', 'ondrej/apache2'].each do |ppa| 
		describe ppa("#{ppa}") do
		  it { should exist }
		  it { should be_enabled }
		end
	end
	
	['apache2', 'apache2-mpm-worker'].each do |package|	
		describe package("#{package}") do
	  	it { should be_installed }
		end
	end
	
	describe service('apache2') do
		it { should be_enabled }
		it { should be_running }
	end

	describe port(80), :if => os[:family] == 'ubuntu' && os[:release] == '12.04' do
	  it { should be_listening.with('tcp') }
	end

  describe command('ufw status') do
    its(:stdout) { should match /80\/tcp[\s]*ALLOW[\s]*Anywhere/ }
  end
  
end