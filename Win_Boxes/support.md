## Description
Le support est une machine Windows en difficulté qui dispose d'un partage SMB permettant l'authentification anonyme. Après s'être connecté au partage, un fichier exécutable est découvert et utilisé pour interroger le serveur LDAP de la machine à la recherche d'utilisateurs disponibles. Grâce à la rétro-ingénierie, à l'analyse du réseau ou à l'émulation, le mot de passe utilisé par le binaire pour lier le serveur LDAP est identifié et peut être utilisé pour effectuer d'autres requêtes LDAP. Un utilisateur appelé "support" est identifié dans la liste des utilisateurs et le champ "info" contient son mot de passe, ce qui permet une connexion WinRM à la machine. Une fois sur la machine, des informations sur le domaine peuvent être recueillies grâce à `SharpHound`, et `BloodHound` révèle que le groupe `Shared Support Accounts` dont l'utilisateur `support` est membre, a les privilèges `GenericAll` sur le contrôleur de domaine. Une attaque de type Resource Based Constrained Delegation est effectuée, et un shell en tant que `NT Authority\System` est reçu.


## Reconnaissance
```
─# /home/blo/tools/nmapautomate/nmapauto.sh $ip

###############################################
###---------) Starting Quick Scan (---------###
###############################################

Starting Nmap 7.94SVN ( https://nmap.org ) at 2024-02-26 19:25 CST
Initiating Ping Scan at 19:25
Scanning 10.129.3.85 [4 ports]
Completed Ping Scan at 19:25, 0.25s elapsed (1 total hosts)
Initiating Parallel DNS resolution of 1 host. at 19:25
Completed Parallel DNS resolution of 1 host. at 19:25, 0.08s elapsed
Initiating SYN Stealth Scan at 19:25
Scanning 10.129.3.85 [1000 ports]
Discovered open port 53/tcp on 10.129.3.85
Discovered open port 139/tcp on 10.129.3.85
Discovered open port 445/tcp on 10.129.3.85
Discovered open port 135/tcp on 10.129.3.85
Discovered open port 3268/tcp on 10.129.3.85
Discovered open port 593/tcp on 10.129.3.85
Discovered open port 3269/tcp on 10.129.3.85
Discovered open port 88/tcp on 10.129.3.85
Discovered open port 389/tcp on 10.129.3.85
Discovered open port 636/tcp on 10.129.3.85
Discovered open port 464/tcp on 10.129.3.85
Completed SYN Stealth Scan at 19:25, 19.90s elapsed (1000 total ports)
Nmap scan report for 10.129.3.85
Host is up (0.29s latency).
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

----------------------------------------------------------------------------------------------------------
Open Ports : 53,88,135,139,389,445,464,593,636,3268,3269                                                                                                     
----------------------------------------------------------------------------------------------------------                                                   

Completed NSE at 19:27, 2.51s elapsed
Initiating NSE at 19:27
Completed NSE at 19:27, 0.00s elapsed
Nmap scan report for 10.129.3.85
Host is up (0.42s latency).
Not shown: 65530 filtered tcp ports (no-response)
PORT      STATE SERVICE    VERSION
53/tcp    open  tcpwrapped
135/tcp   open  tcpwrapped
139/tcp   open  tcpwrapped
445/tcp   open  tcpwrapped
49708/tcp open  tcpwrapped

Open Ports : 53,135,139,445,49708 


└─# nmap -sV -sC -Pn -p53,88,135,139,389,445,464,593,636,3268,3269,49708 $ip            
Host is up (0.43s latency).

PORT      STATE SERVICE       VERSION
53/tcp    open  domain        Simple DNS Plus
88/tcp    open  kerberos-sec  Microsoft Windows Kerberos (server time: 2024-02-27 01:28:49Z)
135/tcp   open  msrpc         Microsoft Windows RPC
139/tcp   open  netbios-ssn   Microsoft Windows netbios-ssn
389/tcp   open  ldap          Microsoft Windows Active Directory LDAP (Domain: support.htb0., Site: Default-First-Site-Name)
445/tcp   open  microsoft-ds?
464/tcp   open  kpasswd5?
593/tcp   open  ncacn_http    Microsoft Windows RPC over HTTP 1.0
636/tcp   open  tcpwrapped
3268/tcp  open  ldap          Microsoft Windows Active Directory LDAP (Domain: support.htb0., Site: Default-First-Site-Name)
3269/tcp  open  tcpwrapped
49708/tcp open  msrpc         Microsoft Windows RPC
Service Info: Host: DC; OS: Windows; CPE: cpe:/o:microsoft:windows

Host script results:
| smb2-security-mode: 
|   3:1:1: 
|_    Message signing enabled and required
| smb2-time: 
|   date: 2024-02-27T01:29:48
|_  start_date: N/A

```

Un AD avec le domain `support.htb` et le DC `DC.support.htb`

**SMB Enum**
```
└─# nxc smb $ip -u '' -p '' 
SMB         10.129.3.85     445    DC               [*] Windows 10.0 Build 20348 x64 (name:DC) (domain:support.htb) (signing:True) (SMBv1:False)
SMB         10.129.3.85     445    DC               [+] support.htb\: 

```
Un utisateur anonyme Valide

**MSRPC**
```
└─# rpcclient -N -U '' $ip
rpcclient $> enumdomains
result was NT_STATUS_ACCESS_DENIED
rpcclient $> enumdomusers
result was NT_STATUS_ACCESS_DENIED
rpcclient $> 
```

**Kerbrute**
```
Version: v1.0.3 (9dad6e1) - 02/26/24 - Ronnie Flathers @ropnop

2024/02/26 19:37:26 >  Using KDC(s):
2024/02/26 19:37:26 >   10.129.3.85:88

2024/02/26 19:37:46 >  [+] VALID USERNAME:       support@support.htb
2024/02/26 19:37:54 >  [+] VALID USERNAME:       guest@support.htb

─# impacket-GetNPUsers support.htb/ -no-pass -usersfile users -dc-ip $ip                     
Impacket v0.12.0.dev1+20231114.165227.4b56c18a - Copyright 2023 Fortra

[-] User support doesn't have UF_DONT_REQUIRE_PREAUTH set
[-] User guest doesn't have UF_DONT_REQUIRE_PREAUTH set
                                                        
```

**PasswordSpray**

```
─# nxc smb $ip -u users -p users --no-bruteforce --continue-on-success
SMB         10.129.3.85     445    DC               [*] Windows 10.0 Build 20348 x64 (name:DC) (domain:support.htb) (signing:True) (SMBv1:False)
SMB         10.129.3.85     445    DC               [-] support.htb\support:support STATUS_LOGON_FAILURE 
SMB         10.129.3.85     445    DC               [-] support.htb\guest:guest STATUS_LOGON_FAILURE 


```

**Note**:
- Toujours enumerer les `shares` avec `smbclient -N -L //domain.htb`
```
└─# smbclient -N //support.htb/SYSVOL
Try "help" to get a list of possible commands.
smb: \> ls
NT_STATUS_ACCESS_DENIED listing \*
smb: \> 
─# smbclient -N //support.htb/support-tools
Try "help" to get a list of possible commands.
smb: \> ls
  .                                   D        0  Wed Jul 20 12:01:06 2022
  ..                                  D        0  Sat May 28 06:18:25 2022
  7-ZipPortable_21.07.paf.exe         A  2880728  Sat May 28 06:19:19 2022
  npp.8.4.1.portable.x64.zip          A  5439245  Sat May 28 06:19:55 2022
  putty.exe                           A  1273576  Sat May 28 06:20:06 2022
  SysinternalsSuite.zip               A 48102161  Sat May 28 06:19:31 2022
  UserInfo.exe.zip                    A   277499  Wed Jul 20 12:01:07 2022
  windirstat1_1_2_setup.exe           A    79171  Sat May 28 06:20:17 2022
  WiresharkPortable64_3.6.5.paf.exe      A 44398000  Sat May 28 06:19:43 2022

                4026367 blocks of size 4096. 970815 blocks available
smb: \> 
```
Un fichier nomme `UserInfo`, humm Let's reverse

```
└─# file UserInfo.exe   
UserInfo.exe: PE32 executable (console) Intel 80386 Mono/.Net assembly, for MS Windows, 3 sections
```

Je trouve un nom `armando`
```


```