# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

%w[ vagrant-berkshelf vagrant-ohai ].each do |plugin|
  unless Vagrant.has_plugin?(plugin)
    raise 'Reqired vagrant plugin not found. Please run "vagrant plugin install ' + plugin + '"'
  end
end

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.synced_folder ".", "/vagrant"

  config.vm.provider "virtualbox" do |vb|
    vb.gui = true
    vb.customize ["modifyvm", :id, "--ioapic", "on"]
    vb.customize ["modifyvm", :id, "--cpus", "2"]
    vb.customize ["modifyvm", :id, "--memory", "2048"]
  end

  time = Time.new
  hostpostfix = "-#{time.strftime('%Y%m%d%H%M%S')}-#{ENV['USER'].gsub('_','-').gsub(' ','-')}"

  config.vm.define "webapp", primary: true do |webapp|
    webapp.vm.hostname = "webapp" + hostpostfix
    webapp.vm.box = "joelhandwell/ubuntu_precise64_vbox_4_3_20"
    webapp.vm.synced_folder "websites", "/websites", owner: "www-data", group: "www-data", mount_options: ["dmode=751,fmode=777"]
    webapp.vm.network "private_network", ip: "192.168.33.10"
    webapp.ohai.primary_nic = "eth1"
    webapp.vm.provision "chef_zero" do |chef|
      chef.cookbooks_path = "cookbooks"
      chef.roles_path = "roles"
      chef.nodes_path = "nodes"
      chef.environments_path = "environments"
      chef.environment = "development"
      chef.data_bags_path = "data_bags"
      chef.add_role "w_common_role"
      chef.add_role "w_varnish_role"
      chef.add_role "w_apache_role"
      chef.add_role "w_memcached_role"
      chef.add_role "w_percona_role"
    end
  end

  config.vm.define "testkitchen", autostart: false do |tk|
    tk.vm.hostname = "testkitchen" + hostpostfix
    tk.vm.box = "joelhandwell/ubuntu12testkitchen"
    tk.vm.synced_folder "testkitchen_ssh", "/testkitchen_ssh", mount_options: ["dmode=700,fmode=600"]
  end
end
