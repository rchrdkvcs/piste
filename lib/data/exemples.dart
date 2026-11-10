import '../models/candidature.dart';

/// Jeu de données de démonstration, importable depuis les paramètres.
///
/// Les dates sont relatives à [maintenant] : l'accueil, les relances et les
/// statistiques restent parlants quel que soit le jour de l'import.
List<Candidature> candidaturesExemple(DateTime maintenant) {
  final jour = DateTime(maintenant.year, maintenant.month, maintenant.day);
  DateTime il(int jours) => jour.subtract(Duration(days: jours));
  DateTime dans(int jours) => jour.add(Duration(days: jours));

  Candidature c({
    required String entreprise,
    required String poste,
    required Statut statut,
    required int envoi,
    int? relance,
    int? modification,
    String notes = '',
    String lien = '',
    Contact contact = Contact.vide,
  }) {
    final modifiee = maintenant.subtract(Duration(days: modification ?? envoi));
    return Candidature(
      entreprise: entreprise,
      poste: poste,
      statut: statut,
      notes: notes,
      lienAnnonce: lien,
      contact: contact,
      dateEnvoi: il(envoi),
      prochaineRelance: relance == null
          ? null
          : (relance >= 0 ? dans(relance) : il(-relance)),
      dateCreation: maintenant.subtract(Duration(days: envoi)),
      dateModification: modifiee,
    );
  }

  return [
    c(
      entreprise: 'Nexora',
      poste: 'Développeur Flutter',
      statut: Statut.entretien,
      envoi: 18,
      relance: 2,
      modification: 1,
      notes:
          'Entretien technique prévu avec le lead mobile. Revoir les '
          'tests widget et la gestion d’état.',
      lien: 'https://exemple.fr/nexora/flutter',
      contact: Contact.saisi(
        nom: 'Camille Martin',
        email: 'camille.martin@exemple.fr',
        telephone: '06 12 34 56 78',
      ),
    ),
    c(
      entreprise: 'Atelier Lumen',
      poste: 'Développeur mobile',
      statut: Statut.envoyee,
      envoi: 9,
      relance: -1,
      notes: 'Candidature spontanée envoyée via le site carrière.',
    ),
    c(
      entreprise: 'Brume Studio',
      poste: 'Ingénieur front-end',
      statut: Statut.enCours,
      envoi: 12,
      relance: 4,
      modification: 3,
      notes: 'Test technique reçu, à rendre sous une semaine.',
      lien: 'https://exemple.fr/brume/front',
      contact: Contact.saisi(nom: 'Léa Dubois', email: 'lea@exemple.fr'),
    ),
    c(
      entreprise: 'Kalia Santé',
      poste: 'Développeur Flutter senior',
      statut: Statut.offre,
      envoi: 34,
      modification: 2,
      notes: 'Proposition reçue : réponse attendue avant la fin du mois.',
      contact: Contact.saisi(
        nom: 'Thomas Bernard',
        telephone: '01 23 45 67 89',
      ),
    ),
    c(
      entreprise: 'Orbital Data',
      poste: 'Développeur full-stack',
      statut: Statut.refusee,
      envoi: 27,
      modification: 15,
      notes:
          'Refus après le premier entretien : profil plus back-end '
          'recherché.',
    ),
    c(
      entreprise: 'Nexora',
      poste: 'Développeur iOS',
      statut: Statut.envoyee,
      envoi: 5,
      relance: 2,
    ),
    c(
      entreprise: 'Verdi Mobilités',
      poste: 'Développeur mobile React Native',
      statut: Statut.enCours,
      envoi: 21,
      relance: 0,
      modification: 7,
      lien: 'https://exemple.fr/verdi/mobile',
    ),
    c(
      entreprise: 'Papillon Éditions',
      poste: 'Développeur applications',
      statut: Statut.refusee,
      envoi: 45,
      modification: 30,
    ),
  ];
}
