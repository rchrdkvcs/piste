import 'package:flutter/cupertino.dart';

import '../../format/dates.dart';
import '../../theme/app_theme.dart';
import '../../theme/typo.dart';
import '../adaptive/adaptive.dart';
import 'actions_formulaire.dart';
import 'champs_candidature.dart';

/// Formulaire iOS : feuille modale, sections groupées, feuille d'actions
/// pour le statut.
class FormulaireCupertino extends StatelessWidget {
  const FormulaireCupertino({
    super.key,
    required this.champs,
    required this.actions,
  });

  final ChampsCandidature champs;
  final ActionsFormulaire actions;

  @override
  Widget build(BuildContext context) {
    final decoration = BoxDecoration(
      color: couleurCarte(context),
      borderRadius: BorderRadius.circular(PisteRayons.ios),
    );

    // Barre Flutter (et non UIKit) dans la feuille : une vue native ne suit
    // pas l'animation d'ouverture et de fermeture de la feuille.
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground.resolveFrom(
        context,
      ),
      navigationBar: CupertinoNavigationBar(
        automaticallyImplyLeading: false,
        backgroundColor: CupertinoColors.systemGroupedBackground.resolveFrom(
          context,
        ),
        border: null,
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: actions.enCours ? null : actions.annuler,
          child: const Text('Annuler'),
        ),
        middle: Text(actions.titre),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: actions.enCours ? null : actions.enregistrer,
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
              children: [
                CupertinoFormSection.insetGrouped(
                  header: const Text('Poste'),
                  footer: Text(
                    'Les champs marqués * sont obligatoires.',
                    style: Typo.legende(context),
                  ),
                  decoration: decoration,
                  children: [
                    CupertinoTextFormFieldRow(
                      controller: champs.entreprise,
                      focusNode: champs.focusEntreprise,
                      prefix: const Text(
                        'Entreprise *',
                        semanticsLabel: 'Entreprise, obligatoire',
                      ),
                      placeholder: 'Google',
                      textAlign: TextAlign.end,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      autofocus: !actions.edition,
                      validator: ChampsCandidature.validerEntreprise,
                    ),
                    CupertinoTextFormFieldRow(
                      controller: champs.poste,
                      focusNode: champs.focusPoste,
                      prefix: const Text(
                        'Poste *',
                        semanticsLabel: 'Poste, obligatoire',
                      ),
                      placeholder: 'Développeur Flutter',
                      textAlign: TextAlign.end,
                      textCapitalization: TextCapitalization.sentences,
                      textInputAction: TextInputAction.next,
                      validator: ChampsCandidature.validerPoste,
                    ),
                  ],
                ),
                CupertinoFormSection.insetGrouped(
                  header: const Text('Suivi'),
                  decoration: decoration,
                  children: [
                    CupertinoListTile(
                      title: const Text('Statut'),
                      additionalInfo: Text(champs.statut.libelle),
                      trailing: const CupertinoListTileChevron(),
                      onTap: actions.choisirStatutIos,
                    ),
                    _ligneDate(
                      context,
                      'Date d’envoi',
                      champs.dateEnvoi,
                      onTap: () => actions.choisirDate(relance: false),
                      onEffacer: () => actions.effacerDate(relance: false),
                    ),
                    _ligneDate(
                      context,
                      'Relance le',
                      champs.relance,
                      onTap: () => actions.choisirDate(relance: true),
                      onEffacer: () => actions.effacerDate(relance: true),
                    ),
                  ],
                ),
                CupertinoFormSection.insetGrouped(
                  header: const Text('Contact'),
                  footer: Text(
                    'Facultatif. Depuis la fiche, touche l’e-mail ou le '
                    'numéro pour écrire ou appeler.',
                    style: Typo.legende(context),
                  ),
                  decoration: decoration,
                  children: [
                    CupertinoTextFormFieldRow(
                      controller: champs.contactNom,
                      prefix: const Text('Nom'),
                      placeholder: 'Camille Martin',
                      textAlign: TextAlign.end,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.name],
                    ),
                    CupertinoTextFormFieldRow(
                      controller: champs.contactEmail,
                      focusNode: champs.focusEmail,
                      prefix: const Text('E-mail'),
                      placeholder: 'camille@exemple.fr',
                      textAlign: TextAlign.end,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autocorrect: false,
                      enableSuggestions: false,
                      autofillHints: const [AutofillHints.email],
                      validator: ChampsCandidature.validerEmail,
                    ),
                    CupertinoTextFormFieldRow(
                      controller: champs.contactTelephone,
                      focusNode: champs.focusTelephone,
                      prefix: const Text('Téléphone'),
                      placeholder: '06 12 34 56 78',
                      textAlign: TextAlign.end,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.telephoneNumber],
                      inputFormatters: ChampsCandidature.filtreTelephone,
                      validator: ChampsCandidature.validerTelephone,
                    ),
                  ],
                ),
                CupertinoFormSection.insetGrouped(
                  header: const Text('Détails'),
                  footer: Text(
                    'Facultatif. L’annonce s’ouvre depuis la fiche.',
                    style: Typo.legende(context),
                  ),
                  decoration: decoration,
                  children: [
                    CupertinoTextFormFieldRow(
                      controller: champs.lien,
                      focusNode: champs.focusLien,
                      prefix: const Text('Annonce'),
                      placeholder: 'exemple.fr/offre',
                      textAlign: TextAlign.end,
                      keyboardType: TextInputType.url,
                      textInputAction: TextInputAction.next,
                      autocorrect: false,
                      enableSuggestions: false,
                      autofillHints: const [AutofillHints.url],
                      validator: ChampsCandidature.validerLien,
                    ),
                    CupertinoTextFormFieldRow(
                      controller: champs.notes,
                      placeholder: 'Notes : étapes, préparation…',
                      minLines: 3,
                      maxLines: 8,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                  ],
                ),
              ],
            ),
            if (actions.enCours)
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

  Widget _ligneDate(
    BuildContext context,
    String titre,
    DateTime? date, {
    required VoidCallback onTap,
    required VoidCallback onEffacer,
  }) {
    return CupertinoListTile(
      title: Text(titre),
      additionalInfo: Text(date == null ? 'Aucune' : dateCourte(date)),
      trailing: date == null
          ? const CupertinoListTileChevron()
          : Semantics(
              label: 'Effacer la date « $titre »',
              button: true,
              excludeSemantics: true,
              child: CupertinoButton(
                padding: EdgeInsets.zero,
                minimumSize: const Size.square(44),
                onPressed: onEffacer,
                child: Icon(
                  CupertinoIcons.xmark_circle_fill,
                  size: 20,
                  color: CupertinoColors.tertiaryLabel.resolveFrom(context),
                ),
              ),
            ),
      onTap: onTap,
    );
  }
}
