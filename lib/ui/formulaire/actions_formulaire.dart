import 'package:flutter/foundation.dart';

import '../../models/candidature.dart';

/// Ce que les vues du formulaire peuvent demander à la page.
class ActionsFormulaire {
  const ActionsFormulaire({
    required this.titre,
    required this.edition,
    required this.enCours,
    required this.annuler,
    required this.enregistrer,
    required this.changerStatut,
    required this.choisirStatutIos,
    required this.choisirDate,
    required this.effacerDate,
  });

  final String titre;
  final bool edition;

  /// Enregistrement en cours : boutons désactivés, indicateur visible.
  final bool enCours;
  final VoidCallback annuler;
  final VoidCallback enregistrer;
  final ValueChanged<Statut> changerStatut;
  final VoidCallback choisirStatutIos;
  final void Function({required bool relance}) choisirDate;
  final void Function({required bool relance}) effacerDate;
}
