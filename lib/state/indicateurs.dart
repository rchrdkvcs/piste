import '../models/candidature.dart';

class Indicateurs {
  Indicateurs.depuis(List<Candidature> candidatures)
    : total = candidatures.length,
      parStatut = {
        for (final s in Statut.values)
          s: candidatures.where((c) => c.statut == s).length,
      },
      parEntreprise = _parEntreprise(candidatures);

  static final vide = Indicateurs.depuis(const []);

  final int total;
  final Map<Statut, int> parStatut;

  final List<MapEntry<String, int>> parEntreprise;

  int compter(Statut statut) => parStatut[statut] ?? 0;

  double proportion(Statut statut) => total == 0 ? 0 : compter(statut) / total;

  static List<MapEntry<String, int>> _parEntreprise(List<Candidature> liste) {
    final noms = <String, String>{};
    final compte = <String, int>{};
    for (final c in liste) {
      final cle = Candidature.cleEntreprise(c.entreprise);
      noms.putIfAbsent(cle, () => c.entreprise.trim());
      compte[cle] = (compte[cle] ?? 0) + 1;
    }
    final entrees = [
      for (final e in compte.entries) MapEntry(noms[e.key]!, e.value),
    ];
    return entrees..sort((a, b) {
      final parNombre = b.value.compareTo(a.value);
      return parNombre != 0
          ? parNombre
          : a.key.toLowerCase().compareTo(b.key.toLowerCase());
    });
  }
}
