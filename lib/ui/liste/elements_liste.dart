import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../models/candidature.dart';
import '../../state/candidature_controller.dart';
import '../../theme/app_theme.dart';
import '../../theme/typo.dart';
import '../adaptive/adaptive.dart';

/// Options du filtre : « Tous les statuts » puis chaque statut.
const filtresStatut = <Statut?>[null, ...Statut.values];

/// Recherche texte : champ natif iOS, `SearchBar` Material.
class ChampRecherche extends StatelessWidget {
  const ChampRecherche({
    super.key,
    required this.controller,
    required this.recherche,
  });

  final CandidatureController controller;
  final TextEditingController recherche;

  @override
  Widget build(BuildContext context) {
    if (estCupertino(context)) {
      return CupertinoSearchTextField(
        controller: recherche,
        placeholder: 'Entreprise, poste ou contact',
        onChanged: controller.rechercher,
        onSuffixTap: () {
          recherche.clear();
          controller.rechercher('');
        },
      );
    }
    return SearchBar(
      controller: recherche,
      hintText: 'Entreprise, poste ou contact',
      elevation: const WidgetStatePropertyAll(0),
      backgroundColor: WidgetStatePropertyAll(couleurCarte(context)),
      side: WidgetStatePropertyAll(
        BorderSide(color: Theme.of(context).colorScheme.outline),
      ),
      leading: const Icon(Icons.search),
      onChanged: controller.rechercher,
      trailing: [
        if (recherche.text.isNotEmpty)
          IconButton(
            tooltip: 'Effacer la recherche',
            icon: const Icon(Icons.close),
            onPressed: () {
              recherche.clear();
              controller.rechercher('');
            },
          ),
      ],
    );
  }
}

/// Chips de filtre Android. Hauteur libre : elles suivent la taille du
/// texte choisie dans les réglages, la ligne défile horizontalement.
class FiltresStatutMaterial extends StatelessWidget {
  const FiltresStatutMaterial({super.key, required this.controller});

  final CandidatureController controller;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(
        children: [
          for (final statut in filtresStatut)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(statut?.libelle ?? 'Tous'),
                selected: controller.filtre == statut,
                onSelected: (_) => controller.filtrer(statut),
              ),
            ),
        ],
      ),
    );
  }
}

/// Filtre actif sur iOS, touché pour le retirer.
class FiltreActifCupertino extends StatelessWidget {
  const FiltreActifCupertino({
    super.key,
    required this.controller,
    required this.filtre,
  });

  final CandidatureController controller;
  final Statut filtre;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('Statut', style: Typo.secondaire(context)),
        const SizedBox(width: 8),
        Semantics(
          label: 'Retirer le filtre ${filtre.libelle}',
          excludeSemantics: true,
          button: true,
          child: CupertinoButton.tinted(
            sizeStyle: CupertinoButtonSize.small,
            onPressed: () => controller.filtrer(null),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(filtre.libelle),
                const SizedBox(width: 6),
                const Icon(CupertinoIcons.xmark, size: 12),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Fond rouge révélé par le balayage de suppression.
class FondSuppression extends StatelessWidget {
  const FondSuppression({super.key});

  @override
  Widget build(BuildContext context) {
    final cupertino = estCupertino(context);
    return Container(
      alignment: AlignmentDirectional.centerEnd,
      padding: const EdgeInsetsDirectional.only(end: 24),
      decoration: BoxDecoration(
        // Rouge assombri : le texte blanc doit atteindre 4,5:1 (le rouge
        // système iOS n'offre que 3,6:1).
        color: cupertino
            ? PisteCouleurs.rougeDestructif
            : Theme.of(context).colorScheme.error,
        borderRadius: BorderRadius.circular(
          cupertino ? PisteRayons.ios : PisteRayons.material,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icone(context, Icons.delete_outline, CupertinoIcons.trash),
            color: Colors.white,
          ),
          const SizedBox(width: 8),
          const Text(
            'Supprimer',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
