require_relative '../spec_helper'

describe 'w_mysql::default' do
	let(:chef_run) { ChefSpec::SoloRunner.converge(described_recipe) }
  
  it 'installs package mysql-server, mysql-client and starts mysql service' do
      expect(chef_run).to create_mysql_service('default').with(bind_address: '0.0.0.0', data_dir: '/data/db')
      expect(chef_run).to create_mysql_client('default')
  end
  
end