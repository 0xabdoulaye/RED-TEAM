## Introduction

Docker est une plateforme de développement logiciel pour la virtualisation avec plusieurs Operasystèmes fonctionnant sur le même hôte. Cela permet de séparer l'infrastructure et les applications afin de fournir des logiciels rapidement. Contrairement aux hyperviseurs, qui sont utilisés pour créer des VM (machines virtuelles), la virtualisation dans Docker est effectuée au niveau du système, également appelé conteneurs Docker.



### First Alpine Linux Containers

- **Concepts in this exercise:**
- Docker engine
- Containers & images
- Image registries and Docker Hub
- Container isolation

Pour lancer notre premiere container on liste d'abord nos container
```sh
$ docker container list
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES
[node1] (local) root@192.168.0.18 ~


$ docker container run hello-world
Unable to find image 'hello-world:latest' locally
latest: Pulling from library/hello-world
c1ec31eb5944: Pull complete 
Digest: sha256:a26bff933ddc26d5cdf7faa98b4ae1e3ec20c4985e6f87ac0973052224d24302
Status: Downloaded newer image for hello-world:latest


```
Et voilà : votre premier conteneur. La sortie du conteneur `hello-world` vous explique un peu ce qui vient de se passer. Essentiellement, le moteur Docker exécuté dans votre terminal a essayé de trouver une image nommée hello-world. Comme vous venez de démarrer, il n'y a pas d'images stockées localement (`Unable to find image...`), le moteur Docker va donc dans son registre Docker par défaut, qui est Docker Hub, pour chercher une image nommée "hello-world". Il y trouve l'image, l'extrait et l'exécute dans un conteneur. La seule fonction de hello-world est de produire le texte que vous voyez dans votre terminal, après quoi le conteneur se termine.


- Maintenant je vais lancer un Linux(Alpine)

```sh
$ docker pull alpine
Using default tag: latest
latest: Pulling from library/alpine
4abcf2066143: Pull complete 
Digest: sha256:c5b1261d6d3e43071626931fc004f70149baeba2c8ec672bd4f27761f8e1ad6b
Status: Downloaded newer image for alpine:latest
docker.io/library/alpine:latest

$ docker images
REPOSITORY    TAG       IMAGE ID       CREATED         SIZE
alpine        latest    05455a08881e   3 months ago    7.38MB
hello-world   latest    d2c94e258dcb   12 months ago   13.3kB

```


```sh
$ docker container run -it alpine /bin/sh
/ # id
uid=0(root) gid=0(root) groups=0(root),1(bin),2(daemon),3(sys),4(adm),6(disk),10(wheel),11(floppy),20(dialout),26(tape),27(video)
/ # whoami
root
/ # ls 
bin    dev    etc    home   lib    media  mnt    opt    proc   root   run    sbin   srv    sys    tmp    usr    var
/ # ls root
/ # 

$ docker container ls -la
CONTAINER ID   IMAGE     COMMAND     CREATED              STATUS                      PORTS     NAMES
2e703f6a6a76   alpine    "/bin/sh"   About a minute ago   Exited (0) 10 seconds ago             heuristic_lehmann


```