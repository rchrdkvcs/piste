import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../format/texte.dart';
import '../../models/candidature.dart';
import '../../state/candidature_controller.dart';
import '../adaptive/adaptive.dart';
import '../formulaire/candidature_form_page.dart';
import '../widgets/liste_candidatures.dart';
import '../widgets/vues_etat.dart';

class CandidaturesPage extends StatefulWidget {
  const CandidaturesPage({super.key, required this.controller});

  final CandidatureController controller;

  @override
  State<CandidaturesPage> createState() => _CandidaturesPageState();
}

class _CandidaturesPageState extends State<CandidaturesPage> {
  late final _recherche = TextEditingController(
    text: widget.controller.recherche,
  );

  CandidatureController get _controller => widget.controller;

  @override
  void dispose() {
    _recherche.dispose();
    super.dispose();
  }

  void _effacer() {
    _recherche.clear();
    _controller.reinitialiserFiltres();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        void ajouter() => ouvrirFormulaire(context, _controller);
        final pret = _controller.etat == EtatChargement.pret;
        return AdaptivePage(
          titre: 'Candidatures',
          surActualisation: () => _controller.charger(silencieux: true),
          actionPrincipale: _controller.lisible
              ? ActionPrincipale(
                  libelle: 'Ajouter une candidature',
                  libelleCourt: 'Ajouter',
                  onPressed: ajouter,
                )
              : null,
          filtre: pret
              ? Filtre<Statut>(
                  libelle: 'Filtrer par statut',
                  nom: 'Statut',
                  tous: 'Tous',
                  options: {for (final s in Statut.values) s: s.libelle},
                  valeur: _controller.filtre,
                  onChanged: _controller.filtrer,
                )
              : null,
          entete: [
            if (pret)
              Marge(
                haut: 4,
                sliver: SliverToBoxAdapter(
                  child: ChampRecherche(
                    controller: _recherche,
                    indication: 'Entreprise, poste ou contact',
                    onChanged: _controller.rechercher,
                  ),
                ),
              ),
          ],
          slivers: switch (_controller.etat) {
            EtatChargement.chargement => const [VueChargement()],
            EtatChargement.erreur => [
              VueErreurLecture(controller: _controller),
            ],
            EtatChargement.vide => [
              VueMessage(
                icone: icone(
                  context,
                  Icons.work_outline,
                  CupertinoIcons.briefcase,
                ),
                titre: 'Aucune candidature',
                message: 'Les candidatures que tu ajoutes apparaissent ici.',
                action: 'Ajouter une candidature',
                onAction: ajouter,
              ),
            ],
            EtatChargement.pret => _liste(context),
          },
        );
      },
    );
  }

  List<Widget> _liste(BuildContext context) {
    final visibles = _controller.visibles;
    if (visibles.isNotEmpty) {
      return [
        SliverCandidatures(
          candidatures: visibles,
          controller: _controller,
          supprimable: true,
          haut: 16,
        ),
      ];
    }
    final criteres = descriptionCriteres(
      _controller.recherche,
      _controller.filtre,
    );
    return [
      VueMessage(
        icone: icone(context, Icons.search_off, CupertinoIcons.search),
        titre: 'Aucun résultat',
        message: 'Aucune candidature ne correspond à $criteres.',
        action: 'Effacer les filtres',
        onAction: _effacer,
      ),
    ];
  }
}
