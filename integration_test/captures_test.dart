import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:piste/main.dart';
import 'package:piste/models/candidature.dart';
import 'package:piste/state/preferences_controller.dart';
import 'package:piste/ui/accueil/accueil_page.dart';
import 'package:piste/ui/fiche/candidature_detail_page.dart';
import 'package:piste/ui/formulaire/candidature_form_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../test/fake_repository.dart';

/// Parcourt les écrans sur un appareil réel ou un simulateur et enregistre
/// une capture de chacun (`flutter drive`, voir le README).
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final exemples = [
    ('Apple', 'iOS Developer', Statut.enCours, 20),
    ('Microsoft', 'Ingénieur logiciel', Statut.envoyee, 22),
    ('Airbnb', 'Software Engineer', Statut.offre, 25),
    ('Spotify', 'Flutter Engineer', Statut.refusee, 28),
    ('Meta', 'Mobile Developer', Statut.enCours, 31),
    ('Google', 'Développeur Flutter', Statut.entretien, 34),
  ];

  FakeCandidatureRepository repository() => FakeCandidatureRepository([
    for (final (i, e) in exemples.indexed)
      Candidature(
        id: i + 1,
        entreprise: e.$1,
        poste: e.$2,
        statut: e.$3,
        notes: e.$1 == 'Google'
            ? 'Premier entretien technique avec l’équipe.\n'
                  'Préparer le portfolio et les exemples.'
            : '',
        lienAnnonce: e.$1 == 'Google' ? 'https://careers.google.com/jobs' : '',
        dateEnvoi: DateTime(2026, 10, 14),
        prochaineRelance: e.$1 == 'Google' ? DateTime(2026, 11, 12) : null,
        dateCreation: DateTime(2026, 10, e.$4 > 31 ? 30 : e.$4),
        dateModification: DateTime(2026, 10, 1).add(Duration(days: e.$4)),
      ),
  ]);

  Future<void> lancer(WidgetTester tester, {int onglet = 0}) async {
    await preparerFormats();
    SharedPreferences.setMockInitialValues({'nom': 'Camille'});
    final preferences = PreferencesController();
    await preferences.charger();
    await tester.pumpWidget(
      PisteApp(
        key: UniqueKey(),
        repository: repository(),
        preferences: preferences,
        ongletInitial: onglet,
      ),
    );
    await attendre(tester);
  }

  var surfaceConvertie = false;

  Future<void> capture(WidgetTester tester, String nom) async {
    await attendre(tester);
    // Android exige de convertir la surface une fois avant de capturer.
    if (Platform.isAndroid && !surfaceConvertie) {
      await binding.convertFlutterSurfaceToImage();
      surfaceConvertie = true;
      await tester.pump();
    }
    await tester.pump();
    await binding.takeScreenshot('${Platform.operatingSystem}_$nom');
  }

  testWidgets('captures', (tester) async {
    await lancer(tester);
    await capture(tester, '01_accueil');

    await tester.tap(find.text('Tout voir'));
    await capture(tester, '02_liste');

    await tester.tap(find.text('Google').first);
    // Mi-transition : la barre d'outils doit rester en place.
    await tester.pump(const Duration(milliseconds: 180));
    await binding.takeScreenshot('${Platform.operatingSystem}_03a_transition');
    await capture(tester, '03_fiche');

    // Retour puis feuille de saisie.
    // Retour par le navigateur (le bouton retour est natif, hors Flutter).
    Navigator.of(tester.element(find.byType(CandidatureDetailPage))).pop();
    await attendre(tester);

    final accueil = tester.widget<AccueilPage>(
      find.byType(AccueilPage, skipOffstage: false),
    );
    unawaited(
      ouvrirFormulaire(
        tester.element(find.byType(AccueilPage, skipOffstage: false)),
        accueil.controller,
      ),
    );
    await capture(tester, '04_formulaire');

    await lancer(tester, onglet: 2);
    await capture(tester, '05_statistiques');

    await lancer(tester, onglet: 3);
    await capture(tester, '06_profil');
  });
}

Future<void> attendre(WidgetTester tester) async {
  for (var i = 0; i < 20; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}
