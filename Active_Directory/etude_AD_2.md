## NTLM Authentication
Outre Kerberos et LDAP, Active Directory utilise plusieurs autres méthodes d'authentification qui peuvent être utilisées (et détournées) par les applications et les services dans AD. Il s'agit de LM, NTLM, NTLMv1 et NTLMv2. LM et NTLM sont des noms de hachage, et NTLMv1 et NTLMv2 sont des protocoles d'authentification qui utilisent le hachage LM ou NT. Voici une comparaison rapide entre ces hachages et ces protocoles, qui nous montre que, bien qu'il ne soit pas parfait, Kerberos est souvent le protocole d'authentification de choix dans la mesure du possible. Il est essentiel de comprendre la différence entre les types de hachage et les protocoles qui les utilisent.

**An NTLM hash looks like this:**
`Rachel:500:aad3c435b514a4eeaad3b935b51304fe:e46b9e548fa0d122de7f59fb6d48eaa2:::`
En examinant le hachage ci-dessus, nous pouvons décomposer le hachage NTLM en ses différentes parties :

- `Rachel` est le nom d'utilisateur
- `500` est l'identifiant relatif (RID). 500 est le RID connu pour le compte administrateur
- `aad3c435b514a4eeaad3b935b51304fe` est le hachage LM et, si les hachages LM sont désactivés sur le système, il ne peut être utilisé pour rien.
- `e46b9e548fa0d122de7f59fb6d48eaa2` est le hachage NT. Ce hachage peut être craqué hors ligne pour révéler la valeur en clair (en fonction de la longueur/de la force du mot de passe) ou utilisé pour une attaque de type "pass-the-hash". Vous trouverez ci-dessous un exemple d'attaque "pass-the-hash" réussie à l'aide de l'outil CrackMapExec :
```
0xz0r0@htb[/htb]$ crackmapexec smb 10.129.41.19 -u rachel -H e46b9e548fa0d122de7f59fb6d48eaa2

SMB         10.129.43.9     445    DC01      [*] Windows 10.0 Build 17763 (name:DC01) (domain:INLANEFREIGHT.LOCAL) (signing:True) (SMBv1:False)
SMB         10.129.43.9     445    DC01      [+] INLANEFREIGHT.LOCAL\rachel:e46b9e548fa0d122de7f59fb6d48eaa2 (Pwn3d!)
```


## Users and Machines Accounts
Les comptes d'utilisateurs sont créés à la fois sur les systèmes locaux (non reliés à AD) et dans Active Directory pour donner à une personne ou à un programme (tel qu'un service système) la possibilité de se connecter à un ordinateur et d'accéder à des ressources en fonction de ses droits. Lorsqu'un utilisateur se connecte, le système vérifie son mot de passe et crée un jeton d'accès. Ce jeton décrit le contenu de sécurité d'un processus ou d'un fil conducteur et inclut l'identité de sécurité de l'utilisateur et son appartenance à un groupe. Chaque fois qu'un utilisateur interagit avec un processus, ce jeton est présenté. 

## Active Directory Groups
Après les utilisateurs, les groupes sont un autre objet important d'Active Directory. Ils permettent de regrouper des utilisateurs similaires et d'attribuer des droits et des accès en masse. Les groupes sont une autre cible importante pour les attaquants et les testeurs de pénétration, car les droits qu'ils confèrent à leurs membres ne sont pas toujours évidents, mais ils peuvent accorder des privilèges excessifs (et même involontaires) qui peuvent être utilisés de manière abusive s'ils ne sont pas correctement paramétrés.

Les groupes dans Active Directory ont deux caractéristiques fondamentales : le type et le scope(etendue)
. Le type de groupe définit l'objectif du groupe, tandis que l'étendue du groupe indique comment le groupe peut être utilisé au sein du domaine ou de la forêt. Lors de la création d'un nouveau groupe, il faut sélectionner un type de groupe. Il en existe deux principaux : les groupes de sécurité et les groupes de distribution.

```
 Get-ADGroup  -Filter * |select samaccountname,groupscope

```

## AD Droits et Privilege
Les droits et privilèges sont les pierres angulaires de la gestion d'AD et, s'ils sont mal gérés, peuvent facilement conduire à des abus par des attaquants ou des testeurs de pénétration. Les droits d'accès et les privilèges sont deux sujets importants dans AD (et dans l'infosec en général), et nous devons comprendre la différence. Les droits sont généralement attribués à des utilisateurs ou à des groupes et concernent les autorisations d'accès à un objet tel qu'un fichier, tandis que les privilèges permettent à un utilisateur d'effectuer une action telle que l'exécution d'un programme, l'arrêt d'un système, la réinitialisation d'un mot de passe, etc. Les privilèges peuvent être attribués individuellement aux utilisateurs ou leur être conférés via l'appartenance à un groupe intégré ou personnalisé.

## Attribution des droits d'utilisateur

En fonction de leur appartenance à un groupe et d'autres facteurs tels que les privilèges que les administrateurs peuvent attribuer via la stratégie de groupe (GPO), les utilisateurs peuvent se voir attribuer différents droits sur leur compte. 

## Viewing a User's Privileges
Après s'être connecté à un hôte, la commande whoami /priv permet d'obtenir une liste de tous les droits attribués à l'utilisateur actuel. Certains droits ne sont disponibles que pour les utilisateurs administratifs et ne peuvent être listés/levés que lors de l'exécution d'une session CMD ou PowerShell élevée. Ces concepts de droits élevés et de contrôle des comptes d'utilisateurs (UAC) sont des fonctions de sécurité introduites avec Windows Vista qui, par défaut, empêchent les applications de fonctionner avec des autorisations complètes, sauf en cas d'absolue nécessité. 

## La securite en AD
Au fil de ce module, nous avons examiné les nombreuses caractéristiques et fonctionnalités d'Active Directory. Toutes reposent sur le principe d'une gestion centralisée et sur la possibilité de partager des informations rapidement, à volonté, avec un grand nombre d'utilisateurs. Pour cette raison, Active Directory peut être considéré comme non sécurisé de par sa conception. Une installation d'Active Directory par défaut ne comporte pas de nombreuses mesures de renforcement, de paramètres et d'outils qui peuvent être utilisés pour sécuriser une implémentation d'AD. Lorsque l'on pense à la cybersécurité, l'une des premières choses qui vient à l'esprit est l'équilibre entre la confidentialité, l'intégrité et la disponibilité, également connu sous le nom de triade de la CIA. Il est difficile de trouver cet équilibre, et AD penche fortement en faveur de la disponibilité et de la confidentialité.

## Group Policy Objects (GPOs)
Un objet de stratégie de groupe (GPO) est un ensemble virtuel de paramètres de stratégie pouvant être appliqués à un ou plusieurs utilisateurs ou ordinateurs. Les GPO comprennent des stratégies telles que le délai de verrouillage de l'écran, la désactivation des ports USB, l'application d'une stratégie de mot de passe de domaine personnalisé, l'installation de logiciels, la gestion des applications, la personnalisation des paramètres d'accès à distance, et bien plus encore. Chaque GPO porte un nom unique et se voit attribuer un identifiant unique (GUID). Ils peuvent être liés à une OU, un domaine ou un site spécifique. Un seul GPO peut être lié à plusieurs conteneurs, et chaque conteneur peut se voir appliquer plusieurs GPO. Ils peuvent être appliqués à des utilisateurs individuels, à des hôtes ou à des groupes en étant appliqués directement à une OU. Chaque GPO contient un ou plusieurs paramètres de stratégie de groupe qui peuvent s'appliquer au niveau de la machine locale ou dans le contexte d'Active Directory.

Exemples de GPO

Voici quelques exemples de ce que l'on peut faire avec les GPO :

   - Établir des politiques de mot de passe différentes pour les comptes de service, les comptes d'administrateur et les comptes d'utilisateur standard à l'aide de GPO distincts.
   - empêcher l'utilisation de supports amovibles (tels que les périphériques USB)
   - la mise en place d'un économiseur d'écran avec mot de passe
   - Restreindre l'accès aux applications dont un utilisateur standard n'a pas besoin, telles que cmd.exe et PowerShell
   - Appliquer des politiques d'audit et de journalisation
   - Empêcher les utilisateurs d'exécuter certains types de programmes et de scripts
   - Déployer des logiciels dans un domaine
   - Empêcher les utilisateurs d'installer des logiciels non approuvés
   - Affichage d'une bannière de connexion chaque fois qu'un utilisateur se connecte à un système
   - Interdire l'utilisation du hachage LM dans le domaine
   - Exécution de scripts au démarrage et à l'arrêt des ordinateurs ou lorsqu'un utilisateur se connecte ou se déconnecte de sa machine