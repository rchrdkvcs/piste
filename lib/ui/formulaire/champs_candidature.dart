import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../format/dates.dart';
import '../../models/candidature.dart';
import '../../models/saisie.dart';

typedef BornesDate = ({
  DateTime? initiale,
  DateTime? premiere,
  DateTime? derniere,
});

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

  late final Candidature _depart;

  static final filtreTelephone = [
    FilteringTextInputFormatter.allow(Saisie.caracteresTelephone),
    LengthLimitingTextInputFormatter(20),
  ];

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

  bool get modifie => !lire(DateTime(0)).memeContenu(_depart);

  void focaliserPremiereErreur() {
    final controles = [
      (entreprise, ReglesCandidature.entreprise, focusEntreprise),
      (poste, ReglesCandidature.poste, focusPoste),
      (lien, ReglesCandidature.lienAnnonce, focusLien),
      (contactEmail, ReglesCandidature.email, focusEmail),
      (contactTelephone, ReglesCandidature.telephone, focusTelephone),
    ];
    for (final (champ, valider, focus) in controles) {
      if (valider(champ.text) != null) return focus.requestFocus();
    }
  }

  void changerDateEnvoi(DateTime? date) {
    dateEnvoi = date;
    final r = relance;
    if (date != null && r != null && r.isBefore(date)) relance = null;
  }

  DateTime suggestionRelance([DateTime? maintenant]) {
    final jour = aujourdhui(maintenant);
    final suggestion = (dateEnvoi ?? jour).add(const Duration(days: 7));
    return suggestion.isBefore(jour) ? jour : suggestion;
  }

  BornesDate bornes({required bool relance, DateTime? maintenant}) => relance
      ? (
          initiale: this.relance ?? suggestionRelance(maintenant),
          premiere: dateEnvoi,
          derniere: null,
        )
      : (initiale: dateEnvoi, premiere: null, derniere: aujourdhui(maintenant));

  void appliquerDate(DateTime? date, {required bool relance}) {
    if (relance) {
      this.relance = date;
    } else {
      changerDateEnvoi(date);
    }
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
