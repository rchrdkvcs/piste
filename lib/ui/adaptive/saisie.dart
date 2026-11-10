import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import 'elements.dart';
import 'plateforme.dart';
import 'typo.dart';

class PageSaisie extends StatelessWidget {
  const PageSaisie({
    super.key,
    required this.titre,
    required this.enCours,
    required this.onAnnuler,
    required this.onEnregistrer,
    required this.sections,
  });

  final String titre;
  final bool enCours;
  final VoidCallback onAnnuler;
  final VoidCallback onEnregistrer;
  final List<Widget> sections;

  @override
  Widget build(BuildContext context) =>
      estCupertino(context) ? _cupertino(context) : _material(context);

  Widget _cupertino(BuildContext context) {
    final fond = CupertinoColors.systemGroupedBackground.resolveFrom(context);
    return CupertinoPageScaffold(
      backgroundColor: fond,
      navigationBar: CupertinoNavigationBar(
        automaticallyImplyLeading: false,
        backgroundColor: fond,
        border: null,
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: enCours ? null : onAnnuler,
          child: const Text('Annuler'),
        ),
        middle: Text(titre),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: enCours ? null : onEnregistrer,
          child: const Text(
            'Enregistrer',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ),
      child: SafeArea(
        child: Stack(
          children: [
            ListView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.only(bottom: 24),
              children: sections,
            ),
            if (enCours)
              const Positioned.fill(
                child: ColoredBox(
                  color: Color(0x14000000),
                  child: Center(child: CupertinoActivityIndicator(radius: 14)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _material(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: CloseButton(onPressed: enCours ? null : onAnnuler),
        title: Text(titre),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: enCours
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox.square(
                      dimension: 24,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    ),
                  )
                : TextButton(
                    onPressed: onEnregistrer,
                    child: const Text('Enregistrer'),
                  ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            PisteEspaces.marge,
            0,
            PisteEspaces.marge,
            32,
          ),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          children: sections,
        ),
      ),
    );
  }
}

class SectionFormulaire extends StatelessWidget {
  const SectionFormulaire({
    super.key,
    required this.titre,
    required this.children,
    this.pied,
  });

  final String titre;
  final String? pied;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final p = pied;
    final legende = p == null ? null : Text(p, style: Typo.legende(context));
    if (estCupertino(context)) {
      return CupertinoFormSection.insetGrouped(
        header: Text(titre),
        footer: legende,
        decoration: decorationGroupee(context),
        children: children,
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TitreSection(
          titre,
          padding: const EdgeInsets.only(top: 24, bottom: 16),
        ),
        for (final (i, champ) in children.indexed) ...[
          if (i > 0) const SizedBox(height: PisteEspaces.entreChamps),
          champ,
        ],
        if (legende != null)
          Padding(padding: const EdgeInsets.only(top: 8), child: legende),
      ],
    );
  }
}
