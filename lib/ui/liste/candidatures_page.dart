import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../models/candidature.dart';
import '../../state/candidature_controller.dart';
import '../adaptive/adaptive.dart';
import '../fiche/actions_candidature.dart';
import '../fiche/candidature_detail_page.dart';
import '../formulaire/candidature_form_page.dart';
import '../widgets/candidature_tile.dart';
import '../widgets/vues_etat.dart';
import 'elements_liste.dart';

/// Liste complète avec recherche texte, filtre de statut et suppression par
/// balayage.
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

  Future<bool> _supprimer(Candidature c) =>
      supprimerAvecConfirmation(context, _controller, c);

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final cupertino = estCupertino(context);
        void ajouter() => ouvrirFormulaire(context, _controller);
        final filtre = _controller.filtre;
        final pret =
            _controller.etat == EtatChargement.pret ||
            _controller.etat == EtatChargement.vide;

        return AdaptivePage(
          titre: 'Candidatures',
          surActualisation: () => _controller.charger(silencieux: true),
          actions: [
            if (_controller.etat == EtatChargement.pret)
              ActionBarre(
                libelle: 'Filtrer par statut',
                symbole: filtre == null
                    ? 'line.3.horizontal.decrease.circle'
                    : 'line.3.horizontal.decrease.circle.fill',
                iconeCupertino: filtre == null
                    ? CupertinoIcons.line_horizontal_3_decrease_circle
                    : CupertinoIcons.line_horizontal_3_decrease_circle_fill,
                seulementIos: true,
                menu: [
                  for (final s in filtresStatut)
                    OptionMenu(
                      libelle: s?.libelle ?? 'Tous les statuts',
                      selectionnee: s == filtre,
                    ),
                ],
                onMenu: (i) => _controller.filtrer(filtresStatut[i]),
              ),
            ActionBarre(
              libelle: 'Ajouter une candidature',
              symbole: 'plus',
              iconeCupertino: CupertinoIcons.add,
              principale: true,
              seulementIos: true,
              onPressed: ajouter,
            ),
          ],
          boutonFlottant: _controller.etat == EtatChargement.pret
              ? FloatingActionButton.extended(
                  heroTag: 'ajouter-liste',
                  onPressed: ajouter,
                  icon: const Icon(Icons.add),
                  label: const Text('Ajouter'),
                )
              : null,
          slivers: [
            if (_controller.etat == EtatChargement.pret)
              Marge(
                haut: 4,
                sliver: SliverToBoxAdapter(
                  child: ChampRecherche(
                    controller: _controller,
                    recherche: _recherche,
                  ),
                ),
              ),
            if (_controller.etat == EtatChargement.pret && !cupertino)
              SliverToBoxAdapter(
                child: FiltresStatutMaterial(controller: _controller),
              ),
            if (cupertino && filtre != null)
              Marge(
                haut: 12,
                sliver: SliverToBoxAdapter(
                  child: FiltreActifCupertino(
                    controller: _controller,
                    filtre: filtre,
                  ),
                ),
              ),
            if (!pret || _controller.etat == EtatChargement.vide)
              ..._etat(context, ajouter)
            else
              ..._liste(context),
          ],
        );
      },
    );
  }

  List<Widget> _etat(BuildContext context, VoidCallback ajouter) {
    return switch (_controller.etat) {
      EtatChargement.chargement => const [VueChargement()],
      EtatChargement.erreur => [VueErreurLecture(controller: _controller)],
      _ => [
        VueMessage(
          icone: icone(context, Icons.work_outline, CupertinoIcons.briefcase),
          titre: 'Aucune candidature',
          message: 'Les candidatures que tu ajoutes apparaissent ici.',
          action: 'Ajouter une candidature',
          onAction: ajouter,
        ),
      ],
    };
  }

  List<Widget> _liste(BuildContext context) {
    final visibles = _controller.visibles;
    if (visibles.isEmpty) {
      final requete = _controller.recherche.trim();
      final filtre = _controller.filtre;
      final criteres = [
        if (requete.isNotEmpty) '« $requete »',
        if (filtre != null) 'le statut ${filtre.libelle}',
      ].join(' avec ');
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
    return [
      Marge(
        haut: 16,
        sliver: SliverList.separated(
          itemCount: visibles.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, i) {
            final c = visibles[i];
            return Dismissible(
              key: ValueKey(c.id),
              direction: DismissDirection.endToStart,
              confirmDismiss: (_) => _supprimer(c),
              background: const FondSuppression(),
              child: CandidatureTile(
                candidature: c,
                onTap: () => ouvrirDetail(context, _controller, c.id!),
              ),
            );
          },
        ),
      ),
    ];
  }
}
