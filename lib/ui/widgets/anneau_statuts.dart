import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../models/candidature.dart';
import '../../theme/statut_couleurs.dart';
import '../../theme/typo.dart';
import '../adaptive/adaptive.dart';

/// Anneau de répartition par statut, total au centre.
class AnneauStatuts extends StatelessWidget {
  const AnneauStatuts({super.key, required this.comptes, required this.total});

  final Map<Statut, int> comptes;
  final int total;

  @override
  Widget build(BuildContext context) {
    final piste = couleurTexteSecondaire(context).withValues(alpha: 0.14);
    final resume = comptes.entries
        .where((e) => e.value > 0)
        .map((e) => '${e.value} ${e.key.libelle.toLowerCase()}')
        .join(', ');
    return Semantics(
      label: '$total candidatures : $resume',
      excludeSemantics: true,
      child: SizedBox.square(
        dimension: 188,
        child: CustomPaint(
          painter: _AnneauPainter(Map.of(comptes), total, piste),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('$total', style: Typo.chiffre(context, taille: 44)),
                const SizedBox(height: 2),
                Text(
                  total > 1 ? 'candidatures' : 'candidature',
                  style: Typo.legende(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AnneauPainter extends CustomPainter {
  _AnneauPainter(this.comptes, this.total, this.piste);

  final Map<Statut, int> comptes;
  final int total;
  final Color piste;

  @override
  void paint(Canvas canvas, Size size) {
    const epaisseur = 18.0;
    final rect = Rect.fromCircle(
      center: size.center(Offset.zero),
      radius: size.shortestSide / 2 - epaisseur / 2,
    );
    final pinceau = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = epaisseur
      ..strokeCap = StrokeCap.butt;

    canvas.drawArc(rect, 0, math.pi * 2, false, pinceau..color = piste);
    if (total == 0) return;

    const espace = 0.035;
    final actifs = comptes.entries.where((e) => e.value > 0).toList();
    var depart = -math.pi / 2;
    for (final e in actifs) {
      final balayage = e.value / total * math.pi * 2;
      final ecart = actifs.length > 1 ? espace : 0.0;
      canvas.drawArc(
        rect,
        depart + ecart / 2,
        balayage - ecart,
        false,
        pinceau..color = e.key.couleur,
      );
      depart += balayage;
    }
  }

  @override
  bool shouldRepaint(_AnneauPainter old) =>
      old.total != total ||
      old.piste != piste ||
      Statut.values.any((s) => old.comptes[s] != comptes[s]);
}
