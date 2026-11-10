import 'package:flutter/painting.dart';

import '../models/candidature.dart';

extension StatutCouleurs on Statut {
  Color get couleur => switch (this) {
    Statut.envoyee => const Color(0xFF6366F1),
    Statut.enCours => const Color(0xFF2F7DE1),
    Statut.entretien => const Color(0xFF1E9E61),
    Statut.offre => const Color(0xFFE8930C),
    Statut.refusee => const Color(0xFFE0485C),
  };

  Color get couleurTexteClair => switch (this) {
    Statut.envoyee => const Color(0xFF5457CD),
    Statut.enCours => const Color(0xFF286ABF),
    Statut.entretien => const Color(0xFF167649),
    Statut.offre => const Color(0xFF976008),
    Statut.refusee => const Color(0xFFB33A4A),
  };
}
