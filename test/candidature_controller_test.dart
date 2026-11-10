import 'package:flutter_test/flutter_test.dart';
import 'package:piste/data/exemples.dart';
import 'package:piste/models/candidature.dart';
import 'package:piste/state/candidature_controller.dart';

import 'fake_repository.dart';

void main() {
  test('lecture impossible puis récupération', () async {
    final repo = FakeCandidatureRepository()..echecLecture = true;
    final controller = CandidatureController(repo);

    await controller.charger();
    expect(controller.etat, EtatChargement.erreur);

    repo.echecLecture = false;
    await controller.charger();
    expect(controller.etat, EtatChargement.vide);
    controller.dispose();
  });

  test('recherche et filtre se combinent sans changer les compteurs', () async {
    final controller = CandidatureController(
      FakeCandidatureRepository([
        exemple(entreprise: 'Google', statut: Statut.entretien),
        exemple(entreprise: 'Meta', statut: Statut.entretien),
        exemple(entreprise: 'Google Cloud', statut: Statut.refusee),
      ]),
    );
    await controller.charger();

    controller
      ..filtrer(Statut.entretien)
      ..rechercher('  google ');

    expect(controller.visibles.map((c) => c.entreprise), ['Google']);
    expect(controller.indicateurs.total, 3);
    expect(controller.indicateurs.compter(Statut.entretien), 2);
    controller.dispose();
  });

  test(
    'proportion nulle sans candidature (pas de division par zéro)',
    () async {
      final controller = CandidatureController(FakeCandidatureRepository());
      await controller.charger();

      expect(controller.indicateurs.proportion(Statut.offre), 0);
      controller.dispose();
    },
  );

  test(
    'enregistrer relit la base et refuse un second appel simultané',
    () async {
      final repo = FakeCandidatureRepository();
      final controller = CandidatureController(repo);
      await controller.charger();

      final premier = controller.enregistrer(exemple());
      await expectLater(controller.enregistrer(exemple()), throwsStateError);
      await premier;

      expect(repo.ecritures, 1);
      expect(controller.etat, EtatChargement.pret);
      expect(controller.candidatures.single.id, isNotNull);
      controller.dispose();
    },
  );

  test("un échec d'écriture remonte et ne modifie pas la liste", () async {
    final repo = FakeCandidatureRepository([exemple(id: 1)]);
    final controller = CandidatureController(repo);
    await controller.charger();

    repo.echecEcriture = true;
    await expectLater(controller.supprimer(1), throwsException);

    expect(controller.indicateurs.total, 1);
    expect(controller.occupe, isFalse);
    controller.dispose();
  });

  test("importer ajoute le jeu d'exemple sans toucher l'existant", () async {
    final repo = FakeCandidatureRepository([exemple(id: 1)]);
    final controller = CandidatureController(repo);
    await controller.charger();

    final maintenant = DateTime(2026, 11, 10, 9);
    final exemples = candidaturesExemple(maintenant);
    final n = await controller.importer(exemples);

    expect(n, exemples.length);
    expect(controller.indicateurs.total, exemples.length + 1);
    expect(controller.parId(1), isNotNull);
    expect(controller.aRelancer(maintenant), isNotEmpty);
    for (final s in Statut.values) {
      expect(controller.indicateurs.compter(s), greaterThan(0), reason: s.name);
    }
    controller.dispose();
  });

  test("le jeu d'exemple respecte les règles de saisie", () {
    final maintenant = DateTime(2026, 11, 10);
    for (final c in candidaturesExemple(maintenant)) {
      expect(ReglesCandidature.entreprise(c.entreprise), isNull);
      expect(ReglesCandidature.poste(c.poste), isNull);
      expect(ReglesCandidature.lienAnnonce(c.lienAnnonce), isNull);
      expect(ReglesCandidature.email(c.contact.email), isNull);
      expect(ReglesCandidature.telephone(c.contact.telephone), isNull);
      expect(c.dateEnvoi!.isAfter(maintenant), isFalse);
      final relance = c.prochaineRelance;
      if (relance != null) expect(relance.isBefore(c.dateEnvoi!), isFalse);
    }
  });
}
