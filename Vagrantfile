# -*- mode: ruby -*-
# vi: set ft=ruby :
Vagrant.configure("2") do |config|
  config.vm.define "gta" do |gta|
    gta.vm.box = "hashicorp/bionic64"
    gta.vm.box_version = "1.0.282"
    gta.vm.hostname = "mygta.com"
    gta.vm.network "forwarded_port", guest: 22, host: 2222, id: "ssh", disabled: false
    gta.vm.network "forwarded_port", guest: 4443, host: 4443
    gta.vm.provider "virtualbox" do |v|
      v.name = "gta"
      v.memory = 16384
      v.cpus = 8
      v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
      v.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
      v.customize [ "guestproperty", "set", :id, "/VirtualBox/GuestAdd/VBoxService/--timesync-set-threshold", 10000 ]
    end
    gta.vm.provision :shell, path: "bootstrap.sh"
  end
end

