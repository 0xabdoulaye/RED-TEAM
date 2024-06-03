Ici je vais Setup un Ubuntu et aussi un BoidCMS a l'interieur

je commence par un PULL request:

```sh
docker pull ubuntu




```


```
FROM ubuntu:latest
RUN apt-get update -y && apt-get install git -y && apt-get install nginx -y && apt-get install nano -y && apt-get install sudo -y && apt-get install wget -y && sudo a2enmod rewrite && service apache2 restart
CMD ["nginx", " "]
EXPOSE 80

WORKDIR /root
COPY wordpress_install.sh wordpress_install.sh
RUN bash chmod +x wordpress_install.sh && bash wordpress_install.sh
RUN sudo usermod -d /var/lib/mysql/ mysql && sudo service mysql restart

RUN sudo mkdir -p /var/www/html/src && sudo wget http://wordpress.org/latest.tar.gz && sudo tar -xvf latest.tar.gz && sudo mv wordpress/* ../ && sudo rm -rf src && sudo chown -R www-data:www-data /var/www/html/
```

