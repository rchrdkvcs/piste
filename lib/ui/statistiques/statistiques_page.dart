import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../models/candidature.dart';
import '../../state/candidature_controller.dart';
import '../../theme/typo.dart';
import '../adaptive/adaptive.dart';
import '../widgets/anneau_statuts.dart';
import '../widgets/avatar_entreprise.dart';
import '../widgets/vues_etat.dart';
import 'repartition.dart';

enum _Vue { suivi, entreprises }

/// Bilan calculé sur toutes les candidatures, indépendamment des filtres
/// de la liste.
class StatistiquesPage extends StatefulWidget {
  const StatistiquesPage({super.key, required this.controller});

  final CandidatureController controller;

  @override
  State<StatistiquesPage> createState() => _StatistiquesPageState();
}

class _StatistiquesPageState extends State<StatistiquesPage> {
  _Vue _vue = _Vue.suivi;

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return AdaptivePage(
          titre: 'Statistiques',
          surActualisation: () => controller.charger(silencieux: true),
          slivers: switch (controller.etat) {
            EtatChargement.chargement => const [VueChargement()],
            EtatChargement.erreur => [VueErreurLecture(controller: controller)],
            EtatChargement.vide => [
              VueMessage(
                icone: icone(
                  context,
                  Icons.pie_chart_outline,
                  CupertinoIcons.chart_pie,
                ),
                titre: 'Pas encore de statistiques',
                message:
                    'Elles se calculent à partir de tes candidatures. '
                    'Ajoute la première depuis l’onglet Candidatures.',
              ),
            ],
            EtatChargement.pret => [
              Marge(
                haut: 4,
                sliver: SliverToBoxAdapter(
                  child: Segments<_Vue>(
                    valeur: _vue,
                    options: const {
                      _Vue.suivi: 'Par statut',
                      _Vue.entreprises: 'Par entreprise',
                    },
                    onChanged: (v) => setState(() => _vue = v),
                  ),
                ),
              ),
              ...switch (_vue) {
                _Vue.suivi => _suivi(context),
                _Vue.entreprises => _entreprises(context),
              },
            ],
          },
        );
      },
    );
  }

  List<Widget> _suivi(BuildContext context) {
    final c = widget.controller;
    final comptes = {for (final s in Statut.values) s: c.compter(s)};
    return [
      Marge(
        haut: 20,
        sliver: SliverToBoxAdapter(
          child: Carte(
            padding: const EdgeInsets.symmetric(vertical: 28),
            child: Center(
              child: AnneauStatuts(comptes: comptes, total: c.total),
            ),
          ),
        ),
      ),
      const Marge(
        sliver: SliverToBoxAdapter(child: TitreSection('Répartition')),
      ),
      Marge(
        sliver: SliverToBoxAdapter(
          child: Carte(
            child: Column(
              children: [
                for (final (i, s) in Statut.values.indexed) ...[
                  if (i > 0)
                    Divider(
                      height: 1,
                      indent: 40,
                      color: couleurTexteSecondaire(context)
                          .withValues(alpha: 0.2),
                    ),
                  LigneRepartition(
                    statut: s,
                    nombre: comptes[s]!,
                    proportion: c.proportion(s),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    ];
  }

  List<Widget> _entreprises(BuildContext context) {
    final entrees = widget.controller.parEntreprise;
    final max = entrees.first.value;
    final n = entrees.length;
    return [
      Marge(
        sliver: SliverToBoxAdapter(
          child: TitreSection(n > 1 ? '$n entreprises' : '1 entreprise'),
        ),
      ),
      Marge(
        sliver: SliverToBoxAdapter(
          child: Carte(
            child: Column(
              children: [
                for (final (i, e) in entrees.indexed) ...[
                  if (i > 0)
                    Divider(
                      height: 1,
                      indent: 64,
                      color: couleurTexteSecondaire(context)
                          .withValues(alpha: 0.2),
                    ),
                  MergeSemantics(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                      child: Row(
                        children: [
                          AvatarEntreprise(e.key, taille: 36),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(e.key, style: Typo.corpsGras(context)),
                                const SizedBox(height: 6),
                                BarreProportion(
                                  valeur: e.value / max,
                                  couleur: couleurAccent(context),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            '${e.value}',
                            style: Typo.chiffre(context, taille: 17),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    ];
  }
}
