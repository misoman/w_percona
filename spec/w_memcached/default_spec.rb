require_relative '../spec_helper'

describe 'w_memcached::default' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new do |node|
      node.set['monit_enabled'] = true
    end.converge(described_recipe)
  end

  it 'runs recipe memcached' do
    expect(chef_run).to include_recipe('memcached')
  end

  it 'enables firewall and runs resoruce firewall_rule to open port 11211' do
  	expect(chef_run).to enable_firewall('ufw')
    expect(chef_run).to allow_firewall_rule('memcached').with(port: 11211, protocol: :tcp)
  end

  it 'runs recipe w_memcached::monit' do
    expect(chef_run).to include_recipe('w_memcached::monit')
  end
end