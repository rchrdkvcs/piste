import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../theme/typo.dart';
import 'plateforme.dart';

/// Ligne d'une [SectionListe] : icône, titre, détail, action éventuelle.
class LigneListe {
  const LigneListe({
    required this.titre,
    this.iconeMaterial,
    this.iconeCupertino,
    this.couleurIcone,
    this.detail,
    this.sousTitre,
    this.onTap,
  });

  final String titre;
  final IconData? iconeMaterial;
  final IconData? iconeCupertino;
  final Color? couleurIcone;
  final String? detail;
  final String? sousTitre;
  final VoidCallback? onTap;
}

/// Groupe de lignes : `CupertinoListSection.insetGrouped` façon Réglages
/// iOS, ou `Card` de `ListTile` Material 3.
class SectionListe extends StatelessWidget {
  const SectionListe({super.key, this.titre, required this.lignes, this.pied});

  final String? titre;
  final String? pied;
  final List<LigneListe> lignes;

  @override
  Widget build(BuildContext context) =>
      estCupertino(context) ? _cupertino(context) : _material(context);

  Widget _cupertino(BuildContext context) {
    final t = titre;
    final p = pied;
    return CupertinoListSection.insetGrouped(
      header: t == null ? null : Text(t),
      footer: p == null ? null : Text(p, style: Typo.legende(context)),
      hasLeading: lignes.any((l) => l.iconeCupertino != null),
      decoration: BoxDecoration(
        color: couleurCarte(context),
        borderRadius: BorderRadius.circular(PisteRayons.ios),
      ),
      children: [
        for (final l in lignes)
          CupertinoListTile.notched(
            leading: l.iconeCupertino == null
                ? null
                : Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: l.couleurIcone ?? couleurAccent(context),
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
            subtitle: l.sousTitre == null ? null : Text(l.sousTitre!),
            additionalInfo: l.detail == null ? null : Text(l.detail!),
            trailing: l.onTap != null ? const CupertinoListTileChevron() : null,
            onTap: l.onTap,
          ),
      ],
    );
  }

  Widget _material(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final t = titre;
    final p = pied;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (t != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Semantics(
                header: true,
                child: Text(t, style: Typo.section(context)),
              ),
            ),
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                for (final (i, l) in lignes.indexed) ...[
                  if (i > 0) const Divider(height: 1, indent: 56),
                  ListTile(
                    leading: l.iconeMaterial == null
                        ? null
                        : Icon(l.iconeMaterial, color: scheme.onSurfaceVariant),
                    title: Text(l.titre),
                    subtitle: _sousTitreMaterial(l),
                    trailing: l.onTap != null
                        ? const Icon(Icons.chevron_right)
                        : null,
                    onTap: l.onTap,
                  ),
                ],
              ],
            ),
          ),
          if (p != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 8, 4, 0),
              child: Text(p, style: Theme.of(context).textTheme.bodySmall),
            ),
        ],
      ),
    );
  }

  Widget? _sousTitreMaterial(LigneListe l) {
    final texte = [l.sousTitre, l.detail].whereType<String>().join(' · ');
    return texte.isEmpty ? null : Text(texte);
  }
}

/// Section groupée contenant un bloc libre (notes…), avec le même titre et
/// les mêmes marges que [SectionListe].
class SectionContenu extends StatelessWidget {
  const SectionContenu({super.key, required this.titre, required this.child});

  final String titre;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (estCupertino(context)) {
      return CupertinoListSection.insetGrouped(
        header: Text(titre),
        decoration: BoxDecoration(
          color: couleurCarte(context),
          borderRadius: BorderRadius.circular(PisteRayons.ios),
        ),
        children: [
          SizedBox(
            width: double.infinity,
            child: Padding(padding: const EdgeInsets.all(16), child: child),
          ),
        ],
      );
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Semantics(
              header: true,
              child: Text(titre, style: Typo.section(context)),
            ),
          ),
          Card(
            child: Padding(padding: const EdgeInsets.all(16), child: child),
          ),
        ],
      ),
    );
  }
}
