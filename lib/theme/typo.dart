import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../ui/adaptive/plateforme.dart';

/// Échelle typographique par rôle.
///
/// iOS suit les tailles Apple (SF Pro : Large Title 34, Title 2 22,
/// Title 3 20, Body 17, Subheadline 15, Footnote 13) ; Android suit
/// l'échelle Material 3 du thème. Les écrans demandent un rôle, jamais une
/// taille.
abstract final class Typo {
  /// Le style Cupertino est `inherit: false` sans ligne de base : certains
  /// widgets (`SelectableText`) l'exigent, on la fournit ici.
  static TextStyle _base(BuildContext context) => estCupertino(context)
      ? CupertinoTheme.of(context).textTheme.textStyle
            .copyWith(textBaseline: TextBaseline.alphabetic)
      : Theme.of(context).textTheme.bodyLarge!;

  static TextStyle _role(
    BuildContext context, {
    required double ios,
    required TextStyle? Function(TextTheme) material,
    FontWeight? poids,
    double? hauteur,
  }) {
    final style = estCupertino(context)
        ? _base(context).copyWith(fontSize: ios)
        : material(Theme.of(context).textTheme) ?? _base(context);
    return style.copyWith(fontWeight: poids, height: hauteur);
  }

  /// Titre de page déroulant avec le contenu.
  static TextStyle grandTitre(BuildContext context) => _role(
    context,
    ios: 34,
    material: (t) => t.headlineMedium,
    poids: FontWeight.w700,
    hauteur: 1.15,
  );

  /// Nom d'une candidature en tête de fiche, salutation.
  static TextStyle titre(BuildContext context) => _role(
    context,
    ios: 22,
    material: (t) => t.headlineSmall,
    poids: FontWeight.w700,
    hauteur: 1.25,
  );

  /// Titre de section.
  static TextStyle section(BuildContext context) => _role(
    context,
    ios: 20,
    material: (t) => t.titleLarge,
    poids: FontWeight.w600,
    hauteur: 1.25,
  );

  /// Texte courant et intitulés de lignes.
  static TextStyle corps(BuildContext context) =>
      _role(context, ios: 17, material: (t) => t.bodyLarge, hauteur: 1.4);

  static TextStyle corpsGras(BuildContext context) =>
      corps(context).copyWith(fontWeight: FontWeight.w600);

  /// Texte d'appoint (poste, description).
  static TextStyle secondaire(BuildContext context) => _role(
    context,
    ios: 15,
    material: (t) => t.bodyMedium,
    hauteur: 1.4,
  ).copyWith(color: couleurTexteSecondaire(context));

  /// Légendes sous un chiffre, pastilles.
  static TextStyle legende(BuildContext context) => _role(
    context,
    ios: 13,
    material: (t) => t.labelMedium,
    hauteur: 1.3,
  ).copyWith(color: couleurTexteSecondaire(context));

  /// Chiffres d'indicateurs : chasse fixe pour qu'ils ne bougent pas.
  static TextStyle chiffre(BuildContext context, {double taille = 28}) =>
      _base(context).copyWith(
        fontSize: taille,
        fontWeight: FontWeight.w700,
        height: 1.1,
        fontFeatures: const [FontFeature.tabularFigures()],
      );
}
