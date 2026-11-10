import 'dart:async';

import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import 'barre.dart';
import 'filtre.dart';
import 'plateforme.dart';
import 'typo.dart';

class AdaptivePage extends StatefulWidget {
  const AdaptivePage({
    super.key,
    required this.titre,
    required this.slivers,
    this.grandTitre = true,
    this.titreDiffere = false,
    this.actions = const [],
    this.actionPrincipale,
    this.filtre,
    this.entete = const [],
    this.surActualisation,
  });

  final String titre;
  final List<Widget> slivers;
  final bool grandTitre;

  final bool titreDiffere;
  final List<ActionBarre> actions;
  final ActionPrincipale? actionPrincipale;
  final Filtre<Object>? filtre;
  final List<Widget> entete;

  final Future<void> Function()? surActualisation;

  @override
  State<AdaptivePage> createState() => _AdaptivePageState();
}

class _AdaptivePageState extends State<AdaptivePage> {
  static const _seuilTitre = 44.0;

  static const _hauteurBarre = 44.0;
  bool _titreReplie = false;

  bool get _pleinEcran =>
      widget.slivers.isNotEmpty && widget.slivers.last is SliverPleinEcran;

  bool _surDefilement(ScrollNotification n) {
    if (n.depth != 0 || n.metrics.axis != Axis.vertical) return false;
    final m = n.metrics;
    final position = m.pixels.clamp(m.minScrollExtent, m.maxScrollExtent);
    final replie = position > _seuilTitre;
    if (replie != _titreReplie) setState(() => _titreReplie = replie);
    return false;
  }

  List<ActionBarre> get _actionsIos {
    final principale = widget.actionPrincipale;
    return [
      ...widget.actions,
      ?widget.filtre?.actionIos(),
      if (principale != null)
        ActionBarre(
          libelle: principale.libelle,
          symbole: 'plus',
          iconeCupertino: CupertinoIcons.add,
          principale: true,
          onPressed: principale.onPressed,
        ),
    ];
  }

  List<Widget> _contenu(BuildContext context) => [
    ...widget.entete,
    ?widget.filtre?.sliver(context),
    ...widget.slivers,
  ];

  Widget? _boutonFlottant() {
    final principale = widget.actionPrincipale;
    if (principale == null) return null;
    return FloatingActionButton.extended(
      heroTag: widget.titre,
      tooltip: principale.libelle,
      onPressed: principale.onPressed,
      icon: const Icon(Icons.add),
      label: Text(principale.libelleCourt),
    );
  }

  @override
  Widget build(BuildContext context) =>
      estCupertino(context) ? _cupertino(context) : _material(context);

  Widget _cupertino(BuildContext context) {
    final rafraichir = widget.surActualisation;
    final marges = MediaQuery.paddingOf(context);
    final differe = widget.grandTitre || widget.titreDiffere;
    final titreBarre = !differe || _titreReplie ? widget.titre : null;

    return AdaptiveScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground.resolveFrom(
        context,
      ),
      appBar: AdaptiveAppBar(
        useNativeToolbar: true,
        title: titreBarre,
        actions: [for (final a in _actionsIos) a.versIos(context)],
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: _surDefilement,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            SliverToBoxAdapter(
              child: SizedBox(
                height: MediaQuery.viewPaddingOf(context).top + _hauteurBarre,
              ),
            ),
            if (rafraichir != null)
              CupertinoSliverRefreshControl(onRefresh: rafraichir),
            if (widget.grandTitre)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  PisteEspaces.marge,
                  4,
                  PisteEspaces.marge,
                  8,
                ),
                sliver: SliverToBoxAdapter(
                  child: Semantics(
                    header: true,
                    child: Text(widget.titre, style: Typo.grandTitre(context)),
                  ),
                ),
              ),
            ..._contenu(context),
            if (!_pleinEcran)
              SliverToBoxAdapter(child: SizedBox(height: marges.bottom + 24)),
          ],
        ),
      ),
    );
  }

  Widget _material(BuildContext context) {
    final rafraichir = widget.surActualisation;
    final titre = Text(
      !widget.titreDiffere || _titreReplie ? widget.titre : '',
    );
    final actions = [for (final a in widget.actions) a.versMaterial(context)];
    final scroll = CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        if (widget.grandTitre)
          SliverAppBar.medium(title: Text(widget.titre), actions: actions)
        else
          SliverAppBar(pinned: true, title: titre, actions: actions),
        ..._contenu(context),
        if (!_pleinEcran)
          SliverToBoxAdapter(
            child: SizedBox(height: widget.actionPrincipale == null ? 24 : 96),
          ),
      ],
    );
    final corps = NotificationListener<ScrollNotification>(
      onNotification: _surDefilement,
      child: scroll,
    );
    return Scaffold(
      floatingActionButton: _boutonFlottant(),
      body: rafraichir == null
          ? corps
          : RefreshIndicator(onRefresh: rafraichir, child: corps),
    );
  }
}

abstract interface class SliverPleinEcran implements Widget {}
