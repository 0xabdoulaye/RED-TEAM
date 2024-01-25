## I am setting up and active directory Hacking Lab

Link : https://medium.com/@reuben.s.royal/windows-active-directory-hacking-lab-setup-part-1-domain-controller-cdd7f24ad259

Link : https://medium.com/r3d-buck3t/building-an-active-directory-lab-part-1-windows-server-2022-setup-7dfaf0dafd5c

After logging into the server,

## AD
Active directory est un systeme qui vous pernet de configurer plusieurs ordinateurs et utilisateurs connecte sur un meme Reseaux dans un serveur centrale
 Imagine a company with hundreds of employees, where each one works in its own (probably Windows) computer. This company has several different departments, like sales, human resources, IT, etc.

Now imagine that the sales department requires a new program to be installed in their workstations. Or that each day an user in a different office forgets its password and it needs to be restored. Or that the new group of interns are only required to work with a few documents of a file server.
 Should the IT team install the program in all the sales workstations, one by one? Should they go to the different offices and restore the user password? Should they create a new user for each intern in the file server that allows only to see files in a directory?

Well, they could do that, though it would be a lot of work (and a waste of money for the company). But since they are smart people, they have all the computers connected in an Active Directory network, so they can perform all these operations from their workstation.

Active Directory allows this by maintaining a centralized database where all the information about users, computers, policies, permissions, etc, is stored. So, for example, the IT team can connect to this database and create the new users for the interns and assign permissions to them to be only allowed to read files in the indicated directories of the specific servers of their departments.

## CREATE A FOREST
 Using a DNS name is very useful, since it allows to create subdomains for management purposes. For example, a company can have a root domain called contoso.local, and then subdomains for different (usually big) departments, like it.contoso.local or sales.contoso.local

 In a forest, each domain has its own database and its own Domain Controllers. However, users of a domain in the forest can also access to the other domains of the forest. 
```
Get-ADForest

```

## AD certificate Setup
Les certificats Active Directory servent a creer des authorites de certification et les service de roles associees pour emettre et gerer les certificats utiliser dans divers applications


## Domains
ce qu'on appelle le Reseau Active directory est souvent connu sous le nom *Domain*. Un domain est une configuration des ordinateurs connecte qui partage la meme base de donnees Active Directory, which is managed by the central servers of a domain, that are called Domain Controllers.
To display the domain on Powershell
 Domain name

Each domain has a DNS name. In many companies, the name of the domain is the same as their web site, for example contoso.com, while others have a different internal domain such as contoso.local.
```
$env:USERDNSDOMAIN
MARVEL.LOCAL

```
or Just to see all
```
Get-ADDomain | select DNSRoot,NetBIOSName,DomainSID


```



## Creating users on the AD
I created a user administrator on the MARVEL.local
I will create 2 user now 

**STEP**
- Tools and then AD users and Computers
- Click on your forest and click on user profile to add a user
Now users added i will add these users on the RemoteManagementGroup
Find the management group
```
Get-ADGroup -Filter {Name -like '*Distan*'}


```
Disable windows Defnder
`Uninstall-WindowsFeature -Name Windows-Defender`