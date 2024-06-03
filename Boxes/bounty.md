## Recon


```
Nmap scan report for 10.129.210.9
Host is up (0.27s latency).
Not shown: 999 filtered tcp ports (no-response)
PORT   STATE SERVICE
80/tcp open  http

Read data files from: /usr/bin/../share/nmap
Nmap done: 1 IP address (1 host up) scanned in 23.47 seconds
           Raw packets sent: 2014 (88.592KB) | Rcvd: 13 (556B)


----------------------------------------------------------------------------------------------------------
Open Ports : 80
----------------------------------------------------------------------------------------------------------
```

Je trouve seuls le port 80 est ouvert et puis je trouve `IIS 7.5`

```
       v2.1.0-dev
________________________________________________

 :: Method           : GET
 :: URL              : http://10.129.210.9/FUZZ
 :: Wordlist         : FUZZ: /usr/share/wordlists/dirb/common.txt
 :: Follow redirects : false
 :: Calibration      : false
 :: Timeout          : 10
 :: Threads          : 40
 :: Matcher          : Response status: 200-299,301,302,307,401,403,405,500
________________________________________________

                        [Status: 200, Size: 630, Words: 25, Lines: 32, Duration: 472ms]
aspnet_client           [Status: 301, Size: 157, Words: 9, Lines: 2, Duration: 474ms]
uploadedfiles           [Status: 301, Size: 157, Words: 9, Lines: 2, Duration: 3107ms]
```

Nothing so i will add the `.aspx`
found a file upload on `http://10.129.210.9/transfer.aspx`

when i upload files, it's come here `http://10.129.210.9/uploadedfiles/ker.png`

but i need to bypass the file extension

- https://vulp3cula.gitbook.io/hackers-grimoire/exploitation/web-application/file-upload-bypass

- https://soroush.me/blog/2014/07/upload-a-web-config-file-for-fun-profit/

alors je trouve ceci : `https://github.com/swisskyrepo/PayloadsAllTheThings/blob/master/Upload%20Insecure%20Files/Configuration%20IIS%20web.config/web.config`