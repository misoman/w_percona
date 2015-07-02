require 'spec_helper'

describe 'w_haproxy::keepalived' do

  describe service('keepalived') do
    it { should be_enabled }
    it { should be_running }
  end

  describe file('/etc/keepalived/keepalived.conf') do
    it { should be_file }
  end  

  describe command('iptables-save') do
    its(:stdout) { should match(/COMMIT/) }
    its(:stdout) { should contain('-A INPUT -p vrrp .*-j ACCEPT') }
  end
     
end