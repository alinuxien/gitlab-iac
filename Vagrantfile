# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
	config.vm.box = "hashicorp/bionic64"
	config.vm.box_version = "1.0.282"
	config.vm.hostname = "gitlab"
        config.vm.network "forwarded_port", guest: 80, host: 80
        config.vm.network "forwarded_port", guest: 443, host: 443
#	config.vm.synced_folder "/srv/gitlabvm/config", "/etc/gitlab", owner: "root", group: "root"
#        config.vm.synced_folder "/srv/gitlabvm/logs", "/var/log/gitlab", owner: "root", group: "root"
#	config.vm.synced_folder "/srv/gitlabvm/data", "/var/opt/gitlab", owner: "root", group: "root"
	config.vm.provider "virtualbox" do |v|
		v.name = "gitlab"
                v.memory = 4096 
                v.cpus = 2
	end
	config.vm.provision :shell, path: "bootstrap.sh"
end

