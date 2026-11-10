import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../format/texte.dart';
import '../../models/candidature.dart';
import '../../state/candidature_controller.dart';
import '../adaptive/adaptive.dart';
import '../widgets/anneau_statuts.dart';
import '../widgets/vues_etat.dart';
import 'repartition.dart';

enum _Vue { suivi, entreprises }

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
    final indicateurs = widget.controller.indicateurs;
    return [
      Marge(
        haut: 20,
        sliver: SliverToBoxAdapter(
          child: Carte(
            padding: const EdgeInsets.symmetric(vertical: 28),
            child: Center(child: AnneauStatuts(indicateurs)),
          ),
        ),
      ),
      const Marge(
        sliver: SliverToBoxAdapter(child: TitreSection('Répartition')),
      ),
      Marge(
        sliver: SliverToBoxAdapter(
          child: CarteLignes(
            retrait: 40,
            children: [
              for (final s in Statut.values)
                LigneRepartition(
                  statut: s,
                  nombre: indicateurs.compter(s),
                  proportion: indicateurs.proportion(s),
                ),
            ],
          ),
        ),
      ),
    ];
  }

  List<Widget> _entreprises(BuildContext context) {
    final entrees = widget.controller.indicateurs.parEntreprise;
    final max = entrees.first.value;
    return [
      Marge(
        sliver: SliverToBoxAdapter(
          child: TitreSection(pluriel(entrees.length, 'entreprise')),
        ),
      ),
      Marge(
        sliver: SliverToBoxAdapter(
          child: CarteLignes(
            retrait: 64,
            children: [
              for (final e in entrees)
                LigneEntreprise(nom: e.key, nombre: e.value, maximum: max),
            ],
          ),
        ),
      ),
    ];
  }
}
