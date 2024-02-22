## Recon
Je commence toujours avec un basic scan
```
└─# nmap 10.129.1.13                              
Host is up (0.17s latency).
Not shown: 996 closed tcp ports (reset)
PORT     STATE SERVICE
135/tcp  open  msrpc
139/tcp  open  netbios-ssn
445/tcp  open  microsoft-ds
3389/tcp open  ms-wbt-server
```
Ensuite mon seconde scan sera de toujours re-scanner les ports ouverts pour leurs versions et autre
```
└─# nmap -sV -sC -Pn -p135,139,445,3389 10.129.1.13
Nmap scan report for 10.129.1.13
Host is up (0.29s latency).

PORT     STATE SERVICE       VERSION
135/tcp  open  msrpc         Microsoft Windows RPC
139/tcp  open  netbios-ssn   Microsoft Windows netbios-ssn
445/tcp  open  microsoft-ds?
3389/tcp open  ms-wbt-server Microsoft Terminal Services
| rdp-ntlm-info: 
|   Target_Name: EXPLOSION
|   NetBIOS_Domain_Name: EXPLOSION
|   NetBIOS_Computer_Name: EXPLOSION
|   DNS_Domain_Name: Explosion
|   DNS_Computer_Name: Explosion
|   Product_Version: 10.0.17763
|_  System_Time: 2024-02-22T13:47:05+00:00
|_ssl-date: 2024-02-22T13:47:13+00:00; +2s from scanner time.
| ssl-cert: Subject: commonName=Explosion
| Not valid before: 2024-02-21T13:41:12
|_Not valid after:  2024-08-22T13:41:12
Service Info: OS: Windows; CPE: cpe:/o:microsoft:windows

Host script results:
| smb2-security-mode: 
|   311: 
|_    Message signing enabled but not required
| smb2-time: 
|   date: 2024-02-22T13:47:05
|_  start_date: N/A
|_clock-skew: mean: 1s, deviation: 0s, median: 1s
```
Ok avec ce resultat j'ai le port `135` qui est le `msrpc` pour le pentest
- https://book.hacktricks.xyz/network-services-pentesting/135-pentesting-msrpc
- https://book.hacktricks.xyz/network-services-pentesting/pentesting-smb/rpcclient-enumeration
essayons de se connecter anonymement sur le msrpc
```
└─# rpcclient -N -U "" 10.129.1.13
Cannot connect to server.  Error was NT_STATUS_ACCESS_DENIED
```
Ca marche pas, je crois que c'est parce que c'est pas un AD

Ensuite on a les ports `139` et `445` qui sont les ports inoubliables du protocole `smb`.
Pour ces ports, primo je vais utiliser `enum4linux -a $ip` pour d'eventuelles informations

```
─# enum4linux -a $ip
Starting enum4linux v0.9.1 ( http://labs.portcullis.co.uk/application/enum4linux/ ) on Thu Feb 22 13:52:43 2024

 =========================================( Target Information )=========================================

Target ........... 10.129.1.13
RID Range ........ 500-550,1000-1050
Username ......... ''
Password ......... ''
Known Usernames .. administrator, guest, krbtgt, domain admins, root, bin, none
```
Ok ceci aussi ne marche pas mais on a deja les users et on a un dernier port ouvert qui est le `3389` RDP
- https://book.hacktricks.xyz/network-services-pentesting/pentesting-rdp

Avec nmap je vais chercher des vulns sur ca
```
└─# ls /usr/share/nmap/scripts | grep "smb"
└─# nmap -sV --script smb-* -Pn -p3389 10.129.1.13
Starting Nmap 7.93 ( https://nmap.org ) at 2024-02-22 13:58 GMT
Nmap scan report for 10.129.1.13
Host is up (0.34s latency).

PORT     STATE SERVICE       VERSION
3389/tcp open  ms-wbt-server Microsoft Terminal Services
Service Info: OS: Windows; CPE: cpe:/o:microsoft:windows

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 7.47 seconds


```
Ca marche pas, Let's crack it