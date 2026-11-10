# Piste

Carnet de suivi de candidatures, hors ligne, pour Android et iOS. Flutter 3.47, Dart 3.13, SQLite.

## Lancer

```bash
flutter pub get
flutter analyze
flutter test
flutter run            # émulateur Android ou simulateur iOS
flutter build apk --release
```

## Fonctionnalités

- CRUD complet : création, fiche détail, modification (même formulaire), suppression avec confirmation (bouton ou balayage).
- Contact de l'entreprise (nom, e-mail, téléphone) : claviers dédiés, validation, e-mail et appel en un geste depuis la fiche.
- Relances : section « À relancer » sur l'accueil, échéance affichée sur la fiche.
- Recherche texte sans accents ni casse (entreprise, poste, contact) combinée à un filtre de statut.
- Lien de l'annonce complété en `https://` s'il est saisi sans protocole.
- Fermer un formulaire modifié demande confirmation.
- Tableau de bord (total, entretiens, offres) et statistiques (anneau + répartition par statut, vue par entreprise).
- États `loading` / `empty` / `success` / `error` visibles, avec « Réessayer » et tirer pour actualiser.
- Thème système / clair / sombre et prénom mémorisés (`shared_preferences`).
- Ouverture du lien de l'offre dans le navigateur (`url_launcher`).

## Interface native par plateforme

Une seule description d'écran, un composant natif par plateforme (`lib/ui/adaptive/adaptive.dart`) :

| Élément | iOS (Cupertino) | Android (Material 3) |
|---|---|---|
| Navigation | `CupertinoTabScaffold`, une pile par onglet | `NavigationBar` + `IndexedStack` |
| Barre de titre | `CupertinoSliverNavigationBar` (grand titre) | `SliverAppBar.large` |
| Ajout | bouton `+` dans la barre | `FloatingActionButton.extended` |
| Formulaire | feuille `CupertinoSheetRoute`, `CupertinoFormSection` | page plein écran, `TextFormField` |
| Statut | `CupertinoActionSheet` | `DropdownButtonFormField` |
| Date | roue `CupertinoDatePicker` | `showDatePicker` |
| Recherche / filtre | `CupertinoSearchTextField` + feuille d'actions | `SearchBar` + `FilterChip` |
| Suppression | `CupertinoActionSheet` destructive | `AlertDialog` |
| Messages | bannière flottante + haptique / `CupertinoAlertDialog` | `SnackBar` |
| Réglages | `CupertinoListSection.insetGrouped` | `Card` + `ListTile` |

La plateforme est lue depuis `Theme.of(context).platform`, ce qui permet de tester les deux rendus avec `TargetPlatformVariant`.

## Architecture

```
lib/
  main.dart                  racine : crée repository + contrôleur, les libère
  models/                    Candidature, Contact, Statut, règles et normalisation de saisie
  data/                      contrat de stockage + implémentation sqflite (v3, migrations v1 → v3)
  state/                     contrôleurs (candidatures, préférences) et indicateurs purs
  format/                    dates et échéances
  theme/                     thème Material 3, couleurs des statuts, échelle typographique
  ui/
    adaptive/                couche Material / Cupertino (plateforme, barre, page, éléments,
                             dialogues, messages, listes, navigation)
    accueil/                 tableau de bord, relances dues
    liste/                   liste, recherche, filtres, balayage
    fiche/                   fiche détail, actions (suppression, liens externes)
    formulaire/              page, état des champs, vues iOS et Android
    statistiques/            anneau et répartition
    profil/                  profil et réglages
    widgets/                 composants partagés (tuile, pastille, avatar, états)
```

Règle : un fichier ne dépasse pas ~250 lignes ; au-delà, il est découpé par responsabilité.

Flux d'un enregistrement : `Form.validate()` → `controller.enregistrer()` → `repository.enregistrer()` → SQLite → relecture → `notifyListeners()` → `ListenableBuilder` reconstruit liste et statistiques. Aucune requête SQL dans l'UI.

## Choix techniques

- **SQLite (sqflite)** : données structurées, persistantes, sans serveur ni compte. `shared_preferences` est réservé aux réglages.
- **ChangeNotifier** : inclus dans Flutter, suffisant pour un état partagé entre quatre onglets ; pas de dépendance de gestion d'état.
- **Widgets natifs plutôt qu'une police/charte imposée** : SF Pro et composants Cupertino sur iOS, Roboto et Material 3 sur Android ; la couleur Piste (`#008F93`) sert de teinte d'accent.
- **Limite** : pas de synchronisation ni de sauvegarde ; une désinstallation efface les données. La version Web n'est pas prise en charge (sqflite).

## Tests

- `test/candidature_test.dart` : sérialisation, statut inconnu, ligne V1.
- `test/saisie_test.dart` : lien, e-mail, téléphone, recherche sans accents, `copyWith` qui efface une date, relances, indicateurs par entreprise, contact sérialisé.
- `test/candidature_controller_test.dart` : erreur puis récupération, recherche + filtre, division par zéro, double enregistrement, échec d'écriture.
- `test/candidature_widget_test.dart` : formulaire invalide puis création (Android et iOS), erreur de lecture + Réessayer, suppression annulée puis confirmée, e-mail invalide puis contact sur la fiche, confirmation d'abandon de saisie.

Glossaire du domaine : `GLOSSARY.md`. Décisions d'architecture : `docs/adr/`.
