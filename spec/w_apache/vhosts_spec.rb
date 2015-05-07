require_relative '../spec_helper'

describe 'w_apache::vhosts' do
	context 'with default setting' do

		let(:web_apps) do
		  [
		  	{ vhost: { main_domain: 'example.com', docroot: 'www', aliases: ['www.example.com', 'ex.com']}},
		    { vhost: { main_domain: 'example2.com', aliases: ['www.example2.com', 'ex2.com']}}
		  ]
	  end

	  let(:chef_run) do
	    ChefSpec::SoloRunner.new do |node|
	    	node.set['w_common']['web_apps'] = web_apps
				node.set['w_memcached']['ips'] = ['127.0.0.1']
	    end.converge(described_recipe)
	  end

	  before do
	    stub_command("/usr/sbin/apache2 -t").and_return(true)
	  end

	  it 'creates directory /websites' do
	    expect(chef_run).to create_directory('/websites').with(owner: 'www-data', group: 'www-data')
	  end

	  it 'creates directory /websites/www when docroot is specified ' do
	    expect(chef_run).to create_directory('/websites/www').with(owner: 'www-data', group: 'www-data')
	  end

	  it 'creates directory /websites/example2.com when docroot is not specified' do
	    expect(chef_run).to create_directory('/websites/example2.com').with(owner: 'www-data', group: 'www-data')
	  end

    describe '/etc/apache2/sites-available/example.com.conf' do
      it 'is created' do
        expect(chef_run).to create_template('/etc/apache2/sites-available/example.com.conf')
      end

      it 'has vhost example.com' do
        expect(chef_run).to render_file('/etc/apache2/sites-available/example.com.conf').with_content('ServerName example.com')
      end

      it 'has doc root /websites/www' do
        expect(chef_run).to render_file('/etc/apache2/sites-available/example.com.conf').with_content('DocumentRoot /websites/www')
      end

      it 'has serveraliases www.example.com and ex.com' do
        expect(chef_run).to render_file('/etc/apache2/sites-available/example.com.conf').with_content('ServerAlias www.example.com ex.com')
      end

      it 'has directory index index.html index.htm index.php' do
        expect(chef_run).to render_file('/etc/apache2/sites-available/example.com.conf').with_content('DirectoryIndex index.html index.htm index.php')
      end

      it 'overwrites the Log setting' do
        expect(chef_run).to render_file('/etc/apache2/sites-available/example.com.conf').with_content('AllowOverride All')
      end
    end

    describe '/etc/apache2/sites-available/example2.com.conf' do
      it 'is created' do
        expect(chef_run).to create_template('/etc/apache2/sites-available/example2.com.conf')
      end

      it 'has vhost example2.com' do
        expect(chef_run).to render_file('/etc/apache2/sites-available/example2.com.conf').with_content('ServerName example2.com')
      end

      it 'has doc root /websites/example2.com' do
        expect(chef_run).to render_file('/etc/apache2/sites-available/example2.com.conf').with_content('DocumentRoot /websites/example2.com')
      end

      it 'has doc root /websites/example2.com' do
        expect(chef_run).to render_file('/etc/apache2/sites-available/example2.com.conf').with_content('ServerAlias www.example2.com ex2.com')
      end

      it 'has directory index index.html index.htm index.php' do
        expect(chef_run).to render_file('/etc/apache2/sites-available/example.com.conf').with_content('DirectoryIndex index.html index.htm index.php')
      end

      it 'overwrites the Log setting' do
        expect(chef_run).to render_file('/etc/apache2/sites-available/example.com.conf').with_content('AllowOverride All')
      end

    end

 end
end