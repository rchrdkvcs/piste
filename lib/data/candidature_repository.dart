import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/candidature.dart';

/// Erreur de stockage exposée au contrôleur, quel que soit le moteur utilisé.
class CandidatureStorageException implements Exception {
  const CandidatureStorageException(this.message);

  final String message;

  @override
  String toString() => 'CandidatureStorageException: $message';
}

/// Contrat de stockage. L'UI et le contrôleur ne connaissent que lui :
/// la production utilise SQLite, les tests un faux repository en mémoire.
abstract interface class CandidatureRepository {
  /// Toutes les candidatures, la dernière modifiée en premier (à date égale,
  /// la plus récemment créée). L'accueil s'appuie sur cet ordre.
  Future<List<Candidature>> toutes();

  /// Crée la candidature si elle n'a pas d'id, la met à jour sinon.
  Future<Candidature> enregistrer(Candidature candidature);

  Future<void> supprimer(int id);

  Future<void> fermer();
}

class SqliteCandidatureRepository implements CandidatureRepository {
  SqliteCandidatureRepository({this.nomFichier = 'piste.db'});

  static const _table = 'candidatures';
  static const _version = 3;

  final String nomFichier;
  Future<Database>? _ouverture;

  /// Connexion ouverte à la première utilisation, puis réutilisée.
  Future<Database> get _db => _ouverture ??= _ouvrir();

  Future<Database> _ouvrir() async {
    return openDatabase(
      join(await getDatabasesPath(), nomFichier),
      version: _version,
      onCreate: (db, version) => db.execute('''
        CREATE TABLE $_table (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          entreprise TEXT NOT NULL,
          poste TEXT NOT NULL,
          status TEXT NOT NULL,
          notes TEXT NOT NULL,
          url TEXT NOT NULL,
          contact_nom TEXT NOT NULL DEFAULT '',
          contact_email TEXT NOT NULL DEFAULT '',
          contact_telephone TEXT NOT NULL DEFAULT '',
          date_candidature TEXT,
          prochaine_relance TEXT,
          date_creation TEXT NOT NULL,
          date_modification TEXT NOT NULL
        )
      '''),
      onUpgrade: (db, ancienne, nouvelle) async {
        if (ancienne < 2) {
          // V1 : ni date de modification, ni date de candidature.
          await db.execute(
            "ALTER TABLE $_table ADD COLUMN date_modification TEXT NOT NULL DEFAULT ''",
          );
          await db.execute(
            'UPDATE $_table SET date_modification = date_creation',
          );
          await db.execute(
            'ALTER TABLE $_table ADD COLUMN date_candidature TEXT',
          );
        }
        if (ancienne < 3) {
          // V3 : contact de l'entreprise.
          for (final colonne in [
            'contact_nom',
            'contact_email',
            'contact_telephone',
          ]) {
            await db.execute(
              "ALTER TABLE $_table ADD COLUMN $colonne TEXT NOT NULL DEFAULT ''",
            );
          }
        }
      },
    );
  }

  @override
  Future<List<Candidature>> toutes() async {
    try {
      final lignes = await (await _db).query(
        _table,
        orderBy: 'date_modification DESC, id DESC',
      );
      return lignes.map(Candidature.fromDatabase).toList();
    } catch (erreur, trace) {
      Error.throwWithStackTrace(
        CandidatureStorageException('lecture : $erreur'),
        trace,
      );
    }
  }

  @override
  Future<Candidature> enregistrer(Candidature candidature) async {
    try {
      final db = await _db;
      final id = candidature.id;
      if (id == null) {
        final nouvelId = await db.insert(_table, candidature.toDatabase());
        return candidature.copyWith(id: nouvelId);
      }
      final lignes = await db.update(
        _table,
        candidature.toDatabase(),
        where: 'id = ?',
        whereArgs: [id],
      );
      if (lignes == 0) {
        throw CandidatureStorageException('candidature $id introuvable');
      }
      return candidature;
    } on CandidatureStorageException {
      rethrow;
    } catch (erreur, trace) {
      Error.throwWithStackTrace(
        CandidatureStorageException('écriture : $erreur'),
        trace,
      );
    }
  }

  @override
  Future<void> supprimer(int id) async {
    try {
      final lignes = await (await _db).delete(
        _table,
        where: 'id = ?',
        whereArgs: [id],
      );
      if (lignes == 0) {
        throw CandidatureStorageException('candidature $id introuvable');
      }
    } on CandidatureStorageException {
      rethrow;
    } catch (erreur, trace) {
      Error.throwWithStackTrace(
        CandidatureStorageException('suppression : $erreur'),
        trace,
      );
    }
  }

  @override
  Future<void> fermer() async {
    final ouverture = _ouverture;
    _ouverture = null;
    if (ouverture != null) await (await ouverture).close();
  }
}
