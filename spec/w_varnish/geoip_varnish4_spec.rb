require_relative '../spec_helper'

describe 'w_varnish::default' do
  before do
    stub_command('apt-key list | grep C7917B12').and_return(true)
    stub_command("apt-key list | grep DE742AFA").and_return(true)
    stub_command('geoipupdate && /etc/init.d/varnish restart').and_return(true)
    stub_command('gzip -d /etc/varnish/GeoIP2-City.mmdb.gz').and_return(true)
    stub_data_bag('w_varnish').and_return(['geoip'])
    stub_data_bag_item("w_varnish", "geoip").and_return(
      maxmind_userid: 'userid',
      maxmind_licensekey: 'licensekey'
    )
    stub_data_bag('aws').and_return(['aws_credential'])
    stub_data_bag_item("aws", "aws_credential").and_return(
      aws_credential: 'deploykey',
      aws_access_key_id: 'xxxxxxxxxxxxxxxxxxkeyid',
      aws_secret_access_key: 'xxxxxxxxxxxxxxxxxxaccesskey'
    )
  end

  context 'with default setting' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new do |node|
        node.set['w_varnish']['geoip']['enabled'] = true
        node.set['w_varnish']['geoip']['auto_update']['enabled'] = false
        node.set['w_varnish']['geoip']['db_file_url'] = 'http://geolite.maxmind.com/download/geoip/database/GeoLite2-City.mmdb.gz'
        node.set['w_varnish']['geoip']['s3']['enabled'] = false
      end.converge(described_recipe)
    end

    it 'include recipe apt-repo' do
      expect(chef_run).to include_recipe('apt-repo::default')
    end

    %w(libmaxminddb-dev automake autoconf build-essential libtool).each do |package|
      it "installs package #{package}" do
        expect(chef_run).to install_package(package)
      end
    end

    it 'downloads free version of geoip db file from maxmind server and extract' do
      expect(chef_run).to create_remote_file('/etc/varnish/GeoIP2-City.mmdb.gz').with(source: 'http://geolite.maxmind.com/download/geoip/database/GeoLite2-City.mmdb.gz')
      expect(chef_run).to run_execute('gzip -d /etc/varnish/GeoIP2-City.mmdb.gz').with(creates: '/etc/varnish/GeoIP2-City.mmdb')
    end

    it 'adds GeoIP vmod' do
      expect(chef_run).to add_w_varnish_vmod('GeoIP').with(
        source: 'https://github.com/simonvik/libvmod_maxminddb',
        packages: ['libgeoip-dev', 'libvarnishapi-dev', 'python-docutils']
      )
    end
  end

  context 'with s3 enabled' do
    let(:s3) do
      {
        enabled: true,
        s3_url: 'https://s3-eu-west-1.amazonaws.com/nweu',
        bucket: 'nweu',
        remote_path: '/chef/w_varnish/geoip/GeoIP2-City_20141209.mmdb'
      }
    end

    let(:chef_run) do
      ChefSpec::SoloRunner.new do |node|
        node.set['w_varnish']['geoip']['enabled'] = true
        node.set['w_varnish']['geoip']['auto_update']['enabled'] = false
        node.set['w_varnish']['geoip']['s3'] = s3
      end.converge(described_recipe)
    end

    it 'downloads geoip db file from s3' do
      expect(chef_run).to create_s3_file('/etc/varnish/GeoIP2-City.mmdb').with(
        s3_url: 'https://s3-eu-west-1.amazonaws.com/nweu',
        bucket: 'nweu',
        remote_path: '/chef/w_varnish/geoip/GeoIP2-City_20141209.mmdb',
        aws_access_key_id: 'xxxxxxxxxxxxxxxxxxkeyid',
        aws_secret_access_key: 'xxxxxxxxxxxxxxxxxxaccesskey'
      )
    end
  end

  context 'with custome download url' do

    let(:chef_run) do
      ChefSpec::SoloRunner.new do |node|
        node.set['w_varnish']['geoip']['enabled'] = true
        node.set['w_varnish']['geoip']['auto_update']['enabled'] = false
        node.set['w_varnish']['geoip']['db_file_url'] = "http://custom.download.com/GeoLite2-City.mmdb"
        node.set['w_varnish']['geoip']['s3']['enabled'] = false
      end.converge(described_recipe)
    end

    it 'downloads geoip db file from custom url' do
      expect(chef_run).to create_remote_file('/etc/varnish/GeoIP2-City.mmdb').with(source: 'http://custom.download.com/GeoLite2-City.mmdb')
    end
  end

  context 'with auto update enabled' do
    let(:auto_update) do
      { enabled: true, minute: 59, hour: 3, weekday: 2}
    end

    let(:chef_run) do
      ChefSpec::SoloRunner.new do |node|
        node.set['w_varnish']['geoip']['enabled'] = true
        node.set['w_varnish']['geoip']['auto_update'] = auto_update
      end.converge(described_recipe)
    end

    it 'installs package' do
      expect(chef_run).to install_package('geoipupdate')
    end

    it 'create template' do
      expect(chef_run).to create_template('/etc/GeoIP.conf').with(
        owner: 'root',
        group: 'root',
        mode: 0644,
        variables: {
          userid: 'userid',
          licensekey: 'licensekey'
        }
      )
    end

    it 'execute command geoipupdate' do
      expect(chef_run).to run_execute('geoipupdate')
    end

    it 'creates a cron to update geoip db automatically' do
      expect(chef_run).to create_cron('auto update geoip db').with(
        minute: '59',
        hour: '3',
        weekday: '2',
        command: 'geoipupdate && /etc/init.d/varnish restart'
      )
    end

    it 'creates link to downloaded db file' do
      expect(chef_run).to create_link('/etc/varnish/GeoIP2-City.mmdb').with(to: '/usr/share/GeoIP/GeoIP2-City.mmdb')
    end
  end
end