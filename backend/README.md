## Dossier du backend

Ce dossier contient le code source du backend de l'application. On a décidé d'utiliser Fastify avec Node.js et TypeScript pour un meilleur contrôle sur les types et la sécurité du code. La base de données est gérée par MongoDB pour un développement plus rapide étant donné l'architecture de données de l'application.

## Fonctionnalités :
* * *
### Utilisateurs
- [x] Créer un compte utilisateur : l'utilisateur s'inscrit en fournissant un nom d'utilisateur, un email, un mot de passe et optionnellement son numéro de téléphone. TODO(?) : envoyer un email de confirmation.
- [x] Se connecter : l'utilisateur se connecte en fournissant son email/son nom d'utilisateur et son mot de passe. Cela retourne un token JWT qui est enregistré sur son appareil jusqu'à ce qu'il se déconnecte et lui permet d'accéder à des fonctionnalités qui nécessitent une authentification.
- [x] Ajouter/retirer un livre à ses favoris : si l'utilisateur a un compte, il peut ajouter/retirer un livre à ses favoris. Cela lui permet d'avoir une notification à chaque fois qu'une action est faite sur un de ses livres favoris.
- [x] Modifier son profil : l'utilisateur peut modifier son nom d'utilisateur, son email, son mot de passe, son numéro de téléphone, ses mots-clés de notification et ses préférences de notification.

* * *
### Livres
- [x] Ajouter/retirer un livre d'une boîte à livres : si l'utilisateur a un compte, son empreinte écologique est mise à jour pour montrer son impact sur l'environnement.
- [x] Obtenir les infos d'un livre via son ISBN : l'utilisateur peut obtenir les informations d'un livre en fournissant son ISBN. Cela permet de remplir automatiquement les champs lors de l'ajout d'un livre via les infos données par Google Books si elles existent.
- [x] Rechercher des livres : l'utilisateur peut rechercher des livres par titre, auteur, ISBN, etc. pour trouver un livre qui l'intéresse.
- [x] Envoyer une notification aux utilisateurs : l'utilisateur peut envoyer une notification à tous les utilisateurs notifiables pour leur demander d'insérer un livre avec un titre particulier dans une boîte à livres.

* * *
### Threads
- [x] Créer un thread : l'utilisateur peut créer un thread sur un livre précis pour en discuter.
- [x] Répondre à un thread : l'utilisateur peut envoyer des messages dans un thread pour discuter avec les autres utilisateurs. Il a l'option de répondre à un message en particulier.
- [x] Réagir à un message : l'utilisateur peut réagir à un message avec un emoji.




