Ici je vais commencer par le PleaseCrackMe sur crackmes.one

Je l'importe sur Ghidra pour une analyse

```c
                    /* Create canary
                        */
  canary = *(long *)(in_FS_OFFSET + 0x28);
  printf("Type in your Username: ");
  __isoc99_scanf(&DAT_00102020,local_78);
  printf("\nType in a number beetween 1 and 9: ");
  __isoc99_scanf(&DAT_0010204d,&local_80);
  if (local_80 < 1) {
    puts("\nError: Number is too small");
    uVar2 = 0xffffffff;
  }
  else if (local_80 < 10) {
    local_7c = 0;
    while( true ) {
      uVar4 = (ulong)local_7c;
      sVar3 = strlen(local_78);
      if (sVar3 <= uVar4) break;
      local_58[local_7c] = (char)local_80 + local_78[local_7c];
      local_7c = local_7c + 1;
    }
    printf("\nType in the password: ");
    __isoc99_scanf(&DAT_00102020,local_38);
    iVar1 = strcmp(local_58,local_38);
    if (iVar1 == 0) {
      puts("\nYou are succesfully logged in");
    }
    else {
      puts("\nWrong password");
    }
    uVar2 = 0;
  }
  else {
    puts("\nError: Number is too big");
    uVar2 = 0xffffffff;
  }
  if (canary != *(long *)(in_FS_OFFSET + 0x28)) {
                    /* WARNING: Subroutine does not return */
    __stack_chk_fail();
  }
  return uVar2;
}
```

j'a bien ce code ci

Dans la premiere ligne j'ai ce code:
```c
  printf("Type in your Username: ");
  __isoc99_scanf(&DAT_00102020,local_78);
```
une fonction de `printf` et aussi une autre de `scanf` qui demande une entree a l'utilisateur, et stock dans une variable `local_78`, je modifie la variable en username.
Une seconde ligne :
```c
  printf("\nType in a number beetween 1 and 9: ");
  __isoc99_scanf(&DAT_0010204d,&local_80);
 ```
Celle ci aussi me demande un nombre entre 1 et 9 alors je la modifie en number

Une autre en bas qui me demande un mot de passe:
```c
   printf("\nType in the password: ");
    __isoc99_scanf(&DAT_00102020,local_38);
    iVar1 = strcmp(local_58,local_38);
    ```
 Donc je modifie en password