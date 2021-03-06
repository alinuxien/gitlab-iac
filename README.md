# Bienvenue sur mon projet GitLab CI/CD Infrastructure As Code
Il s'agit d'un projet réalisé en Avril 2021 dans le cadre de ma formation "Expert DevOps" chez OpenClassRooms.

## AVERTISSEMENT
Il s'agit seulement d'un projet d'étude, à NE PAS UTILISER EN PROD  !!!

## Ca fait quoi ?
Ca crée un serveur virtuel GitLab, dont le but ici est d'exploiter les fonctionnalités d'intégration et déploiement continu ( CI/CD ) pour, développer de l'Infrastructure As Code avec Terraform et Ansible.

A l'usage, on va pouvoir créer des projets équipés de pipeline de CI/CD, qui auront accès à un Runner et une Container Registry, sécurisés, ainsi que quelques autres outils...

Pour cela, nous allons créer une VM Virtual Box à l'aide de Vagrant, contenant une distribution Linux Ubuntu et les outils nécessaires.

Ensuite, des scripts et roles Ansible permettent l'installation et la configuration de GitLab, GitLab Runner, et GitLab Container Registry.

Ce projet est une évolution de mon précédent projet basé sur GitLab [disponible ici](https://github.com/alinuxien/vm-gitlab-ansible)

## Ca ressemble à quoi ?
![Vue d'ensemble des Composants](https://github.com/alinuxien/gitlab-iac/blob/700a4c57805661207c75fdd7023de712561e9cab/gitlab%20iac.png)

## Contenu ?
- Un `Vangrantfile` et un script `bootstrap.sh` pour la VM et son provisionning initial.
- Le fichier `inventaire.ini` sert au bon fonctionnement local de Ansible
- Trois fichiers de Playbook Ansible au nom assez explicite : `install-gitlab.yml`, `install-gitlab-runner.yml`, et `install-gitlab-registry.yml`
- Le dossier `roles` qui contient les scripts détaillés des taches Ansible associées
- Le fichier `memo_lancement_playbook.sh` au cas où
- Le fichier `gitlab.example.com.sslv3.txt` sert à la signature du certificat de sécurité du serveur GitLab créé ( pour que le navigateur puisse l'identifier )
- Le fichier `registry.mygta.com.sslv3.txt` sert à la même chose pour la Container Registry, pour que GitLab la considère sécurisée.
 
## J'ai besoin de quoi ?
- Une machine Linux ou MacOS ( ça peut tourner sur Windows mais je ne m'y suis pas encore essayé ) avec au moins 8 Go de RAM et un bon CPU ( au moins 4 coeurs et 8 threads CPU )
- [Virtual Box](https://www.virtualbox.org/) et [Vagrant](https://www.vagrantup.com/downloads) installés sur la machine. 
- Un petit café, car l'ensemble de l'installation peut prendre 30 mns à 1 heure, selon la puissance de votre connexion Internet et de votre machine.

## Comment ça s'utilise ?
Tout se passe au départ dans un terminal :

- faites une copie locale de ce dépot :  `git clone https://github.com/alinuxien/gitlab-iac`
- allez dans le dossier téléchargé : `cd gitlab-iac`
- en premier lieu, ajustez la puissance allouée à la VM. Je conseille d'allouer la moitié de vos threads cpu et au moins 2048 Mo de RAM ( gardez-en pour pouvoir utiliser la machine hôte ). Editez le fichier `Vagrantfile`: par défaut, j'ai mis `v.memory = 16384` ( mais ça peut tourner avec 4096 ) et `v.cpus = 8` ( 4 ça passe aussi ).
- ajoutez le nom d'hôte `mygta.com` à la boucle locale de votre machine hôte, pour pouvoir accéder à GitLab avec une jolie adresse : `https://mygta.com:4443`
- `sudo vim /etc/hosts` 
- sur la ligne contenant `127.0.0.1 localhost`, ajoutez mygta.com ( au final ça donne `127.0.0.1	mygta.com localhost` )
- enregistrez et quittez ce fichier
- lancez la construction de la VM : `vagrant up`
- une fois terminé, vous pouvez vous connecter dessus : `vagrant ssh`
- dans la VM, allez dans le dossier `/vagrant` ( qui est mappé sur votre dossier de travail `gitlab-iac` sur la machine hôte ) : `cd /vagrant`
- lancez l'installation de GitLab : `ansible-playbook -i inventaire.ini install-gitlab.yml`
- lorsque c'est terminé, vous pouvez vous rendre dans votre navigateur préféré à l'adresse `https://mygta.com:4443` 
- la première configuration peut prendre 5 à 10 minutes, pendant lesquelles le navigateur affiche une erreur `Délai de réponse trop long` ou `502 Bad Gateway` servie par GitLab : c'est normal, il suffit de patienter.
- ensuite, il y aura un avertissement de sécurité, traité dans le point suivant
- importez le certificat d'autorité racine ( Root CA ) dans le navigateur / la machine hote ( selon navigateur et OS ) comme digne de confiance. Ce certificat a été généré par Ansible et est maintenant disponible dans votre dossier de travail sous le nom `alinuxien-ca.cer`. J'ai testé cela sur Chrome sur Linux et MacOS, et au final, le petit cadenas à coté de l'adresse confirme que le site est sécurisé.
- une fois passé cette étape de sécurisation, vous allez devoir changer le mot de passe root défini en provisoire pendant l'installation
- pour récupérer le mot de passe provisoire, toujours dans un terminal de la VM : `sudo cat /etc/gitlab/initial_root_password` ( attention, valable 24 heures )
- dans le navigateur web, sur gitlab ( `https://mygta.com:4443` ), vous pouvez maintenant vous connecter en tant que root avec mot de passe provisoire
- vous devez changer le mot de passe de `root` tout de suite : menu Admin -> Users -> Admnistrator -> Edit
- une fois connecté avec le nouveau mot de passe, allez dans le menu Admin -> Runners ( sous `Overview` )
- sur la droite, vous voyez l'`url` et le `token` qui vont nous servir à pour enregistrer le premier runner
- dans le terminal, vous devez installer GitLab Runner avec la commande : `ansible-playbook -i inventaire.ini install-gitlab-runner.yml`
- une fois terminé, vous pouvez enregistrer un runner : `sudo gitlab-runner register`, renseigner url et token, nom du runner au choix ( `shell` ? ), tag `shell`   ( pour pouvoir utiliser les projets suivants simplement ), et surtout de type `shell`
- pour que le Runner puisque accéder correctement à l'instance GitLab, il faut récupérer l'ip de l'instance ( ifconfig ), éditer le fichier `/etc/gitlab-runner/config.toml` pour y ajouter la ligne `extra_hosts = ["mygta.com:10.0.2.15"]` ( `10.0.2.15` étant l'ip de l'instance GitLab récupérée avec ifconfig ), juste après la ligne `executor = "shell"` ( ou après `tls_verify = false` pour un Runner avec un type d'executor autre que Shell ), et enfin relancer le GitLab-Runner : `sudo gitlab-runner restart`
- tant qu'on y est, on va permettre au Runner d'accéder au daemon Docker : `sudo usermod -aG docker gitlab-runner`
- de retour le navigateur web, allez vérifier que le runner est apparu dans la liste
- "délockez" le runner : case `Lock to current projects` *décochée* 
- de retour dans le terminal, installez la Container Registry intégrée à GitLab : `ansible-playbook -i inventaire.ini install-gitlab-registry.yml`
- ajoutez les noms d'hôte `mygta`, `mygta.com` et `registry.mygta.com` dans /etc/hosts ( toujours dans la VM ) : au final ça donne `127.0.2.1 registry.mygta.com mygta.com mygta`
- on va autoriser le daemon Docker à utiliser notre nouvelle Registry. Pour cela, créez un fichier /etc/docker/daemon.json, avec dedans :

`
{ 
  "insecure-registries" : ["registry.mygta.com"] 
}
`
- et on va recharger la configuration du daemon Docker : `sudo systemctl daemon-reload` puis `sudo systemctl restart docker`


Et voilà! L'environnement de travail est prêt, avec GitLab sécurisé accessible depuis un navigateur web, équipé d'un Runner et d'une Container Registry sécurisés, prêt à exécuter des Pipelines, créer et stocker des Containers Docker, faire de l'IAC avec Ansible et Terraform, ...

# Et après ?
Pour tester cet environnement, je vous propose la suite du projet, qui consiste à créer un Cluster Kubernetes K8S from scratch, sur AWS, 
[disponible ici](https://github.com/alinuxien/k8s-aws-iac)

