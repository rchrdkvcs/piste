import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../state/candidature_controller.dart';
import '../state/preferences_controller.dart';
import 'accueil/accueil_page.dart';
import 'adaptive/adaptive.dart';
import 'liste/candidatures_page.dart';
import 'profil/profil_page.dart';
import 'statistiques/statistiques_page.dart';

/// Navigation principale à quatre onglets.
///
/// iOS : barre d'onglets native (`UITabBar` Liquid Glass sur iOS 26), et une
/// pile de pages par onglet comme dans les apps Apple : la barre reste
/// visible dans une fiche, et retoucher l'onglet ne perd pas sa position.
/// Android : `NavigationBar` Material 3 ; les fiches s'ouvrent par-dessus.
class PisteShell extends StatefulWidget {
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
  State<PisteShell> createState() => _PisteShellState();
}

class _PisteShellState extends State<PisteShell> {
  late int _index = widget.ongletInitial;
  final _navigateurs = List.generate(4, (_) => GlobalKey<NavigatorState>());

  /// Hauteur de la barre d'onglets flottante iOS 26, dessinée par-dessus
  /// le contenu : chaque page la réserve en bas de son défilement.
  static const _hauteurBarreIos26 = 64.0;

  void _aller(int index) {
    if (index == _index && estCupertino(context)) {
      // Retoucher l'onglet actif revient à sa racine (comportement iOS).
      _navigateurs[index].currentState?.popUntil((r) => r.isFirst);
      return;
    }
    setState(() => _index = index);
  }

  Widget _page(int index) => switch (index) {
    0 => AccueilPage(
      controller: widget.controller,
      preferences: widget.preferences,
      onVoirTout: () => _aller(1),
    ),
    1 => CandidaturesPage(controller: widget.controller),
    2 => StatistiquesPage(controller: widget.controller),
    _ => ProfilPage(
      preferences: widget.preferences,
      controller: widget.controller,
    ),
  };

  @override
  Widget build(BuildContext context) =>
      estCupertino(context) ? _cupertino(context) : _material();

  Widget _cupertino(BuildContext context) {
    final mq = MediaQuery.of(context);
    final reserve = PlatformInfo.isIOS26OrHigher() ? _hauteurBarreIos26 : 0.0;
    final onglets = IndexedStack(
      index: _index,
      children: [
        for (var i = 0; i < 4; i++)
          Navigator(
            key: _navigateurs[i],
            onGenerateRoute: (_) =>
                CupertinoPageRoute<void>(builder: (_) => _page(i)),
          ),
      ],
    );

    return AdaptiveScaffold(
      // Le shell ne porte que la barre d'onglets ; chaque page dessine sa
      // propre barre d'outils.
      appBar: const AdaptiveAppBar(useNativeToolbar: true),
      useFixedToolbar: false,
      // Barre toujours pleine taille : la réduction au défilement se
      // déclenchait au moindre rebond, même sur une page vide.
      minimizeBehavior: TabBarMinimizeBehavior.never,
      bottomNavigationBar: AdaptiveBottomNavigationBar(
        selectedIndex: _index,
        onTap: _aller,
        selectedItemColor: couleurAccent(context),
        items: const [
          AdaptiveNavigationDestination(
            icon: 'house',
            selectedIcon: 'house.fill',
            label: 'Accueil',
          ),
          AdaptiveNavigationDestination(
            icon: 'briefcase',
            selectedIcon: 'briefcase.fill',
            label: 'Candidatures',
          ),
          AdaptiveNavigationDestination(
            icon: 'chart.pie',
            selectedIcon: 'chart.pie.fill',
            label: 'Statistiques',
          ),
          AdaptiveNavigationDestination(
            icon: 'person.crop.circle',
            selectedIcon: 'person.crop.circle.fill',
            label: 'Profil',
          ),
        ],
      ),
      body: MediaQuery(
        data: mq.copyWith(
          padding: mq.padding.copyWith(bottom: mq.padding.bottom + reserve),
        ),
        child: onglets,
      ),
    );
  }

  Widget _material() {
    return PopScope(
      // Le retour Android revient d'abord à l'accueil avant de quitter.
      canPop: _index == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) setState(() => _index = 0);
      },
      child: Scaffold(
        body: IndexedStack(
          index: _index,
          children: [for (var i = 0; i < 4; i++) _page(i)],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: _aller,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Accueil',
            ),
            NavigationDestination(
              icon: Icon(Icons.work_outline),
              selectedIcon: Icon(Icons.work),
              label: 'Candidatures',
            ),
            NavigationDestination(
              icon: Icon(Icons.pie_chart_outline),
              selectedIcon: Icon(Icons.pie_chart),
              label: 'Statistiques',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}
