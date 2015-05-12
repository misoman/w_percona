require 'spec_helper'

describe 'w_comman::users' do

	describe group('admin') do
		it { should exist }
	  it { should have_gid 111 }
	end

  describe user('bobo') do
    it { should exist }
    it { should belong_to_group 'admin' }
    it { should have_home_directory '/home/bobo' }
    it { should have_login_shell '/bin/bash' }
    it { should have_authorized_key 'ssh-rsa AAAAB3NzaC1yc2EAAEABIwAAAQEA4tcgfvo5E7HG3u+Bl1zDHmW+L4vbCE41PlCzPnUA+1iLfb6Sv1x/ibzhVsFXALP0LON5lL2/3wf6B+qH7t6JpsmYo8qsWpmKy2J7pygQYrmHsxhxxaVU2NEhZT/2hWLKzF40yJ74/of5yBxwutoESYEl1YIilPiGJaWMmQhFUlCiHa7iZQ0Rx7w+A/waxnslA1cajwb3T4PdmLK5zPd8c+089BiCXzJgrKsGSJQ0Ea/EemoU2LIwvs75P3e6necmMSpj5aZGr9s87orbKq1pNyh3/QWzn4C3OKj8QX1m/g53YkUvzTSJzLeJMZygrhSCEU4KoqmwMWW8yUmLMs2xLQ== bobo@USER-PC' }
  end

	describe file('/home/bobo/.ssh') do
	  it { should be_directory }
	  it { should be_mode 700 }
	  it { should be_owned_by 'bobo' }
	  it { should be_grouped_into 'admin' }
	end

	describe file('/home/bobo/.ssh/authorized_keys') do
	  it { should be_file }
	  it { should be_mode 600 }
	  it { should be_owned_by 'bobo' }
	  it { should be_grouped_into 'admin' }
	end

  describe user('frank') do
    it { should exist }
    it { should belong_to_group 'frank' }
    it { should have_home_directory '/home/frank' }
    it { should have_login_shell '/bin/sh' }
    it { should have_authorized_key 'ssh-rsa AAAHB3NzaC1yc2EAAAABIwAAAQEA4tcgfvo5E7HG3u+Bl1zDHmW+L4vbCE41PlCzPnUA+1iLfb6Sv1x/ibzhVsFXALP0LON5lL2/3wf6B+qH7t6JpsmYo8qsWpmKy2J7pygQYrmHsxhxxaVU2NEhZT/2hWLKzF40yJ74/of5yBxwutoESYEl1YIilPiGJaWMmQhFUlCiHa7iZQ0Rx7w+A/waxnslA1cajwb3T4PdmLK5zPd8c+089BiCXzJgrKsGSJQ0Ea/EemoU2LIwvs75P3e6necmMSpj5aZGr9s87orbKq1pNyh3/QWRn4C3OKj8QX1m/g53YkUvzTSJzLeJMZygrhSCEU4KoqmwMWW8yUmLMs2xLQ== frank@USER-PC' }
  end

	describe file('/home/frank/.ssh') do
	  it { should be_directory }
	  it { should be_mode 700 }
	  it { should be_owned_by 'frank' }
	  it { should be_grouped_into 'frank' }
	end

	describe file('/home/frank/.ssh/authorized_keys') do
	  it { should be_file }
	  it { should be_mode 600 }
	  it { should be_owned_by 'frank' }
	  it { should be_grouped_into 'frank' }
	end

  describe group('admin') do
    it { should exist }
    it { should have_gid 111 }
  end

end