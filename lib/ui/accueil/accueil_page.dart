import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../format/dates.dart';
import '../../format/texte.dart';
import '../../models/candidature.dart';
import '../../state/candidature_controller.dart';
import '../../state/preferences_controller.dart';
import '../../theme/statut_couleurs.dart';
import '../adaptive/adaptive.dart';
import '../formulaire/candidature_form_page.dart';
import '../widgets/indicateur.dart';
import '../widgets/liste_candidatures.dart';
import '../widgets/logo_piste.dart';
import '../widgets/vues_etat.dart';

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
          actionPrincipale: controller.lisible
              ? ActionPrincipale(
                  libelle: 'Ajouter une candidature',
                  libelleCourt: 'Ajouter',
                  onPressed: ajouter,
                )
              : null,
          slivers: switch (controller.etat) {
            EtatChargement.chargement => const [VueChargement()],
            EtatChargement.erreur => [VueErreurLecture(controller: controller)],
            EtatChargement.vide => [
              VueMessage(
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
              _indicateurs(context),
            ],
          ),
        ),
      ),
      if (aRelancer.isNotEmpty) ...[
        Marge(
          sliver: SliverToBoxAdapter(
            child: TitreSection(
              '${pluriel(aRelancer.length, 'candidature')} à relancer',
            ),
          ),
        ),
        SliverCandidatures(
          candidatures: aRelancer,
          controller: controller,
          precision: (c) => 'Relance ${echeanceRelative(c.prochaineRelance!)}',
        ),
      ],
      Marge(
        sliver: SliverToBoxAdapter(
          child: TitreSection(
            'Dernières candidatures',
            action: voirTout == null
                ? null
                : BoutonTexte(
                    libelle: 'Tout voir',
                    semantique: 'Voir toutes les candidatures',
                    onPressed: voirTout,
                  ),
          ),
        ),
      ),
      SliverCandidatures(
        candidatures: controller.candidatures.take(_nombreRecentes).toList(),
        controller: controller,
      ),
    ];
  }

  Widget _indicateurs(BuildContext context) {
    final i = controller.indicateurs;
    Widget carte(
      int valeur,
      String libelle,
      IconData m,
      IconData c,
      Statut s,
    ) => Expanded(
      child: Indicateur(
        valeur: valeur,
        libelle: libelle,
        icone: icone(context, m, c),
        couleur: s.couleur,
      ),
    );
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          carte(
            i.total,
            'Candidatures',
            Icons.work_outline,
            CupertinoIcons.briefcase_fill,
            Statut.enCours,
          ),
          carte(
            i.compter(Statut.entretien),
            'Entretiens',
            Icons.event_available_outlined,
            CupertinoIcons.person_2_fill,
            Statut.entretien,
          ),
          carte(
            i.compter(Statut.offre),
            'Offres',
            Icons.star_outline_rounded,
            CupertinoIcons.star_fill,
            Statut.offre,
          ),
        ],
      ),
    );
  }
}
