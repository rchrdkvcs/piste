import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import 'barre.dart';
import 'plateforme.dart';
import 'typo.dart';

class Filtre<T extends Object> {
  const Filtre({
    required this.libelle,
    required this.nom,
    required this.tous,
    required this.options,
    required this.valeur,
    required this.onChanged,
  });

  final String libelle;
  final String nom;
  final String tous;
  final Map<T, String> options;
  final T? valeur;
  final ValueChanged<T?> onChanged;

  List<T?> get _choix => [null, ...options.keys];

  String _libelle(T? cle) => cle == null ? tous : options[cle]!;

  ActionBarre actionIos() {
    final actif = valeur != null;
    return ActionBarre(
      libelle: libelle,
      symbole: actif
          ? 'line.3.horizontal.decrease.circle.fill'
          : 'line.3.horizontal.decrease.circle',
      iconeCupertino: actif
          ? CupertinoIcons.line_horizontal_3_decrease_circle_fill
          : CupertinoIcons.line_horizontal_3_decrease_circle,
      menu: [
        for (final cle in _choix)
          OptionMenu(libelle: _libelle(cle), selectionnee: cle == valeur),
      ],
      onMenu: (i) => onChanged(_choix[i]),
    );
  }

  Widget sliver(BuildContext context) {
    if (!estCupertino(context)) return SliverToBoxAdapter(child: _Puces(this));
    final actif = valeur;
    if (actif == null) return const SliverToBoxAdapter();
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(
        PisteEspaces.marge,
        12,
        PisteEspaces.marge,
        0,
      ),
      sliver: SliverToBoxAdapter(child: _FiltreActif(this, actif)),
    );
  }
}

class _Puces<T extends Object> extends StatelessWidget {
  const _Puces(this.filtre);

  final Filtre<T> filtre;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(
        PisteEspaces.marge,
        12,
        PisteEspaces.marge,
        0,
      ),
      child: Row(
        children: [
          for (final cle in filtre._choix)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(filtre._libelle(cle)),
                selected: filtre.valeur == cle,
                onSelected: (_) => filtre.onChanged(cle),
              ),
            ),
        ],
      ),
    );
  }
}

class _FiltreActif<T extends Object> extends StatelessWidget {
  const _FiltreActif(this.filtre, this.actif);

  final Filtre<T> filtre;
  final T actif;

  @override
  Widget build(BuildContext context) {
    final libelle = filtre._libelle(actif);
    return Row(
      children: [
        Text(filtre.nom, style: Typo.secondaire(context)),
        const SizedBox(width: 8),
        Semantics(
          label: 'Retirer le filtre $libelle',
          excludeSemantics: true,
          button: true,
          child: CupertinoButton.tinted(
            sizeStyle: CupertinoButtonSize.small,
            onPressed: () => filtre.onChanged(null),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(libelle),
                const SizedBox(width: 6),
                const Icon(CupertinoIcons.xmark, size: 12),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
