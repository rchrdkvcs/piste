import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import 'elements.dart';
import 'plateforme.dart';
import 'typo.dart';

enum TeinteIcone {
  gris(CupertinoColors.systemGrey),
  bleu(CupertinoColors.systemBlue),
  vert(CupertinoColors.systemGreen),
  indigo(CupertinoColors.systemIndigo),
  orange(CupertinoColors.systemOrange),
  rouge(CupertinoColors.systemRed),
  sarcelle(CupertinoColors.systemTeal);

  const TeinteIcone(this.couleur);

  final CupertinoDynamicColor couleur;
}

class LigneListe {
  const LigneListe({
    required this.titre,
    this.iconeMaterial,
    this.iconeCupertino,
    this.teinte,
    this.detail,
    this.sousTitre,
    this.onTap,
  });

  final String titre;
  final IconData? iconeMaterial;
  final IconData? iconeCupertino;
  final TeinteIcone? teinte;
  final String? detail;
  final String? sousTitre;
  final VoidCallback? onTap;
}

class SectionListe extends StatelessWidget {
  const SectionListe({super.key, this.titre, required this.lignes, this.pied});

  final String? titre;
  final String? pied;
  final List<LigneListe> lignes;

  @override
  Widget build(BuildContext context) {
    final cupertino = estCupertino(context);
    return _Section(
      titre: titre,
      pied: pied,
      avecIcones: lignes.any((l) => l.iconeCupertino != null),
      children: [
        for (final l in lignes)
          cupertino ? _ligneCupertino(context, l) : _ligneMaterial(context, l),
      ],
    );
  }

  Widget _ligneCupertino(BuildContext context, LigneListe l) {
    final sousTitre = l.sousTitre;
    final detail = l.detail;
    return CupertinoListTile.notched(
      leading: l.iconeCupertino == null
          ? null
          : Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color:
                    l.teinte?.couleur.resolveFrom(context) ??
                    couleurAccent(context),
                borderRadius: BorderRadius.circular(7),
              ),
              child: Icon(
                l.iconeCupertino,
                color: CupertinoColors.white,
                size: 18,
              ),
            ),
      leadingSize: 30,
      title: Text(l.titre),
      subtitle: sousTitre == null ? null : Text(sousTitre),
      additionalInfo: detail == null ? null : Text(detail),
      trailing: l.onTap != null ? const CupertinoListTileChevron() : null,
      onTap: l.onTap,
    );
  }

  Widget _ligneMaterial(BuildContext context, LigneListe l) {
    final texte = [l.sousTitre, l.detail].whereType<String>().join(' · ');
    return ListTile(
      leading: l.iconeMaterial == null
          ? null
          : Icon(
              l.iconeMaterial,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
      title: Text(l.titre),
      subtitle: texte.isEmpty ? null : Text(texte),
      trailing: l.onTap != null ? const Icon(Icons.chevron_right) : null,
      onTap: l.onTap,
    );
  }
}

class SectionContenu extends StatelessWidget {
  const SectionContenu({super.key, required this.titre, required this.child});

  final String titre;
  final Widget child;

  @override
  Widget build(BuildContext context) => _Section(
    titre: titre,
    children: [
      SizedBox(
        width: double.infinity,
        child: Padding(padding: const EdgeInsets.all(16), child: child),
      ),
    ],
  );
}

class _Section extends StatelessWidget {
  const _Section({
    required this.children,
    this.titre,
    this.pied,
    this.avecIcones = false,
  });

  final String? titre;
  final String? pied;
  final bool avecIcones;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final t = titre;
    final p = pied;
    if (estCupertino(context)) {
      return CupertinoListSection.insetGrouped(
        header: t == null ? null : Text(t),
        footer: p == null ? null : Text(p, style: Typo.legende(context)),
        hasLeading: avecIcones,
        decoration: decorationGroupee(context),
        children: children,
      );
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        PisteEspaces.marge,
        24,
        PisteEspaces.marge,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (t != null)
            TitreSection(t, padding: const EdgeInsets.only(bottom: 12)),
          CarteLignes(retrait: avecIcones ? 56 : 16, children: children),
          if (p != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 8, 4, 0),
              child: Text(p, style: Theme.of(context).textTheme.bodySmall),
            ),
        ],
      ),
    );
  }
}

class LigneCarte extends StatelessWidget {
  const LigneCarte({
    super.key,
    required this.titre,
    required this.sousTitre,
    this.avant,
    this.badge,
    this.onTap,
  });

  final Widget titre;
  final Widget sousTitre;
  final Widget? avant;
  final Widget? badge;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    if (estCupertino(context)) {
      return Carte(
        child: CupertinoListTile(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          leadingSize: 44,
          leading: avant,
          title: titre,
          subtitle: sousTitre,
          additionalInfo: badge,
          trailing: const CupertinoListTileChevron(),
          onTap: onTap,
        ),
      );
    }
    return Carte(
      child: ListTile(
        contentPadding: const EdgeInsets.fromLTRB(16, 8, 12, 8),
        leading: avant,
        title: titre,
        subtitle: sousTitre,
        trailing: badge,
        onTap: onTap,
      ),
    );
  }
}
