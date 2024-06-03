Let's create a wordpress Lab

- je commence par download `FROM bitnami/wordpress:6-debian-12`


```sh
# Copyright Broadcom, Inc. All Rights Reserved.
# SPDX-License-Identifier: APACHE-2.0

version: '2'
services:
  mariadb:
    image: docker.io/bitnami/mariadb:11.3
    volumes:
      - 'mariadb_data:/bitnami/mariadb'
    environment:
      # ALLOW_EMPTY_PASSWORD is recommended only for development.
      - ALLOW_EMPTY_PASSWORD=yes
      - MARIADB_USER=bn_wordpress
      - MARIADB_DATABASE=bitnami_wordpress
  wordpress:
    image: docker.io/bitnami/wordpress:6
    ports:
      - '80:8080'
      - '443:8443'
    volumes:
      - 'wordpress_data:/bitnami/wordpress'
    depends_on:
      - mariadb
    environment:
      # ALLOW_EMPTY_PASSWORD is recommended only for development.
      - ALLOW_EMPTY_PASSWORD=yes
      - WORDPRESS_DATABASE_HOST=mariadb
      - WORDPRESS_DATABASE_PORT_NUMBER=3306
      - WORDPRESS_DATABASE_USER=bn_wordpress
      - WORDPRESS_DATABASE_NAME=bitnami_wordpress
volumes:
  mariadb_data:
    driver: local
  wordpress_data:
    driver: local

```
en changeant le `build: .` je specifie que l'image sera dans le Dockerfile
et ensuite creer un `Dockerfile` pour les commandes automatique

```sh
FROM wordpress

RUN apt update

COPY hash-form.php /var/www/html/wp-content/plugins
```
j'ajoute un user avec `useradd`

```sh
FROM wordpress

RUN apt update && apt install sudo && install less

WORKDIR /root
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
RUN chmod +x wp-cli.phar
RUN sudo mv wp-cli.phar /usr/local/bin/wp
RUN chown www-data:www-data /var/www/html/ -R
RUN useradd -d /home/hacker -m -p hacker -s /bin/bash hacker && \
    echo "hacker:Password1" | chpasswd


WORKDIR /var/www/html/wp-content/plugins
RUN wp plugin delete --all --allow-root
RUN curl -O https://downloads.wordpress.org/plugin/hash-form.1.1.0.zip
RUN wp plugin install hash-form.1.1.0.zip --allow-root
RUN wp plugin activate hash-form --allow-root


WORKDIR /
RUN chmod +s /usr/bin/chmod
COPY root.txt /root

```

faire un `docker-compose down` pour arreter les conteneurs deja creer, puis recreer avec `docker-compose up -d --build`


```sh
$ docker-compose build
[+] Building 2.2s (12/12) FINISHED   

$ docker-compose up -d
[+] Building 0.0s (0/0)                                                                                 docker:default
[+] Running 3/3
 ✔ Network root_default        Created                                                                            0.1s 
 ✔ Container root-db-1         Started                                                                            0.1s 
 ✔ Container root-wordpress-1  Started                                                                            0.1s 
[node1] (local) root@192.168.0.8 ~
$ docker ps
CONTAINER ID   IMAGE            COMMAND                  CREATED         STATUS         PORTS                  NAMES
a02fb3c4c7e9   mysql:8.0        "docker-entrypoint.s…"   4 seconds ago   Up 3 seconds   3306/tcp, 33060/tcp    root-db-1
1970840d1516   root-wordpress   "docker-entrypoint.s…"   4 seconds ago   Up 3 seconds   0.0.0.0:8080->80/tcp   root-wordpress-1
[node1] (local) root@192.168.0.8 ~
$ docker exec -it root-wordpress-1 bash
root@1970840d1516:/var/www/html# ls /home
hacker
root@1970840d1516:/var/www/html# 


```

I will add wp-cli and activate the plugin

Here is my version of `Dockerfile`

```sh
FROM wordpress:latest

RUN apt update -y && apt install sudo -y && apt install less -y

WORKDIR /root
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
RUN chmod +x wp-cli.phar
RUN sudo mv wp-cli.phar /usr/local/bin/wp
RUN chown www-data:www-data /var/www/html/ -R
RUN useradd -d /home/hacker -m -p hacker -s /bin/bash hacker && \
    echo "hacker:Password1" | chpasswd



WORKDIR /
RUN chmod +s /usr/bin/chmod
COPY root.txt /root
COPY .hidden > /home/hacker/


WORKDIR /root
COPY entrypoint.sh /root
RUN chmod +x /root/entrypoint.sh
CMD ["/root/entrypoint.sh"]

```


`entrypoint.sh`

```sh
#!/bin/bash
set -e

cd /var/www/html

wp plugin delete --all --allow-root
curl -O https://downloads.wordpress.org/plugin/hash-form.1.1.0.zip
wp plugin install hash-form.1.1.0.zip --allow-root
wp plugin activate hash-form --allow-root

# Exécuter l'entrée par défaut de WordPress
exec docker-entrypoint.sh "$@"


```


```sh
FROM wordpress:latest

RUN apt update -y && apt install sudo -y && apt install less -y

WORKDIR /root
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
RUN chmod +x wp-cli.phar
RUN sudo mv wp-cli.phar /usr/local/bin/wp
RUN chown www-data:www-data /var/www/html/ -R
RUN useradd -d /home/hacker -m -p hacker -s /bin/bash hacker && \
    echo "hacker:Password1" | chpasswd



WORKDIR /
RUN chmod +s /usr/bin/chmod
COPY root.txt /root
RUN echo "hacker:Password1" > /home/hacker/.hidden


WORKDIR /root
COPY entrypoint.sh /root
RUN chmod +x /root/entrypoint.sh
CMD ["/root/entrypoint.sh"]
EXPOSE 8080


```