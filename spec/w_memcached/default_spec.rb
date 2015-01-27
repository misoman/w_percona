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

#  it 'runs resoruce firewall' do
#    expect(chef_run).to include_recipe('iptables')
#  end

  it 'runs recipe uv_memcached::monit' do
    expect(chef_run).to include_recipe('w_memcached::monit')
  end
end
