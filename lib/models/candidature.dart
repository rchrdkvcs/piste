import 'saisie.dart';

/// Étapes possibles d'une candidature.
///
/// Le nom de la valeur (`name`) est celui stocké en base : ne pas le renommer
/// sans prévoir de migration. Les couleurs vivent dans `theme/` : le modèle
/// ne dépend pas de l'interface.
enum Statut {
  envoyee('Envoyée', 'Envoyées'),
  enCours('En cours', 'En cours'),
  entretien('Entretien', 'Entretiens'),
  offre('Offre', 'Offres'),
  refusee('Refusée', 'Refusées');

  const Statut(this.libelle, this.libellePluriel);

  final String libelle;
  final String libellePluriel;

  /// Une candidature refusée est close : plus rien à relancer.
  bool get estClos => this == Statut.refusee;

  /// Lit un statut stocké. Une valeur inconnue (ancienne version, donnée
  /// corrompue) retombe sur [Statut.envoyee] au lieu de faire planter l'app.
  static Statut depuisNom(String? nom) {
    for (final statut in values) {
      if (statut.name == nom) return statut;
    }
    return Statut.envoyee;
  }
}

/// Personne à contacter dans l'entreprise. Tous les champs sont facultatifs ;
/// l'e-mail et le téléphone sont stockés normalisés.
class Contact {
  const Contact({this.nom = '', this.email = '', this.telephone = ''});

  static const vide = Contact();

  final String nom;
  final String email;
  final String telephone;

  /// Contact prêt à enregistrer : espaces retirés, e-mail en minuscules,
  /// téléphone réduit à ses chiffres (et `+` initial).
  factory Contact.saisi({
    String nom = '',
    String email = '',
    String telephone = '',
  }) => Contact(
    nom: nom.trim(),
    email: Saisie.normaliserEmail(email),
    telephone: telephone.trim().isEmpty
        ? ''
        : Saisie.normaliserTelephone(telephone),
  );

  @override
  bool operator ==(Object other) =>
      other is Contact &&
      other.nom == nom &&
      other.email == email &&
      other.telephone == telephone;

  @override
  int get hashCode => Object.hash(nom, email, telephone);
}

class Candidature {
  const Candidature({
    this.id,
    required this.entreprise,
    required this.poste,
    required this.statut,
    this.notes = '',
    this.lienAnnonce = '',
    this.contact = Contact.vide,
    this.dateEnvoi,
    this.prochaineRelance,
    required this.dateCreation,
    required this.dateModification,
  });

  /// `null` tant que la candidature n'a pas été enregistrée.
  final int? id;
  final String entreprise;
  final String poste;
  final Statut statut;
  final String notes;

  /// Adresse de l'annonce publiée par l'entreprise, vide si inconnue.
  final String lienAnnonce;
  final Contact contact;
  final DateTime? dateEnvoi;
  final DateTime? prochaineRelance;
  final DateTime dateCreation;
  final DateTime dateModification;

  /// Clé d'une entreprise : sans casse ni espaces autour. « Google » et
  /// « google » sont la même entreprise.
  static String cleEntreprise(String nom) => nom.trim().toLowerCase();

  /// Vrai si la relance est prévue aujourd'hui ou est dépassée, et que la
  /// candidature n'est pas close.
  bool aRelancer(DateTime aujourdhui) {
    final relance = prochaineRelance;
    if (relance == null || statut.estClos) return false;
    final jour = DateTime(aujourdhui.year, aujourdhui.month, aujourdhui.day);
    return !DateTime(relance.year, relance.month, relance.day).isAfter(jour);
  }

  /// Les dates facultatives se passent sous forme de fonction pour pouvoir
  /// être remises à `null` : `copyWith(prochaineRelance: () => null)`.
  Candidature copyWith({
    int? id,
    String? entreprise,
    String? poste,
    Statut? statut,
    String? notes,
    String? lienAnnonce,
    Contact? contact,
    DateTime? Function()? dateEnvoi,
    DateTime? Function()? prochaineRelance,
    DateTime? dateCreation,
    DateTime? dateModification,
  }) {
    return Candidature(
      id: id ?? this.id,
      entreprise: entreprise ?? this.entreprise,
      poste: poste ?? this.poste,
      statut: statut ?? this.statut,
      notes: notes ?? this.notes,
      lienAnnonce: lienAnnonce ?? this.lienAnnonce,
      contact: contact ?? this.contact,
      dateEnvoi: dateEnvoi != null ? dateEnvoi() : this.dateEnvoi,
      prochaineRelance: prochaineRelance != null
          ? prochaineRelance()
          : this.prochaineRelance,
      dateCreation: dateCreation ?? this.dateCreation,
      dateModification: dateModification ?? this.dateModification,
    );
  }

  /// Les noms de colonnes historiques (`status`, `url`, `date_candidature`)
  /// sont conservés : les renommer imposerait de reconstruire la table.
  Map<String, Object?> toDatabase() {
    return {
      if (id != null) 'id': id,
      'entreprise': entreprise,
      'poste': poste,
      'status': statut.name,
      'notes': notes,
      'url': lienAnnonce,
      'contact_nom': contact.nom,
      'contact_email': contact.email,
      'contact_telephone': contact.telephone,
      'date_candidature': dateEnvoi?.toIso8601String(),
      'prochaine_relance': prochaineRelance?.toIso8601String(),
      'date_creation': dateCreation.toIso8601String(),
      'date_modification': dateModification.toIso8601String(),
    };
  }

  factory Candidature.fromDatabase(Map<String, Object?> ligne) {
    final creation =
        _date(ligne['date_creation']) ?? DateTime.fromMillisecondsSinceEpoch(0);
    return Candidature(
      id: ligne['id'] as int?,
      entreprise: ligne['entreprise'] as String? ?? '',
      poste: ligne['poste'] as String? ?? '',
      statut: Statut.depuisNom(ligne['status'] as String?),
      notes: ligne['notes'] as String? ?? '',
      lienAnnonce: ligne['url'] as String? ?? '',
      contact: Contact(
        nom: ligne['contact_nom'] as String? ?? '',
        email: ligne['contact_email'] as String? ?? '',
        telephone: ligne['contact_telephone'] as String? ?? '',
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

/// Règles de saisie d'une candidature : message d'erreur, ou `null` si la
/// valeur est acceptable. Le formulaire les affiche sous chaque champ.
abstract final class ReglesCandidature {
  static String? entreprise(String? v) =>
      (v ?? '').trim().isEmpty ? 'Indique le nom de l’entreprise.' : null;

  static String? poste(String? v) =>
      (v ?? '').trim().isEmpty ? 'Indique l’intitulé du poste.' : null;

  static String? lienAnnonce(String? v) {
    final texte = v?.trim() ?? '';
    if (texte.isEmpty || Saisie.lienValide(texte)) return null;
    return 'Saisis une adresse web, par exemple exemple.fr/offre.';
  }

  static String? email(String? v) {
    final texte = v?.trim() ?? '';
    if (texte.isEmpty || Saisie.emailValide(texte)) return null;
    return 'Saisis une adresse e-mail, par exemple prenom@exemple.fr.';
  }

  static String? telephone(String? v) {
    final texte = v?.trim() ?? '';
    if (texte.isEmpty || Saisie.telephoneValide(texte)) return null;
    return 'Saisis un numéro de 6 à 15 chiffres, par exemple 06 12 34 56 78.';
  }
}
