# Piste

Suivi de candidatures hors ligne pour iOS et Android. Flutter, SQLite, sans compte ni serveur.

## Démarrer

```bash
flutter pub get
flutter run
```

Pour avoir des données tout de suite : **Profil > Paramètres > Importer le jeu de données**.

## Vérifier

```bash
flutter analyze
flutter test
```

## Fonctionnalités

- Créer, consulter, modifier et supprimer une candidature (balayage ou bouton).
- Suivre statut, date d'envoi, relance, contact et lien de l'annonce.
- Rechercher et filtrer par statut.
- Accueil avec relances dues, statistiques par statut et par entreprise.
- Thème clair, sombre ou automatique.
- Composants natifs : Cupertino / Liquid Glass sur iOS, Material 3 sur Android.

## Documentation

- [Guide du code](docs/guide.md) : organisation, règles, tâches courantes.
- [Glossaire](GLOSSARY.md) : vocabulaire du domaine.
- [Décisions](docs/adr/) : choix d'architecture.
