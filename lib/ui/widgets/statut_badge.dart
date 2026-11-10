import 'package:flutter/material.dart';

import '../../models/candidature.dart';
import '../../theme/statut_couleurs.dart';
import '../adaptive/adaptive.dart';

class StatutBadge extends StatelessWidget {
  const StatutBadge(this.statut, {super.key});

  final Statut statut;

  @override
  Widget build(BuildContext context) {
    final sombre = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: statut.couleur.withValues(alpha: sombre ? 0.24 : 0.12),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        statut.libelle,
        maxLines: 1,
        softWrap: false,
        style: Typo.legende(context).copyWith(
          color: sombre
              ? Color.lerp(statut.couleur, Colors.white, 0.35)
              : statut.couleurTexteClair,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
