require_relative '../spec_helper'

describe 'w_nfs::client' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new do |node|
      node.set['nfs']['nfs_server_ip'] = '172.31.7.12'
	  end.converge(described_recipe)
  end

  it 'includes recipe nfs::client4' do
    expect(chef_run).to include_recipe('nfs::client4')
  end

  it 'creates a directory /data' do
    expect(chef_run).to create_directory('/data').with(owner: 'root', group: 'root', mode: 00777)
  end

  it 'enables a mount /data' do
    expect(chef_run).to enable_mount('/data').with(device: '172.31.7.12:/exports/data', fstype: 'nfs', options: ['rw', 'noauto'], pass: 0)
  end

mount_subtree = <<EOF
#!/bin/sh -e
sleep 5
mount /data
exit 0
EOF

  it 'renders the file /etc/rc.local with content' do
    expect(chef_run).to render_file('/etc/rc.local').with_content(mount_subtree)  
  end
         
end