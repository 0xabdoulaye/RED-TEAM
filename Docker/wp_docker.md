```sh
FROM ubuntu:latest

RUN apt update && apt-get install sudo wget nano -y
RUN sudo apt install apache2 \
                 ghostscript \
                 libapache2-mod-php \
                 mysql-server \
                 php \
                 php-bcmath \
                 php-curl \
                 php-imagick \
                 php-intl \
                 php-json \
                 php-mbstring \
                 php-mysql \
                 php-xml \
                 php-zip -y

RUN sudo apt-get remove mysql-client && sudo apt-get install mysql-server
RUN service apache2 start
RUN service mysql start
RUN sudo chown www-data: /var/www/html

WORKDIR /root
RUN wget https://wordpress.org/latest.tar.gz 
RUN sudo tar zx -f latest.tar.gz -C /var/www/html/
COPY wordpress.conf /etc/apache2/sites-available/wordpress.conf
RUN sudo a2ensite wordpress && service apache2 restart && sudo a2enmod rewrite
COPY start-services.sh start-services.sh
RUN chmod +x start-services.sh
RUN wget https://downloads.wordpress.org/plugin/hash-form.1.1.0.zip
RUN wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
RUN chmod +x wp-cli.phar && sudo mv wp-cli.phar /usr/local/bin/wp
EXPOSE 80 3306


CMD ["bash"]


```

```sh
#!/bin/bash

sudo service apache2 --full-restart
sudo service mysql --full-restart
sudo rm /var/www/html/index.html
sudo mv /var/www/html/wordpress/* /var/www/html/
sudo cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php
sudo -u www-data sed -i 's/database_name_here/wordpress/' /var/www/html/wp-config.php && sudo -u www-data sed -i 's/username_here/eviladmin/' /var/www/html/wp-config.php && sudo -u www-data sed -i 's/password_here/Password1/' /var/www/html/wp-config.php && sudo -u www-data sed -i 's/localhost/127.0.0.1:3306/' /var/www/html/wp-config.php


sudo mysql -u root -e "CREATE DATABASE IF NOT EXISTS wordpress; CREATE USER IF NOT EXISTS 'eviladmin'@'localhost' IDENTIFIED BY 'Password1'; GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, ALTER ON wordpress.* TO 'eviladmin'@'localhost'; FLUSH PRIVILEGES;"


wp plugin delete --path=/var/www/html --all --allow-root

wp plugin install hash-form.1.1.0.zip --path=/var/www/html --allow-root
wp plugin activate --all --path=/var/www/html --allow-root




```


```sh
<VirtualHost *:80>
    DocumentRoot /var/www/html/
    <Directory /var/www/html/>
        Options FollowSymLinks
        AllowOverride Limit Options FileInfo
        DirectoryIndex index.php
        Require all granted
    </Directory>
    <Directory /var/www/html/wp-content>
        Options FollowSymLinks
        Require all granted
    </Directory>
</VirtualHost>

```


Database:

```sh
mysql> CREATE DATABASE IF NOT EXISTS wordpress;
Query OK, 1 row affected (0.01 sec)
CREATE USER eviladmin@localhost IDENTIFIED BY 'Password1';

mysql> GRANT SELECT,INSERT,UPDATE,DELETE,CREATE,DROP,ALTER
    -> ON wordpress.*
    -> TO eviladmin@localhost;
Query OK, 1 row affected (0,00 sec)
```

```sh
mysql -u root -e "CREATE DATABASE IF NOT EXISTS wordpress; CREATE USER IF NOT EXISTS 'eviladmin'@'localhost' IDENTIFIED BY 'Password1'; GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, ALTER ON wordpress.* TO 'eviladmin'@'localhost'; FLUSH PRIVILEGES;"

```



```sh
sudo -u www-data sed -i 's/database_name_here/wordpress/' /var/www/html/wp-config.php

sudo -u www-data sed -i 's/username_here/eviladmin/' /var/www/html/wp-config.php

sudo -u www-data sed -i 's/password_here/Password1/' /var/www/html/wp-config.php

sudo -u www-data sed -i 's/localhost/127.0.0.1:3306/' /var/www/html/wp-config.php
```