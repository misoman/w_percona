require_relative '../spec_helper'

describe 'w_percona::default' do

  context 'with default setting' do

    let(:web_apps) do
      [
        {vhost: {main_domain: 'example.com'}, connection_domain: { webapp_domain: 'webapp.example.com' }, mysql: [ { db: 'db1', user: 'user', password: 'pw' } ] },
        {vhost: {main_domain: 'ex.com'}, connection_domain: { webapp_domain: 'webapp.example.com' }, mysql: [ { db: 'db2', user: 'user', password: 'pw' } ] }
      ]
    end

    let(:chef_run) do
      ChefSpec::SoloRunner.new do |node|
        node.set['w_common']['web_apps'] = web_apps
        node.set['dbhosts']['webapp_ip'] = ['1.1.1.1', '2.2.2.2']
        node.set['percona']['xinetd_enabled'] = false
        node.automatic['hostname'] = 'dbhost.example.com'
      end.converge(described_recipe)
    end

    before do
      stub_command("mysqladmin --user=root --password='' version").and_return(true)
      stub_search(:node, 'role:percona').and_return([ { private_ipaddress: '10.10.10.10' }, { private_ipaddress: '10.10.10.11' } ])
      stub_data_bag_item('w_percona', 'db_credential').and_return('id' => 'db_credential', 'root_password' => 'rootpassword', 'backup_password' => 'backuppassword')
    end

    %w( cluster backup toolkit ).each do |recipe|
      it "runs recipe percona::#{recipe}" do
        expect(chef_run).to include_recipe("percona::#{recipe}")
      end
    end

    it 'runs recipe w_percona::database' do
      expect(chef_run).to include_recipe('w_percona::database')
    end

    it 'not runs recipe w_percona::xinetd' do
      expect(chef_run).to_not include_recipe('w_percona::xinetd')
    end

    it 'enables firewall' do
      expect(chef_run).to install_firewall('default')
    end

    [3306, 4444, 4567, 4568, 9200].each do |percona_port|
      it "runs resoruce firewall_rule to open port #{percona_port}" do
        expect(chef_run).to create_firewall_rule("percona port #{percona_port.to_s}").with(port: percona_port, protocol: :tcp)
      end
    end
  end
end