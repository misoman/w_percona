require 'spec_helper'

describe 'w_haproxy::default' do

  describe service('haproxy') do
    it { should be_enabled }
    it { should be_running }
  end

  describe file('/usr/local/etc/haproxy/haproxy.cfg') do
    it { should be_file }
  end  

  describe port(80) do
    it { should be_listening }
  end

  describe port(443) do
    it { should be_listening }
  end

  describe port(22002) do
    it { should be_listening }
  end    
end