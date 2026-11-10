import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'plateforme.dart';

class Onglet {
  const Onglet({
    required this.libelle,
    required this.symbole,
    required this.icone,
    required this.iconeActive,
    required this.page,
  });

  final String libelle;
  final String symbole;
  final IconData icone;
  final IconData iconeActive;
  final Widget Function(ValueChanged<int> aller) page;
}

class NavigationOnglets extends StatefulWidget {
  const NavigationOnglets({super.key, required this.onglets, this.initial = 0});

  final List<Onglet> onglets;
  final int initial;

  @override
  State<NavigationOnglets> createState() => _NavigationOngletsState();
}

class _NavigationOngletsState extends State<NavigationOnglets> {
  static const _hauteurBarreIos26 = 64.0;

  late int _index = widget.initial;
  late final _navigateurs = [
    for (final _ in widget.onglets) GlobalKey<NavigatorState>(),
  ];

  void _aller(int index) {
    if (index == _index && estCupertino(context)) {
      _navigateurs[index].currentState?.popUntil((r) => r.isFirst);
      return;
    }
    setState(() => _index = index);
  }

  Widget _page(int i) => widget.onglets[i].page(_aller);

  @override
  Widget build(BuildContext context) =>
      estCupertino(context) ? _cupertino(context) : _material();

  Widget _cupertino(BuildContext context) {
    final mq = MediaQuery.of(context);
    final reserve = PlatformInfo.isIOS26OrHigher() ? _hauteurBarreIos26 : 0.0;
    return AdaptiveScaffold(
      appBar: const AdaptiveAppBar(useNativeToolbar: true),
      useFixedToolbar: false,
      minimizeBehavior: TabBarMinimizeBehavior.never,
      bottomNavigationBar: AdaptiveBottomNavigationBar(
        selectedIndex: _index,
        onTap: _aller,
        selectedItemColor: couleurAccent(context),
        items: [
          for (final o in widget.onglets)
            AdaptiveNavigationDestination(
              icon: o.symbole,
              selectedIcon: '${o.symbole}.fill',
              label: o.libelle,
            ),
        ],
      ),
      body: MediaQuery(
        data: mq.copyWith(
          padding: mq.padding.copyWith(bottom: mq.padding.bottom + reserve),
        ),
        child: IndexedStack(
          index: _index,
          children: [
            for (final (i, cle) in _navigateurs.indexed)
              Navigator(
                key: cle,
                onGenerateRoute: (_) =>
                    CupertinoPageRoute<void>(builder: (_) => _page(i)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _material() {
    return PopScope(
      canPop: _index == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) setState(() => _index = 0);
      },
      child: Scaffold(
        body: IndexedStack(
          index: _index,
          children: [for (var i = 0; i < widget.onglets.length; i++) _page(i)],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: _aller,
          destinations: [
            for (final o in widget.onglets)
              NavigationDestination(
                icon: Icon(o.icone),
                selectedIcon: Icon(o.iconeActive),
                label: o.libelle,
              ),
          ],
        ),
      ),
    );
  }
}
