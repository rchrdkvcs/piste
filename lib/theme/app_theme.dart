import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Couleurs de la direction artistique Piste.
///
/// Le teal de marque (#008F93) n'atteint que 3,9:1 sous un texte blanc : il
/// est assombri en [accentClair] (5,5:1 en blanc, 4,9:1 sur le fond groupé
/// iOS) pour tout ce qui porte du texte. En sombre, le turquoise porte un
/// texte encre (7,3:1).
abstract final class PisteCouleurs {
  static const accentClair = Color(0xFF007579);
  static const turquoise = Color(0xFF00BEB4);
  static const encre = Color(0xFF0B1D32);
  static const fondClair = Color(0xFFF5F7F9);
  static const carteSombre = Color(0xFF13293F);
  static const bordureClaire = Color(0xFFE4E9EE);
  static const bordureSombre = Color(0xFF233B55);

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

/// Thème Material 3 (Android). Sur iOS, les widgets Cupertino et natifs
/// prennent la couleur d'accent mais gardent les couleurs système.
ThemeData pisteTheme(Brightness brightness) {
  final sombre = brightness == Brightness.dark;
  final accent = sombre ? PisteCouleurs.turquoise : PisteCouleurs.accentClair;
  final surAccent = sombre ? PisteCouleurs.encre : Colors.white;

  final scheme =
      ColorScheme.fromSeed(
        seedColor: PisteCouleurs.accentClair,
        brightness: brightness,
      ).copyWith(
        primary: accent,
        onPrimary: surAccent,
        surface: sombre ? PisteCouleurs.encre : PisteCouleurs.fondClair,
        onSurface: sombre ? const Color(0xFFE8EEF3) : PisteCouleurs.encre,
        surfaceContainerLowest: sombre
            ? PisteCouleurs.carteSombre
            : Colors.white,
        outlineVariant: sombre
            ? PisteCouleurs.bordureSombre
            : PisteCouleurs.bordureClaire,
      );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: scheme.surface,
    cardTheme: CardThemeData(
      color: scheme.surfaceContainerLowest,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(PisteRayons.material),
        side: BorderSide(color: scheme.outlineVariant),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      surfaceTintColor: Colors.transparent,
      centerTitle: false,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: scheme.surfaceContainerLowest,
      indicatorColor: accent.withValues(alpha: 0.16),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: accent,
      foregroundColor: surAccent,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: scheme.surfaceContainerLowest,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: scheme.outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        // Bordure de champ : 3:1 minimum (WCAG 1.4.11), d'où `outline`.
        borderSide: BorderSide(color: scheme.outline),
      ),
    ),
    // Chips : rendu Material 3 par défaut (sélection en secondaryContainer,
    // texte onSecondaryContainer), seule la bordure gagne en contraste.
    chipTheme: ChipThemeData(side: BorderSide(color: scheme.outline)),
    cupertinoOverrideTheme: const CupertinoThemeData(
      primaryColor: PisteCouleurs.accentIos,
    ),
  );
}
