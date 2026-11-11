import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'plateforme.dart';

abstract final class Typo {
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

  static TextStyle grandTitre(BuildContext context) => _role(
    context,
    ios: 34,
    material: (t) => t.headlineMedium,
    poids: FontWeight.w700,
    hauteur: 1.15,
  );

  static TextStyle titre(BuildContext context) => _role(
    context,
    ios: 22,
    material: (t) => t.headlineSmall,
    poids: FontWeight.w700,
    hauteur: 1.25,
  );

  static TextStyle section(BuildContext context) => _role(
    context,
    ios: 20,
    material: (t) => t.titleLarge,
    poids: FontWeight.w600,
    hauteur: 1.25,
  );

  static TextStyle corps(BuildContext context) =>
      _role(context, ios: 17, material: (t) => t.bodyLarge, hauteur: 1.4);

  static TextStyle corpsGras(BuildContext context) =>
      corps(context).copyWith(fontWeight: FontWeight.w600);

  static TextStyle secondaire(BuildContext context) => _role(
    context,
    ios: 15,
    material: (t) => t.bodyMedium,
    hauteur: 1.4,
  ).copyWith(color: couleurTexteSecondaire(context));

  static TextStyle legende(BuildContext context) => _role(
    context,
    ios: 13,
    material: (t) => t.labelMedium,
    hauteur: 1.3,
  ).copyWith(color: couleurTexteSecondaire(context));

  static TextStyle chiffre(BuildContext context, {double taille = 28}) =>
      _base(context).copyWith(
        fontSize: taille,
        fontWeight: FontWeight.w700,
        height: 1.1,
        fontFeatures: const [FontFeature.tabularFigures()],
      );
}

class TexteSysteme extends StatelessWidget {
  const TexteSysteme({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => estCupertino(context)
      ? DefaultTextStyle(
          style: CupertinoTheme.of(context).textTheme.textStyle,
          child: child,
        )
      : child;
}

class LuminositeImposee extends StatelessWidget {
  const LuminositeImposee({super.key, required this.mode, required this.child});

  final ThemeMode mode;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final luminosite = switch (mode) {
      ThemeMode.light => Brightness.light,
      ThemeMode.dark => Brightness.dark,
      ThemeMode.system => null,
    };
    if (luminosite == null) return child;
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(platformBrightness: luminosite),
      child: child,
    );
  }
}
