import 'package:flutter/material.dart';

import '../../format/texte.dart';
import '../../theme/app_theme.dart';

class AvatarInitiales extends StatelessWidget {
  const AvatarInitiales({
    super.key,
    required this.texte,
    required this.couleur,
    this.taille = 44,
    this.lettres = 1,
    this.iconeVide,
  });

  final String texte;
  final Color couleur;
  final double taille;
  final int lettres;
  final IconData? iconeVide;

  @override
  Widget build(BuildContext context) {
    final contenu = initiales(texte, max: lettres);
    return ExcludeSemantics(
      child: Container(
        width: taille,
        height: taille,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: teinteDouce(couleur),
          shape: BoxShape.circle,
        ),
        child: contenu.isEmpty && iconeVide != null
            ? Icon(iconeVide, size: taille / 2, color: couleur)
            : Text(
                contenu.isEmpty ? '?' : contenu,
                textScaler: TextScaler.noScaling,
                style: TextStyle(
                  color: couleur,
                  fontSize: taille * (lettres > 1 ? 0.35 : 0.42),
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }
}
