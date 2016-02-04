require_relative '../spec_helper'

describe 'w_percona::database' do

  context 'with default setting' do

    let(:chef_run) do
      ChefSpec::SoloRunner.new do |node|
        node.set['w_common']['web_apps'] = web_apps
        node.set['dbhosts']['webapp_ip'] = ['1.1.1.1', '2.2.2.2']
        node.set['dbhosts']['db_ip'] = ['4.4.4.4', '5.5.5.5']
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
      expect(chef_run).to run_execute("Create a mysql database db for webapp example.com").with(command: "mysql -uroot -p'rootpassword' -e \"CREATE DATABASE IF NOT EXISTS db;\"")

      ['example2.com', 'example3.com'].each do |vhost|
        ['db2', 'db3', 'db4'].each do |webapp_db|
          expect(chef_run).to run_execute("Create a mysql database #{webapp_db} for webapp #{vhost}").with(command: "mysql -uroot -p'rootpassword' -e \"CREATE DATABASE IF NOT EXISTS #{webapp_db};\"")
        end
      end
    end

    webapp_hosts = []

    webapp_hosts << '1.1.1.1'
    webapp_hosts << '2.2.2.2'

    ['1.1.1.1', '2.2.2.2'].each_index do |index|
      webapp_hosts << index.to_s + 'webapp.example.com'
    end

    webapp_hosts << '4.4.4.4'
    webapp_hosts << '5.5.5.5'

    ['4.4.4.4', '5.5.5.5'].each_index do |index|
      webapp_hosts << index.to_s + 'db.example.com'
    end

    webapp_hosts << 'localhost'

    webapp_hosts.each do |webapp_user_host|

      it "Create a mysql user for webapp if not exist, and grant access of db to user user at host #{webapp_user_host} for vhost example.com" do
        expect(chef_run).to run_execute("Create a mysql user for webapp if not exist, and grant access of db to user user at host #{webapp_user_host} for vhost example.com")
        .with(command: "mysql -uroot -p'rootpassword' -e \"GRANT ALL ON db.* TO 'user'@'#{webapp_user_host}' IDENTIFIED BY 'password';\"")
      end

      ['example2.com', 'example3.com'].each do |vhost|
        ['db2', 'db3', 'db4'].each do |webapp_db|
          it "Create a mysql user for webapp if not exist, and grant access of #{webapp_db} to user user at host #{webapp_user_host} for vhost #{vhost}" do
            expect(chef_run).to run_execute("Create a mysql user for webapp if not exist, and grant access of #{webapp_db} to user user at host #{webapp_user_host} for vhost #{vhost}")
            .with(command: "mysql -uroot -p'rootpassword' -e \"GRANT ALL ON #{webapp_db}.* TO 'user'@'#{webapp_user_host}' IDENTIFIED BY 'password';\"")
          end
        end
      end
    end

    it 'flush privileges' do
      expect(chef_run).to run_execute("mysqladmin -uroot -p'rootpassword' reload")
    end
  end
end