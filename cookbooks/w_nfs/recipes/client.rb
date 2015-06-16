#
# Cookbook Name:: w_nfs
# Recipe:: client
#

include_recipe 'nfs::client4'

directory node['nfs']['subtree'] do
  owner 'root'
  group 'root'
  mode 00777
end

# This is to resolve slow network connection and are not establishing mount at reboot https://help.ubuntu.com/community/NFSv4Howto
mount node['nfs']['subtree'] do
  device node['nfs']['nfs_server_ip'] + ":#{node['nfs']['directory']}#{node['nfs']['subtree']}"
  fstype 'nfs'
  options 'rw,noauto'
  pass 0
  action [ :mount, :enable]
end

mount_subtree = <<EOF
#!/bin/sh -e
sleep 5
mount /data
exit 0
EOF

file '/etc/rc.local' do
  content mount_subtree
end

# This is to mount nfs exports on boot via cron
#include_recipe 'cron'
#
#cron_d "mount_nfs_on_boot" do
#  predefined_value '@reboot'
#  command "mount -t nfs #{node['nfs']['nfs_server_ip']}:/exports/data /data -orw"
#  user 'root'
#end