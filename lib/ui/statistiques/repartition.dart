import 'package:flutter/material.dart';

import '../../models/candidature.dart';
import '../../theme/app_theme.dart';
import '../../theme/statut_couleurs.dart';
import '../adaptive/adaptive.dart';
import '../widgets/avatar_entreprise.dart';

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
          backgroundColor: teinteDouce(couleur),
        ),
      ),
    );
  }
}

class LigneEntreprise extends StatelessWidget {
  const LigneEntreprise({
    super.key,
    required this.nom,
    required this.nombre,
    required this.maximum,
  });

  final String nom;
  final int nombre;
  final int maximum;

  @override
  Widget build(BuildContext context) {
    return MergeSemantics(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Row(
          children: [
            AvatarEntreprise(nom, taille: 36),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(nom, style: Typo.corpsGras(context)),
                  const SizedBox(height: 6),
                  BarreProportion(
                    valeur: nombre / maximum,
                    couleur: couleurAccent(context),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Text('$nombre', style: Typo.chiffre(context, taille: 17)),
          ],
        ),
      ),
    );
  }
}
