import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:piste/main.dart';
import 'package:piste/models/candidature.dart';
import 'package:piste/state/preferences_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fake_repository.dart';

Future<FakeCandidatureRepository> lancer(
  WidgetTester tester, [
  List<Candidature> initiales = const [],
]) async {
  tester.view
    ..physicalSize = const Size(1206, 2622)
    ..devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  SharedPreferences.setMockInitialValues({});
  final preferences = PreferencesController();
  await preferences.charger();
  final repo = FakeCandidatureRepository(initiales);
  await tester.pumpWidget(PisteApp(repository: repo, preferences: preferences));
  await tester.pumpAndSettle();
  return repo;
}

Future<void> attendreBanniere(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 3));
  await tester.pumpAndSettle();
}
