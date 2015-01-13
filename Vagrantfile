# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.synced_folder ".", "/vagrant"

  config.vm.provider "virtualbox" do |vb|
    vb.gui = true
    vb.customize ["modifyvm", :id, "--ioapic", "on"]
    vb.customize ["modifyvm", :id, "--cpus", "2"]
    vb.customize ["modifyvm", :id, "--memory", "2048"]
  end

  time = Time.new
  hostpostfix = "-#{time.strftime('%Y%m%d%H%M%S')}-#{ENV['USER'].gsub('_','-')}"

  config.vm.define "webapp", primary: true do |webapp|
    webapp.vm.hostname = "webapp" + hostpostfix
    webapp.vm.box = "joelhandwell/ubuntu_trusty64_vbox_4_3_20"
    webapp.vm.provision "chef_zero" do |chef|
      chef.cookbooks_path = "cookbooks"
      chef.roles_path = "roles"
      chef.nodes_path = "nodes"
      chef.environments_path = "environments"
      chef.environment = "development"
      chef.add_role "w_common_role"
      chef.add_role "w_varnish_role"
      chef.add_role "w_apache_role"
      chef.add_role "w_percona_role"
    end
  end

  config.vm.define "testkitchen", autostart: false do |tk|
    tk.vm.hostname = "testkitchen" + hostpostfix
    tk.vm.box = "joelhandwell/ubuntu12testkitchen"
    tk.vm.synced_folder "testkitchen_ssh", "/testkitchen_ssh", mount_options: ["dmode=700,fmode=600"]
  end
end
