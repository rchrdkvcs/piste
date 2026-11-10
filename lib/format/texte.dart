import '../models/candidature.dart';

String pluriel(int nombre, String singulier, [String? forme]) =>
    '$nombre ${nombre > 1 ? forme ?? '${singulier}s' : singulier}';

String initiales(String texte, {int max = 1}) => texte
    .trim()
    .split(RegExp(r'\s+'))
    .where((mot) => mot.isNotEmpty)
    .take(max)
    .map((mot) => String.fromCharCode(mot.runes.first).toUpperCase())
    .join();

String descriptionCriteres(String recherche, Statut? filtre) {
  final requete = recherche.trim();
  return [
    if (requete.isNotEmpty) '« $requete »',
    if (filtre != null) 'le statut ${filtre.libelle}',
  ].join(' avec ');
}
