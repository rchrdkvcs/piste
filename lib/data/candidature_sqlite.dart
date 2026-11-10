import '../models/candidature.dart';

abstract final class CandidatureSqlite {
  static const table = 'candidatures';
  static const version = 3;

  static const creation =
      '''
    CREATE TABLE $table (
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
  ''';

  static List<String> migrations(int ancienne) => [
    if (ancienne < 2) ...[
      "ALTER TABLE $table ADD COLUMN date_modification TEXT NOT NULL DEFAULT ''",
      'UPDATE $table SET date_modification = date_creation',
      'ALTER TABLE $table ADD COLUMN date_candidature TEXT',
    ],
    if (ancienne < 3)
      for (final colonne in [
        'contact_nom',
        'contact_email',
        'contact_telephone',
      ])
        "ALTER TABLE $table ADD COLUMN $colonne TEXT NOT NULL DEFAULT ''",
  ];

  static Map<String, Object?> versLigne(Candidature c) => {
    if (c.id != null) 'id': c.id,
    'entreprise': c.entreprise,
    'poste': c.poste,
    'status': c.statut.name,
    'notes': c.notes,
    'url': c.lienAnnonce,
    'contact_nom': c.contact.nom,
    'contact_email': c.contact.email,
    'contact_telephone': c.contact.telephone,
    'date_candidature': c.dateEnvoi?.toIso8601String(),
    'prochaine_relance': c.prochaineRelance?.toIso8601String(),
    'date_creation': c.dateCreation.toIso8601String(),
    'date_modification': c.dateModification.toIso8601String(),
  };

  static Candidature depuisLigne(Map<String, Object?> ligne) {
    String texte(String colonne) => ligne[colonne] as String? ?? '';
    final creation =
        _date(ligne['date_creation']) ?? DateTime.fromMillisecondsSinceEpoch(0);
    return Candidature(
      id: ligne['id'] as int?,
      entreprise: texte('entreprise'),
      poste: texte('poste'),
      statut: Statut.depuisNom(ligne['status'] as String?),
      notes: texte('notes'),
      lienAnnonce: texte('url'),
      contact: Contact(
        nom: texte('contact_nom'),
        email: texte('contact_email'),
        telephone: texte('contact_telephone'),
      ),
      dateEnvoi: _date(ligne['date_candidature']),
      prochaineRelance: _date(ligne['prochaine_relance']),
      dateCreation: creation,
      dateModification: _date(ligne['date_modification']) ?? creation,
    );
  }

  static DateTime? _date(Object? valeur) =>
      valeur is String && valeur.isNotEmpty ? DateTime.tryParse(valeur) : null;
}
