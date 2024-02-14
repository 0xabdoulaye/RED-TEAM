## AD administration Part 2
Dans cette section du laboratoire guidé, nous allons effectuer les dernières tâches de la journée. Nous devons ajouter un ordinateur au domaine et modifier l'OU dans lequel il réside.

Task 4 Add and Remove Computers To The Domain
Nos nouveaux utilisateurs auront besoin d'ordinateurs pour effectuer leurs tâches quotidiennes. Le service d'assistance vient de terminer leur provisionnement et nous demande de les ajouter au domaine INLANEFREIGHT. Comme ces postes d'analystes sont nouveaux, nous devons nous assurer que les hôtes se retrouvent dans la bonne OU une fois qu'ils ont rejoint le domaine, afin que la stratégie de groupe puisse prendre effet correctement.

L'hôte que nous devons joindre au domaine INLANEFREIGHT est nommé : ACADEMY-IAD-W10 et possède les informations d'identification suivantes à utiliser pour se connecter et terminer le processus de provisionnement :

**Powershell to join a Domain**
```powershell
PS C:\htb> Add-Computer -DomainName INLANEFREIGHT.LOCAL -Credential INLANEFREIGHT\HTB-student_adm -Restart
```
Then write admin user and passwd
Cette chaîne utilise le domaine (INLANEFREIGHT.LOCAL) auquel nous souhaitons joindre l'hôte, et nous devons spécifier l'utilisateur dont les informations d'identification seront utilisées pour autoriser la jointure. (HTB-student_ADM). La spécification du redémarrage dans la chaîne est nécessaire car la jonction ne se produira pas tant que l'hôte n'aura pas redémarré, ce qui lui permettra d'acquérir les paramètres et les stratégies du domaine.

## Conclusion
Nous avons commencé à nous enfoncer dans le trou du lapin qu'est Active Directory. Que nous l'aimions ou que nous le détestions, si nous voulons poursuivre dans la voie de la sécurité technique de l'information, nous devrons nous occuper d'Active Directory d'une manière ou d'une autre : le renforcer et l'administrer en tant qu'administrateur système soucieux de la sécurité, l'attaquer en tant que pentester de réseau, le défendre en tant que chasseur de menaces, ou encore répondre à des incidents ou faire de la criminalistique numérique. 

La plateforme principale Hack The Box propose de nombreuses cibles pour apprendre et s'entraîner à l'énumération et aux attaques AD. Voici quelques boîtes qui valent la peine d'être vérifiées :

Active
Résoluye
Forest
Cascade
