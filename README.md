Setup
=====

A installer de préférence sur un serveur dédié.

```shell
$ sudo apt install docker.io python3
$ git clone git@github.com:ssbx/ansible-control-node-template.git
$ cd ansible-control-node-template
$ make pyvenv_init
```

Activation
==========

Activer l'environnement python:

```sh
$ source activate
```

L'activer automatiquement au login:

```sh
$ echo "source $(pwd)/activate" >> $HOME/.bashrc
```

Créer un environnement d'execution
==================================

Pour en créer un nouvel environnement modifier les numéros de versions dans 
le makefile (VERSION_MAJ/VERSION_MIN).

Faire les modifs désirées sur le fichier *ansible-exec-env.yaml* (voir la 
[doc ansible "Execution environment definition"](https://ansible.readthedocs.io/projects/builder/en/latest/definition/)).

Lancer le build:

```sh
$ make exec-env_build
```

Verifier la présence de l'image dans la liste d'images docker et 
ansible-navigator, et faire le menage:

```sh
$ docker images
$ ansible-navigator images --mode interactive
```

Faire le ménage:

```sh
$ make exec-env_clean
$ docker system prune
```

Pour en faire l'environnement par defaut, editer le fichier de conf 
*ansible-navigator.yaml*.

Edition de fichier encodés avec ansible-vault
=============================================

Les données sensibles sont encodées dans un fichier a l'aide d'un mot de passe.
Les données encodées sont suivie sur git, le mot de passe doit rester local.
Le mot de passe du vault est contenu dans *ansible-vault.password*. Il est 
ignoré par .gitignore.

Création du fichier encodé:

```sh
$ ansible-vault create inventory/group_vars/all.yaml
Mot de passe:
Confrimation mot de passe:
$ echo "mon mot de passe" > ansible-vault.password
$ chmod go-r ansible-vault.password
```

Configuration a ajouter à ~/.vimrc pour sécuriser l'edition de fichier vaults
par vim:

```vimrc
" secure config recommandé pour l'utilisation de ansible-vault
set nobackup            
set noswapfile
set nowritebackup
set viminfo=
set clipboard=
```

Configuration pour test minimal
===============================

Editer *inventory/hosts.yaml* pour pointer vers un élément réseau. L'exemple
utilise un élément réseau cisco.

Ajouter le fichier encodé *inventory/group_vars/all.yaml* pour renseigner les
identifiants de connexion avec la commande:

```sh
$ ansible-vault edit inventory/group_vars/all.yaml
```

Ça doit ressembler à ça:

```yaml
cisco_user_1: nomutilisateur
cisco_password_1: password
```

Lancer le playbook de test
==========================

A propos d' *ansible-navigator run*:
- la plupars de sa conf est lue des fichiers "activate", "ansible-navigator.yaml", 
"ansible.cfg"
- monte automatiquement ~/.ssh sur le conteneur
- accepte toutes les options d' *ansible-playbook*

Lancement avec contexte d'execution par defaut:

```sh
$ ansible-navigator run playbooks/ping.yaml -l my_host_group
```

Avec contexte d'execution specifique:

```sh
$ ansible-navigator run playbooks/ping.yaml --eei reseau_ee:1.2
```

