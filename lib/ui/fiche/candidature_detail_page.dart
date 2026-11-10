import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../format/dates.dart';
import '../../models/candidature.dart';
import '../../state/candidature_controller.dart';
import '../actions/actions_candidature.dart';
import '../adaptive/adaptive.dart';
import '../formulaire/candidature_form_page.dart';
import '../widgets/avatar_entreprise.dart';
import '../widgets/statut_badge.dart';
import '../widgets/vues_etat.dart';
import 'lignes_fiche.dart';

Future<void> ouvrirDetail(
  BuildContext context,
  CandidatureController controller,
  int id,
) {
  return ouvrirPage<void>(
    context,
    (_) => CandidatureDetailPage(controller: controller, id: id),
  );
}

class CandidatureDetailPage extends StatefulWidget {
  const CandidatureDetailPage({
    super.key,
    required this.controller,
    required this.id,
  });

  final CandidatureController controller;
  final int id;

  @override
  State<CandidatureDetailPage> createState() => _CandidatureDetailPageState();
}

class _CandidatureDetailPageState extends State<CandidatureDetailPage> {
  Candidature? _derniere;
  bool _suppression = false;

  Future<void> _modifier(Candidature c) =>
      ouvrirFormulaire(context, widget.controller, initiale: c);

  Future<void> _supprimer(Candidature c) async {
    setState(() => _suppression = true);
    final supprimee = await supprimerAvecConfirmation(
      context,
      widget.controller,
      c,
    );
    if (!mounted) return;
    if (supprimee) {
      Navigator.of(context).pop();
    } else {
      setState(() => _suppression = false);
    }
  }

  Future<void> _ouvrir(Uri uri, String erreur) =>
      ouvrirExterne(context, uri, erreur: erreur);

  List<ActionBarre> _actions(BuildContext context, Candidature c, bool bloque) {
    if (estCupertino(context)) {
      return [
        ActionBarre(
          libelle: 'Modifier',
          texte: true,
          onPressed: bloque ? null : () => _modifier(c),
        ),
        ActionBarre(
          libelle: 'Plus d’actions',
          symbole: 'ellipsis',
          iconeCupertino: CupertinoIcons.ellipsis_circle,
          menu: const [
            OptionMenu(
              libelle: 'Supprimer la candidature',
              symbole: 'trash',
              destructive: true,
            ),
          ],
          onMenu: (_) {
            if (!bloque) _supprimer(c);
          },
        ),
      ];
    }
    return [
      ActionBarre(
        libelle: 'Supprimer la candidature',
        iconeMaterial: Icons.delete_outline,
        onPressed: bloque ? null : () => _supprimer(c),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final c = _derniere = widget.controller.parId(widget.id) ?? _derniere;
        if (c == null) {
          return AdaptivePage(
            titre: 'Candidature',
            grandTitre: false,
            slivers: [
              VueMessage(
                icone: icone(context, Icons.search_off, CupertinoIcons.search),
                titre: 'Candidature introuvable',
                message: 'Elle a été supprimée ou n’existe plus.',
              ),
            ],
          );
        }
        final cupertino = estCupertino(context);
        final bloque = _suppression || widget.controller.occupe;

        final suivi = lignesSuivi(
          c,
          ouvrir: _ouvrir,
          maintenant: DateTime.now(),
        );
        final contact = lignesContact(c, ouvrir: _ouvrir);

        return AdaptivePage(
          titre: c.entreprise,
          grandTitre: false,
          titreDiffere: true,
          actions: _actions(context, c, bloque),
          slivers: [
            Marge(
              haut: 12,
              sliver: SliverToBoxAdapter(child: _entete(context, c)),
            ),
            if (suivi.isNotEmpty)
              SliverToBoxAdapter(
                child: SectionListe(titre: 'Suivi', lignes: suivi),
              ),
            if (contact.isNotEmpty)
              SliverToBoxAdapter(
                child: SectionListe(titre: 'Contact', lignes: contact),
              ),
            if (c.notes.trim().isNotEmpty)
              SliverToBoxAdapter(
                child: SectionContenu(
                  titre: 'Notes',
                  child: SelectableText(c.notes, style: Typo.corps(context)),
                ),
              ),
            SliverToBoxAdapter(
              child: SectionListe(
                titre: 'Historique',
                lignes: [
                  LigneListe(
                    titre: 'Créée le',
                    detail: dateLongue(c.dateCreation),
                  ),
                  LigneListe(
                    titre: 'Modifiée le',
                    detail: dateLongue(c.dateModification),
                  ),
                ],
              ),
            ),
            if (!cupertino)
              Marge(
                haut: 28,
                sliver: SliverToBoxAdapter(
                  child: BoutonPrincipal(
                    libelle: 'Modifier la candidature',
                    icone: Icons.edit_outlined,
                    onPressed: bloque ? null : () => _modifier(c),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _entete(BuildContext context, Candidature c) {
    return Row(
      children: [
        AvatarEntreprise(c.entreprise, taille: 64),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                header: true,
                child: Text(c.entreprise, style: Typo.titre(context)),
              ),
              const SizedBox(height: 2),
              Text(c.poste, style: Typo.secondaire(context)),
              const SizedBox(height: 10),
              StatutBadge(c.statut),
            ],
          ),
        ),
      ],
    );
  }
}
