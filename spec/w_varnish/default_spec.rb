require_relative '../spec_helper'

describe 'w_varnish::default' do
  before do
    stub_command('apt-key list | grep C7917B12').and_return(true)
    stub_command("apt-key list | grep DE742AFA").and_return(true)
  end

  context 'with default setting and node[\'varnish\'][\'backend_hosts\']=(3 backend_hosts)' do
    let(:backend_hosts) { ['1.1.1.1', '2.2.2.2', '3.3.3.3'] }
    let(:chef_run) do
      ChefSpec::SoloRunner.new do |node|
        node.automatic['ipaddress'] = '4.4.4.4'
        node.set['varnish']['listen_address'] = ''
        node.set['varnish']['listen_port'] = 6081
        node.set['varnish']['admin_listen_port'] = '6082'
        node.set['varnish']['memory_limit'] = '16G'
        node.set['varnish']['backend_port'] = '8080'
        node.set['varnish']['backend_hosts'] = backend_hosts
        node.set['monit_enabled'] = false
        node.set['w_varnish']['multi_cookie_enabled'] = false
        node.set['w_varnish']['geoip']['enabled'] = false
      end.converge(described_recipe)
    end
    let(:template_etc_varnish_default_vcl) { chef_run.template('/etc/varnish/default.vcl') }
    let(:template_etc_default_varnish) { chef_run.template('/etc/default/varnish') }

    it 'runs recipe varnish::repo' do
      expect(chef_run).to include_recipe('varnish::repo')
    end

    it 'installs the varnish package' do
      expect(chef_run).to install_package('varnish')
    end

    it 'creates /etc/varnish/devicedetect.vcl' do
      expect(chef_run).to create_cookbook_file('/etc/varnish/devicedetect.vcl').with(
        source: 'devicedetect.vcl',
        mode: '0755',
        owner: 'root',
        group: 'root'
      )
      expect(chef_run).to render_file('/etc/varnish/devicedetect.vcl').with_content('sub devicedetect {')
    end

    it "doesn't raise error" do
      expect { chef_run }.to_not raise_error
    end

    describe '/etc/varnish/default.vcl' do
      it 'is created' do
        expect(chef_run).to create_template('/etc/varnish/default.vcl')
      end

      it 'has the healthcheck of itself as backend of web front haproxy with /varnishhealthcheck and return HTTP status code 200' do
        expect(chef_run).to render_file('/etc/varnish/default.vcl').with_content('if (req.url == "/varnishhealthcheck")')
        expect(chef_run).to render_file('/etc/varnish/default.vcl').with_content('return (synth(200, "Varnish server is healthy")')
      end

      it 'has the healthcheck of apache2 for its backend with /ping.php & timeout greater than 0' do
        expect(chef_run).to render_file('/etc/varnish/default.vcl').with_content('probe healthcheck')
        expect(chef_run).to render_file('/etc/varnish/default.vcl').with_content('.url = "/ping.php"')
        expect(chef_run).to render_file('/etc/varnish/default.vcl').with_content(/probe healthcheck \{.*\.url = "\/ping\.php".*\.timeout = [1-9][0-9]* s;.*\}/m)
      end

      it 'has all backends' do
        backend_hosts.each_index do |index|
          expect(chef_run).to render_file('/etc/varnish/default.vcl').with_content(/backend web#{index} \{.*\.host = "#{backend_hosts[index]}";.*\.port = "8080";.*\}/m)
        end
      end

      it 'adds all backends to round_robin director' do
        expect(chef_run).to render_file('/etc/varnish/default.vcl').with_content(/sub vcl_init \{.*directors\.round_robin\(\);.*add_backend\(web0\).*add_backend\(web1\).*add_backend\(web2\).*\}/m)
      end

      #it 'adds geoip in hash' do (uncomment and edit if generate cache object by location)
      #  expect(chef_run).to render_file('/etc/varnish/default.vcl').with_content('hash_data(req.http.X-GeoIP);')
      #  expect(chef_run).to render_file('/etc/varnish/default.vcl').with_content('hash_data(req.http.X-GeoIP-City);')
      #end
    end

    it 'sends reload notification to varnish service when /etc/varnish/default.vcl updated' do
      expect(template_etc_varnish_default_vcl).to notify('service[varnish]').to(:reload)
    end

    describe '/etc/default/varnish' do
      it 'is created' do
        expect(chef_run).to create_template('/etc/default/varnish')
      end

      it 'has listen address and port' do
        expect(chef_run).to render_file('/etc/default/varnish').with_content(/VARNISH_LISTEN_ADDRESS=4.4.4.4/)
        expect(chef_run).to render_file('/etc/default/varnish').with_content(/VARNISH_LISTEN_PORT=6081/)
      end

      it 'has admin listen address and port' do
        expect(chef_run).to render_file('/etc/default/varnish').with_content(/VARNISH_ADMIN_LISTEN_ADDRESS=0.0.0.0/)
        expect(chef_run).to render_file('/etc/default/varnish').with_content(/VARNISH_ADMIN_LISTEN_PORT=6082/)
      end

      it 'has memory limit' do
        expect(chef_run).to render_file('/etc/default/varnish').with_content(/VARNISH_STORAGE_SIZE=16G/)
      end
    end

    it 'sends restart notification to varnish serivce when /etc/default/varnish updated' do
      expect(template_etc_default_varnish).to notify('service[varnish]').to(:restart)
    end

    it 'enables firewall' do
      expect(chef_run).to enable_firewall('ufw')
    end

    [8080, 6081, 6082].each do |listen_port|
      it "runs resoruce firewall_rule to open port #{listen_port}" do
        expect(chef_run).to allow_firewall_rule("listen port #{listen_port}").with(port: listen_port, protocol: :tcp)
      end
    end

    it 'enables and restarts varnish service' do
      expect(chef_run).to enable_service('varnish')
      expect(chef_run).to start_service('varnish')
    end

    it 'enables and restarts varnishlog service' do
      expect(chef_run).to enable_service('varnishlog')
      expect(chef_run).to start_service('varnishlog')
    end
  end

  context 'with node[\'varnish\'][\'listen_address\'] not specified' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new do |node|
        node.automatic['ipaddress'] = '4.4.4.4'
        node.set['varnish']['listen_address'] = '5.5.5.5'
      end.converge(described_recipe)
    end

    describe '/etc/default/varnish' do
      it 'is created' do
        expect(chef_run).to create_template('/etc/default/varnish')
      end

      it 'has listen address and admin listen custom ip' do
        expect(chef_run).to render_file('/etc/default/varnish').with_content(/VARNISH_LISTEN_ADDRESS=5.5.5.5/)
        expect(chef_run).to render_file('/etc/default/varnish').with_content(/VARNISH_ADMIN_LISTEN_ADDRESS=0.0.0.0/)
      end
    end
  end

  context 'with multi cookie enabled' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new do |node|
        node.set['w_varnish']['multi_cookie_enabled'] = true
      end.converge(described_recipe)
    end

    it 'runs recipe w_varnish::multi_cookie' do
      expect(chef_run).to include_recipe('w_varnish::multi_cookie')
    end
  end

  context 'with geoip enabled' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new do |node|
        node.set['w_varnish']['geoip']['enabled'] = true
      end.converge(described_recipe)
    end

    it 'runs recipe w_varnish::geoip_varnish4' do
      expect(chef_run).to include_recipe('w_varnish::geoip_varnish4')
    end

    describe '/etc/varnish/default.vcl' do
      it 'is created' do
        expect(chef_run).to create_template('/etc/varnish/default.vcl')
      end

      it 'imports maxminddb' do
        expect(chef_run).to render_file('/etc/varnish/default.vcl').with_content('import maxminddb;')
      end
    end
  end

  context 'with monit enabled' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new do |node|
        node.set['monit_enabled'] = true
      end.converge(described_recipe)
    end

    it 'include recipe w_varnish::monit' do
      expect(chef_run).to include_recipe('w_varnish::monit')
    end
  end
end