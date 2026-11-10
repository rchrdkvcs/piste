import 'package:flutter_test/flutter_test.dart';
import 'package:piste/data/candidature_sqlite.dart';
import 'package:piste/format/dates.dart';
import 'package:piste/format/texte.dart';
import 'package:piste/models/candidature.dart';

void main() {
  test('bornerDate ramène la date dans l’intervalle, sans heure', () {
    final min = DateTime(2026, 1, 1);
    final max = DateTime(2026, 12, 31);
    expect(bornerDate(DateTime(2025, 6, 1), min, max), min);
    expect(bornerDate(DateTime(2027, 6, 1), min, max), max);
    expect(
      bornerDate(DateTime(2026, 5, 4, 18), min, max),
      DateTime(2026, 5, 4),
    );
  });

  test('pluriel et initiales', () {
    expect(pluriel(1, 'entreprise'), '1 entreprise');
    expect(pluriel(3, 'entreprise'), '3 entreprises');
    expect(initiales('  camille   martin ', max: 2), 'CM');
    expect(initiales('élodie'), 'É');
    expect(initiales('   '), '');
  });

  test('description des critères de recherche', () {
    expect(descriptionCriteres(' meta ', null), '« meta »');
    expect(
      descriptionCriteres('meta', Statut.offre),
      '« meta » avec le statut Offre',
    );
  });

  test('migrations : rien depuis la V3, tout depuis la V1', () {
    expect(CandidatureSqlite.migrations(3), isEmpty);
    expect(CandidatureSqlite.migrations(2), hasLength(3));
    expect(CandidatureSqlite.migrations(1), hasLength(6));
  });
}
