## Intro
L'injection SQL (SQLi) est une vulnérabilité de sécurité web qui permet à un pirate d'interférer avec les requêtes qu'une application adresse à sa base de données. Cela peut permettre à un pirate de visualiser des données qu'il n'est normalement pas en mesure d'extraire. Il peut s'agir de données appartenant à d'autres utilisateurs ou de toute autre donnée à laquelle l'application peut accéder. Dans de nombreux cas, un pirate peut modifier ou supprimer ces données, ce qui entraîne des changements persistants dans le contenu ou le comportement de l'application.

Dans certaines situations, un pirate peut intensifier une attaque par injection SQL pour compromettre le serveur sous-jacent ou une autre infrastructure dorsale. Cela peut également lui permettre d'effectuer des attaques par déni de service.

## How to detect SQL injection vulnerabilities
Vous pouvez détecter manuellement les injections SQL en utilisant un ensemble systématique de tests pour chaque point d'entrée de l'application. Pour ce faire, vous devez généralement soumettre :

    Le caractère guillemet simple ' et rechercher des erreurs ou d'autres anomalies.
    Une syntaxe SQL spécifique qui évalue la valeur de base (originale) du point d'entrée et une valeur différente, et qui recherche des différences systématiques dans les réponses de l'application.
    Conditions booléennes telles que OR 1=1 et OR 1=2, et recherche de différences dans les réponses de l'application.
    Charges utiles conçues pour déclencher des délais lorsqu'elles sont exécutées dans le cadre d'une requête SQL, et recherche de différences dans le temps de réponse.
    Charges utiles OAST conçues pour déclencher une interaction réseau hors bande lorsqu'elles sont exécutées dans le cadre d'une requête SQL, et surveiller les interactions qui en résultent.


Imaginons une application d'achat qui affiche des produits dans différentes catégories. Lorsque l'utilisateur clique sur la catégorie Cadeaux, son navigateur demande l'URL :
- `https://insecure-website.com/products?category=Gifts`

 L'application effectue alors une requête SQL pour extraire de la base de données les détails des produits concernés :
 - `SELECT * FROM products WHERE category = 'Gifts' AND released = 1`


 - L'application n'implémente aucune défense contre les attaques par injection SQL. Cela signifie qu'un attaquant peut construire l'attaque suivante, par exemple :
 - `https://insecure-website.com/products?category=Gifts'+OR+1=1--`

La requête modifiée renvoie tous les éléments pour lesquels la catégorie est `Gifts` ou 1 est égal à 1. Comme `1=1` est toujours vrai, la requête renvoie tous les articles.
- `SELECT * FROM products WHERE category = 'Gifts' OR 1=1--' AND released = 1`


## Subvertir la logique de l'application
Imaginez une application qui permet aux utilisateurs de se connecter avec un nom d'utilisateur et un mot de passe. Si un utilisateur soumet le nom d'utilisateur "wiener" et le mot de passe "bluecheese", l'application vérifie les informations d'identification en exécutant la requête SQL suivante :
- ``SELECT * FROM users WHERE username = 'wiener' AND password = 'bluecheese'``

Si la requête renvoie les détails d'un utilisateur, la connexion est réussie. Dans le cas contraire, elle est rejetée.

Dans ce cas, un attaquant peut se connecter en tant que n'importe quel utilisateur sans avoir besoin d'un mot de passe. Il peut le faire en utilisant la séquence de commentaires SQL ``--`` pour supprimer la vérification du mot de passe dans la clause WHERE de la requête. Par exemple, en soumettant le nom d'utilisateur ``"administrator"--`` et un mot de passe vide, on obtient la requête suivante :
- ``SELECT * FROM users WHERE username = 'administrator'--' AND password = ''``

Cette requête renvoie l'utilisateur dont le nom d'utilisateur est administrateur et permet à l'attaquant de se connecter en tant qu'utilisateur en ignorant le mot de passe.