require_relative '../spec_helper'

describe 'w_percona::default' do

  context 'with default setting' do

    let(:package_cluster) {chef_run.package('percona-xtradb-cluster-56')}
    let(:conf_template) {chef_run.template('/etc/mysql/my.cnf')}
    let(:execute_grants) {chef_run.execute('mysql-install-privileges')}

    let(:chef_run) do
      ChefSpec::SoloRunner.new do |node|
        node.set['w_common']['web_apps'] = web_apps
        node.set['dbhosts']['webapp_ip'] = ['1.1.1.1', '2.2.2.2']
        node.set['w_percona']['xinetd_enabled'] = true
        node.automatic['hostname'] = 'dbhost.example.com'
        node.set['percona']['cluster']['cluster_ips'] = ['10.10.10.10', '10.10.10.11', '10.10.10.12']
        node.set['percona']['server']['role'] = ['cluster']
        node.set['percona']['cluster']['wsrep_sst_auth'] = 'ssttestuser:ssttestpassword'
      end.converge(described_recipe)
    end

    before do
      stub_data_bag_item('w_percona', 'db_credential').and_return('id' => 'db_credential', 'root_password' => 'rootpassword', 'backup_password' => 'backuppassword')
      stub_command("grep 9200/tcp /etc/services").and_return(false)
      stub_command("mysqladmin --user=root --password='' version").and_return(true)
      stub_command("mysql -uroot -p'rootpassword' -e \"SELECT user FROM mysql.user where host='localhost' and user='clustercheck';\" | grep -c \"clustercheck\"").and_return(false)
      stub_command("test -f /var/lib/mysql/mysql/user.frm").and_return(true)
      stub_command("mysqladmin --user=root --password='' version").and_return(true)
    end

    it 'enables firewall' do
      expect(chef_run).to install_firewall('default')
    end

    [3306, 4444, 4567, 4568, 9200].each do |percona_port|
      it "runs resoruce firewall_rule to open port #{percona_port}" do
        expect(chef_run).to create_firewall_rule("percona port #{percona_port.to_s}").with(port: percona_port, protocol: :tcp)
      end
    end

    describe 'percona::cluster recipe' do
      it 'include percona::cluster recipe' do
        expect(chef_run).to include_recipe('percona::cluster')
      end

      it 'include percona::package_repo recipe' do
        expect(chef_run).to include_recipe('percona::package_repo')
        expect(chef_run).to add_apt_preference('00percona').with(glob: '*', pin: 'release o=Percona Development Team', pin_priority: '1001')
        expect(chef_run).to add_apt_repository('percona').with(uri: 'http://repo.percona.com/apt', distribution: 'trusty', components: ['main'], keyserver: 'hkp://keyserver.ubuntu.com:80', key: '0x1C4CBDCDCD2EFD2A')
      end

      it 'installs percona cluster package' do
        expect(chef_run).to install_package('percona-xtradb-cluster-56')
        expect(package_cluster).to notify('service[mysql]').to(:stop).immediately
      end

      it 'include percona::configure_server recipe' do
        expect(chef_run).to include_recipe('percona::configure_server')
        expect(chef_run).not_to install_package('libjemalloc1')
        expect(chef_run).to create_template('/root/.my.cnf').with(owner: 'root', group: 'root', mode: '0600', source: 'my.cnf.root.erb', sensitive: true)
        expect(chef_run).to create_directory('/etc/mysql').with(owner: 'root', group: 'root', mode: '0755')
        expect(chef_run).to create_directory('/var/lib/mysql').with(owner: 'mysql', group: 'mysql', recursive: true)
        expect(chef_run).to create_directory('log directory').with(path: '/var/log/mysql', owner: 'mysql', group: 'mysql', recursive: true)
        expect(chef_run).to create_directory('/var/tmp').with(owner: 'mysql', group: 'mysql', recursive: true)
        expect(chef_run).to create_directory('/etc/mysql/conf.d/').with(owner: 'mysql', group: 'mysql', recursive: true)
        expect(chef_run).not_to create_directory('slow query log directory').with(path: '/var/log/mysql', owner: 'mysql', group: 'mysql', recursive: true)
        expect(chef_run).to enable_service('mysql')
        expect(chef_run).not_to run_execute('setup mysql datadir').with(command: 'mysql_install_db --defaults-file=/etc/mysql/my.cnf --user=mysql')
        expect(chef_run).not_to include_recipe('percona::ssl')
        expect(chef_run).to create_template('/etc/mysql/my.cnf').with(source: 'my.cnf.cluster.erb', owner: 'root', group: 'root', mode: '0644', sensitive: true)
        expect(conf_template).to notify('service[mysql]').to(:restart).immediately
        expect(chef_run).to run_execute('Update MySQL root password').with(command: "mysqladmin --user=root --password='' password 'rootpassword'", sensitive: true)
        expect(chef_run).to create_template('/etc/mysql/debian.cnf').with(source: 'debian.cnf.erb', owner: 'root', group: 'root', mode: '0640', sensitive: true)
      end

      it 'include percona::access_grants recipe' do
        expect(chef_run).to include_recipe('percona::access_grants')
        expect(chef_run).to create_template('/etc/mysql/grants.sql').with(source: 'grants.sql.erb', owner: 'root', group: 'root', mode: '0600', sensitive: true)
        expect(chef_run).not_to run_execute('mysql-install-privileges').with(command: "/usr/bin/mysql -p'rootpassword -e '' &> /dev/null > /dev/null &> /dev/null ; if [ $? -eq 0 ] ; then /usr/bin/mysql -p'rootpassword < /etc/mysql/grants.sql ; else /usr/bin/mysql < /etc/mysql/grants.sql ; fi ;")
        expect(execute_grants).to subscribe_to('template[/etc/mysql/grants.sql]').on(:run).immediately
      end

      it 'include percona::backup recipe' do
        expect(chef_run).to include_recipe('percona::backup')
        expect(chef_run).to install_package('xtrabackup').with(options: '--force-yes')
      end

      it 'include percona::toolkit recipe' do
        expect(chef_run).to include_recipe('percona::toolkit')
        expect(chef_run).to install_package('percona-toolkit').with(options: '--force-yes')
      end
    end

    it 'creats /etc/mysql/my.cnf' do
      expect(chef_run).to render_file('/etc/mysql/my.cnf').with_content('gcomm://10.10.10.10,10.10.10.11,10.10.10.12')
      expect(chef_run).to render_file('/etc/mysql/my.cnf').with_content('wsrep_sst_auth                 = ssttestuser:ssttestpassword')
      expect(chef_run).to render_file('/etc/mysql/my.cnf').with_content('log-error = /var/log/mysql.err')
    end

    it 'runs recipe w_percona::database' do
      expect(chef_run).to include_recipe('w_percona::database')
    end

    it 'not runs recipe w_percona::xinetd' do
      expect(chef_run).to include_recipe('w_percona::xinetd')
    end
  end
end
