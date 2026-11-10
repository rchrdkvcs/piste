import 'package:flutter/painting.dart';

import '../models/candidature.dart';

/// Couleurs d'un statut pour les graphiques et pastilles.
extension StatutCouleurs on Statut {
  /// Teinte du statut.
  Color get couleur => switch (this) {
    Statut.envoyee => const Color(0xFF6366F1),
    Statut.enCours => const Color(0xFF2F7DE1),
    Statut.entretien => const Color(0xFF1E9E61),
    Statut.offre => const Color(0xFFE8930C),
    Statut.refusee => const Color(0xFFE0485C),
  };

  /// Texte sur la pastille en thème clair : contraste mesuré ≥ 4,6:1 sur
  /// le fond teinté de la pastille.
  Color get couleurTexteClair => switch (this) {
    Statut.envoyee => const Color(0xFF5457CD),
    Statut.enCours => const Color(0xFF286ABF),
    Statut.entretien => const Color(0xFF167649),
    Statut.offre => const Color(0xFF976008),
    Statut.refusee => const Color(0xFFB33A4A),
  };
}
