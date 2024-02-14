Dans cette section, nous allons jouer le rôle d'administrateurs de domaine pour Inlanefreight pendant une journée. Nous avons été chargés d'aider le service informatique à clôturer certains ordres de travail. Nous effectuerons donc des actions telles que l'ajout et la suppression d'utilisateurs et de groupes, la gestion de la stratégie de groupe, etc. La réussite de ces tâches peut nous permettre d'être promus au sein de l'équipe informatique de niveau II du service d'assistance.

## Task 1
Notre première tâche de la journée consiste à ajouter quelques utilisateurs nouvellement embauchés dans AD.
First, import le module
```
Import-Module -Name ActiveDirectory

```
Then, pour ajouter un user on peux aller avec le powershell en utilisant le `New-ADUser` et aussi avec le GUI
```powershell
PS C:\htb> New-ADUser -Name "Orion Starchaser" -Accountpassword (ConvertTo-SecureString -AsPlainText (Read-Host "Enter a secure password") -Force ) -Enabled $true -OtherAttributes @{'title'="Analyst";'mail'="o.starchaser@inlanefreight.local"}
```
Added from GUI
## Remove Users
User
Mike O'Hare
Paul Valencia
```powershell
Remove-ADUser -Identity pvalencia
```

Pour le GUI je dois me rendre dans employee et ensuite chercher le user et le supprimer

## Task 2: Manage Groups and Other Organizational Units
Je l'ai fais avec le GUI
 1. From within the IT OU, Right click and select "New" > "Organizational Unit" 
 2. Now that we have our OU, let's create the Security Group for our Analysts.
Right-click on our new OU Security Analysts and select "New > Group" and a popup window should appear.

    Input the name of the group Security Analysts
    Select the Group scope Domain local
    ensure group type says Security not "Distribution".
    Once you check the options, hit OK.
Now Let's Just add these user to our group
**Add User to Group via PowerShell**
```
PS C:\htb> Add-ADGroupMember -Identity analysts -Members ACepheus,OStarchaser,ACallisto
```
## Task 3: Manage Group Policy Objects
Ensuite, on nous a demandé de dupliquer la stratégie de groupe Logon Banner, de la renommer Security Analysts Control et de la modifier pour qu'elle fonctionne avec la nouvelle OU Analysts. Nous devrons apporter les modifications suivantes à l'objet de stratégie :

    nous modifierons les paramètres de la stratégie de mot de passe pour les utilisateurs de ce groupe et nous autoriserons expressément les utilisateurs à accéder à PowerShell et à CMD puisque leurs tâches quotidiennes l'exigent.
    En ce qui concerne les paramètres de l'ordinateur, nous devons nous assurer que la bannière de connexion est appliquée et que l'accès aux supports amovibles est bloqué.

 Pour dupliquer un objet de stratégie de groupe, on peut utiliser la cmdlet `Copy-GPO` ou le faire à partir de la console de gestion de la stratégie de groupe.
 ```
PS C:\htb> Copy-GPO -SourceName "Logon Banner" -TargetName "Security Analysts Control"
```
Link the New GPO to an OU

```
PS C:\htb> New-GPLink -Name "Security Analysts Control" -Target "ou=Security Analysts,ou=IT,OU=HQ-NYC,OU=Employees,OU=Corp,dc=INLANEFREIGHT,dc=LOCAL" -LinkEnabled Yes
 ```

Résumé

Ceci conclut la première partie du laboratoire guidé. Nous avons abordé la gestion des utilisateurs, des groupes et de la stratégie de groupe. Dans la section suivante, nous allons ajouter un ordinateur au domaine INLANEFREIGHT, modifier l'OU dans lequel il existe, et nous assurer qu'il est dans le groupe approprié pour recevoir la stratégie de groupe que nous avons créée plus tôt.