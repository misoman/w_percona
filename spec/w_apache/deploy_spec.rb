require_relative '../spec_helper'

describe 'w_apache::deploy' do
	context 'with default setting' do

		let(:web_apps) do
		  [
		  	{ vhost: { main_domain: 'examplewebsite.com', docroot: 'examplewebsite.com' }, deploy: { repo_ip: '9.9.9.9', repo_domain: 'git.examplewebsite.com', repo_url: 'https://git.examplewebsite.com/www.git' } },
		  	{ vhost: { main_domain: 'admin.examplewebsite.com', docroot: 'examplewebsite.com/admin' }, deploy: { repo_url: 'https://git.examplewebsite.com/admin.git' } }
		  ]
	  end

	  let(:chef_run) do
	    ChefSpec::SoloRunner.new do |node|
	    	node.set['w_common']['web_apps'] = web_apps
	    	node.set['w_apache']['deploy']['enabled'] = true
				node.set['w_memcached']['ips'] = ['127.0.0.1']
	    end.converge(described_recipe)
	  end

	  before do
	    stub_command("cat /websites/examplewebsite.com/.git/config | grep https://git.examplewebsite.com/www.git").and_return(false)
	    stub_command("cat /websites/examplewebsite.com/admin/.git/config | grep https://git.examplewebsite.com/admin.git").and_return(false)
	    stub_data_bag('w_apache').and_return(['deploykey'])
	    stub_data_bag_item("w_apache", "deploykey").and_return('id' => 'deploykey', 'private_key' => '-----BEGIN RSA PRIVATE KEY-----CVIOpAIBAAKCAQEA4tcgfvo5E7HG3u+Bl1zDHmW+L4vbCE31PlCzPnUA+1iLfb6Sv1x/ibzhVsFXALP0LON5lL2/3wf6B+qH7t6JpsmYo8qsWpmKy2J7pygQYrmHsxhxxaVU2NEhZT/uhWLKzF40yJ74/of5yBxwutoESYEl1YIilPiGJaWMmQtFUlCiHa7iZQ0Rx7w+A/waxnslA1cajwb3T4PdmLK5zPd8c+089BiCXzJgrKsGSJQ0Ea/EemoU2LIwvs75P3e6necmMSpjqaZGr9s87orbKq1pNyh3/QWzn4C3OKj8QX1m/g51YkUvzTSJzLeJMZygrhSCEU4KoqmwMWW8yUmLMs2xLQIBIwKCAQEAlREGudeh2b33txJrGlLmnvJnCU1GyvFmpUr5ci+hjzovx6kemwJFLqCxVkSJoWBQAD22S80mULwZVai/ujp3tr795/o2vzGy+q5ug8ne4cpgfQFvVf7unRu23CKyr2zOaQq0+N1/DanQByih2d+5rKVTYGt1z5wAYeHRa+LVyF+ixRjZh8kl0y74V32MpWoLddDjK4t5Kcqp/YRJ+cZrj0sqZhIKotbowhbzPZm4a9s7tqbsgLzTbKZPDLqibA1sxtC0DjfavaVEG79QWw+ReNJpxXLCK6LuoiOlJTheOkkX9OT0Hmt4UKILtQsNxASzwD6omQT1L1zqj/d1G/dutwKBgQD2UbMPrhxyjQktLCM7EUCcQvs7siyPGzdCxCsYy8fLEYnHD+8BIaqbfdmzpcca5US0UluTUHBG89qshKN8GlhGqGoghxrvT9QOMvL4vz/bx5Bc3CWyAaqR0rLoPMIRyJdhxMP2oDNKw6j3dF1s6KyBlH16zGoVyhse8AJTjXhGYwKBgQDrwXHVmmV77jPv+aqEHa9sLncKu/sI3nE/Gxdc9GXsUK5LoeGHUNyPgeYNAkdZk2tcPqEv5b5lRwJaAICVQ03sF2xoyiAVo5xi6mmfypik72MK3iY+UE2Cm7/V7XvQ8wfY5g6OCdgjxgG3k3xLWFW3TSNMfhaq3G9PKrhkC3i3LwKBgQDvSA0H6vcQMTwdQNHEWeb+MnBl4EiLBH7TJPaqX47ihhDQANmMEhNyekEyLAM+stUG8Os+pelpfywyj3o+CvarCgCx4lSt9cautSaLPXE75m77HwAMAZ5hxV1WoWwRRoRtmpJ6jP6gZkxeGUTQMnuxE+eb3IRPrmN9I6p9DRXAtwKBgQCa7NXG4c2pNiIhWuxlcpfZYFzbKxKuDoTu9IuyHPKFWZcbwiZ9fkfMBOeiJhGhQ55Sj45+j6kAuaJ1qI8DAFfHCBQKWPCDP6FIUOZTEBsqjq7MoJzJ3P+8Ona/x/JHeyJp9kQUMlrVrgEg3UMM8Ofe2utPhg7lTwdRR/WDkoKHAQKBgQDeqRjEqLVs8sHu49PeVY2v/JbDhWHLmyCTP7v8tn9UA/E0JATz8/7lEr5nqGoWx7MK4AYv4QUIRH9eamkMA8TZy7gAPCCb13wllU0ntbD7Dtm0RioxGwnD4GeQEBwIQ4BdMl4wbDmPt9rhBEGkD9vGDkmbU4iHoWK8rC0EHrgCsQ+=-----END RSA PRIVATE KEY-----')
		end

	  it 'runs recipe git' do
	    expect(chef_run).to include_recipe('git')
	  end

	  it 'generates /etc/hosts file entry to enable communication btw web and gitlap server' do
	  	expect(chef_run).to append_hostsfile_entry('9.9.9.9').with_hostname('git.examplewebsite.com').with_unique(true)
	  end

	  it 'creates /var/www/.ssh and /var/www/.ssh/id_rsa' do
	    expect(chef_run).to create_directory('/var/www/.ssh').with(owner: 'www-data', group: 'www-data', mode: '0700')
	    expect(chef_run).to create_file('/var/www/.ssh/id_rsa').with_content('-----BEGIN RSA PRIVATE KEY-----CVIOpAIBAAKCAQEA4tcgfvo5E7HG3u+Bl1zDHmW+L4vbCE31PlCzPnUA+1iLfb6Sv1x/ibzhVsFXALP0LON5lL2/3wf6B+qH7t6JpsmYo8qsWpmKy2J7pygQYrmHsxhxxaVU2NEhZT/uhWLKzF40yJ74/of5yBxwutoESYEl1YIilPiGJaWMmQtFUlCiHa7iZQ0Rx7w+A/waxnslA1cajwb3T4PdmLK5zPd8c+089BiCXzJgrKsGSJQ0Ea/EemoU2LIwvs75P3e6necmMSpjqaZGr9s87orbKq1pNyh3/QWzn4C3OKj8QX1m/g51YkUvzTSJzLeJMZygrhSCEU4KoqmwMWW8yUmLMs2xLQIBIwKCAQEAlREGudeh2b33txJrGlLmnvJnCU1GyvFmpUr5ci+hjzovx6kemwJFLqCxVkSJoWBQAD22S80mULwZVai/ujp3tr795/o2vzGy+q5ug8ne4cpgfQFvVf7unRu23CKyr2zOaQq0+N1/DanQByih2d+5rKVTYGt1z5wAYeHRa+LVyF+ixRjZh8kl0y74V32MpWoLddDjK4t5Kcqp/YRJ+cZrj0sqZhIKotbowhbzPZm4a9s7tqbsgLzTbKZPDLqibA1sxtC0DjfavaVEG79QWw+ReNJpxXLCK6LuoiOlJTheOkkX9OT0Hmt4UKILtQsNxASzwD6omQT1L1zqj/d1G/dutwKBgQD2UbMPrhxyjQktLCM7EUCcQvs7siyPGzdCxCsYy8fLEYnHD+8BIaqbfdmzpcca5US0UluTUHBG89qshKN8GlhGqGoghxrvT9QOMvL4vz/bx5Bc3CWyAaqR0rLoPMIRyJdhxMP2oDNKw6j3dF1s6KyBlH16zGoVyhse8AJTjXhGYwKBgQDrwXHVmmV77jPv+aqEHa9sLncKu/sI3nE/Gxdc9GXsUK5LoeGHUNyPgeYNAkdZk2tcPqEv5b5lRwJaAICVQ03sF2xoyiAVo5xi6mmfypik72MK3iY+UE2Cm7/V7XvQ8wfY5g6OCdgjxgG3k3xLWFW3TSNMfhaq3G9PKrhkC3i3LwKBgQDvSA0H6vcQMTwdQNHEWeb+MnBl4EiLBH7TJPaqX47ihhDQANmMEhNyekEyLAM+stUG8Os+pelpfywyj3o+CvarCgCx4lSt9cautSaLPXE75m77HwAMAZ5hxV1WoWwRRoRtmpJ6jP6gZkxeGUTQMnuxE+eb3IRPrmN9I6p9DRXAtwKBgQCa7NXG4c2pNiIhWuxlcpfZYFzbKxKuDoTu9IuyHPKFWZcbwiZ9fkfMBOeiJhGhQ55Sj45+j6kAuaJ1qI8DAFfHCBQKWPCDP6FIUOZTEBsqjq7MoJzJ3P+8Ona/x/JHeyJp9kQUMlrVrgEg3UMM8Ofe2utPhg7lTwdRR/WDkoKHAQKBgQDeqRjEqLVs8sHu49PeVY2v/JbDhWHLmyCTP7v8tn9UA/E0JATz8/7lEr5nqGoWx7MK4AYv4QUIRH9eamkMA8TZy7gAPCCb13wllU0ntbD7Dtm0RioxGwnD4GeQEBwIQ4BdMl4wbDmPt9rhBEGkD9vGDkmbU4iHoWK8rC0EHrgCsQ+=-----END RSA PRIVATE KEY-----').with(owner: 'www-data', group: 'www-data', mode: '600')
	  end

	  it 'runs a execute git init for www' do
	    expect(chef_run).to run_execute('git init for https://git.examplewebsite.com/www.git').with(cwd: '/websites/examplewebsite.com', command: 'git init', user: 'www-data', group: 'www-data', creates: '/websites/examplewebsite.com/.git/HEAD')
	  end
		
	  it 'runs a execute git remote add origin url for www' do
	    expect(chef_run).to run_execute('git remote add origin https://git.examplewebsite.com/www.git').with(cwd: '/websites/examplewebsite.com', user: 'www-data', group: 'www-data')
	  end

	  it 'doesn not run a execute git remote add origin url when www repo already exists' do
	  	stub_command("cat /websites/examplewebsite.com/.git/config | grep https://git.examplewebsite.com/www.git").and_return(true)
	    expect(chef_run).to_not run_execute('git remote add origin https://git.examplewebsite.com/www.git').with(cwd: '/websites/examplewebsite.com', user: 'www-data', group: 'www-data')
	  end
	  
	  it 'runs a execute git init for admin' do
	    expect(chef_run).to run_execute('git init for https://git.examplewebsite.com/admin.git').with(cwd: '/websites/examplewebsite.com/admin', command: 'git init', user: 'www-data', group: 'www-data', creates: '/websites/examplewebsite.com/admin/.git/HEAD')
	  end
	  
	  it 'runs a execute git remote add origin url for admin' do
	    expect(chef_run).to run_execute('git remote add origin https://git.examplewebsite.com/admin.git').with(cwd: '/websites/examplewebsite.com/admin', user: 'www-data', group: 'www-data')
	  end

	  it 'doesn not run a execute git remote add origin url when admin repo already exists' do
	  	stub_command("cat /websites/examplewebsite.com/admin/.git/config | grep https://git.examplewebsite.com/admin.git").and_return(true)
	    expect(chef_run).to_not run_execute('git remote add origin https://git.examplewebsite.com/admin.git').with(cwd: '/websites/examplewebsite.com/admin', user: 'www-data', group: 'www-data')
	  end
	  
	end
end