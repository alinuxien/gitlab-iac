# Bienvenue sur mon projet GitLab CI/CD
Il s'agit d'un projet réalisé en Aout 2020 dans le cadre de ma formation "Expert DevOps" chez OpenClassRooms.

## Ca fait quoi ?
Ca crée un serveur virtuel GitLab, dont le but ici est d'exploiter les fonctionnalités d'intégration et déploiement continu ( CI/CD ) pour, par exemple, générer automatiquement les pages d'un site web statique à l'aide de [Pelican](https://docs.getpelican.com/en/4.5.0/index.html).

A l'usage, vous écrivez les articles de votre blog en MarkDown, et les pages html seront générées et déposées sur le dépôt GitHub défini, consultables en ligne sur GitHub Pages ( [dans mon cas ici](https://alinuxien.github.io/pelican/) ) 

Pour cela, nous allons créer une VM Virtual Box à l'aide de Vagrant, contenant une distribution Linux Ubuntu et les outils nécessaires.

Ensuite, des scripts et roles Ansible permettent l'installation et la configuration de GitLab et de GitLab Runner.

Ce projet se base sur un autre projet fait le mois dernier et dédié à Vagrant, [disponible ici](https://github.com/alinuxien/Vagrant)

## Contenu ?
- Un `Vangrantfile` et un script `bootstrap.sh` pour la VM.
- Le fichier `inventaire.ini` sert au bon fonctionnement local de Ansible
- Trois fichiers de Playbook Ansible au nom assez explicite : `install-gitlab.yml`, `install-gitlab-runner.yml`, et `install-pelican.yml`
- Le dossier `roles` qui contient les scripts détaillés des taches Ansible associées
- Le fichier `memo_lancement_playbook.sh` au cas où
- Le fichier `gitlab.example.com.sslv3.txt` sert à la signature du certificat de sécurité du serveur GitLab créé ( pour que le navigateur puisse l'identifier )
 
## J'ai besoin de quoi ?
- Une machine Linux ou MacOS ( ça peut tourner sur Windows mais je ne m'y suis pas encore essayé ) avec au moins 8 Go de RAM et un bon CPU ( au moins 4 coeurs et 8 threads CPU )
- [Virtual Box](https://www.virtualbox.org/) et [Vagrant](https://www.vagrantup.com/downloads) installés sur la machine. 
- Un petit café, car l'ensemble de l'installation peut prendre 30 mns à 1 heure, selon la puissance de votre connexion Internet et de votre machine.

## Comment ça s'utilise ?
Tout se passe au départ dans un terminal :

- faites une copie locale de ce dépot :  `git clone https://github.com/alinuxien/vm-gitlab-ansible.git`
- allez dans le dossier téléchargé : `cd vm-gitlab-ansible`
- en premier lieu, ajustez la puissance allouée à la VM. Je conseille d'allouer la moitié de vos threads cpu et au moins 2048 Mo de RAM ( gardez-en pour pouvoir utiliser la machine hôte ). Editez le fichier `Vagrantfile`: par défaut, j'ai mis `v.memory = 4096` ( suffisant ) et `v.cpus = 4` ( 6 ou 8 c'est encore mieux ).
- ajoutez le nom d'hôte `gitlab.example.com` à la boucle locale de votre machine hôte, pour pouvoir accéder à GitLab avec une jolie adresse : `https://gitlab.example.com:4443`
- `sudo vim /etc/hosts` 
- sur la ligne contenant `127.0.0.1 localhost`, ajoutez gitlab.example.com ( au final ça donne `127.0.0.1	gitlab.example.com localhost` )
- enregistrez et quittez ce fichier
- lancez la construction de la VM : `vagrant up`
- une fois terminé, vous pouvez vous connecter dessus : `vagrant ssh`
- dans la VM, allez dans le dossier `/vagrant` ( qui est mappé sur votre dossier de travail `vm-gitlab-ansible` ) : `cd /vagrant`
- lancez l'installation de GitLab : `ansible-playbook -i inventaire.ini install-gitlab.yml`
- lorsque c'est terminé, vous pouvez vous rendre dans votre navigateur préféré à l'adresse `https://gitlab.example.com:4443` 
- la première configuration peut prendre 5 à 10 minutes, pendant lesquelles le navigateur affiche une erreur `Délai de réponse trop long` ou `502 Bad Gateway` servie par GitLab : c'est normal, il suffit de patienter.
- ensuite, il y aura un avertissement de sécurité, traité dans le point suivant
- importez le certificat d'autorité racine ( Root CA ) dans le navigateur / la machine hote ( selon navigateur et OS ) comme digne de confiance. Ce certificat a été généré par Ansible et est maintenant disponible dans votre dossier de travail sous le nom `alinuxien-ca.cer`. J'ai testé cela sur Chrome sur Linux et MacOS, et au final, le petit cadenas à coté de l'adresse confirme que le site est sécurisé.
- une fois passé cette étape de sécurisation, sur votre site GitLab, vous pouvez définir un mot de passe ( pour l'utilisateur `root` ) et ensuite vous connecter en tant que `root`.
- allez dans `Configure GitLab` en bas, puis `Runners` dans le menu à gauche ( sous `Overview` )
- sur la droite, vous voyez l'`url` et le `token` qui vont nous servir à pour enregistrer le premier runner
- dans le terminal, vous devez installer GitLab Runner avec la commande : `ansible-playbook -i inventaire.ini install-gitlab-runner.yml`
- une fois terminé, vous pouvez enregistrer un runner : `sudo gitlab-runner register`, renseigner url et token, nom du runner au choix ( `shell` ? ), et surtout de type `shell`
- pour que le Runner puisque accéder correctement à l'instance GitLab, il faut récupérer l'ip de l'instance ( ifconfig ), éditer le fichier `/etc/gitlab-runner/config.toml` pour y ajouter la ligne `extra_hosts = ["gitlab.example.com:10.0.2.15"]` ( `10.0.2.15` étant l'ip de l'instance GitLab récupérée avec ifconfig ), juste après la ligne `executor = "shell"` ( ou après `tls_verify = false` pour un Runner avec un type d'executor autre que Shell ), et enfin relancer le GitLab-Runner : `sudo gitlab-runner restart`
- de retour le navigateur web, allez vérifier que le runner est apparu dans la liste
- "délockez" le runner : case `Lock to current projects` *décochée* 
- de retour une dernière fois dans le terminal, installez Pelican : `ansible-playbook -i inventaire.ini install-pelican.yml`

Et voilà! L'environnement de travail est prêt à mouliner et expédier du markdown...

# Et après ?
Comme prévu, vous pouvez gérer un blog écrit en markdown qui va être transformé automatiquement en HTML par GitLab et Pelican et publié sur votre dépôt GitHub Pages.
[Un exemple est disponible ici](https://gitlab.com/alinuxien/pelican)

