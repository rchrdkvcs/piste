import 'package:flutter_test/flutter_test.dart';
import 'package:piste/format/dates.dart';
import 'package:piste/models/candidature.dart';
import 'package:piste/models/saisie.dart';
import 'package:piste/state/indicateurs.dart';

import 'fake_repository.dart';

void main() {
  group('lien de l’annonce', () {
    test('complète une adresse sans protocole', () {
      expect(
        Saisie.normaliserLien(' exemple.fr/offre '),
        'https://exemple.fr/offre',
      );
      expect(Saisie.normaliserLien('http://a.fr'), 'http://a.fr');
      expect(Saisie.normaliserLien('  '), '');
    });

    test('refuse ce qui n’est pas une adresse web', () {
      expect(ReglesCandidature.lienAnnonce('exemple.fr/offre'), isNull);
      expect(ReglesCandidature.lienAnnonce(''), isNull);
      expect(ReglesCandidature.lienAnnonce('pas une adresse'), isNotNull);
      expect(ReglesCandidature.lienAnnonce('ftp://a.fr'), isNotNull);
      expect(ReglesCandidature.lienAnnonce('localhost'), isNotNull);
    });
  });

  test('e-mail', () {
    expect(ReglesCandidature.email(' Camille@Exemple.fr '), isNull);
    expect(ReglesCandidature.email(''), isNull);
    expect(ReglesCandidature.email('camille@'), isNotNull);
    expect(ReglesCandidature.email('camille@exemple'), isNotNull);
    expect(ReglesCandidature.email('ca mille@exemple.fr'), isNotNull);
    expect(
      Saisie.normaliserEmail(' Camille@Exemple.FR '),
      'camille@exemple.fr',
    );
  });

  test('téléphone : validation, normalisation, affichage', () {
    expect(ReglesCandidature.telephone('06 12 34 56 78'), isNull);
    expect(ReglesCandidature.telephone('+33 6 12 34 56 78'), isNull);
    expect(ReglesCandidature.telephone('12345'), isNotNull);
    expect(ReglesCandidature.telephone('06 12 ab'), isNotNull);
    expect(Saisie.normaliserTelephone('+33 (0)6.12'), '+330612');
    expect(Saisie.formaterTelephone('0612345678'), '06 12 34 56 78');
    expect(Saisie.formaterTelephone('+33612345678'), '+33 6 12 34 56 78');
  });

  test('recherche insensible aux accents et à la casse', () {
    expect(Saisie.pourRecherche('Société Générale'), 'societe generale');
    expect(Saisie.pourRecherche('Œuvre'), 'oeuvre');
  });

  test('copyWith peut effacer une date facultative', () {
    final c = exemple().copyWith(prochaineRelance: () => DateTime(2026, 11, 2));
    expect(c.prochaineRelance, isNotNull);
    expect(c.copyWith(prochaineRelance: () => null).prochaineRelance, isNull);
    expect(c.copyWith(poste: 'Autre').prochaineRelance, DateTime(2026, 11, 2));
  });

  test('à relancer : échéance atteinte et candidature non close', () {
    final jour = DateTime(2026, 11, 10, 15);
    final due = exemple().copyWith(
      prochaineRelance: () => DateTime(2026, 11, 10),
    );
    expect(due.aRelancer(jour), isTrue);
    expect(
      due
          .copyWith(prochaineRelance: () => DateTime(2026, 11, 11))
          .aRelancer(jour),
      isFalse,
    );
    expect(due.copyWith(statut: Statut.refusee).aRelancer(jour), isFalse);
    expect(exemple().aRelancer(jour), isFalse);
  });

  test('échéance relative', () {
    final m = DateTime(2026, 11, 10, 23);
    expect(echeanceRelative(DateTime(2026, 11, 10), m), 'aujourd’hui');
    expect(echeanceRelative(DateTime(2026, 11, 7), m), 'il y a 3 jours');
    expect(echeanceRelative(DateTime(2026, 11, 11), m), 'demain');
  });

  test('indicateurs : une entreprise ne dépend pas de la casse', () {
    final i = Indicateurs.depuis([
      exemple(entreprise: 'Google'),
      exemple(entreprise: 'google '),
      exemple(entreprise: 'Meta'),
    ]);
    expect(i.parEntreprise.first.key, 'Google');
    expect(i.parEntreprise.first.value, 2);
    expect(i.parEntreprise.length, 2);
  });

  test('le contact survit à la sérialisation', () {
    final c = exemple(id: 3).copyWith(
      contact: Contact.saisi(
        nom: ' Camille ',
        email: 'C@X.FR',
        telephone: '06 12 34 56 78',
      ),
    );
    final relue = Candidature.fromDatabase(c.toDatabase());
    expect(
      relue.contact,
      const Contact(nom: 'Camille', email: 'c@x.fr', telephone: '0612345678'),
    );
  });

  test('une ligne V2 sans colonnes de contact se lit', () {
    final relue = Candidature.fromDatabase({
      'id': 1,
      'entreprise': 'Nexora',
      'poste': 'Dev',
      'status': 'offre',
      'notes': '',
      'url': '',
      'date_creation': '2026-10-01T10:00:00.000',
    });
    expect(relue.contact, Contact.vide);
  });
}
