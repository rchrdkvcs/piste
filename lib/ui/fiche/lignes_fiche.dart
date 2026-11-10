import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../format/dates.dart';
import '../../models/candidature.dart';
import '../../models/saisie.dart';
import '../adaptive/adaptive.dart';

typedef OuvrirExterne = void Function(Uri uri, String erreur);

List<LigneListe> lignesSuivi(
  Candidature c, {
  required OuvrirExterne ouvrir,
  required DateTime maintenant,
}) {
  final relance = c.prochaineRelance;
  final enRetard = c.aRelancer(maintenant);
  return [
    if (c.dateEnvoi != null)
      LigneListe(
        titre: 'Date d’envoi',
        detail: dateLongue(c.dateEnvoi!),
        iconeMaterial: Icons.send_outlined,
        iconeCupertino: CupertinoIcons.paperplane_fill,
        teinte: TeinteIcone.indigo,
      ),
    if (relance != null)
      LigneListe(
        titre: 'Prochaine relance',
        detail: dateLongue(relance),
        sousTitre: c.statut.estClos
            ? null
            : enRetard
            ? 'À faire (${echeanceRelative(relance, maintenant)})'
            : echeanceRelative(relance, maintenant),
        iconeMaterial: enRetard
            ? Icons.notification_important_outlined
            : Icons.notifications_none,
        iconeCupertino: CupertinoIcons.bell_fill,
        teinte: enRetard ? TeinteIcone.rouge : TeinteIcone.orange,
      ),
    if (c.lienAnnonce.isNotEmpty)
      LigneListe(
        titre: 'Ouvrir l’annonce',
        sousTitre: _hote(c.lienAnnonce),
        iconeMaterial: Icons.open_in_new,
        iconeCupertino: CupertinoIcons.link,
        teinte: TeinteIcone.sarcelle,
        onTap: () => ouvrir(
          Uri.parse(Saisie.normaliserLien(c.lienAnnonce)),
          'Vérifie l’adresse de l’annonce : ${c.lienAnnonce}',
        ),
      ),
  ];
}

List<LigneListe> lignesContact(Candidature c, {required OuvrirExterne ouvrir}) {
  final contact = c.contact;
  return [
    if (contact.nom.isNotEmpty)
      LigneListe(
        titre: contact.nom,
        iconeMaterial: Icons.person_outline,
        iconeCupertino: CupertinoIcons.person_fill,
        teinte: TeinteIcone.gris,
      ),
    if (contact.email.isNotEmpty)
      LigneListe(
        titre: 'E-mail',
        sousTitre: contact.email,
        iconeMaterial: Icons.mail_outline,
        iconeCupertino: CupertinoIcons.mail_solid,
        teinte: TeinteIcone.bleu,
        onTap: () => ouvrir(
          Uri(scheme: 'mailto', path: contact.email),
          'Aucune application de messagerie ne peut écrire à '
          '${contact.email}.',
        ),
      ),
    if (contact.telephone.isNotEmpty)
      LigneListe(
        titre: 'Téléphone',
        sousTitre: Saisie.formaterTelephone(contact.telephone),
        iconeMaterial: Icons.phone_outlined,
        iconeCupertino: CupertinoIcons.phone_fill,
        teinte: TeinteIcone.vert,
        onTap: () => ouvrir(
          Uri(scheme: 'tel', path: contact.telephone),
          'Cet appareil ne peut pas appeler le '
          '${Saisie.formaterTelephone(contact.telephone)}.',
        ),
      ),
  ];
}

String _hote(String lien) {
  final hote = Uri.tryParse(lien)?.host ?? '';
  if (hote.isEmpty) return lien;
  return hote.startsWith('www.') ? hote.substring(4) : hote;
}
