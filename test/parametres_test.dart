import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:piste/data/exemples.dart';
import 'package:piste/main.dart';

import 'outils.dart';

void main() {
  setUpAll(preparerFormats);

  testWidgets('Paramètres : importer le jeu de données', (tester) async {
    await lancer(tester);
    await tester.tap(find.text('Profil'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Paramètres'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Importer le jeu de données'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Importer'));
    await tester.pumpAndSettle();

    final n = candidaturesExemple(DateTime.now()).length;
    expect(find.text('$n candidatures importées'), findsOneWidget);
    Navigator.of(tester.element(find.text('Importer le jeu de données'))).pop();
    await tester.pumpAndSettle();
    expect(find.text('$n'), findsOneWidget);
  }, variant: TargetPlatformVariant.only(TargetPlatform.android));
}
