import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import 'data/candidature_repository.dart';
import 'state/candidature_controller.dart';
import 'state/preferences_controller.dart';
import 'theme/app_theme.dart';
import 'ui/adaptive/adaptive.dart';
import 'ui/piste_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await preparerFormats();
  final preferences = PreferencesController();
  await preferences.charger();
  runApp(
    PisteApp(
      repository: SqliteCandidatureRepository(),
      preferences: preferences,
    ),
  );
}

Future<void> preparerFormats() async {
  Intl.defaultLocale = 'fr_FR';
  await initializeDateFormatting('fr_FR');
}

class PisteApp extends StatefulWidget {
  const PisteApp({
    super.key,
    required this.repository,
    required this.preferences,
    this.ongletInitial = 0,
  });

  final CandidatureRepository repository;

  final int ongletInitial;
  final PreferencesController preferences;

  @override
  State<PisteApp> createState() => _PisteAppState();
}

class _PisteAppState extends State<PisteApp> {
  late final CandidatureController controller;

  @override
  void initState() {
    super.initState();
    controller = CandidatureController(widget.repository);
    unawaited(controller.charger());
  }

  @override
  void dispose() {
    controller.dispose();
    unawaited(widget.repository.fermer());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.preferences,
      builder: (context, _) => MaterialApp(
        title: 'Piste',
        debugShowCheckedModeBanner: false,
        theme: pisteTheme(Brightness.light),
        darkTheme: pisteTheme(Brightness.dark),
        themeMode: widget.preferences.themeMode,
        locale: const Locale('fr', 'FR'),
        supportedLocales: const [Locale('fr', 'FR'), Locale('en')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        builder: (context, child) => LuminositeImposee(
          mode: widget.preferences.themeMode,
          child: TexteSysteme(child: child!),
        ),
        home: PisteShell(
          controller: controller,
          preferences: widget.preferences,
          ongletInitial: widget.ongletInitial,
        ),
      ),
    );
  }
}
