## Approfondissement de mes bases en AD chez OpenClassrooms
Active Directory est une solution proposée par Microsoft pour la gestion d’un système d’information
Dans ce cours, vous serez dans le rôle d’un auditeur de sécurité informatique Active Directory. Vous êtes mandaté par une entreprise pour tester la sécurité de son système d’information interne. Votre client s’appelle MedicEx. C’est une entreprise spécialisée dans les produits pharmaceutiques permettant de décupler les capacités du cerveau. Votre interlocuteur, Mehdi Cale, est le responsable IT de l’entreprise.
Votre rôle sera de :

-  lister le plus de vulnérabilités possible, avec des démonstrations d'exploitation permettant à votre client de reproduire vos attaques ;

-     donner les recommandations associées pour que votre client puisse sécuriser et surveiller son système d’information. Vous l’accompagnerez dans cette démarche.

Comme Active Directory est utilisé partout, les attaquants se sont spécialisés et savent dénicher les vulnérabilités qui leur permettront de prendre le contrôle du système d’information. Parce que oui, compromettre l’Active Directory permet de compromettre la quasi-totalité du système d’information. Ça vaut le coup de se pencher un peu dessus, n’est-ce pas ?

## Organisez votre prise de notes
Dans un premier temps, soyez conscient que lors de vos attaques, vous allez crouler sous les informations récoltées en amont via différentes méthodes. Que ce soit des noms de machines, d’utilisateurs, des adresses IP, des flux réseau, des versions de service, des vulnérabilités, la plupart de ces informations sont suffisamment importantes pour que vous soyez le plus exhaustif possible.

Maintenant que vous êtes un pro de la prise de notes, il faut préparer votre arsenal pour attaquer un environnement Active Directory. Vous allez utiliser plusieurs outils, mais aujourd’hui, les outils sont souvent dépendants des systèmes d’exploitation pour lesquels ils ont été écrits. C’est pourquoi il est très important de pouvoir jongler entre différents environnements de test pour utiliser le bon outil au bon moment.
En résumé

   - La prise de notes est essentielle pour structurer les informations que vous allez récolter, et leur donner de la valeur. (Joplin)

  - Un environnement de travail avec Linux et Windows permet de faire face à tous les besoins lors de l’attaque.

  - Attaquer un système est un cycle continu qui alterne entre la recherche d’information et l’exploitation.
 
## Identifiez les machines de l’environnement de travail
Afin d’identifier les machines vulnérables, il faut d’abord les découvrir sur le réseau. C’est le premier réflexe que j’ai lorsque je démarre un test d’intrusion dans une entreprise. Je vais chercher où se trouvent les machines. Bien sûr, le client sait où se trouvent la plupart de ses équipements, mais deux points restent intéressants :

  - il est important que vous sachiez les découvrir par vous-même, quelle que soit la taille du réseau ;

   - il arrive régulièrement que des serveurs soient allumés sans que le client le sache. Ce sont d’ailleurs très souvent ces machines qui présentent un intérêt pour l’attaque, puisqu'elles ne sont pas surveillées, ou le sont peu.

### Scan TCP

Le scan le plus commun est le scan TCP. Lorsqu’un client veut accéder à un service proposé par un serveur, il peut utiliser le protocole TCP (Transmission Control Protocol). C’est un protocole qui permet au client de s’assurer que le serveur reçoit bien ses messages dans l’ordre, et de même pour le serveur vis-à-vis du client. Il est très utile lorsque les paquets doivent impérativement être reçus par le serveur. Imaginez un serveur proposant un service de vente sur internet, mais qui ne vérifie pas les informations de paiement.
Pour cela, le client indique au serveur qu’il veut communiquer avec lui sur un port spécifique, port correspondant au service demandé, en envoyant un message SYN (Synchronize). Si le serveur accepte la connexion sur ce port, il répondra avec un SYN/ACK (Synchronize Acknowledge). Le client validera cette réponse avec un simple ACK (Acknowledge).

Si le serveur refuse la connexion sur ce port, il répondra avec un RST/ACK (Reset Acknowledge).Enfin, si le serveur est éteint, il n’y aura pas de réponse du tout.

### Scan SYN

Un autre  type de scan dont je veux vous parler est le scan SYN. Il permet d’aller plus vite que le scan TCP. Dans le scan TCP, dès qu’un port est ouvert, l’outil ferme correctement la connexion en répondant avec le dernier ACK. Eh bien le scan SYN ne le fait pas. Il ne fait qu’envoyer un SYN, analyse la réponse comme précédemment, et passe à l’IP suivante. Ça permet d’économiser un peu de temps, et donc de scanner plus vite !
```
➜  ~ sudo nmap -sS 212.83.142.0/24
```
Faites attention avec les scans SYN, car vous ouvrez des connexions, mais vous ne les fermez pas. Certains systèmes risquent alors d’atteindre rapidement le nombre de connexions ouvertes autorisées, et ne répondront plus, ni à vous, ni aux utilisateurs. La plupart des systèmes récents savent gérer ce type de scan, mais de vieux systèmes peuvent être mis à mal. Un scan TCP sera alors plus adapté.

### Scan NetBIOS
Le dernier type de scan que j’utilise très souvent est le scan NetBIOS. Il est particulier car il est plus limité que les scans précédents, mais il est extrêmement rapide. Il repose sur le protocole NetBIOS, propre à Windows, qui permet de faire un lien entre adresse IP et nom de machine.
L’outil NBTscan, lui aussi gratuit et open source, permet d’effectuer ce type de scan. Je l’utilise quand je dois scanner des très grandes plages réseau, et c’est vraiment efficace.
```
└─# nbtscan 212.83.142.0/24
Doing NBT name scan for addresses from 212.83.142.0/24

IP address       NetBIOS Name     Server    User             MAC address
------------------------------------------------------------------------------
212.83.142.26    WIN-634D76S8EA5  <server>  <unknown>        00:50:56:02:08:50
```
Comme le protocole utilisé est propre à Windows, NBTscan ne découvrira la plupart du temps que des machines Windows. Comme il est extrêmement rapide, cela permet de voir où se trouvent les machines dans un très grand réseau, pour ensuite faire des scans plus complets dans ces sous-réseaux découverts.
- Une fois que vous avez identifié les machines présentes sur le réseau, une recherche de vulnérabilités peut vous permettre de prendre la main sur l’une d’entre elles.

## Énumérez les vulnérabilités
Vous savez maintenant quelles machines sont accessibles sur le réseau. L’objectif est d’aller un peu plus loin, et de découvrir les services proposés par ces machines pour peut-être en exploiter, et prendre la main sur quelques hôtes.
- La première étape cruciale est l’énumération de ports. Nous avons évoqué cette technique lors des scans TCP et SYN. Lorsque vous savez qu’une machine vous répond, vous pouvez effectuer un balayage de ports.
```terminal
➜  ~ nmap -sV -Pn -p- --min-rate 3000 $ip
Not shown: 65529 filtered tcp ports (no-response)
PORT     STATE SERVICE       VERSION
22/tcp   open  ssh           OpenSSH for_Windows_8.1 (protocol 2.0)
53/tcp   open  domain        Simple DNS Plus
135/tcp  open  msrpc         Microsoft Windows RPC
139/tcp  open  netbios-ssn   Microsoft Windows netbios-ssn
445/tcp  open  microsoft-ds?
3389/tcp open  ms-wbt-server Microsoft Terminal Services
Service Info: OS: Windows; CPE: cpe:/o:microsoft:windows


➜  ~ nmap -sV -sC -Pn -p22,53,135,139,445,3389 $ip
Host is up (0.19s latency).

PORT     STATE SERVICE       VERSION
22/tcp   open  ssh           OpenSSH for_Windows_8.1 (protocol 2.0)
| ssh-hostkey:
|   3072 55:c1:bb:f7:73:5b:8d:dd:3c:7b:ed:18:19:a3:9e:cb (RSA)
|   256 70:c0:56:fe:ae:30:92:98:76:8b:0b:37:35:98:f3:94 (ECDSA)
|_  256 b9:28:b9:55:60:f1:8e:0f:7f:15:d1:1f:f5:3c:90:f0 (ED25519)
53/tcp   open  domain        Simple DNS Plus
135/tcp  open  msrpc         Microsoft Windows RPC
139/tcp  open  netbios-ssn   Microsoft Windows netbios-ssn
445/tcp  open  microsoft-ds?
3389/tcp open  ms-wbt-server Microsoft Terminal Services
|_ssl-date: 2024-02-17T00:02:25+00:00; -2h00m00s from scanner time.
| ssl-cert: Subject: commonName=DC01.medic.ex
| Not valid before: 2024-02-15T23:42:56
|_Not valid after:  2024-08-16T23:42:56
| rdp-ntlm-info:
|   Target_Name: MEDICEX
|   NetBIOS_Domain_Name: MEDICEX
|   NetBIOS_Computer_Name: DC01
|   DNS_Domain_Name: medic.ex
|   DNS_Computer_Name: DC01.medic.ex
|   Product_Version: 10.0.20348
|_  System_Time: 2024-02-17T00:01:45+00:00
Service Info: OS: Windows; CPE: cpe:/o:microsoft:windows

Host script results:
|_clock-skew: mean: -2h00m00s, deviation: 0s, median: -2h00m00s
| smb2-time:
|   date: 2024-02-17T00:01:48
|_  start_date: N/A
| smb2-security-mode:
|   3:1:1:
|_    Message signing enabled but not required
```
Je trouve ici:
```
|   Target_Name: MEDICEX
|   NetBIOS_Domain_Name: MEDICEX
|   NetBIOS_Computer_Name: DC01
|   DNS_Domain_Name: medic.ex
|   DNS_Computer_Name: DC01.medic.ex
|   Product_Version: 10.0.20348
```
- Découvrir les services proposés par les machines, leur version et leurs potentielles vulnérabilités permet de préparer un plan d’attaque solide.

## Identifiez les points d’entrée
Vous avez maintenant connaissance des machines présentes sur le parc informatique, des services proposés par ces différentes machines, et potentiellement des vulnérabilités que vous pourrez exploiter pour commencer votre phase de compromission. Pour compléter cette reconnaissance, il est primordial de découvrir l’environnement Active Directory.

## Identifiez le domaine Active Directory
Active Directory est une solution proposée par Microsoft pour la gestion d’un système d’information. Il est primordial d’analyser comment cette solution a été implémentée et configurée, pour préparer votre plan d’attaque. Active Directory évolue avec le temps, donc déterminer la version utilisée vous permet de connaître les fonctionnalités et mécanismes de sécurité présents dans la version implémentée dans l’entreprise.

- L’utilitaire `ldapsearch` ([page du manuel Idapsearch](https://linux.die.net/man/1/ldapsearch)) permet d’effectuer des requêtes vers un serveur LDAP, et dans votre cas, il permet de demander anonymement à un contrôleur de domaine des informations sur le domaine.
```terminal
└─# ldapsearch -x -H ldap://$ip -s base -LLL
domainFunctionality: 7
forestFunctionality: 7
domainControllerFunctionality: 7
rootDomainNamingContext: DC=medic,DC=ex
ldapServiceName: medic.ex:dc01$@MEDIC.EX
isGlobalCatalogReady: TRUE
subschemaSubentry: CN=Aggregate,CN=Schema,CN=Configuration,DC=medic,DC=ex
serverName: CN=DC01,CN=Servers,CN=Default-First-Site-Name,CN=Sites,CN=Configur
 ation,DC=medic,DC=ex
schemaNamingContext: CN=Schema,CN=Configuration,DC=medic,DC=ex
namingContexts: DC=medic,DC=ex
namingContexts: CN=Configuration,DC=medic,DC=ex
namingContexts: CN=Schema,CN=Configuration,DC=medic,DC=ex
namingContexts: DC=DomainDnsZones,DC=medic,DC=ex
namingContexts: DC=ForestDnsZones,DC=medic,DC=ex
isSynchronized: TRUE
highestCommittedUSN: 114941
dsServiceName: CN=NTDS Settings,CN=DC01,CN=Servers,CN=Default-First-Site-Name,
 CN=Sites,CN=Configuration,DC=medic,DC=ex
dnsHostName: DC01.medic.ex
defaultNamingContext: DC=medic,DC=ex
currentTime: 20240217000910.0Z
configurationNamingContext: CN=Configuration,DC=medic,DC=ex

```
- Il est possible de fournir l’adresse IP d’un contrôleur de domaine plutôt que le nom de machine dans la ligne de commande.
Vous connaissez également le nom du contrôleur de domaine que vous avez sollicité grâce à l’entrée `dnsHostName`, DC01 dans cet exemple.
Enfin, l’entrée rootDomainNamingContext vous indique le nom du domaine racine de la forêt. Il se peut qu’il soit similaire au domaine que vous auditez, ce qui signifie que vous êtes dans le domaine racine. Il y a de grandes chances pour que ce soit alors le seul domaine de la forêt.

## Découvrez les serveurs clés
Toujours dans la phase de découverte d’informations, énumérer les serveurs clés vous sera très utile pour préparer vos attaques. En effet, ces serveurs sont des cibles idéales puisqu’ils contiennent des données sensibles ou confidentielles, et que leur compromission vous permettra de bien avancer dans votre attaque.
Dans notre environnement, il y a un contrôleur de domaine, `DC01`.
Si vous n’avez pas connaissance du nom de domaine, vous pouvez effectuer un scan nmap pour découvrir les serveurs avec le port 88 ouvert. Ce port est spécifique à Kerberos, donc aux contrôleurs de domaine.
```
└─# nmap -sV -sC -Pn -p88 $ip
Starting Nmap 7.94SVN ( https://nmap.org ) at 2024-02-16 20:17 CST
Nmap scan report for ctf06.root-me.org (212.83.142.83)
Host is up (0.15s latency).

PORT   STATE SERVICE      VERSION
88/tcp open  kerberos-sec Microsoft Windows Kerberos (server time: 2024-02-17 00:17:40Z)

```

## Cartographiez les partages réseau
Un autre élément que je vous conseille de cartographier, ce sont les partages réseau. Ils contiennent très souvent des informations extrêmement sensibles pour l’entreprise. C’est très souvent via ces partages que l’ensemble des collaborateurs échangent des documents. Les partages réseau sous Windows utilisent le protocole SMB pour les échanges de fichiers. Ce service est en écoute sur le port 445. Ainsi, pour trouver les partages sur le réseau, vous pouvez scanner le port 445 sur les différentes machines que vous avez déjà découvertes. L’outil CrackMapExec est un outil open source qui vous permet d'interagir de nombreuses manières avec vos cibles, en utilisant entre autres le protocole SMB. Cet outil permet notamment de faire cette recherche de partages réseau. Il s’utilise de la manière suivante :
```
$ cme smb 10.10.10.0/24 -u pixis -p P4ssw0rd -d medic.ex --shares

SMB         10.10.10.2 445    DC01             [*] Windows 10.0 Build 20348 x64 (name:DC01) (domain:medic.ex) (signing:False) (SMBv1:False)
SMB         10.10.10.2 445    DC01             [+] medic.ex\pixis:P4ssw0rd
SMB         10.10.10.2 445    DC01             [*] Enumerated shares
SMB         10.10.10.2 445    DC01             Share           Permissions     Remark
SMB         10.10.10.2 445    DC01             -----           -----------     ------
SMB         10.10.10.2 445    DC01             ADMIN$                          Administration à distance
SMB         10.10.10.2 445    DC01             C$                              Partage par défaut
SMB         10.10.10.2 445    DC01             IPC$            READ            IPC distant
SMB         10.10.10.2 445    DC01             IT                              
SMB         10.10.10.2 445    DC01             NETLOGON        READ            Partage de serveur d'accŠs 
SMB         10.10.10.2 445    DC01             Privé                           
SMB         10.10.10.2 445    DC01             Production                      
SMB         10.10.10.2 445    DC01             Publique        READ            
SMB         10.10.10.2 445    DC01             Recherche et Développement                 
SMB         10.10.10.2 445    DC01             SYSVOL          READ            Partage de serveur d'accŠs


```
Vous recevez ainsi la liste des partages réseau ouverts, et vous savez si vous y avez accès en lecture et/ou écriture, grâce à la colonne “Permissions”.

## Compromettez un premier compte
Avec les notes que vous avez prises sur les différents éléments du système d’information cible, vous êtes maintenant capable de choisir vos premières cibles pour compromettre un premier compte sur le domaine.
Lors du `nbtscan` j'ai trouver une machine windows. Donc je fais du nmap sur elle
```
└─# nmap -sV -Pn -p- --min-rate 3000 212.83.142.26
Host is up (0.99s latency).
Not shown: 985 closed tcp ports (reset)
PORT      STATE    SERVICE
135/tcp   open     msrpc
139/tcp   open     netbios-ssn
445/tcp   open     microsoft-ds
1755/tcp  filtered wms
1935/tcp  filtered rtmp
3077/tcp  filtered orbix-loc-ssl
3389/tcp  open     ms-wbt-server
5200/tcp  filtered targus-getdata
49152/tcp open     unknown
49153/tcp open     unknown
49154/tcp open     unknown
49155/tcp open     unknown
49156/tcp open     unknown
49157/tcp open     unknown
49161/tcp open     unknown
```

Parmi ces services, voici quelques vulnérabilités que je trouve régulièrement, et qui me permettent de prendre la main sur la machine lorsqu’elle est exploitée :
`MS17-010` est une vulnérabilité sur le service SMB des machines Windows. Elle a été corrigée en 2017, mais vous trouverez régulièrement des  machines qui ne sont plus mises à jour dans un système d’information. Pour identifier des machines vulnérables, l’outil nmap vous sera utile.
```
└─# nmap --script smb-vuln-ms17-010.nse -p445 --open 212.83.142.0/24


```

## Profitez d’une politique de mot de passe faible
Vous avez découvert la politique de mot de passe de l’entreprise lors de votre phase de reconnaissance. La connaître vous permettra de tenter de trouver des premiers identifiants valides mais faibles.

Pour cela, vous pouvez faire du `password spraying`. Cela signifie que vous allez tenter d’utiliser un mot de passe simple sur tout ou partie des utilisateurs du domaine.
Il existe d’ailleurs beaucoup d’outils pour vérifier la validité d’un mot de passe sur plusieurs comptes. L’outil SprayHound en est un.

`sprayhound -U ./utilisateurs.txt -p Medicex1 -d medic.ex -dc 10.10.10.2`
le mot de passe Medicex1 sera testé sur la liste des utilisateurs fournie dans le fichier utilisateurs.txt.

Enfin, une technique qui peut parfois fonctionner, c'est le user-as-pass. Vous allez chercher les utilisateurs pour lesquels le mot de passe est exactement leur nom d’utilisateur. Cela arrive régulièrement, et vous pourrez trouver des comptes comme test ayant pour mot de passe test, ou encore servicesql ayant également comme mot de passe servicesql.
SprayHound est capable de faire ces tests. Pour cela, vous pouvez utiliser les mêmes lignes de commande que précédemment, sauf que vous ne précisez pas de mot de passe à tester. Vous pourrez alors fournir une liste de noms d’utilisateurs ( -U  ), ou fournir un premier compte ( -lu  et -lp  ).
```
sprayhound -U ./utilisateurs.txt -d medic.ex -dc 10.10.10.2
sprayhound -d medic.ex -dc 10.10.10.2 -lu pixis -lp P4ssw0rd
```

## responder
Se mettre en position de man-in-the-middle (homme du milieu) n’est jamais anodin. Il existe un risque que vous interfériez avec le travail d’un collaborateur, en bloquant temporairement un accès à un serveur légitime, par exemple. Faites donc toujours attention lorsque vous faites des attaques au niveau du réseau.
- L’outil Responder vous permet de faire ça automatiquement, en précisant l’interface réseau qu’il doit utiliser pour se mettre en écoute des sollicitations LLMNR et NBT-NS.
Vous récolterez parfois des identifiants en clair, mais plus souvent des hashs NTLMv1 ou NTLMv2, en fonction de la version de NTLM configurée pour les machines attaquées. Ces condensats doivent ensuite être cassés, avec l’outil hashcat, par exemple.

## En résumé

Vous connaissez maintenant plusieurs techniques qui peuvent être appliquées pour prendre la main sur un premier compte. Les voici dans l’ordre dans lequel je les applique personnellement pendant mes tests d’intrusion :

- exploiter les systèmes et applications vulnérables ;
- profiter des mots de passe par défaut ;
- compromettre un utilisateur via du password spraying ;
- compromettre un utilisateur ou une machine via une attaque réseau,  en se positionnant en homme du milieu.