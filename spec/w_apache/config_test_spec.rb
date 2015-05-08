require_relative '../spec_helper'

describe 'w_apache::config_test' do
	context 'with default setting' do
	
		let(:web_apps) do
		  [
		  	{ vhost: { main_domain: 'example.com', docroot: 'www' }, mysql: [ { db: 'db', user: 'user', password: 'password' }], connection_domain: { db_domain: 'db.example.com' }},
		    { vhost: { main_domain: 'example2.com' }, mysql: [ { db: 'db2', user: 'user', password: 'password' }], connection_domain: { db_domain: 'db.example.com' }},
		  ]
	  end
	
	  let(:chef_run) do
	    ChefSpec::SoloRunner.new do |node|
	    	node.set['w_common']['web_apps'] = web_apps
				node.set['w_memcached']['ips'] = ['127.0.0.1']
				node.set['apache']['access_file_name'] = '.htaccess'
	    end.converge(described_recipe)
	  end
	  
		describe 'when docroot is specified' do
		
		  it 'is creates /websites/www/config_test.php' do
		    expect(chef_run).to create_template('/websites/www/config_test.php')
		  end
		  
		  it 'creates file /websites/www/info.php' do
		  	expect(chef_run).to create_file('/websites/www/info.php').with_content('<?php phpinfo(); ?>')
		  end

		  it 'creates /websites/www/redirect_test' do
		    expect(chef_run).to create_directory('/websites/www/redirect_test')
		  end
		  
		  %w[ old new ].each do |filename|
			  it "creates /websites/www/redirect_test/#{filename}file.html" do
			  	expect(chef_run).to create_file("/websites/www/redirect_test/#{filename}file.html").with_content("<html><body>this is #{filename} file</body></html>")
			  end
		  end
		  
		  access_file_content = <<-eos
    RewriteEngine ON\n    Redirect 301 /redierct_test/oldfile.html /redierct_test/newfile.html
eos
		  
		  it 'creates file /websites/www/redirect_test/.htaccess' do
		  	expect(chef_run).to create_file('/websites/www/redirect_test/.htaccess').with_content(access_file_content)
		  end

	  end


		describe 'when docroot is not specified' do
		
		  it 'is creates /websites/example2.com/config_test.php' do
		    expect(chef_run).to create_template('/websites/example2.com/config_test.php')
		  end
		  
		  it 'creates file /websites/example2.com/info.php' do
		  	expect(chef_run).to create_file('/websites/example2.com/info.php').with_content('<?php phpinfo(); ?>')
		  end

		  it 'creates /websites/example2.com/redirect_test' do
		    expect(chef_run).to create_directory('/websites/example2.com/redirect_test')
		  end
		  
		  %w[ old new ].each do |filename|
			  it "creates /websites/example2.com/redirect_test/#{filename}file.html" do
			  	expect(chef_run).to create_file("/websites/example2.com/redirect_test/#{filename}file.html").with_content("<html><body>this is #{filename} file</body></html>")
			  end
		  end

		  access_file_content = <<-eos
    RewriteEngine ON\n    Redirect 301 /redierct_test/oldfile.html /redierct_test/newfile.html
eos
		  	  
		  it 'creates file /websites/example2.com/redirect_test/.htaccess' do
		  	expect(chef_run).to create_file('/websites/example2.com/redirect_test/.htaccess').with_content(access_file_content)
		  end

	  end

  end
end