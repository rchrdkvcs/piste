import 'package:flutter/material.dart';

import '../../models/candidature.dart';
import '../../theme/typo.dart';
import 'actions_formulaire.dart';
import 'champ_date.dart';
import 'champs_candidature.dart';

/// Formulaire Android : page plein écran Material 3.
class FormulaireMaterial extends StatelessWidget {
  const FormulaireMaterial({
    super.key,
    required this.champs,
    required this.actions,
  });

  final ChampsCandidature champs;
  final ActionsFormulaire actions;

  @override
  Widget build(BuildContext context) {
    const espace = SizedBox(height: 16);
    return Scaffold(
      appBar: AppBar(
        leading: CloseButton(
          onPressed: actions.enCours ? null : actions.annuler,
        ),
        title: Text(actions.titre),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: actions.enCours
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox.square(
                      dimension: 24,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    ),
                  )
                : TextButton(
                    onPressed: actions.enregistrer,
                    child: const Text('Enregistrer'),
                  ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          children: [
            Text(
              'Les champs marqués * sont obligatoires.',
              style: Typo.secondaire(context),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: champs.entreprise,
              focusNode: champs.focusEntreprise,
              autofocus: !actions.edition,
              decoration: const InputDecoration(
                labelText: 'Entreprise *',
                hintText: 'Google',
                prefixIcon: Icon(Icons.business_outlined),
              ),
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              validator: ChampsCandidature.validerEntreprise,
            ),
            espace,
            TextFormField(
              controller: champs.poste,
              focusNode: champs.focusPoste,
              decoration: const InputDecoration(
                labelText: 'Intitulé du poste *',
                hintText: 'Développeur Flutter',
                prefixIcon: Icon(Icons.badge_outlined),
              ),
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.next,
              validator: ChampsCandidature.validerPoste,
            ),
            espace,
            DropdownButtonFormField<Statut>(
              initialValue: champs.statut,
              decoration: const InputDecoration(
                labelText: 'Statut',
                prefixIcon: Icon(Icons.flag_outlined),
              ),
              items: [
                for (final s in Statut.values)
                  DropdownMenuItem(value: s, child: Text(s.libelle)),
              ],
              onChanged: (s) {
                if (s != null) actions.changerStatut(s);
              },
            ),
            espace,
            ChampDate(
              libelle: 'Date d’envoi',
              icone: Icons.event_outlined,
              date: champs.dateEnvoi,
              onTap: () => actions.choisirDate(relance: false),
              onEffacer: () => actions.effacerDate(relance: false),
            ),
            espace,
            ChampDate(
              libelle: 'Prochaine relance',
              icone: Icons.notifications_none,
              date: champs.relance,
              onTap: () => actions.choisirDate(relance: true),
              onEffacer: () => actions.effacerDate(relance: true),
            ),
            espace,
            TextFormField(
              controller: champs.lien,
              focusNode: champs.focusLien,
              decoration: const InputDecoration(
                labelText: 'Lien vers l’annonce',
                hintText: 'exemple.fr/offre',
                prefixIcon: Icon(Icons.link),
              ),
              keyboardType: TextInputType.url,
              textInputAction: TextInputAction.next,
              autocorrect: false,
              enableSuggestions: false,
              autofillHints: const [AutofillHints.url],
              validator: ChampsCandidature.validerLien,
            ),
            const SizedBox(height: 28),
            Semantics(
              header: true,
              child: Text('Contact', style: Typo.section(context)),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: champs.contactNom,
              decoration: const InputDecoration(
                labelText: 'Nom du contact',
                hintText: 'Camille Martin',
                prefixIcon: Icon(Icons.person_outline),
              ),
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.name],
            ),
            espace,
            TextFormField(
              controller: champs.contactEmail,
              focusNode: champs.focusEmail,
              decoration: const InputDecoration(
                labelText: 'E-mail',
                hintText: 'camille@exemple.fr',
                prefixIcon: Icon(Icons.mail_outline),
              ),
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autocorrect: false,
              enableSuggestions: false,
              autofillHints: const [AutofillHints.email],
              validator: ChampsCandidature.validerEmail,
            ),
            espace,
            TextFormField(
              controller: champs.contactTelephone,
              focusNode: champs.focusTelephone,
              decoration: const InputDecoration(
                labelText: 'Téléphone',
                hintText: '06 12 34 56 78',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.telephoneNumber],
              inputFormatters: ChampsCandidature.filtreTelephone,
              validator: ChampsCandidature.validerTelephone,
            ),
            const SizedBox(height: 28),
            espace,
            TextFormField(
              controller: champs.notes,
              decoration: const InputDecoration(
                labelText: 'Notes',
                hintText: 'Étapes, préparation…',
                alignLabelWithHint: true,
              ),
              minLines: 3,
              maxLines: 8,
              textCapitalization: TextCapitalization.sentences,
            ),
          ],
        ),
      ),
    );
  }
}
