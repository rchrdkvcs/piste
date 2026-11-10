import '../format/dates.dart';
import 'saisie.dart';

enum Statut {
  envoyee('Envoyée', 'Envoyées'),
  enCours('En cours', 'En cours'),
  entretien('Entretien', 'Entretiens'),
  offre('Offre', 'Offres'),
  refusee('Refusée', 'Refusées');

  const Statut(this.libelle, this.libellePluriel);

  final String libelle;
  final String libellePluriel;

  bool get estClos => this == Statut.refusee;

  static Statut depuisNom(String? nom) {
    for (final statut in values) {
      if (statut.name == nom) return statut;
    }
    return Statut.envoyee;
  }
}

class Contact {
  const Contact({this.nom = '', this.email = '', this.telephone = ''});

  static const vide = Contact();

  final String nom;
  final String email;
  final String telephone;

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

  final int? id;
  final String entreprise;
  final String poste;
  final Statut statut;
  final String notes;

  final String lienAnnonce;
  final Contact contact;
  final DateTime? dateEnvoi;
  final DateTime? prochaineRelance;
  final DateTime dateCreation;
  final DateTime dateModification;

  static String cleEntreprise(String nom) => nom.trim().toLowerCase();

  bool aRelancer(DateTime aujourdhui) {
    final relance = prochaineRelance;
    if (relance == null || statut.estClos) return false;
    return !sansHeure(relance).isAfter(sansHeure(aujourdhui));
  }

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

  bool memeContenu(Candidature autre) =>
      entreprise == autre.entreprise &&
      poste == autre.poste &&
      statut == autre.statut &&
      notes == autre.notes &&
      lienAnnonce == autre.lienAnnonce &&
      contact == autre.contact &&
      dateEnvoi == autre.dateEnvoi &&
      prochaineRelance == autre.prochaineRelance;
}

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
