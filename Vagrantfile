# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
	config.vm.box = "hashicorp/bionic64"
	config.vm.box_version = "1.0.282"
	config.vm.define "gitlab"
	config.vm.hostname = "gitlab.example.com"
        config.vm.network "forwarded_port", guest: 80, host: 8080
        config.vm.network "forwarded_port", guest: 4443, host: 4443
	config.vm.provider "virtualbox" do |v|
		v.name = "gitlab"
                v.memory = 8196 
                v.cpus = 8
	end
	config.vm.provision :shell, path: "bootstrap.sh"
end

