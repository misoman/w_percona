require 'spec_helper'

describe 'w_varnish::multi_cookie' do

	describe package('libvarnishapi-dev') do
    it { should be_installed }
  end
  
  describe package('python-docutils') do
    it { should be_installed }
  end

	#describe file('/usr/lib/varnish/vmods/xxx') do
	#	it { should be_file }
	#end

end