import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Initiale de l'entreprise sur une teinte stable dérivée de son nom.
/// Décorative : le nom est déjà lu à côté.
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

  /// Empreinte stable d'une exécution à l'autre (FNV-1a), contrairement à
  /// `String.hashCode` : une entreprise garde toujours la même teinte.
  static int _empreinte(String texte) {
    var h = 0x811C9DC5;
    for (final unite in texte.codeUnits) {
      h = ((h ^ unite) * 0x01000193) & 0xFFFFFFFF;
    }
    return h;
  }

  @override
  Widget build(BuildContext context) {
    final nom = entreprise.trim();
    final couleur = _teintes[_empreinte(nom.toLowerCase()) % _teintes.length];
    return ExcludeSemantics(
      child: Container(
        width: taille,
        height: taille,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: couleur.withValues(alpha: 0.14),
          shape: BoxShape.circle,
        ),
        child: Text(
          nom.isEmpty ? '?' : nom.characters.first.toUpperCase(),
          textScaler: TextScaler.noScaling,
          style: TextStyle(
            color: couleur,
            fontSize: taille * 0.42,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
