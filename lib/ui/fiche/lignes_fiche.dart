import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../format/dates.dart';
import '../../models/candidature.dart';
import '../../models/saisie.dart';
import '../../theme/statut_couleurs.dart';
import '../adaptive/adaptive.dart';

/// Ouvre une adresse externe ; le message s'affiche si c'est impossible.
typedef OuvrirExterne = void Function(Uri uri, String erreur);

/// Lignes « Suivi » de la fiche : envoi, relance, annonce.
List<LigneListe> lignesSuivi(Candidature c, {required OuvrirExterne ouvrir}) {
  final relance = c.prochaineRelance;
  final enRetard = c.aRelancer(DateTime.now());
  return [
    if (c.dateEnvoi != null)
      LigneListe(
        titre: 'Date d’envoi',
        detail: dateLongue(c.dateEnvoi!),
        iconeMaterial: Icons.send_outlined,
        iconeCupertino: CupertinoIcons.paperplane_fill,
        couleurIcone: Statut.envoyee.couleur,
      ),
    if (relance != null)
      LigneListe(
        titre: 'Relance prévue le',
        detail: dateLongue(relance),
        sousTitre: c.statut.estClos
            ? null
            : enRetard
            ? 'À faire (${echeanceRelative(relance)})'
            : echeanceRelative(relance),
        iconeMaterial: enRetard
            ? Icons.notification_important_outlined
            : Icons.notifications_none,
        iconeCupertino: CupertinoIcons.bell_fill,
        couleurIcone: enRetard ? Statut.refusee.couleur : Statut.offre.couleur,
      ),
    if (c.lienAnnonce.isNotEmpty)
      LigneListe(
        titre: 'Ouvrir l’annonce',
        sousTitre: _hote(c.lienAnnonce),
        iconeMaterial: Icons.open_in_new,
        iconeCupertino: CupertinoIcons.link,
        couleurIcone: Statut.enCours.couleur,
        onTap: () => ouvrir(
          Uri.parse(Saisie.normaliserLien(c.lienAnnonce)),
          'Vérifie l’adresse de l’annonce : ${c.lienAnnonce}',
        ),
      ),
  ];
}

/// Lignes « Contact » de la fiche : e-mail et téléphone ouvrent
/// l'application dédiée.
List<LigneListe> lignesContact(Candidature c, {required OuvrirExterne ouvrir}) {
  final contact = c.contact;
  return [
    if (contact.nom.isNotEmpty)
      LigneListe(
        titre: contact.nom,
        iconeMaterial: Icons.person_outline,
        iconeCupertino: CupertinoIcons.person_fill,
        couleurIcone: CupertinoColors.systemGrey,
      ),
    if (contact.email.isNotEmpty)
      LigneListe(
        titre: 'E-mail',
        sousTitre: contact.email,
        iconeMaterial: Icons.mail_outline,
        iconeCupertino: CupertinoIcons.mail_solid,
        couleurIcone: CupertinoColors.systemBlue,
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
        couleurIcone: CupertinoColors.systemGreen,
        onTap: () => ouvrir(
          Uri(scheme: 'tel', path: contact.telephone),
          'Cet appareil ne peut pas appeler le '
          '${Saisie.formaterTelephone(contact.telephone)}.',
        ),
      ),
  ];
}

/// Hôte affichable d'un lien (`www.` retiré), ou le lien brut.
String _hote(String lien) {
  final hote = Uri.tryParse(lien)?.host ?? '';
  if (hote.isEmpty) return lien;
  return hote.startsWith('www.') ? hote.substring(4) : hote;
}
