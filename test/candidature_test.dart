import 'package:flutter_test/flutter_test.dart';
import 'package:piste/data/candidature_sqlite.dart';
import 'package:piste/models/candidature.dart';

void main() {
  test('une candidature retrouve ses informations après sérialisation', () {
    final origine = Candidature(
      id: 7,
      entreprise: 'Asteria',
      poste: 'Mobile Developer',
      statut: Statut.entretien,
      notes: 'Préparer le portfolio',
      lienAnnonce: 'https://asteria.example/offre',
      dateEnvoi: DateTime(2026, 10, 14),
      prochaineRelance: DateTime(2026, 11, 2),
      dateCreation: DateTime(2026, 10, 14, 9, 30),
      dateModification: DateTime(2026, 11, 4, 18),
    );

    final relue = CandidatureSqlite.depuisLigne(
      CandidatureSqlite.versLigne(origine),
    );

    expect(relue.id, 7);
    expect(relue.entreprise, 'Asteria');
    expect(relue.statut, Statut.entretien);
    expect(relue.notes, 'Préparer le portfolio');
    expect(relue.dateEnvoi, DateTime(2026, 10, 14));
    expect(relue.prochaineRelance, DateTime(2026, 11, 2));
    expect(relue.dateModification, DateTime(2026, 11, 4, 18));
  });

  test('un statut inconnu ne fait pas planter la lecture', () {
    final relue = CandidatureSqlite.depuisLigne({
      'id': 1,
      'entreprise': 'Nexora',
      'poste': 'Dev',
      'status': 'statut_supprime',
      'notes': '',
      'url': '',
      'date_creation': '2026-10-01T10:00:00.000',
    });

    expect(relue.statut, Statut.envoyee);
    expect(relue.dateModification, relue.dateCreation);
    expect(relue.prochaineRelance, isNull);
  });
}
