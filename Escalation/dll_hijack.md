Une DLL (Dynamic Link Library) est une bibliothèque qui contient du code et des données pouvant être utilisés par plusieurs programmes en même temps. Essentiellement, les DLL sont un ensemble d'instructions qui existent en dehors du code d'un exécutable, mais qui sont nécessaires au fonctionnement de ce dernier.

L'ordre de recherche prédéfini commence par le répertoire de l'application ; toutefois, la "pré-recherche" a été énumérée ci-dessus pour montrer que si le nom de la DLL n'est PAS une DLL déjà chargée en mémoire et n'est pas une DLL connue, c'est à ce moment-là que la recherche commence dans le répertoire de l'application.

   - Les DLL connues sont répertoriées dans la clé de registre 
   ``HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\KnownDLLs.``

L'application vérifie chaque dossier de la liste un par un ; si la DLL ne s'y trouve pas, elle passe au dossier suivant jusqu'à ce que la DLL soit finalement trouvée ou qu'elle ne soit pas trouvée du tout.

   Les programmes exécutés en tant que `SYSTEM` ignorent le "répertoire courant". Cela signifie que, par défaut, notre `PATH` ne contient PAS de répertoire accessible en écriture.

Comme nous nous concentrons uniquement sur le répertoire de l'application et les répertoires listés dans notre PATH, nous devrons compter soit sur le fait que le répertoire de l'application a des permissions faibles, soit sur le fait que notre variable d'environnement PATH a été mise à jour avec un répertoire accessible en écriture. SI - et SEULEMENT SI - l'un de ces deux critères est rempli, alors nous pouvons détourner une DLL pour une escalade de privilèges.

- **Alors, qu'est-ce que le détournement de DLL** ?

Le détournement de DLL est une technique de piratage qui consiste à tromper une application légitime/de confiance pour qu'elle charge une DLL arbitraire - et souvent malveillante.

- Il existe de nombreuses formes de détournement de DLL, telles que :

   - DLL replacement
   - DLL search order hijacking
   - Phantom DLL hijacking
   - DLL redirection
   - WinSxS DLL replacement (sideloading)
   - Relative path DLL Hijacking


## DLL replacement