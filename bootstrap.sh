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
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"

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
apt-get install -y python3.8 software-properties-common ansible
sed -i '/\[defaults\]/a interpreter_python = auto_legacy_silent' /etc/ansible/ansible.cfg
#sed -i 's/#allow_world_readable_tmpfiles = False/allow_world_readable_tmpfiles = True/g' /etc/ansible/ansible.cfg

echo "*******************************"
echo "* [6]: INSTALLATION DE DOCKER *"
echo "*******************************"
apt-get install -y apt-transport-https ca-certificates curl gnupg-agent docker-ce docker-ce-cli containerd.io
usermod -aG docker vagrant

echo "**********************************"
echo "* [7]: INSTALLATION DE TERRAFORM *"
echo "**********************************"
apt-get install -y terraform
sudo -u vagrant terraform -install-autocomplete

echo "**************************************"
echo "* [8]: INSTALLATION DE AMAZON CLI V2 *"
echo "**************************************"
apt-get install -y unzip
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install

echo "*************************************************"
echo "* [9]: INSTALLATION DE TREE ET VIDANGE DU CACHE *"
echo "*************************************************"
apt-get install -y tree
apt-get clean -y

echo "*****************************************************************************"
echo "* [10]: INSTALLATION DES OUTILS REQUIS POUR DEPLOYER K8S : CFSSL ET KUBECTL *"
echo "*****************************************************************************"
apt-get install -y golang-cfssl
wget https://storage.googleapis.com/kubernetes-release/release/v1.21.0/bin/linux/amd64/kubectl
chmod +x kubectl
mv kubectl /usr/local/bin/

echo "********************************"
echo "* [11]: INSTALLATION DE PACKER *"
echo "********************************"
apt-get install -y packer


