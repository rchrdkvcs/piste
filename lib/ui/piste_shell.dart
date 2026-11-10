import 'package:flutter/material.dart';

import '../state/candidature_controller.dart';
import '../state/preferences_controller.dart';
import 'accueil/accueil_page.dart';
import 'adaptive/adaptive.dart';
import 'liste/candidatures_page.dart';
import 'profil/profil_page.dart';
import 'statistiques/statistiques_page.dart';

class PisteShell extends StatelessWidget {
  const PisteShell({
    super.key,
    required this.controller,
    required this.preferences,
    this.ongletInitial = 0,
  });

  final int ongletInitial;
  final CandidatureController controller;
  final PreferencesController preferences;

  @override
  Widget build(BuildContext context) {
    return NavigationOnglets(
      initial: ongletInitial,
      onglets: [
        Onglet(
          libelle: 'Accueil',
          symbole: 'house',
          icone: Icons.home_outlined,
          iconeActive: Icons.home,
          page: (aller) => AccueilPage(
            controller: controller,
            preferences: preferences,
            onVoirTout: () => aller(1),
          ),
        ),
        Onglet(
          libelle: 'Candidatures',
          symbole: 'briefcase',
          icone: Icons.work_outline,
          iconeActive: Icons.work,
          page: (_) => CandidaturesPage(controller: controller),
        ),
        Onglet(
          libelle: 'Statistiques',
          symbole: 'chart.pie',
          icone: Icons.pie_chart_outline,
          iconeActive: Icons.pie_chart,
          page: (_) => StatistiquesPage(controller: controller),
        ),
        Onglet(
          libelle: 'Profil',
          symbole: 'person.crop.circle',
          icone: Icons.person_outline,
          iconeActive: Icons.person,
          page: (_) =>
              ProfilPage(preferences: preferences, controller: controller),
        ),
      ],
    );
  }
}
