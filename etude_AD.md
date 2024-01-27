## Mes Etudes d'active Directory
Active Directory est un système qui permet de gérer un ensemble d'ordinateurs et d'utilisateurs connectés au même réseau à partir d'un serveur central.

Les failles et les mauvaises configurations d'Active Directory peuvent souvent être utilisées pour foothold (accès interne), se déplacer latéralement et verticalement au sein d'un réseau et obtenir un accès non autorisé à des ressources protégées telles que des bases de données, des partages de fichiers, du code source, etc.
- AD est essentiellement une grande base de données accessible à tous les utilisateurs du domaine, quel que soit leur niveau de privilège. Un compte utilisateur AD de base sans privilèges supplémentaires peut être utilisé pour énumérer la majorité des objets contenus dans AD, y compris, mais sans s'y limiter, les objets suivants

Domain Computers 	Domain Users
Domain Group Information 	Organizational Units (OUs)
Default Domain Policy 	Functional Domain Levels
Password Policy 	Group Policy Objects (GPOs)
Domain Trusts 	Access Control Lists (ACLs)

Une forest peut contenir plusieurs domaines, et un domaine peut inclure d'autres domaines enfants ou sous-domaines.
Un domaine est une structure au sein de laquelle les objets contenus (utilisateurs, ordinateurs et groupes) sont accessibles. Il comporte de nombreuses unités organisationnelles (OU) intégrées, telles que les contrôleurs de domaine, les utilisateurs et les ordinateurs, et de nouvelles OU peuvent être créées selon les besoins. Les OU peuvent contenir des objets et des sous-OU, ce qui permet d'attribuer différentes stratégies de groupe.

## Active Directory Terminology

- Object
Un objet peut être défini comme toute ressource présente dans un environnement Active Directory, comme les OU, les imprimantes, les utilisateurs, les contrôleurs de domaine, etc.
- Attributes
Chaque objet d'Active Directory est associé à un ensemble d'attributs utilisés pour définir les caractéristiques de l'objet en question. Un objet ordinateur contient des attributs tels que le nom d'hôte et le nom DNS. Tous les attributs d'Active Directory ont un nom LDAP associé qui peut être utilisé lors de requêtes LDAP, comme displayName pour le nom complet et given name pour le prénom.
- Domain
Un domaine est un groupe logique d'objets tels que des ordinateurs, des utilisateurs, des OU, des groupes, etc. Nous pouvons considérer chaque domaine comme une ville différente au sein d'un État ou d'un pays. Les domaines peuvent fonctionner de manière totalement indépendante les uns des autres ou être reliés par des relations de confiance.
- Forest
Un Forest est un ensemble de domaines Active Directory.

- NTDS.DIT
Le fichier `NTDS.DIT` peut être considéré comme le cœur d'Active Directory. Il est stocké sur un contrôleur de domaine à l'emplacement `C:\Windows\NTDS` il s'agit d'une base de données qui stocke les données AD telles que les informations sur les objets utilisateurs et groupes, l'appartenance à un groupe et, ce qui est le plus important pour les attaquants et les testeurs de pénétration, les hachages de mots de passe de tous les utilisateurs du domaine. Une fois le domaine entièrement compromis, un attaquant peut récupérer ce fichier, extraire les hachages et les utiliser pour effectuer une attaque de type "pass-the-hash" ou les craquer hors ligne à l'aide d'un outil tel que Hashcat afin d'accéder à d'autres ressources du domaine. Si le paramètre Stocker le mot de passe avec un cryptage réversible est activé, le NTDS.DIT stockera également les mots de passe en clair pour tous les utilisateurs créés ou qui ont modifié leur mot de passe après que cette politique a été définie. Bien que cela soit rare, certaines organisations peuvent activer ce paramètre si elles utilisent des applications ou des protocoles qui ont besoin d'utiliser le mot de passe existant d'un utilisateur (et non Kerberos) pour l'authentification.

## Active Directory Objects
On parle souvent d'"objets" lorsqu'il s'agit d'AD. Qu'est-ce qu'un objet ? Un objet peut être défini comme TOUTE ressource présente dans un environnement Active Directory, comme les OU, les imprimantes, les utilisateurs, les contrôleurs de domaine.

![Object]{./adobjects.png}

- Domain Controllers
Les contrôleurs de domaine sont essentiellement le cerveau d'un réseau AD. Ils traitent les demandes d'authentification, vérifient les utilisateurs sur le réseau et contrôlent qui peut accéder aux différentes ressources du domaine. Toutes les demandes d'accès sont validées par le contrôleur de domaine et les demandes d'accès privilégié sont basées sur les rôles prédéterminés attribués aux utilisateurs. Il applique également les politiques de sécurité et stocke des informations sur tous les autres objets du domaine.