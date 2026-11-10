import 'package:flutter/material.dart';

import '../../models/candidature.dart';
import '../../state/candidature_controller.dart';
import '../../theme/app_theme.dart';
import '../actions/actions_candidature.dart';
import '../adaptive/adaptive.dart';
import '../fiche/candidature_detail_page.dart';
import 'candidature_tile.dart';

class SliverCandidatures extends StatelessWidget {
  const SliverCandidatures({
    super.key,
    required this.candidatures,
    required this.controller,
    this.precision,
    this.supprimable = false,
    this.haut = 0,
  });

  final List<Candidature> candidatures;
  final CandidatureController controller;
  final String Function(Candidature c)? precision;
  final bool supprimable;
  final double haut;

  @override
  Widget build(BuildContext context) {
    return Marge(
      haut: haut,
      sliver: SliverList.separated(
        itemCount: candidatures.length,
        separatorBuilder: (_, _) =>
            const SizedBox(height: PisteEspaces.entreLignes),
        itemBuilder: (context, i) {
          final c = candidatures[i];
          final tuile = CandidatureTile(
            candidature: c,
            precision: precision?.call(c),
            onTap: () => ouvrirDetail(context, controller, c.id!),
          );
          if (!supprimable) return tuile;
          return SupprimableParBalayage(
            cle: ValueKey(c.id),
            confirmer: () => supprimerAvecConfirmation(context, controller, c),
            child: tuile,
          );
        },
      ),
    );
  }
}
