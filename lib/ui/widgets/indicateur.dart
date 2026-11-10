import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../theme/typo.dart';
import '../adaptive/adaptive.dart';

/// Indicateur chiffré du tableau de bord.
class Indicateur extends StatelessWidget {
  const Indicateur({
    super.key,
    required this.valeur,
    required this.libelle,
    required this.icone,
    required this.couleur,
  });

  final int valeur;
  final String libelle;
  final IconData icone;
  final Color couleur;

  @override
  Widget build(BuildContext context) {
    return MergeSemantics(
      child: Carte(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ExcludeSemantics(child: Icon(icone, color: couleur, size: 22)),
            const SizedBox(height: 12),
            Text('$valeur', style: Typo.chiffre(context)),
            const SizedBox(height: 2),
            // Pas de troncature : le libellé passe à la ligne si le texte
            // est agrandi dans les réglages.
            Text(libelle, style: Typo.legende(context)),
          ],
        ),
      ),
    );
  }
}
