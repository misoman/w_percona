require 'spec_helper'

describe 'w_varnish::default' do
  describe package('varnish') do
    it { should be_installed }
  end

  describe service('varnish') do
    it { should be_enabled }
    it { should be_running }
  end

  describe service('varnishlog') do
    it { should be_enabled }
  end

  describe file('/etc/varnish/devicedetect.vcl') do
    it { should be_file }
    it { should contain 'sub devicedetect {' }
  end

  describe file('/etc/default/varnish') do
    it { should be_file }
  end

  describe file('/etc/varnish/default.vcl') do
    it { should be_file }
    its(:content) { should match(/timeout = 5 s/) }
  end

  describe port(80) do
    it { should be_listening }
  end

  describe port(6082) do
    it { should be_listening }
  end

  describe command("curl -I http://172.31.2.12/varnishhealthcheck") do
    its(:stdout) {should match /200 Varnish server is healthy/}
  end
end