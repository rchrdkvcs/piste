# Stockage local SQLite, sans compte ni synchronisation

Les candidatures vivent uniquement dans une base SQLite sur l'appareil (sqflite) ; il n'y a ni compte, ni serveur, ni sauvegarde. C'est voulu : l'application doit fonctionner hors ligne, sans inscription, et des données de recherche d'emploi restent privées. Le prix accepté est qu'une désinstallation efface tout et que le Web n'est pas pris en charge. `shared_preferences` est réservé aux réglages (thème, prénom), jamais aux données métier.

## Conséquences

- Tout changement de schéma passe par une migration `onUpgrade` versionnée ; les valeurs de statut sont stockées par nom et ne se renomment pas sans migration.
- Ajouter une synchronisation plus tard imposera des identifiants stables hors appareil (l'id auto-incrémenté local n'en est pas un).
