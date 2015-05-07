require_relative '../spec_helper'

describe 'w_varnish::multi_cookie' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new.converge(described_recipe)
  end

  it 'adds varnish vmod Header' do
    expect(chef_run).to add_w_varnish_vmod('Header').with(
      source: 'https://github.com/varnish/libvmod-header',
      branch: '4.0',
      packages: ['libvarnishapi-dev', 'python-docutils']
    )
  end

end