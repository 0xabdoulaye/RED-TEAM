## Doing More With Docker Images
Dans l'exercice précédent, vous avez extrait des images du Docker Store pour les exécuter dans vos conteneurs. Vous avez ensuite exécuté plusieurs instances et noté comment chaque instance était isolée des autres. Nous avons laissé entendre que cette méthode est utilisée quotidiennement dans de nombreux environnements informatiques de production, mais il est évident que nous avons besoin de quelques outils supplémentaires pour que Docker devienne une véritable source d'économie de temps et d'argent.

La première chose à faire est de trouver comment créer nos propres images. Bien qu'il existe plus de 700 000 images sur le Docker Store, il est presque certain qu'aucune d'entre elles ne correspond exactement à ce que vous utilisez dans votre centre de données aujourd'hui. Même quelque chose d'aussi commun qu'une image d'un système d'exploitation Windows aurait ses propres ajustements avant que vous ne l'exécutiez en production. Dans le premier laboratoire, nous avons créé un fichier appelé "hello.txt" dans l'une de nos instances de conteneur. Si cette instance de notre conteneur Alpine était quelque chose que nous voulions réutiliser dans de futurs conteneurs et partager avec d'autres, nous devrions créer une image personnalisée que tout le monde pourrait utiliser.

Nous commencerons par la forme la plus simple de création d'image, dans laquelle nous livrons simplement l'une de nos instances de conteneur en tant qu'image. Ensuite, nous explorerons une méthode beaucoup plus puissante et utile pour créer des images : ``le Dockerfile.``

Nous verrons ensuite comment obtenir les détails d'une image à travers l'inspection et explorer le système de fichiers pour avoir une meilleure compréhension de ce qui se passe sous le capot.


### Image creation from a container
```sh
$ docker container run -it ubuntu
Unable to find image 'ubuntu:latest' locally
latest: Pulling from library/ubuntu
49b384cc7b4a: Pull complete 
Digest: sha256:3f85b7caad41a95462cf5b787d8a04604c8262cdcdf9a472b8c52ef83375fe15
Status: Downloaded newer image for ubuntu:latest
root@870d9247f85b:/# 
```
Bien installer, ici comme le container n'existait pas, docker a saisi le container dans le docker Hub et puis l'a installer. Alors je lance ma machine
```
$ docker run -it ubuntu bash
root@69a2f2cf299d:/# id
uid=0(root) gid=0(root) groups=0(root)
```

A l'interieur on peux lancer des commandes qu'on veux comme sur Linux ordinaire.

```sh
root@69a2f2cf299d:/# apt-get update
Fetched 22.2 MB in 3s (7168 kB/s)                          
Reading package lists... Done

```
Pour customizer un peu j'installe `figlet`

```sh
root@69a2f2cf299d:/# apt-get install net-tools
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done

root@69a2f2cf299d:/# figlet "hacked"
 _                _            _ 
| |__   __ _  ___| | _____  __| |
| '_ \ / _` |/ __| |/ / _ \/ _` |
| | | | (_| | (__|   <  __/ (_| |
|_| |_|\__,_|\___|_|\_\___|\__,_|
                                 
```

Imaginons maintenant que cette nouvelle application figlet soit très utile et que vous souhaitiez la partager avec le reste de votre équipe. Vous pourriez leur dire de faire exactement ce que vous avez fait ci-dessus et d'installer figlet dans leur propre conteneur, ce qui est assez simple dans cet exemple. Mais s'il s'agissait d'une application réelle pour laquelle vous venez d'installer plusieurs paquets et de passer par un certain nombre d'étapes de configuration, le processus pourrait s'avérer fastidieux et sujet aux erreurs. Il serait plus simple de créer une image que vous pouvez partager avec votre équipe.
- Pour commencer, nous devons obtenir l'ID de ce conteneur à l'aide de la commande ls (n'oubliez pas l'option -a car les conteneurs qui ne fonctionnent pas ne sont pas retournés par la commande ls).
```sh
$ docker container ls -a
CONTAINER ID   IMAGE           COMMAND       CREATED          STATUS                      PORTS     NAMES
69a2f2cf299d   ubuntu:latest   "bash"        22 minutes ago   Exited (0) 2 minutes ago              reverent_roentgen
870d9247f85b   ubuntu          "/bin/bash"   23 minutes ago   Exited (0) 23 minutes ago             clever_shaw
```

- Maintenant, pour créer une image, nous devons "commit" ce conteneur. Commit crée une image localement sur le système qui exécute le moteur Docker. Exécutez la commande suivante, en utilisant l'ID du conteneur que vous avez récupéré, afin de valider le conteneur et de créer une image à partir de celui-ci.

```sh
$ docker container commit 69a2f2cf299d
sha256:35e019a2ca60def16ea025452ee958ec680b62cbd58373d88c6f4256d76cab2a
$ docker images
REPOSITORY   TAG       IMAGE ID       CREATED          SIZE
<none>       <none>    35e019a2ca60   11 seconds ago   114MB
ubuntu       latest    bf3dc08bfed0   10 days ago      76.2MB

$ docker image tag 35e019a2ca60 custom
$ docker images
REPOSITORY   TAG       IMAGE ID       CREATED         SIZE
custom       latest    35e019a2ca60   2 minutes ago   114MB
ubuntu       latest    bf3dc08bfed0   10 days ago     76.2MB
```

Alors la je viens de donner un tag a mon image que je viens juste de creer a partir du commit

```sh
$ docker container run custom figlet "Docker"
 ____             _             
|  _ \  ___   ___| | _____ _ __ 
| | | |/ _ \ / __| |/ / _ \ '__|
| |_| | (_) | (__|   <  __/ |   
|____/ \___/ \___|_|\_\___|_|   
                                
```

Maintenant les outils que j'avais deja installer sont pas supprimer de la Box Docker.

## Image creation using a Dockerfile
Au lieu de créer une image binaire statique, nous pouvons utiliser un fichier appelé `Dockerfile` pour créer une image. Le résultat final est essentiellement le même, mais avec un Dockerfile, nous fournissons les instructions pour construire l'image, plutôt que simplement les fichiers binaires bruts. Ceci est utile car il devient beaucoup plus facile de gérer les changements, en particulier lorsque vos images deviennent plus grandes et plus complexes.
- voici mon Dockerfile
```sh
FROM custom
RUN apt-get update && apt-get install python3 -y
COPY main.py /root
WORKDIR /root
CMD ["python3", "main.py"]
```

J'ai creer un dockerfile a partir de mon image recente qui s'appelle `custom` et qui va lancer mon `hello world` python quand je l'execute

```sh
$ docker image build -t hello_world .
[+] Building 0.9s (9/9) FINISHED                                              docker:default
 => [internal] load build definition from Dockerfile                                    0.0s
 => => transferring dockerfile: 158B                                                    0.0s
 => [internal] load .dockerignore                                                       0.0s
 => => transferring context: 2B                                                         0.0s
 => [internal] load metadata for docker.io/library/custom:latest                        0.0s
 => [1/4] FROM docker.io/library/custom                                                 0.0s
 => [internal] load build context                                                       0.0s
 => => transferring context: 28B                                                        0.0s
 => CACHED [2/4] RUN apt-get update && apt-get install python3 -y                       0.0s
 => [3/4] COPY main.py /root                                                            0.1s
 => [4/4] WORKDIR /root                                                                 0.0s
 => exporting to image                                                                  0.7s 
 => => exporting layers                                                                 0.7s
 => => writing image sha256:f7896ce0df3412792dacc51601ad59083d2ff88a4110ab4c07dda4b328  0.0s
 => => naming to docker.io/library/hello_world   

```

### What just happened?
Nous avons créé deux fichiers : notre code d'application (main.py) est un simple bout de code python qui imprime un message. Et le fichier Dockerfile contient les instructions pour que le moteur Docker crée notre conteneur personnalisé. Ce fichier Docker fait ce qui suit :

- Spécifie une image de base à partir de laquelle tirer - l'image `custom` que nous avons utilisée dans les laboratoires précédents.
Ensuite, il exécute deux commandes (`apt-get update && apt-get install python3 -y`) à l'intérieur de ce conteneur qui installe python3.
- Ensuite, nous lui avons demandé de `COPIER` les fichiers de notre répertoire de travail dans le conteneur. Le seul fichier que nous avons pour l'instant est notre `main.py`.
- Ensuite, nous spécifions le `WORKDIR` - le répertoire que le conteneur doit utiliser lorsqu'il démarre
- Enfin, nous avons donné à notre conteneur une commande (CMD) à exécuter lorsque le conteneur démarre.