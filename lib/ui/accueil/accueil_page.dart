import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../format/dates.dart';
import '../../models/candidature.dart';
import '../../state/candidature_controller.dart';
import '../../state/preferences_controller.dart';
import '../../theme/statut_couleurs.dart';
import '../../theme/typo.dart';
import '../adaptive/adaptive.dart';
import '../fiche/candidature_detail_page.dart';
import '../formulaire/candidature_form_page.dart';
import '../widgets/candidature_tile.dart';
import '../widgets/indicateur.dart';
import '../widgets/logo_piste.dart';
import '../widgets/vues_etat.dart';

/// Tableau de bord : salutation, indicateurs et dernières candidatures.
class AccueilPage extends StatelessWidget {
  const AccueilPage({
    super.key,
    required this.controller,
    this.preferences,
    this.onVoirTout,
  });

  final CandidatureController controller;
  final PreferencesController? preferences;
  final VoidCallback? onVoirTout;

  static const _nombreRecentes = 4;

  @override
  Widget build(BuildContext context) {
    final prefs = preferences;
    return ListenableBuilder(
      listenable: Listenable.merge([controller, ?prefs]),
      builder: (context, _) {
        void ajouter() => ouvrirFormulaire(context, controller);
        final nom = prefs?.prenom ?? '';
        return AdaptivePage(
          titre: nom.isEmpty ? 'Bonjour' : 'Bonjour, $nom',
          surActualisation: () => controller.charger(silencieux: true),
          actions: [
            ActionBarre(
              libelle: 'Ajouter une candidature',
              symbole: 'plus',
              iconeCupertino: CupertinoIcons.add,
              principale: true,
              seulementIos: true,
              onPressed: ajouter,
            ),
          ],
          boutonFlottant: controller.etat == EtatChargement.pret
              ? FloatingActionButton.extended(
                  heroTag: 'ajouter-accueil',
                  onPressed: ajouter,
                  icon: const Icon(Icons.add),
                  label: const Text('Ajouter'),
                )
              : null,
          slivers: switch (controller.etat) {
            EtatChargement.chargement => const [VueChargement()],
            EtatChargement.erreur => [VueErreurLecture(controller: controller)],
            EtatChargement.vide => [
              VueMessage(
                icone: icone(
                  context,
                  Icons.work_outline,
                  CupertinoIcons.briefcase,
                ),
                illustration: const LogoPiste(taille: 88),
                titre: 'Bienvenue dans Piste',
                message:
                    'Ajoute une candidature pour suivre son avancement, de '
                    'l’envoi à la réponse.',
                action: 'Ajouter une candidature',
                onAction: ajouter,
              ),
            ],
            EtatChargement.pret => _contenu(context),
          },
        );
      },
    );
  }

  List<Widget> _contenu(BuildContext context) {
    final recentes = controller.candidatures.take(_nombreRecentes).toList();
    final aRelancer = controller.aRelancer();
    final voirTout = onVoirTout;

    return [
      Marge(
        sliver: SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Voici où en sont tes candidatures.',
                style: Typo.secondaire(context),
              ),
              const SizedBox(height: 20),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: Indicateur(
                        valeur: controller.total,
                        libelle: 'Candidatures',
                        icone: icone(
                          context,
                          Icons.work_outline,
                          CupertinoIcons.briefcase_fill,
                        ),
                        couleur: Statut.enCours.couleur,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Indicateur(
                        valeur: controller.compter(Statut.entretien),
                        libelle: 'Entretiens',
                        icone: icone(
                          context,
                          Icons.event_available_outlined,
                          CupertinoIcons.person_2_fill,
                        ),
                        couleur: Statut.entretien.couleur,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Indicateur(
                        valeur: controller.compter(Statut.offre),
                        libelle: 'Offres',
                        icone: icone(
                          context,
                          Icons.star_outline_rounded,
                          CupertinoIcons.star_fill,
                        ),
                        couleur: Statut.offre.couleur,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      if (aRelancer.isNotEmpty) ...[
        Marge(
          sliver: SliverToBoxAdapter(
            child: TitreSection(
              aRelancer.length > 1
                  ? '${aRelancer.length} candidatures à relancer'
                  : '1 candidature à relancer',
            ),
          ),
        ),
        Marge(
          sliver: SliverList.separated(
            itemCount: aRelancer.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final c = aRelancer[i];
              return CandidatureTile(
                candidature: c,
                precision: 'Relance ${echeanceRelative(c.prochaineRelance!)}',
                onTap: () => ouvrirDetail(context, controller, c.id!),
              );
            },
          ),
        ),
      ],
      Marge(
        sliver: SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TitreSection(
                'Dernières candidatures',
                action: voirTout == null
                    ? null
                    : Semantics(
                        label: 'Voir toutes les candidatures',
                        excludeSemantics: true,
                        button: true,
                        child: estCupertino(context)
                            ? CupertinoButton(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                minimumSize: const Size(44, 44),
                                onPressed: voirTout,
                                child: const Text('Tout voir'),
                              )
                            : TextButton(
                                onPressed: voirTout,
                                child: const Text('Tout voir'),
                              ),
                      ),
              ),
            ],
          ),
        ),
      ),
      Marge(
        sliver: SliverList.separated(
          itemCount: recentes.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, i) => CandidatureTile(
            candidature: recentes[i],
            onTap: () => ouvrirDetail(context, controller, recentes[i].id!),
          ),
        ),
      ),
    ];
  }
}
