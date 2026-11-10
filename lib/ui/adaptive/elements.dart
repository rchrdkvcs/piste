import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../theme/typo.dart';
import 'plateforme.dart';

/// Marges horizontales communes des pages.
class Marge extends StatelessWidget {
  const Marge({super.key, required this.sliver, this.haut = 0});

  final Widget sliver;
  final double haut;

  @override
  Widget build(BuildContext context) => SliverPadding(
    padding: EdgeInsets.fromLTRB(20, haut, 20, 0),
    sliver: sliver,
  );
}

/// Carte arrondie : surface groupée sans bordure sur iOS, `Card` Material.
class Carte extends StatelessWidget {
  const Carte({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final contenu = padding == null
        ? child
        : Padding(padding: padding!, child: child);
    if (estCupertino(context)) {
      final rayon = BorderRadius.circular(PisteRayons.ios);
      return DecoratedBox(
        decoration: BoxDecoration(
          color: couleurCarte(context),
          borderRadius: rayon,
        ),
        child: ClipRRect(borderRadius: rayon, child: contenu),
      );
    }
    return Card(clipBehavior: Clip.antiAlias, child: contenu);
  }
}

/// Titre de section au-dessus d'un groupe de cartes.
class TitreSection extends StatelessWidget {
  const TitreSection(this.texte, {super.key, this.action});

  final String texte;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 32, bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Semantics(
              header: true,
              child: Text(texte, style: Typo.section(context)),
            ),
          ),
          ?action,
        ],
      ),
    );
  }
}

/// Action principale de l'écran : bouton Liquid Glass teinté sur iOS 26,
/// `FilledButton` Material 3 sur Android.
class BoutonPrincipal extends StatelessWidget {
  const BoutonPrincipal({
    super.key,
    required this.libelle,
    required this.onPressed,
    this.icone,
  });

  final String libelle;
  final VoidCallback? onPressed;
  final IconData? icone;

  @override
  Widget build(BuildContext context) {
    if (estCupertino(context)) {
      return SizedBox(
        width: double.infinity,
        height: 52,
        child: AdaptiveButton(
          onPressed: onPressed,
          enabled: onPressed != null,
          label: libelle,
          color: couleurAccent(context),
          style: PlatformInfo.isIOS26OrHigher()
              ? AdaptiveButtonStyle.prominentGlass
              : AdaptiveButtonStyle.filled,
          size: AdaptiveButtonSize.large,
        ),
      );
    }
    final ic = icone;
    return ic == null
        ? FilledButton(onPressed: onPressed, child: Text(libelle))
        : FilledButton.icon(
            onPressed: onPressed,
            icon: Icon(ic),
            label: Text(libelle),
          );
  }
}

/// Contrôle segmenté : `UISegmentedControl` natif sur iOS, `SegmentedButton`.
class Segments<T extends Object> extends StatelessWidget {
  const Segments({
    super.key,
    required this.valeur,
    required this.options,
    required this.onChanged,
  });

  final T valeur;
  final Map<T, String> options;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final cles = options.keys.toList();
    if (estCupertino(context)) {
      return SizedBox(
        width: double.infinity,
        child: AdaptiveSegmentedControl(
          labels: options.values.toList(),
          selectedIndex: cles.indexOf(valeur),
          onValueChanged: (i) => onChanged(cles[i]),
        ),
      );
    }
    return SizedBox(
      width: double.infinity,
      child: SegmentedButton<T>(
        showSelectedIcon: false,
        selected: {valeur},
        onSelectionChanged: (s) => onChanged(s.first),
        segments: [
          for (final e in options.entries)
            ButtonSegment(value: e.key, label: Text(e.value)),
        ],
      ),
    );
  }
}
