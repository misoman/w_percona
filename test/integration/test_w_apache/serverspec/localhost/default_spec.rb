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

  if package('nfs-common').installed?
    describe 'nfs client' do
      describe package('nfs-common') do
        it { should be_installed }
      end
  
      describe user('www-data') do
        it { should exist }
        it { should have_uid 33 }
      end
  
      describe port(32_765) do
        it { should be_listening }
      end
  
      #It should be verified after nfs server is verified
      describe 'file should be synced between client & server '\
               'with www-data as owner' do
        describe file('/data/testfile1') do
          it { should be_file }
          it { should be_owned_by 'www-data' }
        end
      end
    end
  else
    describe 'nfs client is not installed'
  end
  
end