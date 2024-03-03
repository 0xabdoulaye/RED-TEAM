## Propagez-vous latéralement avec le protocole NTLM
Vous avez vos premiers identifiants sur le réseau, ou un premier accès sur un poste ou serveur du domaine. Il vous faut alors continuer votre plan d’attaque, et compromettre d’autres utilisateurs ou machines pour tenter de récupérer de nouveaux accès.

## Exploitez le protocole NTLM
Le protocole NTLM est l’un des deux protocoles d’authentification utilisés dans les environnements Microsoft. Il permet à un utilisateur de prouver qui il est auprès d’un serveur.
Pour finaliser l’authentification, il ne reste plus au serveur qu’à vérifier la validité de la réponse envoyée par le client. Pour ce faire, le serveur a une base de données des utilisateurs locaux appelée SAM (Security Accounts Manager). Il y a la liste des noms d’utilisateurs, et le hash de leur mot de passe, appelé hash NT. Cela permet d’éviter de stocker les mots de passe en clair sur la machine. Quand le serveur reçoit la réponse du client qui tente de s’authentifier, il reçoit le challenge chiffré avec ce hash. Le serveur va procéder à la même opération en cherchant le hash de l’utilisateur dans sa table, et il va chiffrer le challenge qu’il a envoyé avec ce hash.

## Pass-The-Hash
Si vous avez bien suivi, dans tous les cas l’utilisateur n’a utilisé que le hash NT de son mot de passe pour s’authentifier, jamais son mot de passe en clair.
 Avec le protocole NTLM, si vous volez le mot de passe en clair, ou si vous volez le hash NT du mot de passe, vous aurez toutes les billes en main pour vous authentifier. Finalement, on peut même dire qu’avoir le hash NT revient à avoir le mot de passe en clair, dans la majorité des cas.
 Eh oui, si vous avez compromis un seul de ces postes, et que vous avez trouvé le hash du compte administrateur, il y a de grandes chances pour que ce même hash soit valide sur tous les autres postes ! C’est ce qu’on appelle le pass-the-hash.
 - Pour extraire les hash NT des utilisateurs locaux sur des machines, le paramètre  `--sam ` doit être fourni à CrackMapExec, ainsi que les identifiants d’un compte administrateur.
 `$ cme smb 10.10.10.0/24 -u pixis -p P4ssw0rd -d medic.ex --sam`
 - Si un signe [+] vert apparait dans la sortie de CrackMapExec pour une machine, c’est que le compte a le droit de s’authentifier sur cette machine. Si vous avez également le message (Pwn3d!), alors vous êtes administrateur de la machine.
 - Pour s’authentifier avec le hash NT d’un utilisateur, vous pouvez utiliser le paramètre  -H  de CrackMapExec. Il faut également ajouter le paramètre  --local-auth  si vous vous authentifiez avec un compte local, et non un compte du domaine.
 ```
cme smb 10.10.10.0/24 -u Administrateur -H aad3b435b51404eeaad3b435b51404ee:01a27c88a6c1bd0ab0944599129c58a6 --local-auth
 ```
 Vous pouvez également utiliser le paramètre  -hashes  pour tous les outils propres à la suite Impacket. Par exemple l’outil psexec.py.
 ```
psexec.py Administrateur@dc01.medic.ex -hashes aad3b435b51404eeaad3b435b51404ee:01a27c88a6c1bd0ab0944599129c58a6

 ```
 - Attention, le compte administrateur local peut être Administrateur ou Administrator, en fonction de la langue utilisée sur la machine Windows. Pensez bien à essayer les deux !
 ## En résumé

Une des options pour effectuer du mouvement latéral au sein d’un Active Directory, est de :
- Compromettre des machines avec la technique du pass-the-hash. 
-  Se faire passer pour une victime avec le relais NTLM.
-   Forcer une machine distante à s’authentifier auprès de votre machine avec la coercition d’authentification.

## Exploitez le protocole Kerberos
Le protocole Kerberos est le deuxième protocole d’authentification clé dans un Active Directory. C’est d’ailleurs le protocole utilisé par défaut quand c’est possible. Il existe plusieurs manières d’exploiter ce protocole pour du mouvement latéral. Pour bien les comprendre, nous allons faire un bref rappel du fonctionnement de ce protocole.
### Kerberos
Lorsqu’un utilisateur veut utiliser un service, il doit pouvoir prouver auprès du service qui il est. Pour cela, au préalable, l’utilisateur va demander auprès du contrôleur de domaine un TGT, ou Ticket-Granting-Ticket. C’est l’équivalent d’un passeport. Ce document contient des informations sur l’utilisateur, notamment son nom et les groupes auxquels il appartient. D’ailleurs, comme un passeport, il doit être infalsifiable. L’utilisateur ne doit pas pouvoir changer son nom à son bon vouloir. Donc ce TGT est protégé par une clé que seul le contrôleur de domaine connaît.
Pour pouvoir récupérer ce ticket, l’utilisateur doit se préauthentifier auprès du contrôleur de domaine en prouvant qu’il connaît son mot de passe. Si cette préauthentification est validée par le contrôleur de domaine, alors celui-ci lui renvoie son TGT.

## Kerberoasting
Une fois le TGT en main, un utilisateur peut faire une demande de ticket de service pour n’importe quel service du domaine. Or, un ticket de service est protégé par le mot de passe du compte de service demandé. Donc en théorie, si vous demandez un ticket de service, vous pouvez essayer vous-même de trouver la clé qui déchiffre le ticket. Il suffit d’en essayer beaucoup, et peut-être que vous tomberez sur la bonne.
En revanche, il y a aussi des comptes utilisateurs qui exécutent parfois des services. Et c’est là que repose l’attaque Kerberoasting. L’idée est de demander des tickets de service pour tous les services qui sont portés par des utilisateurs. Pour chaque ticket, vous tenterez de trouver le mot de passe qui le protège. Si vous y parvenez, vous aurez trouvé le mot de passe du compte en question !
- Un outil de la suite Impacket permet d’automatiser ce processus. Il s’appelle `GetUserSPNs.py.`
`GetUserSPNs.py -request medic.ex/pixis:P4ssw0rd -outputfile hashes.kerberoast`
Une fois les tickets récupérés, l’outil les mettra sous une forme compréhensible pour des outils comme hashcat, pour tenter de retrouver le mot de passe associé.
- Il existe des outils qui indiqueront que le compte `krbtgt` est Kerberoastable. En effet, ce compte est assimilé à un compte utilisateur, et possède un SPN (kadmin/changepw). Cependant, d’une part ce compte est désactivé, et d’autre part il existe sur toutes les versions d’Active Directory et possède un mot de passe long et complexe. Il n’est pas utile de perdre du temps à essayer de casser son mot de passe.
### Pass-the-Ticket
Vous vous souvenez de la technique du pass-the-hash que vous avez découverte avec le protocole NTLM ? Ici, il est question de tickets, donc ce que vous pouvez passer, ce sont des tickets ! Si vous compromettez une machine, ou un compte administrateur sur un poste, vous pouvez tenter de retrouver des tickets Kerberos en mémoire pour les réutiliser. En effet, si vous trouvez le ticket TGT d’un autre compte, vous pourrez potentiellement le réutiliser pour vous faire passer pour ce compte, sous réserve qu’il ne soit pas expiré. C’est ce qu’on appelle la technique du pass-the-ticket.
- L’outil `lsassy` permet de récupérer à distance des informations d’authentification sur un poste compromis, notamment les TGT. 
```
lsassy -u pixis -p P4ssw0rd -d medic.ex 10.10.10.2
[...]
MEDIC.EX\Administrateur  [TGT] Domain: MEDIC.EX - End time: 2023-11-09 12:46 (TGT_MEDIC.EX_Administrateur_krbtgt_MEDIC.EX_bcb82275.kirbi)
[...]
24 Kerberos tickets written to /home/pixis/.config/lsassy/tickets
```
Cela signifie que sur le poste distant, le TGT du compte Administrateur est présent, et qu’il est valide jusqu’à une certaine date. Par défaut, ce ticket est enregistré au format `.kirbi`, mais vous pouvez le convertir en `.ccache `pour l’utiliser avec la suite Impacket.
```
ticketConverter.py 
~/.config/lsassy/tickets/TGT_MEDIC.EX_Administrateur_krbtgt_MEDIC.EX_bcb82275.kirbi 
/tmp/Administrateur.ccache

```
Pour l’utiliser, il faut l’exporter dans la variable d’environnement KRB5CCNAME puis vous pourrez utiliser tous les outils de la suite impacket avec le paramètre -k pour utiliser ce ticket.
```
export KRB5CCNAME=/tmp/Administrateur.ccache
smbclient.py -k DC01.medic.ex

```
- Pour que cette technique fonctionne, il faut être précis sur ses lignes de commandes.
Dans l’authentification utilisant Kerberos, les vrais noms de machine doivent être utilisés, notamment dans la dernière commande (ici  smbclient.py  ). Si vous testez cette commande dans l’environnement root-me depuis votre machine d’attaque, il faudra au préalable trouver l’IP publique de la machine de CTF, et enregistrer dans votre fichier hosts la ligne suivante :
`XXX.XXX.XXX.XXX DC01 DC01.medic.ex medic.ex`

## Exploitez les autres protocoles
Dans un environnement Active Directory, de nombreux autres protocoles cohabitent. Certains d’entre eux permettent de prendre la main à distance sur une machine, comme SMB, RDP, SSH, WinRM, VNC, WMI et bien d’autres.
Si vous avez des identifiants, vous pouvez les utiliser pour vous propager latéralement. Voici quelques exemples d’outils qui peuvent être utilisés pour ce déplacement latéral.
- Avec SMB, vous avez la possibilité de créer à distance un service et de l’exécuter. Un service, ce n’est rien d’autre qu’une application qui fonctionne en arrière-plan. C’est ce que fait l’outil psexec lorsque vous l’utilisez pour exécuter des commandes à distance. Cet outil a été porté dans la suite `Impacket` que vous connaissez maintenant. Il s’appelle `psexec.py`.
`psexec.py medic.ex/pixis:P4ssw0rd@dc01.medic.ex`

## En résumé

En plus de l'exploitation du protocole NTLM vu au chapitre précédent, pour effectuer du mouvement latéral au sein d’un Active Directory, vous avez plusieurs options :

- Utiliser le Kerberoasting pour découvrir de nouveaux identifiants.
- Découvrir des informations sensibles dans les partages réseau.