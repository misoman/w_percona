require_relative '../spec_helper'

describe 'w_nfs::default' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new do |node|
      node.set['nfs']['network'] = '172.31.0.0/16'
	  end.converge(described_recipe)
  end
  
  it 'installs a apt_package nfs-kernel-server' do
    expect(chef_run).to install_apt_package('nfs-kernel-server')
  end

  it 'creates a directory /exports and /exports/data' do
    expect(chef_run).to create_directory('/exports').with(owner: 'root', group: 'root', mode: 00777)
    expect(chef_run).to create_directory('/exports/data').with(owner: 'www-data', group: 'www-data')
  end

  it 'includes recipe nfs::server4' do
    expect(chef_run).to include_recipe('nfs::server4')
  end
  
  it 'creates /etc/exports and add exports' do
    expect(chef_run).to create_nfs_export('/exports').with(network: '172.31.0.0/16', writeable: true, sync: false, options: ['insecure', 'no_subtree_check'])
    expect(chef_run).to create_nfs_export('/exports/data').with(network: '172.31.0.0/16', writeable: true, sync: false, options: ['insecure', 'no_subtree_check'])
  end

  it 'enables firewall' do
  	expect(chef_run).to enable_firewall('ufw')
  end

  [2049, 32765, 32766, 32767, 32768, 32769].each do |listen_port|
  	it "runs resoruce firewall_rule to open port #{listen_port}" do
    	expect(chef_run).to allow_firewall_rule("nfs port #{listen_port}").with(port: listen_port, protocol: :tcp)
    end
  end
    
end