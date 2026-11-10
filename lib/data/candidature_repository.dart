import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/candidature.dart';
import 'candidature_sqlite.dart';

class CandidatureStorageException implements Exception {
  const CandidatureStorageException(this.message);

  final String message;

  @override
  String toString() => 'CandidatureStorageException: $message';
}

abstract interface class CandidatureRepository {
  Future<List<Candidature>> toutes();

  Future<Candidature> enregistrer(Candidature candidature);

  Future<void> enregistrerTous(List<Candidature> candidatures);

  Future<void> supprimer(int id);

  Future<void> fermer();
}

class SqliteCandidatureRepository implements CandidatureRepository {
  SqliteCandidatureRepository({this.nomFichier = 'piste.db'});

  static const _table = CandidatureSqlite.table;

  final String nomFichier;
  Future<Database>? _ouverture;

  Future<Database> get _db => _ouverture ??= _ouvrir();

  Future<Database> _ouvrir() async => openDatabase(
    join(await getDatabasesPath(), nomFichier),
    version: CandidatureSqlite.version,
    onCreate: (db, _) => db.execute(CandidatureSqlite.creation),
    onUpgrade: (db, ancienne, _) async {
      for (final requete in CandidatureSqlite.migrations(ancienne)) {
        await db.execute(requete);
      }
    },
  );

  Future<T> _proteger<T>(
    String operation,
    Future<T> Function(Database db) action,
  ) async {
    try {
      return await action(await _db);
    } on CandidatureStorageException {
      rethrow;
    } catch (erreur, trace) {
      Error.throwWithStackTrace(
        CandidatureStorageException('$operation : $erreur'),
        trace,
      );
    }
  }

  @override
  Future<List<Candidature>> toutes() => _proteger('lecture', (db) async {
    final lignes = await db.query(
      _table,
      orderBy: 'date_modification DESC, id DESC',
    );
    return lignes.map(CandidatureSqlite.depuisLigne).toList();
  });

  @override
  Future<Candidature> enregistrer(Candidature candidature) =>
      _proteger('écriture', (db) async {
        final ligne = CandidatureSqlite.versLigne(candidature);
        final id = candidature.id;
        if (id == null) {
          return candidature.copyWith(id: await db.insert(_table, ligne));
        }
        final lignes = await db.update(
          _table,
          ligne,
          where: 'id = ?',
          whereArgs: [id],
        );
        _verifierTrouvee(lignes, id);
        return candidature;
      });

  @override
  Future<void> enregistrerTous(List<Candidature> candidatures) =>
      _proteger('import', (db) async {
        final lot = db.batch();
        for (final c in candidatures) {
          lot.insert(_table, CandidatureSqlite.versLigne(c));
        }
        await lot.commit(noResult: true);
      });

  @override
  Future<void> supprimer(int id) => _proteger('suppression', (db) async {
    final lignes = await db.delete(_table, where: 'id = ?', whereArgs: [id]);
    _verifierTrouvee(lignes, id);
  });

  void _verifierTrouvee(int lignes, int id) {
    if (lignes == 0) {
      throw CandidatureStorageException('candidature $id introuvable');
    }
  }

  @override
  Future<void> fermer() async {
    final ouverture = _ouverture;
    _ouverture = null;
    if (ouverture != null) await (await ouverture).close();
  }
}
