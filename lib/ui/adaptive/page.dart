import 'dart:async';

import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../theme/typo.dart';
import 'barre.dart';
import 'plateforme.dart';

/// Page défilante avec la barre native de chaque plateforme.
///
/// iOS : barre d'outils Liquid Glass (`AdaptiveScaffold`). Le grand titre
/// défile avec le contenu et passe dans la barre une fois recouvert, comme
/// dans les apps Apple.
/// Android : `SliverAppBar.medium` Material 3.
class AdaptivePage extends StatefulWidget {
  const AdaptivePage({
    super.key,
    required this.titre,
    required this.slivers,
    this.grandTitre = true,
    this.titreDiffere = false,
    this.actions = const [],
    this.boutonFlottant,
    this.surActualisation,
  });

  final String titre;
  final List<Widget> slivers;
  final bool grandTitre;

  /// iOS : le titre n'apparaît dans la barre qu'une fois l'en-tête de la
  /// page recouvert (fiche dont l'en-tête affiche déjà le nom).
  final bool titreDiffere;
  final List<ActionBarre> actions;

  /// Bouton flottant Android. Sur iOS, l'action se place dans la barre.
  final Widget? boutonFlottant;

  /// Tirer pour actualiser, avec le contrôle natif de chaque plateforme.
  final Future<void> Function()? surActualisation;

  @override
  State<AdaptivePage> createState() => _AdaptivePageState();
}

class _AdaptivePageState extends State<AdaptivePage> {
  /// Défilement au-delà duquel le grand titre est recouvert par la barre.
  static const _seuilTitre = 44.0;

  /// Hauteur de la barre d'outils iOS (UIKit et Cupertino : 44 pt).
  static const _hauteurBarre = 44.0;
  bool _titreReplie = false;

  bool get _pleinEcran =>
      widget.slivers.isNotEmpty && widget.slivers.last is SliverPleinEcran;

  bool _surDefilement(ScrollNotification n) {
    if (n.depth != 0 || n.metrics.axis != Axis.vertical) return false;
    // Position bornée : le rebond en bas de page ne compte pas comme un
    // défilement (sinon le titre apparaîtrait en double).
    final m = n.metrics;
    final position = m.pixels.clamp(m.minScrollExtent, m.maxScrollExtent);
    final replie = position > _seuilTitre;
    if (replie != _titreReplie) setState(() => _titreReplie = replie);
    return false;
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
        actions: [for (final a in widget.actions) a.versIos(context)],
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: _surDefilement,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            // Hauteur fixe (barre d'état + barre d'outils) : la barre
            // n'apparaît qu'une fois le grand titre recouvert, et ce
            // réservé constant évite que le contenu saute à ce moment-là.
            SliverToBoxAdapter(
              child: SizedBox(
                height: MediaQuery.viewPaddingOf(context).top + _hauteurBarre,
              ),
            ),
            if (rafraichir != null)
              CupertinoSliverRefreshControl(onRefresh: rafraichir),
            if (widget.grandTitre)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                sliver: SliverToBoxAdapter(
                  child: Semantics(
                    header: true,
                    child: Text(widget.titre, style: Typo.grandTitre(context)),
                  ),
                ),
              ),
            ...widget.slivers,
            // Un état plein écran (vide, erreur, chargement) occupe déjà
            // l'espace restant : une marge en plus créerait un défilement.
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
    final actions = [
      for (final a in widget.actions)
        if (!a.seulementIos) a.versMaterial(context),
    ];
    final scroll = CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        if (widget.grandTitre)
          SliverAppBar.medium(title: Text(widget.titre), actions: actions)
        else
          SliverAppBar(pinned: true, title: titre, actions: actions),
        ...widget.slivers,
        if (!_pleinEcran)
          SliverToBoxAdapter(
            child: SizedBox(height: widget.boutonFlottant == null ? 24 : 96),
          ),
      ],
    );
    final corps = NotificationListener<ScrollNotification>(
      onNotification: _surDefilement,
      child: scroll,
    );
    return Scaffold(
      floatingActionButton: widget.boutonFlottant,
      body: rafraichir == null
          ? corps
          : RefreshIndicator(onRefresh: rafraichir, child: corps),
    );
  }
}

/// Sliver qui remplit l'espace restant de la page (états vide, erreur,
/// chargement). [AdaptivePage] n'ajoute alors pas de marge basse.
abstract interface class SliverPleinEcran implements Widget {}
