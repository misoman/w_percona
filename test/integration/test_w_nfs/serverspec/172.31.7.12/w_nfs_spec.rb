require 'spec_helper'

if interface('eth1').has_ipv4_address?('172.31.7.12')
  describe 'nfs server' do
    describe package('nfs-kernel-server') do
      it { should be_installed }
    end

    describe service('nfs-kernel-server') do
      it { should be_enabled }
      it { should be_running }
    end

    describe user('www-data') do
      it { should exist }
      it { should have_uid 33 }
    end

    describe port(2_049) do
      it { should be_listening }
    end

    describe port(32_765) do
      it { should be_listening }
    end

    describe port(32_767) do
      it { should be_listening }
    end

    describe 'file should be synced between client & server '\
             ' with www-data as owner' do
      describe command('su www-data -c "touch /exports/data/testfile1"') do
        its(:exit_status) { should eq 0 }
      end
      # describe file('/exports/data/testfile2') do
      #   it { should be_file }
      #   it { should be_owned_by 'www-data' }
      # end
    end
  end
end
