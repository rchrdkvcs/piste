import 'package:flutter/material.dart';

import '../../models/candidature.dart';
import '../adaptive/adaptive.dart';
import 'champs_candidature.dart';

const libelleDateEnvoi = 'Date d’envoi';
const libelleRelance = 'Prochaine relance';

List<Widget> sectionsCandidature(
  ChampsCandidature champs, {
  required bool edition,
  required ValueChanged<Statut> onStatut,
  required void Function({required bool relance}) onDate,
  required void Function({required bool relance}) onEffacerDate,
}) => [
  SectionFormulaire(
    titre: 'Poste',
    pied: 'Les champs marqués * sont obligatoires.',
    children: [
      ChampTexte(
        controller: champs.entreprise,
        focusNode: champs.focusEntreprise,
        libelle: 'Entreprise',
        indication: 'Google',
        icone: Icons.business_outlined,
        obligatoire: true,
        autofocus: !edition,
        capitalisation: TextCapitalization.words,
        validateur: ReglesCandidature.entreprise,
      ),
      ChampTexte(
        controller: champs.poste,
        focusNode: champs.focusPoste,
        libelle: 'Poste',
        indication: 'Développeur Flutter',
        icone: Icons.badge_outlined,
        obligatoire: true,
        capitalisation: TextCapitalization.sentences,
        validateur: ReglesCandidature.poste,
      ),
    ],
  ),
  SectionFormulaire(
    titre: 'Suivi',
    children: [
      ChampChoix<Statut>(
        libelle: 'Statut',
        icone: Icons.flag_outlined,
        valeur: champs.statut,
        options: {for (final s in Statut.values) s: s.libelle},
        onChanged: onStatut,
      ),
      ChampDate(
        libelle: libelleDateEnvoi,
        icone: Icons.event_outlined,
        date: champs.dateEnvoi,
        onTap: () => onDate(relance: false),
        onEffacer: () => onEffacerDate(relance: false),
      ),
      ChampDate(
        libelle: libelleRelance,
        icone: Icons.notifications_none,
        date: champs.relance,
        onTap: () => onDate(relance: true),
        onEffacer: () => onEffacerDate(relance: true),
      ),
    ],
  ),
  SectionFormulaire(
    titre: 'Contact',
    pied:
        'Facultatif. Depuis la fiche, touche l’e-mail ou le numéro pour '
        'écrire ou appeler.',
    children: [
      ChampTexte(
        controller: champs.contactNom,
        libelle: 'Nom',
        indication: 'Camille Martin',
        icone: Icons.person_outline,
        capitalisation: TextCapitalization.words,
        autofill: const [AutofillHints.name],
      ),
      ChampTexte(
        controller: champs.contactEmail,
        focusNode: champs.focusEmail,
        libelle: 'E-mail',
        indication: 'camille@exemple.fr',
        icone: Icons.mail_outline,
        clavier: TextInputType.emailAddress,
        correction: false,
        autofill: const [AutofillHints.email],
        validateur: ReglesCandidature.email,
      ),
      ChampTexte(
        controller: champs.contactTelephone,
        focusNode: champs.focusTelephone,
        libelle: 'Téléphone',
        indication: '06 12 34 56 78',
        icone: Icons.phone_outlined,
        clavier: TextInputType.phone,
        autofill: const [AutofillHints.telephoneNumber],
        formatage: ChampsCandidature.filtreTelephone,
        validateur: ReglesCandidature.telephone,
      ),
    ],
  ),
  SectionFormulaire(
    titre: 'Détails',
    pied: 'Facultatif. L’annonce s’ouvre depuis la fiche.',
    children: [
      ChampTexte(
        controller: champs.lien,
        focusNode: champs.focusLien,
        libelle: 'Annonce',
        indication: 'exemple.fr/offre',
        icone: Icons.link,
        clavier: TextInputType.url,
        correction: false,
        autofill: const [AutofillHints.url],
        validateur: ReglesCandidature.lienAnnonce,
      ),
      ChampTexte(
        controller: champs.notes,
        libelle: 'Notes',
        indication: 'étapes, préparation…',
        multiligne: true,
        capitalisation: TextCapitalization.sentences,
      ),
    ],
  ),
];
