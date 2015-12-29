require_relative '../spec_helper'

describe 'w_percona::database' do

  context 'with default setting' do

    let(:web_apps) do
      [
        { vhost: {main_domain: 'example.com'}, connection_domain: { webapp_domain: 'webapp.example.com' }, mysql: [ { db: 'db1', user: 'user', password: 'pw' } ] },
        { vhost: {main_domain: 'ex.com'}, connection_domain: { webapp_domain: 'webapp.example.com' }, mysql: [ { db: ['db2', 'db3', 'db4'], user: 'user', password: 'pw' } ] },
      ]
    end

    let(:chef_run) do
      ChefSpec::SoloRunner.new do |node|
        node.set['w_common']['web_apps'] = web_apps
        node.set['dbhosts']['webapp_ip'] = ['1.1.1.1', '2.2.2.2']
        node.set['percona']['server']['root_password'] = 'rootpassword'
        node.automatic['hostname'] = 'dbhost.example.com'
        node.set['w_percona']['xinetd_enabled'] = true
        node.set['percona']['cluster']['wsrep_sst_auth'] = 'ssttestuser:ssttestpassword'
      end.converge(described_recipe)
    end

    before do
      stub_data_bag_item('w_percona', 'db_credential').and_return('id' => 'db_credential', 'root_password' => 'rootpassword', 'backup_password' => 'backuppassword')
      stub_command("mysqladmin --user=root --password='' version").and_return(true)
      stub_command("mysql -uroot -p'rootpassword' -e \"SELECT user FROM mysql.user where host='localhost' and user='clustercheck';\" | grep -c \"clustercheck\"").and_return(false)
      stub_search(:node, 'chef_environment:_default AND role:w_percona_role').and_return(
        [
          { private_ipaddress: '10.10.9.10', roles: ["w_common_role", "w_percona_role"]},
          { private_ipaddress: '10.10.9.11', roles: ["w_common_role", "w_percona_role"]}
        ])
    end

    ['dbhost.example.com', 'localhost'].each do |empty_user_host|
      it "delete default anonymous user @ #{empty_user_host}" do
        expect(chef_run).to run_execute("mysql -uroot -p'rootpassword' -e \"DELETE FROM mysql.user WHERE user='' AND host='#{empty_user_host}';\"")
      end
    end

    ['dbhost.example.com', '192.168.33.1', '127.0.0.1', '::1'].each do |root_host|
      it "apply root password on @#{root_host}" do
        expect(chef_run).to run_execute("mysql -uroot -p'rootpassword' -e \"UPDATE mysql.user SET password=password('rootpassword') WHERE user='root' AND host='#{root_host}';\"")
      end
    end

    it "grants sstuser to localhost and %" do
      expect(chef_run).to run_execute("mysql -uroot -p'rootpassword' -e \"GRANT RELOAD, LOCK TABLES, REPLICATION CLIENT ON *.* TO 'ssttestuser'@'localhost' IDENTIFIED BY 'ssttestpassword';\"")
      expect(chef_run).to run_execute("mysql -uroot -p'rootpassword' -e \"GRANT RELOAD, LOCK TABLES, REPLICATION CLIENT ON *.* TO 'ssttestuser'@'%' IDENTIFIED BY 'ssttestpassword';\"")
    end

    it "creates clustercheck with process privilege" do
      expect(chef_run).to run_execute("mysql -uroot -p'rootpassword' -e \"INSERT into mysql.user (host,user,password,Process_priv) VALUES ('localhost','clustercheck',password('backuppassword'),'Y');\"")
    end

    it 'Create a mysql database for webapp' do
      expect(chef_run).to run_execute("mysql -uroot -p'rootpassword' -e \"CREATE DATABASE IF NOT EXISTS db1;\"")
      expect(chef_run).to run_execute("mysql -uroot -p'rootpassword' -e \"CREATE DATABASE IF NOT EXISTS db2;\"")
      expect(chef_run).to run_execute("mysql -uroot -p'rootpassword' -e \"CREATE DATABASE IF NOT EXISTS db3;\"")
      expect(chef_run).to run_execute("mysql -uroot -p'rootpassword' -e \"CREATE DATABASE IF NOT EXISTS db4;\"")
    end

    ['example.com', 'ex.com'].each do |vhost|
      ['db1', 'db2', 'db3', 'db4'].each do |webapp_db|

        webapp_hosts = []

        webapp_hosts << '1.1.1.1'
        webapp_hosts << '2.2.2.2'

        ['1.1.1.1', '2.2.2.2'].each_index do |index|
          webapp_hosts << index.to_s + 'webapp.example.com'
        end

        webapp_hosts << 'localhost'

        webapp_hosts.each do |webapp_user_host|
          it "Create a mysql user for webapp if not exist, and grant access of #{webapp_db} to user user at host #{webapp_user_host} for vhost #{vhost}" do
            expect(chef_run).to run_execute("mysql -uroot -p'rootpassword' -e \"GRANT ALL ON #{webapp_db}.* TO 'user'@'#{webapp_user_host}' IDENTIFIED BY 'pw';\"")
          end
        end
      end
    end

    it 'create user previleges for db1 for 0webapp.example.com' do
      expect(chef_run).to run_execute("mysql -uroot -p'rootpassword' -e \"GRANT ALL ON db1.* TO 'user'@'0webapp.example.com' IDENTIFIED BY 'pw';\"")
    end

    it 'flush privileges' do
      expect(chef_run).to run_execute("mysqladmin -uroot -p'rootpassword' reload")
    end
  end
end