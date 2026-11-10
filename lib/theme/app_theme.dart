import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

abstract final class PisteCouleurs {
  static const accentClair = Color(0xFF007579);
  static const turquoise = Color(0xFF00BEB4);

  static const rougeDestructif = Color(0xFFD70015);

  static const accentIos = CupertinoDynamicColor.withBrightness(
    color: accentClair,
    darkColor: turquoise,
  );
}

abstract final class PisteRayons {
  static const ios = 22.0;

  static const material = 16.0;
}

abstract final class PisteEspaces {
  static const marge = 20.0;
  static const entreLignes = 10.0;
  static const entreChamps = 16.0;
}

Color teinteDouce(Color couleur) => couleur.withValues(alpha: 0.14);

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
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(),
    ),
    chipTheme: ChipThemeData(side: BorderSide(color: scheme.outline)),
    cupertinoOverrideTheme: const CupertinoThemeData(
      primaryColor: PisteCouleurs.accentIos,
    ),
  );
}
