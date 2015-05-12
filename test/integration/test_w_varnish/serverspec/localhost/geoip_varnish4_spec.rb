require 'spec_helper'

describe 'w_varnish::geoip_varnish4' do

  describe package('libmaxminddb-dev') do
    it { should be_installed }
  end

  describe package('automake') do
    it { should be_installed }
  end

  describe package('autoconf') do
    it { should be_installed }
  end

  describe package('build-essential') do
    it { should be_installed }
  end

  describe package('libtool') do
    it { should be_installed }
  end

  # uncomment if our subscription supports autoupdate
  #describe package('geoipupdate') do
  #  it { should be_installed }
  #end

  describe file('/etc/varnish/GeoIP2-City.mmdb') do
    it { should be_file }
  end

  describe file('/usr/lib/varnish/vmods/libvmod_maxminddb.so') do
    it { should be_file }
  end
end