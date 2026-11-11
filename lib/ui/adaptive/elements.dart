import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import 'plateforme.dart';
import 'typo.dart';

class Marge extends StatelessWidget {
  const Marge({super.key, required this.sliver, this.haut = 0});

  final Widget sliver;
  final double haut;

  @override
  Widget build(BuildContext context) => SliverPadding(
    padding: EdgeInsets.fromLTRB(
      PisteEspaces.marge,
      haut,
      PisteEspaces.marge,
      0,
    ),
    sliver: sliver,
  );
}

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
        decoration: decorationGroupee(context),
        child: ClipRRect(borderRadius: rayon, child: contenu),
      );
    }
    return Card(clipBehavior: Clip.antiAlias, child: contenu);
  }
}

class CarteLignes extends StatelessWidget {
  const CarteLignes({super.key, required this.children, this.retrait = 16});

  final List<Widget> children;
  final double retrait;

  @override
  Widget build(BuildContext context) {
    final couleur = couleurTexteSecondaire(context).withValues(alpha: 0.2);
    return Carte(
      child: Column(
        children: [
          for (final (i, enfant) in children.indexed) ...[
            if (i > 0) Divider(height: 1, indent: retrait, color: couleur),
            enfant,
          ],
        ],
      ),
    );
  }
}

class TitreSection extends StatelessWidget {
  const TitreSection(
    this.texte, {
    super.key,
    this.action,
    this.padding = const EdgeInsets.only(top: 32, bottom: 12),
  });

  final String texte;
  final Widget? action;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
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

class BoutonTexte extends StatelessWidget {
  const BoutonTexte({
    super.key,
    required this.libelle,
    required this.onPressed,
    this.semantique,
  });

  final String libelle;
  final VoidCallback? onPressed;
  final String? semantique;

  @override
  Widget build(BuildContext context) {
    final bouton = estCupertino(context)
        ? CupertinoButton(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            minimumSize: const Size(44, 44),
            onPressed: onPressed,
            child: Text(libelle),
          )
        : TextButton(onPressed: onPressed, child: Text(libelle));
    return Semantics(
      label: semantique ?? libelle,
      excludeSemantics: true,
      button: true,
      child: bouton,
    );
  }
}

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
    return SizedBox(
      width: double.infinity,
      child: estCupertino(context)
          ? CupertinoSlidingSegmentedControl<T>(
              groupValue: valeur,
              onValueChanged: (v) {
                if (v != null) onChanged(v);
              },
              children: {
                for (final e in options.entries)
                  e.key: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Text(e.value, maxLines: 1),
                  ),
              },
            )
          : SegmentedButton<T>(
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
