## Stack
L'une des zones de mémoire les plus courantes que vous aurez à traiter est le stack. C'est là que sont stockées les variables locales du code.

- Le `push` c'est ajouter quelque chose dans le stack
- Le `Pop` est le contraire du `push` retire
- Le `rsp` ou le `stack pointer`. il point vers le haut du stack.
- Le `rbp` ou base pointer vers toujours vers le debut(bas) du stack

## Words
Vous entendrez peut-être le terme "word" tout au long de ce document. Un `word` ne représente que deux octets de données. Un `dword` correspond à quatre octets de données. Un `qword` représente huit octets de données.


## Registers
Les registres sont essentiellement des endroits où le processeur peut stocker de la mémoire(stack). On peut les considérer comme des seaux dans lesquels le processeur peut stocker des informations. 
- La difference entre le `stack` est que le `Registers` peut stocker une seule valeur alors que le `stack` peux stocker plusieurs valeurs

Dans x64 linux, les arguments d'une fonction sont transmis via des registres. Les premiers arguments sont passés par ces registres :
```console
rdi :    Premier argument
rsi : deuxième argument
rdx :    Troisième argument
rcx : quatrième argument    Quatrième argument
r8 :     Cinquième argument
r9 : Sixième argument
```