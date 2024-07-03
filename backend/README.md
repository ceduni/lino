## Dossier du backend

Ce dossier contient le code source du backend de l'application. On a décidé d'utiliser Fastify avec Node.js et TypeScript pour un meilleur contrôle sur les types et la sécurité du code. La base de données est gérée par MongoDB pour un développement plus rapide étant donné l'architecture de données de l'application.

## Fonctionnalités :
* * *
### Utilisateurs
- [x] `GET /users`: Avoir les infos d'un utilisateur à partir de son ID
- [x] `GET /users/favorites`: Avoir une liste des livres favoris d'un utilisateur
- [x] `DELETE /users/favorites/:bookId`: Ajouter/retirer un livre à ses favoris : si l'utilisateur a un compte, il peut ajouter/retirer un livre à ses favoris. Cela lui permet d'avoir une notification à chaque fois qu'une action est faite sur un de ses livres favoris.
- [x] `POST /users/register`: Créer un compte utilisateur : l'utilisateur s'inscrit en fournissant un nom d'utilisateur, un email, un mot de passe et optionnellement son numéro de téléphone. TODO(?) : envoyer un email de confirmation.
- [x] `POST /users/login`: Se connecter : l'utilisateur se connecte en fournissant son email/son nom d'utilisateur et son mot de passe. Cela retourne un token JWT qui est enregistré sur son appareil jusqu'à ce qu'il se déconnecte et lui permet d'accéder à des fonctionnalités qui nécessitent une authentification.
- [x] `POST /users/update`: Modifier son profil : l'utilisateur peut modifier son nom d'utilisateur, son email, son mot de passe, son numéro de téléphone, ses mots-clés de notification et ses préférences de notification.

* * *
### Livres
- [x] `GET /books/get/:id`: Avoir les infos d'un livre à partir de son ID
- [x] `GET /books/bookbox/:id`: Avoir les infos d'une boîte à livres et la liste des livres qui y sont présents 
- [x] `GET /books/:bookQRCode/:bookBoxId`: Retirer un livre d'une boîte à livres : si l'utilisateur a un compte, son empreinte écologique est mise à jour pour montrer son impact sur l'environnement.
- [x] `POST /books/add`: Ajouter un livre dans une boîte à livres : si l'utilisateur a un compte, son empreinte écologique est mise à jour pour montrer son impact sur l'environnement.
- [x] `GET /books/:isbn`: Obtenir les infos d'un livre via son ISBN : l'utilisateur peut obtenir les informations d'un livre en fournissant son ISBN. Cela permet de remplir automatiquement les champs lors de l'ajout d'un livre via les infos données par Google Books si elles existent.
- [x] `GET /books/search`: Rechercher des livres : l'utilisateur peut rechercher des livres par titre, auteur, ISBN, etc. pour trouver un livre qui l'intéresse.
- [x] `POST /books/alert`: Envoyer une notification aux utilisateurs : l'utilisateur peut envoyer une notification à tous les utilisateurs notifiables pour leur demander d'insérer un livre avec un titre particulier dans une boîte à livres.

* * *
### Threads
- [x] `GET /threads/:threadId`: Avoir les infos d'un thread à partir de son ID
- [x] `GET /threads/search`: Rechercher des threads : l'utilisateur peut rechercher des threads par titre, auteur, etc. pour trouver un thread qui l'intéresse.
- [x] `POST /threads/new`: Créer un thread : l'utilisateur peut créer un thread sur un livre précis pour en discuter.
- [x] `POST /threads/messages`: Répondre à un thread : l'utilisateur peut envoyer des messages dans un thread pour discuter avec les autres utilisateurs. Il a l'option de répondre à un message en particulier.
- [x] `POST /threads/messages/reactions`: Réagir à un message : l'utilisateur peut réagir à un message avec un emoji.




