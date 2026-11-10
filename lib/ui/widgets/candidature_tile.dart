import 'package:flutter/material.dart';

import '../../models/candidature.dart';
import '../adaptive/adaptive.dart';
import 'avatar_entreprise.dart';
import 'statut_badge.dart';

class CandidatureTile extends StatelessWidget {
  const CandidatureTile({
    super.key,
    required this.candidature,
    this.onTap,
    this.precision,
  });

  final Candidature candidature;
  final VoidCallback? onTap;
  final String? precision;

  Text _ligne(String texte, TextStyle style) =>
      Text(texte, maxLines: 1, overflow: TextOverflow.ellipsis, style: style);

  @override
  Widget build(BuildContext context) {
    final c = candidature;
    final extra = precision;
    final poste = _ligne(c.poste, Typo.secondaire(context));
    return LigneCarte(
      avant: AvatarEntreprise(c.entreprise),
      titre: _ligne(c.entreprise, Typo.corpsGras(context)),
      sousTitre: extra == null
          ? poste
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                poste,
                _ligne(
                  extra,
                  Typo.legende(context).copyWith(color: couleurErreur(context)),
                ),
              ],
            ),
      badge: StatutBadge(c.statut),
      onTap: onTap,
    );
  }
}
