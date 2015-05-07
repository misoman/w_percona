include_recipe 'git'

if node['w_apache']['deploy'].has_key? 'repo_ip' then

	repo_ip = node['w_apache']['deploy']['repo_ip']
	repo_domain = node['w_apache']['deploy']['repo_domain']

	hostsfile_entry repo_ip do
	  hostname repo_domain
	  action :append
	  unique true
	end
end

directory "/var/www/.ssh" do
  owner 'www-data'
  group 'www-data'
  mode '0700'
  action :create
end

private_key = data_bag_item('w_apache', 'deploykey')['private_key']

file '/var/www/.ssh/id_rsa' do
  content private_key
  owner 'www-data'
  group 'www-data'
  mode '600'
end

url = node['w_apache']['deploy']['repo_url']

execute 'git init' do
  cwd '/websites'
  user 'www-data'
  group 'www-data'
  creates '/websites/.git/HEAD'
end

execute "git remote add origin #{url}" do
  cwd '/websites'
  user 'www-data'
  group 'www-data'
  not_if "cat /websites/.git/config | grep #{url}"
end
