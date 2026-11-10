# Guide du code

## Organisation

```
lib/
  main.dart        racine de l'app
  app_info.dart    nom, version, description
  models/          Candidature, Contact, Statut, règles de saisie
  data/            stockage SQLite et jeu de données d'exemple
  state/           contrôleurs (candidatures, préférences) et indicateurs
  format/          dates et textes (pluriel, initiales, critères)
  theme/           thème, couleur d'accent, espaces, couleurs des statuts
  ui/
    adaptive/      composants natifs par plateforme
    actions/       actions partagées (suppression, liens externes)
    accueil/ liste/ fiche/ formulaire/ statistiques/ profil/
    widgets/       éléments propres à Piste (tuile, avatar, anneau…)
```

Flux : écran → `CandidatureController` → `CandidatureRepository` → SQLite. L'écran se reconstruit à chaque notification du contrôleur.

## Règles

- **Une description par écran.** Un écran ne construit aucun widget propre à une plateforme : il passe par `ui/adaptive/`, qui choisit le composant natif ([ADR 0002](adr/0002-couche-adaptative-composants-natifs.md)).
- **Couleurs système.** Seul l'accent est imposé. Fonds, cartes et dialogues viennent de la palette système (Material 3 générée depuis l'accent, couleurs dynamiques iOS).
- **Pas de SQL hors de `data/`.** Les noms de colonnes ne sortent pas de `candidature_sqlite.dart`.
- **Logique testable hors widgets.** Règles, dates et textes sont des fonctions pures dans `models/`, `format/` ou `state/`.
- **Fichiers courts.** 250 lignes maximum, un rôle par fichier.
- **Pas de commentaires.** Les noms portent le sens, le vocabulaire suit le [glossaire](../GLOSSARY.md).

## Tâches courantes

- **Ajouter un champ à la candidature :** modèle (`models/candidature.dart`), colonne et migration (`data/candidature_sqlite.dart`, incrémenter `version`), saisie (`ui/formulaire/sections_candidature.dart`), fiche (`ui/fiche/lignes_fiche.dart`).
- **Ajouter un composant natif :** un widget dans `ui/adaptive/` qui rend les deux variantes, exporté par `adaptive.dart`.
- **Modifier les données d'exemple :** `data/exemples.dart`. Les dates sont relatives au jour de l'import.
- **Régénérer les icônes de l'app :**

  ```bash
  flutter test tool/generer_icones_test.dart
  dart pub global activate flutter_launcher_icons
  dart pub global run flutter_launcher_icons
  ```

## Tests

`test/` couvre les modèles, le stockage, le contrôleur, la saisie et les parcours principaux (iOS et Android via `TargetPlatformVariant`). Le stockage est remplacé par `FakeCandidatureRepository`.
