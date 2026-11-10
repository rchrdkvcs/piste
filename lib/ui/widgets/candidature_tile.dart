import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../models/candidature.dart';
import '../../theme/typo.dart';
import '../adaptive/adaptive.dart';
import 'avatar_entreprise.dart';
import 'statut_badge.dart';

/// Ligne de candidature, avec le composant de liste natif de la plateforme.
/// Le nom et le poste tronqués restent lisibles en entier dans la fiche.
class CandidatureTile extends StatelessWidget {
  const CandidatureTile({
    super.key,
    required this.candidature,
    this.onTap,
    this.precision,
  });

  final Candidature candidature;
  final VoidCallback? onTap;

  /// Ligne supplémentaire sous le poste (échéance de relance…).
  final String? precision;

  @override
  Widget build(BuildContext context) {
    final c = candidature;
    final titre = Text(
      c.entreprise,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: Typo.corpsGras(context),
    );
    final extra = precision;
    final poste = Text(
      c.poste,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: Typo.secondaire(context),
    );
    final sousTitre = extra == null
        ? poste
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              poste,
              Text(
                extra,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Typo.legende(context)
                    .copyWith(color: couleurErreur(context)),
              ),
            ],
          );

    if (estCupertino(context)) {
      return Carte(
        child: CupertinoListTile(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          leadingSize: 44,
          leading: AvatarEntreprise(c.entreprise),
          title: titre,
          subtitle: sousTitre,
          additionalInfo: StatutBadge(c.statut),
          trailing: const CupertinoListTileChevron(),
          onTap: onTap,
        ),
      );
    }
    return Carte(
      child: ListTile(
        contentPadding: const EdgeInsets.fromLTRB(16, 8, 12, 8),
        leading: AvatarEntreprise(c.entreprise),
        title: titre,
        subtitle: sousTitre,
        trailing: StatutBadge(c.statut),
        onTap: onTap,
      ),
    );
  }
}
