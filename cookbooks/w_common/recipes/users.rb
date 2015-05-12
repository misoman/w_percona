admins = data_bag('w_common')

group 'admin' do
	gid 111
end

admins.each do |login|
  userdata = data_bag_item('w_common', login)
  home = "/home/#{login}"
	
	if userdata['admin'] == true then
	  user(login) do
	  	gid 111
	  	shell '/bin/bash'
	  	home      home
	    supports  :manage_home => true
	  end
	  
	  directory "#{home}/.ssh" do
			mode '0700'
			owner login
			group 'admin'
			recursive true
		end

		file "#{home}/.ssh/authorized_keys" do
			mode '0600'
			owner login
			group 'admin'
			content userdata['ssh_public_key']		
		end
		
	else
	  user(login) do
	  	shell '/bin/sh'
	  	home      home
	    supports  :manage_home => true
	  end
	  
	  directory "#{home}/.ssh" do
			mode '0700'
			owner login
			group login
			recursive true
		end

		file "#{home}/.ssh/authorized_keys" do
			mode '0600'
			owner login
			group login
			content userdata['ssh_public_key']		
		end	  
	end	
end