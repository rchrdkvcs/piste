import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../format/dates.dart';
import '../../models/candidature.dart';
import '../../models/saisie.dart';

/// Champs du formulaire de candidature : contrôleurs de texte, focus,
/// statut et dates. Partagé par les vues iOS et Android.
class ChampsCandidature {
  ChampsCandidature(this.initiale)
    : entreprise = TextEditingController(text: initiale?.entreprise),
      poste = TextEditingController(text: initiale?.poste),
      lien = TextEditingController(text: initiale?.lienAnnonce),
      notes = TextEditingController(text: initiale?.notes),
      contactNom = TextEditingController(text: initiale?.contact.nom),
      contactEmail = TextEditingController(text: initiale?.contact.email),
      contactTelephone = TextEditingController(
        text: initiale == null || initiale.contact.telephone.isEmpty
            ? ''
            : Saisie.formaterTelephone(initiale.contact.telephone),
      ),
      statut = initiale?.statut ?? Statut.envoyee,
      dateEnvoi = initiale == null ? aujourdhui() : initiale.dateEnvoi,
      relance = initiale?.prochaineRelance {
    _depart = lire(DateTime(0));
  }

  /// Candidature modifiée, ou `null` pour une création.
  final Candidature? initiale;

  final TextEditingController entreprise;
  final TextEditingController poste;
  final TextEditingController lien;
  final TextEditingController notes;
  final TextEditingController contactNom;
  final TextEditingController contactEmail;
  final TextEditingController contactTelephone;
  final focusEntreprise = FocusNode();
  final focusPoste = FocusNode();
  final focusLien = FocusNode();
  final focusEmail = FocusNode();
  final focusTelephone = FocusNode();

  Statut statut;
  DateTime? dateEnvoi;
  DateTime? relance;

  /// Instantané de départ : sert à savoir s'il y a des changements à perdre.
  late final Candidature _depart;

  static const validerEntreprise = ReglesCandidature.entreprise;
  static const validerPoste = ReglesCandidature.poste;
  static const validerLien = ReglesCandidature.lienAnnonce;
  static const validerEmail = ReglesCandidature.email;
  static const validerTelephone = ReglesCandidature.telephone;

  /// Saisie du téléphone : chiffres, espaces, `+ . - ( )` uniquement.
  static final filtreTelephone = [
    FilteringTextInputFormatter.allow(Saisie.caracteresTelephone),
    LengthLimitingTextInputFormatter(20),
  ];

  /// Candidature telle que saisie, champs nettoyés.
  Candidature lire(DateTime maintenant) => Candidature(
    id: initiale?.id,
    entreprise: entreprise.text.trim(),
    poste: poste.text.trim(),
    statut: statut,
    notes: notes.text.trim(),
    lienAnnonce: Saisie.normaliserLien(lien.text),
    contact: Contact.saisi(
      nom: contactNom.text,
      email: contactEmail.text,
      telephone: contactTelephone.text,
    ),
    dateEnvoi: dateEnvoi,
    prochaineRelance: relance,
    dateCreation: initiale?.dateCreation ?? maintenant,
    dateModification: maintenant,
  );

  bool get modifie {
    final a = lire(DateTime(0));
    final b = _depart;
    return a.entreprise != b.entreprise ||
        a.poste != b.poste ||
        a.statut != b.statut ||
        a.notes != b.notes ||
        a.lienAnnonce != b.lienAnnonce ||
        a.contact != b.contact ||
        a.dateEnvoi != b.dateEnvoi ||
        a.prochaineRelance != b.prochaineRelance;
  }

  /// Place le focus sur le premier champ en erreur pour que le lecteur
  /// d'écran l'annonce et que le clavier s'ouvre au bon endroit.
  void focaliserPremiereErreur() {
    final controles = [
      (entreprise, validerEntreprise, focusEntreprise),
      (poste, validerPoste, focusPoste),
      (lien, validerLien, focusLien),
      (contactEmail, validerEmail, focusEmail),
      (contactTelephone, validerTelephone, focusTelephone),
    ];
    for (final (champ, valider, focus) in controles) {
      if (valider(champ.text) != null) return focus.requestFocus();
    }
  }

  /// Nouvelle date d'envoi : une relance devenue antérieure est effacée.
  void changerDateEnvoi(DateTime? date) {
    dateEnvoi = date;
    final r = relance;
    if (date != null && r != null && r.isBefore(date)) relance = null;
  }

  /// Relance proposée par défaut : une semaine après l'envoi (ou après
  /// aujourd'hui), jamais dans le passé.
  DateTime suggestionRelance() {
    final jour = aujourdhui();
    final suggestion = (dateEnvoi ?? jour).add(const Duration(days: 7));
    return suggestion.isBefore(jour) ? jour : suggestion;
  }

  void dispose() {
    for (final c in [
      entreprise,
      poste,
      lien,
      notes,
      contactNom,
      contactEmail,
      contactTelephone,
    ]) {
      c.dispose();
    }
    for (final f in [
      focusEntreprise,
      focusPoste,
      focusLien,
      focusEmail,
      focusTelephone,
    ]) {
      f.dispose();
    }
  }
}
