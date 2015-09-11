require_relative '../spec_helper'

describe 'w_percona::xinetd' do

  let(:chef_run) do
    ChefSpec::SoloRunner.new do |node|
      node.set['percona']['xinetd_enabled'] = true
    end.converge(described_recipe)
  end

  before do
    stub_data_bag_item('w_percona', 'db_credential').and_return('id' => 'db_credential', 'backup_password' => 'backuppassword')
    stub_command("grep 9200/tcp /etc/services").and_return(false)
  end

  it 'runs xinetd recipe' do
    expect(chef_run).to include_recipe('xinetd')
  end

  it 'is created' do
      expect(chef_run).to create_template('/etc/xinetd.d/mysqlchk')
  end

  it 'installs xinetd package' do
    expect(chef_run).to install_package('xinetd')
  end

  it 'runs command to create mysqlchk service' do
    expect(chef_run).to run_execute('echo "mysqlchk 9200/tcp # mysqlchk" >> /etc/services')
  end
      
end