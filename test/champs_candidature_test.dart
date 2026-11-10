import 'package:flutter_test/flutter_test.dart';
import 'package:piste/models/candidature.dart';
import 'package:piste/ui/formulaire/champs_candidature.dart';

import 'fake_repository.dart';

void main() {
  final maintenant = DateTime(2026, 11, 10, 15);

  test('une saisie intacte n’est pas modifiée, un changement l’est', () {
    final champs = ChampsCandidature(exemple(id: 1));
    expect(champs.modifie, isFalse);

    champs.notes.text = 'Relancer lundi';
    expect(champs.modifie, isTrue);
    champs.dispose();
  });

  test('une date d’envoi postérieure efface la relance', () {
    final champs = ChampsCandidature(null)
      ..dateEnvoi = DateTime(2026, 11, 1)
      ..relance = DateTime(2026, 11, 5);

    champs.appliquerDate(DateTime(2026, 11, 8), relance: false);

    expect(champs.dateEnvoi, DateTime(2026, 11, 8));
    expect(champs.relance, isNull);
    champs.dispose();
  });

  test('bornes : envoi jamais futur, relance jamais avant l’envoi', () {
    final champs = ChampsCandidature(null)..dateEnvoi = DateTime(2026, 11, 1);

    final envoi = champs.bornes(relance: false, maintenant: maintenant);
    expect(envoi.derniere, DateTime(2026, 11, 10));
    expect(envoi.premiere, isNull);

    final relance = champs.bornes(relance: true, maintenant: maintenant);
    expect(relance.premiere, DateTime(2026, 11, 1));
    expect(relance.initiale, DateTime(2026, 11, 10));
    champs.dispose();
  });

  test('la relance suggérée est une semaine après un envoi récent', () {
    final champs = ChampsCandidature(null)..dateEnvoi = DateTime(2026, 11, 8);
    expect(champs.suggestionRelance(maintenant), DateTime(2026, 11, 15));
    champs.dispose();
  });

  test('lire nettoie la saisie', () {
    final champs = ChampsCandidature(null)
      ..entreprise.text = '  Nexora '
      ..poste.text = 'Dev'
      ..lien.text = 'exemple.fr/offre'
      ..statut = Statut.entretien;

    final c = champs.lire(maintenant);

    expect(c.entreprise, 'Nexora');
    expect(c.lienAnnonce, 'https://exemple.fr/offre');
    expect(c.statut, Statut.entretien);
    champs.dispose();
  });
}
