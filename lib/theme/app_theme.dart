import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Couleurs de la direction artistique Piste.
///
/// Seul l'accent est imposé : fonds, cartes, barres et dialogues prennent
/// les couleurs système (palette Material 3 dérivée de l'accent sur
/// Android, couleurs dynamiques sur iOS) pour qu'aucun écran ne mélange une
/// teinte maison et un composant natif.
///
/// Le teal de marque (#008F93) n'atteint que 3,9:1 sous un texte blanc : il
/// est assombri en [accentClair] (5,5:1 en blanc, 4,9:1 sur le fond groupé
/// iOS) pour tout ce qui porte du texte. En sombre, le turquoise porte un
/// texte foncé.
abstract final class PisteCouleurs {
  static const accentClair = Color(0xFF007579);
  static const turquoise = Color(0xFF00BEB4);

  /// Fond d'action destructive sous texte blanc (5,4:1).
  static const rougeDestructif = Color(0xFFD70015);

  /// Couleur d'accent iOS, résolue selon l'apparence.
  static const accentIos = CupertinoDynamicColor.withBrightness(
    color: accentClair,
    darkColor: turquoise,
  );
}

/// Rayons : une valeur par plateforme, utilisée par toutes les surfaces.
abstract final class PisteRayons {
  /// Cartes et sections groupées iOS 26.
  static const ios = 22.0;

  /// Cartes Material 3 (forme « large »).
  static const material = 16.0;
}

/// Thème Material 3 (Android) : palette générée depuis l'accent, sans
/// surface personnalisée. Sur iOS, les widgets Cupertino et natifs prennent
/// la couleur d'accent mais gardent les couleurs système.
ThemeData pisteTheme(Brightness brightness) {
  final sombre = brightness == Brightness.dark;
  final base = ColorScheme.fromSeed(
    seedColor: PisteCouleurs.accentClair,
    brightness: brightness,
  );
  final scheme = base.copyWith(
    primary: sombre ? PisteCouleurs.turquoise : PisteCouleurs.accentClair,
    onPrimary: sombre ? base.onPrimaryFixed : Colors.white,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    cardTheme: CardThemeData(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(PisteRayons.material),
        side: BorderSide(color: scheme.outlineVariant),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    // Champ « outlined » Material 3 : bordure `outline` (3:1, WCAG 1.4.11).
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(),
    ),
    // Chips : rendu Material 3 par défaut, seule la bordure gagne en
    // contraste.
    chipTheme: ChipThemeData(side: BorderSide(color: scheme.outline)),
    cupertinoOverrideTheme: const CupertinoThemeData(
      primaryColor: PisteCouleurs.accentIos,
    ),
  );
}
