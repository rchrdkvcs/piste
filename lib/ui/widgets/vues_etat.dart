import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../state/candidature_controller.dart';
import '../../theme/typo.dart';
import '../adaptive/adaptive.dart';

/// Chargement : indicateur natif (roue iOS, cercle Material).
class VueChargement extends StatelessWidget implements SliverPleinEcran {
  const VueChargement({super.key});

  @override
  Widget build(BuildContext context) => SliverFillRemaining(
    hasScrollBody: false,
    child: Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom),
      child: const Center(child: CircularProgressIndicator.adaptive()),
    ),
  );
}

/// État vide, erreur ou aucun résultat : ce qui se passe, puis quoi faire.
class VueMessage extends StatelessWidget implements SliverPleinEcran {
  const VueMessage({
    super.key,
    required this.icone,
    required this.titre,
    required this.message,
    this.action,
    this.onAction,
    this.couleur,
    this.illustration,
  });

  /// Remplace la pastille d'icône (logo sur le premier écran).
  final Widget? illustration;
  final IconData icone;
  final String titre;
  final String message;
  final String? action;
  final VoidCallback? onAction;
  final Color? couleur;

  @override
  Widget build(BuildContext context) {
    final teinte = couleur ?? couleurAccent(context);
    final libelle = action;
    // La marge basse (barre d'onglets, zone sûre) est incluse ici pour que
    // le bloc reste centré dans l'espace visible sans créer de défilement.
    final bas = MediaQuery.paddingOf(context).bottom;
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(32, 16, 32, 16 + bas),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ExcludeSemantics(
              child:
                  illustration ??
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: teinte.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icone, size: 36, color: teinte),
                  ),
            ),
            const SizedBox(height: 20),
            Text(
              titre,
              textAlign: TextAlign.center,
              style: Typo.section(context),
            ),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 320),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: Typo.secondaire(context),
              ),
            ),
            if (libelle != null) ...[
              const SizedBox(height: 24),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 320),
                child: BoutonPrincipal(libelle: libelle, onPressed: onAction),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Lecture SQLite en échec : jamais présentée comme une liste vide.
class VueErreurLecture extends StatelessWidget implements SliverPleinEcran {
  const VueErreurLecture({super.key, required this.controller});

  final CandidatureController controller;

  @override
  Widget build(BuildContext context) => VueMessage(
    icone: icone(
      context,
      Icons.error_outline,
      CupertinoIcons.exclamationmark_triangle,
    ),
    couleur: couleurErreur(context),
    titre: 'Lecture impossible',
    message:
        'Tes candidatures n’ont pas pu être lues. Réessaie dans un instant.',
    action: 'Réessayer',
    onAction: controller.charger,
  );
}
