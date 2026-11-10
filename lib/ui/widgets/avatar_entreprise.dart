import 'package:flutter/widgets.dart';

import 'avatar.dart';

class AvatarEntreprise extends StatelessWidget {
  const AvatarEntreprise(this.entreprise, {super.key, this.taille = 44});

  final String entreprise;
  final double taille;

  static const _teintes = [
    Color(0xFF2F7DE1),
    Color(0xFF00A39C),
    Color(0xFFE0485C),
    Color(0xFF8B5CF6),
    Color(0xFFE8930C),
    Color(0xFF1E9E61),
    Color(0xFF0EA5E9),
  ];

  static int _empreinte(String texte) {
    var h = 0x811C9DC5;
    for (final unite in texte.codeUnits) {
      h = ((h ^ unite) * 0x01000193) & 0xFFFFFFFF;
    }
    return h;
  }

  @override
  Widget build(BuildContext context) {
    final cle = entreprise.trim().toLowerCase();
    return AvatarInitiales(
      texte: entreprise,
      couleur: _teintes[_empreinte(cle) % _teintes.length],
      taille: taille,
    );
  }
}
