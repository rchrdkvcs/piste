import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:piste/main.dart';
import 'package:piste/state/preferences_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fake_repository.dart';
import 'outils.dart';

void main() {
  setUpAll(preparerFormats);

  testWidgets('Android : formulaire invalide puis création', (tester) async {
    await lancer(tester);
    expect(find.text('Bienvenue dans Piste'), findsOneWidget);

    await tester.tap(find.text('Ajouter une candidature'));
    await tester.pumpAndSettle();

    final enregistrer = find.widgetWithText(TextButton, 'Enregistrer');
    await tester.tap(enregistrer);
    await tester.pumpAndSettle();
    expect(find.text('Indique le nom de l’entreprise.'), findsOneWidget);
    expect(find.text('Indique l’intitulé du poste.'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Entreprise *'),
      'Nexora',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Poste *'),
      'Développeur Flutter',
    );
    await tester.tap(enregistrer);
    await tester.pumpAndSettle();

    expect(find.text('Nexora'), findsOneWidget);
    expect(find.text('Candidature ajoutée'), findsOneWidget);
  }, variant: TargetPlatformVariant.only(TargetPlatform.android));

  testWidgets('iOS : feuille de saisie Cupertino et validation', (
    tester,
  ) async {
    await lancer(tester);

    await tester.tap(find.byIcon(CupertinoIcons.add).first);
    await tester.pumpAndSettle();
    expect(find.byType(CupertinoFormSection), findsWidgets);

    await tester.tap(find.text('Enregistrer'));
    await tester.pumpAndSettle();
    expect(find.text('Indique le nom de l’entreprise.'), findsOneWidget);

    final champs = find.byType(CupertinoTextFormFieldRow);
    await tester.enterText(champs.at(0), 'Asteria');
    await tester.enterText(champs.at(1), 'Mobile Developer');
    await tester.tap(find.text('Enregistrer'));
    await tester.pumpAndSettle();

    expect(find.byType(CupertinoFormSection), findsNothing);
    expect(find.text('Asteria'), findsOneWidget);
    await attendreBanniere(tester);
  }, variant: TargetPlatformVariant.only(TargetPlatform.iOS));

  testWidgets('erreur de lecture : Réessayer recharge les données', (
    tester,
  ) async {
    final repo = FakeCandidatureRepository([exemple(entreprise: 'Meta')])
      ..echecLecture = true;
    tester.view
      ..physicalSize = const Size(1206, 2622)
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({});
    final preferences = PreferencesController();
    await preferences.charger();
    await tester.pumpWidget(
      PisteApp(repository: repo, preferences: preferences),
    );
    await tester.pumpAndSettle();

    expect(find.text('Lecture impossible'), findsOneWidget);
    expect(find.text('Aucune candidature'), findsNothing);

    repo.echecLecture = false;
    await tester.tap(find.text('Réessayer'));
    await tester.pumpAndSettle();
    expect(find.text('Meta'), findsOneWidget);
  });

  testWidgets('suppression : annulée puis confirmée', (tester) async {
    await lancer(tester, [exemple(id: 1, entreprise: 'Spotify')]);

    await tester.tap(find.text('Spotify'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Supprimer la candidature'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Annuler'));
    await tester.pumpAndSettle();
    expect(find.text('Spotify'), findsWidgets);

    await tester.tap(find.byTooltip('Supprimer la candidature'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Supprimer'));
    await tester.pumpAndSettle();

    expect(find.text('Spotify'), findsNothing);
    expect(find.text('Bienvenue dans Piste'), findsOneWidget);
  }, variant: TargetPlatformVariant.only(TargetPlatform.android));

  testWidgets(
    'Android : e-mail invalide bloque, contact visible sur la fiche',
    (tester) async {
      await lancer(tester);
      await tester.tap(find.text('Ajouter une candidature'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Entreprise *'),
        'Nexora',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Poste *'),
        'Dev',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'E-mail'),
        'camille@',
      );
      final enregistrer = find.widgetWithText(TextButton, 'Enregistrer');
      await tester.tap(enregistrer);
      await tester.pumpAndSettle();
      expect(
        find.text('Saisis une adresse e-mail, par exemple prenom@exemple.fr.'),
        findsOneWidget,
      );

      await tester.enterText(
        find.widgetWithText(TextFormField, 'E-mail'),
        'Camille@Nexora.fr',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Téléphone'),
        '0612345678',
      );
      await tester.tap(enregistrer);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Nexora'));
      await tester.pumpAndSettle();
      expect(find.text('camille@nexora.fr'), findsOneWidget);
      expect(find.text('06 12 34 56 78'), findsOneWidget);
    },
    variant: TargetPlatformVariant.only(TargetPlatform.android),
  );

  testWidgets('Android : fermer une saisie en cours demande confirmation', (
    tester,
  ) async {
    await lancer(tester);
    await tester.tap(find.text('Ajouter une candidature'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(CloseButton));
    await tester.pumpAndSettle();
    expect(find.text('Bienvenue dans Piste'), findsOneWidget);

    await tester.tap(find.text('Ajouter une candidature'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Entreprise *'),
      'Nexora',
    );
    await tester.tap(find.byType(CloseButton));
    await tester.pumpAndSettle();
    expect(find.text('Abandonner la candidature ?'), findsOneWidget);

    await tester.tap(find.text('Annuler'));
    await tester.pumpAndSettle();
    expect(find.text('Nouvelle candidature'), findsOneWidget);

    await tester.tap(find.byType(CloseButton));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Abandonner'));
    await tester.pumpAndSettle();
    expect(find.text('Bienvenue dans Piste'), findsOneWidget);
  }, variant: TargetPlatformVariant.only(TargetPlatform.android));
}
