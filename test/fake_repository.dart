import 'package:piste/data/candidature_repository.dart';
import 'package:piste/models/candidature.dart';

/// Repository en mémoire, sans plugin natif. Peut simuler des pannes.
class FakeCandidatureRepository implements CandidatureRepository {
  FakeCandidatureRepository([List<Candidature> initiales = const []]) {
    for (final c in initiales) {
      final id = c.id ?? ++_dernierId;
      if (id > _dernierId) _dernierId = id;
      _lignes[id] = c.copyWith(id: id);
    }
  }

  final _lignes = <int, Candidature>{};
  int _dernierId = 0;

  bool echecLecture = false;
  bool echecEcriture = false;
  int ecritures = 0;

  @override
  Future<List<Candidature>> toutes() async {
    if (echecLecture) {
      throw const CandidatureStorageException('lecture simulée');
    }
    final liste = _lignes.values.toList()
      ..sort((a, b) => b.dateModification.compareTo(a.dateModification));
    return liste;
  }

  @override
  Future<Candidature> enregistrer(Candidature candidature) async {
    // Laisse le temps à un second appui de se produire.
    await Future<void>.delayed(const Duration(milliseconds: 10));
    if (echecEcriture) {
      throw const CandidatureStorageException('écriture simulée');
    }
    ecritures++;
    final id = candidature.id ?? ++_dernierId;
    final enregistree = candidature.copyWith(id: id);
    _lignes[id] = enregistree;
    return enregistree;
  }

  @override
  Future<void> supprimer(int id) async {
    if (echecEcriture) {
      throw const CandidatureStorageException('suppression simulée');
    }
    if (_lignes.remove(id) == null) {
      throw CandidatureStorageException('candidature $id introuvable');
    }
  }

  @override
  Future<void> fermer() async {}
}

Candidature exemple({
  int? id,
  String entreprise = 'Nexora',
  String poste = 'Développeur Flutter',
  Statut statut = Statut.envoyee,
  DateTime? modification,
}) {
  final date = modification ?? DateTime(2026, 10, 14);
  return Candidature(
    id: id,
    entreprise: entreprise,
    poste: poste,
    statut: statut,
    dateCreation: date,
    dateModification: date,
  );
}
