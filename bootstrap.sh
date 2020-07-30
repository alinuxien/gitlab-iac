#!/usr/bin/env bash

echo "*******************************************"
echo "* [1]: RECONSTRUCTION DE L'INDEX DE MANDB *"
echo "*******************************************"
rm -rf /var/cache/man
mandb -c

echo "*************************************"
echo "* [2]: AJOUT DES DEPOTS NECESSAIRES *"
echo "*************************************"
apt-add-repository --yes --update ppa:ansible/ansible
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
apt-add-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

echo "********************************************************"
echo "* [3]: MISE A JOUR DE LA LISTE DES PAQUETS DISPONIBLES *"
echo "********************************************************"
apt-get update

echo "****************************"
echo "* [4]: INSTALLATION DE VIM *"
echo "****************************"
apt-get install -y vim

echo "********************************"
echo "* [5]: INSTALLATION DE ANSIBLE *"
echo "********************************"
apt-get install -y python software-properties-common ansible
sed -i '/\[defaults\]/a interpreter_python = auto_legacy_silent' /etc/ansible/ansible.cfg
sed -i 's/#allow_world_readable_tmpfiles = False/allow_world_readable_tmpfiles = True/g' /etc/ansible/ansible.cfg

echo "*******************************"
echo "* [6]: INSTALLATION DE DOCKER *"
echo "*******************************"
apt-get install -y apt-transport-https ca-certificates curl gnupg-agent docker-ce docker-ce-cli containerd.io
usermod -aG docker vagrant

echo "*************************************************"
echo "* [7]: INSTALLATION DE TREE ET VIDANGE DU CACHE *"
echo "*************************************************"
apt-get install -y tree
apt-get clean -y

