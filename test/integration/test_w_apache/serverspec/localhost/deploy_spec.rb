require 'spec_helper'

describe 'w_apache::deploy' do

	describe host('git.examplewebsite.com') do
    it { should be_resolvable.by('hosts') }
    its(:ipaddress) { should eq '9.9.9.9' }
  end
	
	describe file('/var/www/.ssh') do
	  it { should be_directory }
	  it { should be_mode 700 }
	  it { should be_owned_by 'www-data' }
	  it { should be_grouped_into 'www-data' }
	end

	describe file('/var/www/.ssh/id_rsa') do
	  it { should be_file }
	  it { should be_mode 600 }
	  it { should be_owned_by 'www-data' }
	  it { should be_grouped_into 'www-data' }
	  it { should contain '-----BEGIN RSA PRIVATE KEY-----CHIOpAIBAAKCAQEA4tcgfvo5E7HG3u+Bl1zDHmW+L4vbCE31PlCzPnUA+1iLfb6Sv1x/ibzhVsFXALP0LON5lL2/3wf6B+qH7t6JpsmYo8qsWpmKy2J7pygQYrmHsxhxxaVU2NEhZT/uhWLKzF40yJ74/of5yBxwutoESYEl1YIilPiGJaWMmQtFUlCiHa7iZQ0Rx7w+A/waxnslA1cajwb3T4PdmLK5zPd8c+089BiCXzJgrKsGSJQ0Ea/EemoU2LIwvs75P3e6necmMSpjqaZGr9s87orbKq1pNyh3/QWzn4C3OKj8QX1m/g51YkUvzTSJzLeJMZygrhSCEU4KoqmwMWW8yUmLMs2xLQIBIwKCAQEAlREGudeh2b33txJrGlLmnvJnCU1GyvFmpUr5ci+hjzovx6kemwJFLqCxVkSJoWBQAD22S80mULwZVai/ujp3tr795/o2vzGy+q5ug8ne4cpgfQFvVf7unRu23CKyr2zOaQq0+N1/DanQByih2d+5rKVTYGt1z5wAYeHRa+LVyF+ixRjZh8kl0y74V32MpWoLddDjK4t5Kcqp/YRJ+cZrj0sqZhIKotbowhbzPZm4a9s7tqbsgLzTbKZPDLqibA1sxtC0DjfavaVEG79QWw+ReNJpxXLCK6LuoiOlJTheOkkX9OT0Hmt4UKILtQsNxASzwD6omQT1L1zqj/d1G/dutwKBgQD2UbMPrhxyjQktLCM7EUCcQvs7siyPGzdCxCsYy8fLEYnHD+8BIaqbfdmzpcca5US0UluTUHBG89qshKN8GlhGqGoghxrvT9QOMvL4vz/bx5Bc3CWyAaqR0rLoPMIRyJdhxMP2oDNKw6j3dF1s6KyBlH16zGoVyhse8AJTjXhGYwKBgQDrwXHVmmV77jPv+aqEHa9sLncKu/sI3nE/Gxdc9GXsUK5LoeGHUNyPgeYNAkdZk2tcPqEv5b5lRwJwAICVQ03sF2xoyiAVo5xi6mmfypik72MK3iY+UE2Cm7/V7XvQ8wfY5g6OCdgjxgG3k3xLWFW3TSNMfhaq3G9PKrhkC3i3LwKBgQDvSA0H6vcQMTwdQNHEWeb+MnBl4EiLBH7TJPaqX47ihhDQANmMEhNyekEyLAM+stUG8Os+pelpfywyj3o+CvarCgCx4lSt9cautSaLPXE75m77HwAMAZ5hxV1WoWwRRoRtmpJ6jP6gZkxeGUTQMnuxE+eb3IRPrmN9I6p9DRXAtwKBgQCa7NXG4c2pNiIhWuxlcpfZYFzbKxKuDoTu9IuyHPKFWZcbwiZ9fkfMBOeiJhGhQ55Sj45+j6kAuaJ1qI8DAFfHCBQKWPCDP6FIUOZTEBsqjq7MoJzJ3P+8Ona/x/JHeyJp9kQUMlrVrgEg3UMM8Ofe2utPhg7lTwdRR/WDkoKHAQKBgQDeqRjEqLVs8sHu49PeVY2v/JbDhWHLmyCTP7v8tn9UA/E0JATz8/7lEr5nqGoWx7MK4AYv4QUIRH9eamkMA8TZy7gAPCCb13wllU0ntbD7Dtm0RioxGwnD4GeQEBwIQ4BdMl4wbDmPt9rhBEGkD0vGDkmbU4iHoWK8rC0EHrgCsQ+=-----END RSA PRIVATE KEY-----' }
	end

  describe command('cd /websites/examplewebsite.com && git remote -v') do
    its(:stdout) { should contain('git.examplewebsite.com/repo.git') }
  end

end