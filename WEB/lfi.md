## PHP Wrappers
Les wrappers PHP font partie des fonctionnalités de PHP qui permettent aux utilisateurs d'accéder à différents flux de données. Les wrappers peuvent également accéder ou exécuter du code via des protocoles PHP intégrés, ce qui peut entraîner des risques de sécurité importants s'ils ne sont pas correctement gérés.

Par exemple, une application vulnérable au LFI peut inclure des fichiers basés sur une entrée fournie par l'utilisateur sans validation suffisante. Dans ce cas, les attaquants peuvent utiliser le filtre `php://filter`. Ce filtre permet à un utilisateur d'effectuer des opérations de modification de base sur les données avant qu'elles ne soient lues ou écrites. Par exemple, si un attaquant veut encoder le contenu d'un fichier inclus comme `/etc/passwd` en base64. Ceci peut être réalisé en utilisant le filtre de conversion `convert.base64-encode` du wrapper. La charge utile finale sera alors `php://filter/convert.base64-encode/resource=/etc/passwd`

## Data Wrappers
Le wrapper de flux de données est un autre exemple de la fonctionnalité de wrapper de PHP. Le wrapper `data://` permet d'intégrer des données en ligne. Il est utilisé pour intégrer de petites quantités de données directement dans le code de l'application.
par exemple: `data:text/plain,<?php phpinfo(); ?>` on fais du URL encode


```data:text/plain,<?=`$_GET[0]`?>```

En faisant ceci :
```
http://10.10.152.222/playground.php?page=data:text/plain,%3C?=`$_GET[0]`?%3E&0=id
 uid=33(www-data) gid=33(www-data) groups=33(www-data),27(sudo) 
```


### Challenge
Quand j'essaie de faire un LFI dans `http://10.10.152.222/lfi.php?page=%2Fetc%2Fpasswd` on me dit ` You are not allowed to go outside /var/www/html/ directory!` So maintenant je vais faire dans ce repertoire et faire un bypass

```
http://10.10.152.222/lfi.php?page=/var/www/html/..//..//..//..//..//..//etc/passwd
```

Voici le code :

```php
           
function containsStr($str, $subStr){
    return strpos($str, $subStr) !== false;
}

if(isset($_GET['page'])){
    if(!containsStr($_GET['page'], '../..') && containsStr($_GET['page'], '/var/www/html')){
        include $_GET['page'];
    }else{ 
        echo 'You are not allowed to go outside /var/www/html/ directory!';
    }
}
```
La fonction PHP `containsStr` vérifie si une sous-chaîne existe dans une chaîne de caractères. La condition `if` vérifie deux choses. Premièrement, si `$_GET['page']` ne contient pas la sous-chaîne ``../..`` et si `$_GET['page']` contient la sous-chaîne `/var/www/html`, cependant, ``..//..//`` contourne ce filtre parce qu'il navigue encore effectivement vers le haut de deux répertoires, de manière similaire à ``../../.`` Il ne correspond pas exactement au motif bloqué ``../...`` en raison des barres obliques supplémentaires. Les barres obliques supplémentaires // dans ``..//..//`` sont traitées comme une seule barre oblique par le système de fichiers. Cela signifie que ``../../ `` et ``..//..//`` sont fonctionnellement équivalents en termes de navigation dans les répertoires, mais que seul ../../ est explicitement filtré par le code.

## Bypass
Les techniques d'encodage sont souvent utilisées pour contourner les filtres de sécurité de base que les applications web peuvent avoir mis en place. Ces filtres recherchent généralement des séquences évidentes de traversée de répertoire telles que ``../.`` Cependant, les attaquants peuvent souvent échapper à la détection en encodant ces séquences et en continuant à naviguer dans le système de fichiers du serveur.


   -  Standard URL Encoding: ../ becomes %2e%2e%2f
   - Double Encoding: Useful if the application decodes inputs twice. ../ becomes %252e%252e%252f
   

## LFI2RCE with Session Files

Les fichiers de session PHP peuvent également être utilisés dans une attaque LFI, conduisant à une exécution de code à distance, en particulier si un attaquant peut manipuler les données de session. Dans une application web classique, les données de session sont stockées dans des fichiers sur le serveur. Si un pirate peut injecter du code malveillant dans ces fichiers de session, et si l'application inclut ces fichiers par le biais d'une vulnérabilité LFI, cela peut conduire à l'exécution de code.


## LFI2RCE Log Poisoning
Log Poisoning est une technique par laquelle un attaquant injecte un code exécutable dans le fichier journal d'un serveur web et utilise ensuite une vulnérabilité LFI pour inclure et exécuter ce fichier journal. Cette méthode est particulièrement furtive car les fichiers journaux sont partagés et constituent une partie apparemment inoffensive des opérations du serveur web. Dans une attaque par Log Poisoning, l'attaquant doit d'abord injecter un code PHP malveillant dans un fichier journal. Il peut le faire de différentes manières, par exemple en créant un agent utilisateur malveillant, en envoyant une charge utile via une URL à l'aide de Netcat ou un en-tête referrer que le serveur enregistre. Une fois que le code PHP se trouve dans le fichier journal, l'attaquant peut exploiter une vulnérabilité LFI pour l'inclure dans un fichier PHP standard. Le serveur exécute alors le code malveillant contenu dans le fichier journal, ce qui conduit à un RCE.