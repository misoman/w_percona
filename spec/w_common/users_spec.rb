require_relative '../spec_helper'

describe 'w_common::users' do

  context 'default configuration for admin user' do

	  let(:chef_run) do
	    ChefSpec::SoloRunner.new do |node|
	    
	    end.converge(described_recipe)
	  end
	  
	  before do
    	stub_data_bag('w_common').and_return(['charlie'])
    	stub_data_bag_item('w_common', 'charlie').and_return('id' => 'charlie', 'admin' => true, 'ssh_public_key' => 'ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA4tcgfvo5E7HG3u+Bl1zDHmW+L4vbCE41PlCzPnUA+1iLfb6Sv1x/ibzhVsFXALP0LON5lL2/3wf6B+qH7t6JpsmYo8qsWpmKy2J7pygQYrmHsxhxxaVU2NEhZT/2hWLKzF40yJ74/of5yBxwutoESYEl1YIilPiGJaWMmQhFUlCiHa7iZQ0Rx7w+A/waxnslA1cajwb3T4PdmLK5zPd8c+089BiCXzJgrKsGSJQ0Ea/EemoU2LIwvs75P3e6necmMSpj5aZGr9s87orbKq1pNyh3/QWzn4C3OKj8QX1m/g53YkUvzTSJzLeJMZygrhSCEU4KoqmwMWW8yUmLMs2xLQ== user@USER-PC')
    	stub_command("which sudo").and_return(true)
		end
	  
	  it 'creates user charlie as admin with ssh public key' do
	  	expect(chef_run).to create_user('charlie').with(gid: 111, shell: '/bin/bash', home: '/home/charlie', supports: {:manage_home => true})
	  end
	  
	  it 'creates /home/username/.ssh directory' do
	  	expect(chef_run).to create_directory('/home/charlie/.ssh').with(mode: '0700', owner: 'charlie', group: 'admin', recursive: true)
	  end
	  
	  it 'creates /home/username/.ssh/authorized_keys file' do
	  	expect(chef_run).to create_file('/home/charlie/.ssh/authorized_keys').with(mode: '0600', owner: 'charlie', group: 'admin', content: 'ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA4tcgfvo5E7HG3u+Bl1zDHmW+L4vbCE41PlCzPnUA+1iLfb6Sv1x/ibzhVsFXALP0LON5lL2/3wf6B+qH7t6JpsmYo8qsWpmKy2J7pygQYrmHsxhxxaVU2NEhZT/2hWLKzF40yJ74/of5yBxwutoESYEl1YIilPiGJaWMmQhFUlCiHa7iZQ0Rx7w+A/waxnslA1cajwb3T4PdmLK5zPd8c+089BiCXzJgrKsGSJQ0Ea/EemoU2LIwvs75P3e6necmMSpj5aZGr9s87orbKq1pNyh3/QWzn4C3OKj8QX1m/g53YkUvzTSJzLeJMZygrhSCEU4KoqmwMWW8yUmLMs2xLQ== user@USER-PC')
	  end

	end
	
  context 'default configuration for normal user' do

	  let(:chef_run) do
	    ChefSpec::SoloRunner.new do |node|
	    
	    end.converge(described_recipe)
	  end
	  
	  before do
    	stub_data_bag('w_common').and_return(['charlie2'])
    	stub_data_bag_item('w_common', 'charlie2').and_return('id' => 'charlie2', 'admin' => false, 'ssh_public_key' => 'ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA4tcgfvo5E7HG3u+Bl1zDHmW+L4vbCE41PlCzPnUA+1iLfb6Sv1x/ibzhVsFXALP0LON5lL2/3wf6B+qH7t6JpsmYo8qsWpmKy2J7pygQYrmHsxhxxaVU2NEhZT/2hWLKzF40yJ74/of5yBxwutoESYEl1YIilPiGJaWMmQhFUlCiHa7iZQ0Rx7w+A/waxnslA1cajwb3T4PdmLK5zPd8c+089BiCXzJgrKsGSJQ0Ea/EemoU2LIwvs75P3e6necmMSpj5aZGr9s87orbKq1pNyh3/QWzn4C3OKj8QX1m/g53YkUvzTSJzLeJMZygrhSCEU4KoqmwMWW8yUmLMs2xLQ== user@USER-PC')
    	stub_command("which sudo").and_return(true)
		end
	  
	  it 'creates user charlie2 as normal user with ssh public key' do
	  	expect(chef_run).to create_user('charlie2').with(shell: '/bin/sh', home: '/home/charlie2', supports: {:manage_home => true})
	  end
	  
	  it 'creates /home/username/.ssh directory' do
	  	expect(chef_run).to create_directory('/home/charlie2/.ssh').with(mode: '0700', owner: 'charlie2', group: 'charlie2', recursive: true)
	  end
	  
	  it 'creates /home/username/.ssh/authorized_keys file' do
	  	expect(chef_run).to create_file('/home/charlie2/.ssh/authorized_keys').with(mode: '0600', owner: 'charlie2', group: 'charlie2', content: 'ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA4tcgfvo5E7HG3u+Bl1zDHmW+L4vbCE41PlCzPnUA+1iLfb6Sv1x/ibzhVsFXALP0LON5lL2/3wf6B+qH7t6JpsmYo8qsWpmKy2J7pygQYrmHsxhxxaVU2NEhZT/2hWLKzF40yJ74/of5yBxwutoESYEl1YIilPiGJaWMmQhFUlCiHa7iZQ0Rx7w+A/waxnslA1cajwb3T4PdmLK5zPd8c+089BiCXzJgrKsGSJQ0Ea/EemoU2LIwvs75P3e6necmMSpj5aZGr9s87orbKq1pNyh3/QWzn4C3OKj8QX1m/g53YkUvzTSJzLeJMZygrhSCEU4KoqmwMWW8yUmLMs2xLQ== user@USER-PC')
	  end

	end
		
end