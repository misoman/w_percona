require_relative '../spec_helper'

describe 'w_memcached::monit' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new.converge(described_recipe)
  end

  it 'runs recipe monit' do
    expect(chef_run).to include_recipe('monit::default')
  end

  %w( ssh memcached ).each do |service|
    it "creates monit config for #{service}" do
      expect(chef_run).to add_monit_config(service)
    end
  end
  
end
