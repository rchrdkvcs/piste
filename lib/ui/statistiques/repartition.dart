import 'package:flutter/material.dart';

import '../../models/candidature.dart';
import '../../theme/statut_couleurs.dart';
import '../../theme/typo.dart';

/// Statut, nombre, pourcentage et barre de proportion.
class LigneRepartition extends StatelessWidget {
  const LigneRepartition({
    super.key,
    required this.statut,
    required this.nombre,
    required this.proportion,
  });

  final Statut statut;
  final int nombre;
  final double proportion;

  @override
  Widget build(BuildContext context) {
    final pourcentage = (proportion * 100).round();
    return Semantics(
      label: '${statut.libellePluriel} : $nombre, soit $pourcentage %',
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: statut.couleur,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    statut.libellePluriel,
                    style: Typo.corps(context),
                  ),
                ),
                Text('$nombre', style: Typo.chiffre(context, taille: 17)),
                SizedBox(
                  width: 56,
                  child: Text(
                    '$pourcentage %',
                    textAlign: TextAlign.end,
                    style: Typo.secondaire(context).copyWith(
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 24),
              child: BarreProportion(
                valeur: proportion,
                couleur: statut.couleur,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Barre horizontale décorative (la valeur est lue par la ligne).
class BarreProportion extends StatelessWidget {
  const BarreProportion({
    super.key,
    required this.valeur,
    required this.couleur,
  });

  final double valeur;
  final Color couleur;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(
          value: valeur,
          minHeight: 6,
          color: couleur,
          backgroundColor: couleur.withValues(alpha: 0.14),
        ),
      ),
    );
  }
}
