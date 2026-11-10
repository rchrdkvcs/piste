import 'package:flutter/foundation.dart';

import '../data/candidature_repository.dart';
import '../models/candidature.dart';
import '../models/saisie.dart';
import 'indicateurs.dart';

enum EtatChargement { chargement, pret, vide, erreur }

/// Source de vérité des candidatures, partagée par tous les écrans.
///
/// Créé une seule fois par la racine de l'application ; les pages reçoivent
/// la même instance et l'écoutent avec un `ListenableBuilder`.
class CandidatureController extends ChangeNotifier {
  CandidatureController(this.repository);

  final CandidatureRepository repository;

  EtatChargement _etat = EtatChargement.chargement;
  List<Candidature> _candidatures = const [];
  Indicateurs _indicateurs = Indicateurs.vide;
  String _recherche = '';
  Statut? _filtre;
  bool _occupe = false;
  bool _libere = false;

  EtatChargement get etat => _etat;
  List<Candidature> get candidatures => List.unmodifiable(_candidatures);
  String get recherche => _recherche;
  Statut? get filtre => _filtre;
  bool get occupe => _occupe;

  /// Candidatures après recherche texte et filtre de statut combinés.
  /// La recherche ignore casse et accents, et porte sur l'entreprise, le
  /// poste et le nom du contact.
  List<Candidature> get visibles {
    final query = Saisie.pourRecherche(_recherche);
    return _candidatures
        .where((c) {
          if (_filtre != null && c.statut != _filtre) return false;
          if (query.isEmpty) return true;
          final texte = Saisie.pourRecherche(
            '${c.entreprise} ${c.poste} ${c.contact.nom}',
          );
          return texte.contains(query);
        })
        .toList(growable: false);
  }

  // --- Indicateurs : toujours calculés sur la liste complète. -------------

  int get total => _indicateurs.total;
  int compter(Statut statut) => _indicateurs.compter(statut);
  double proportion(Statut statut) => _indicateurs.proportion(statut);
  List<MapEntry<String, int>> get parEntreprise => _indicateurs.parEntreprise;

  /// Candidatures dont la relance est due ou dépassée, la plus ancienne
  /// d'abord.
  List<Candidature> aRelancer([DateTime? maintenant]) {
    final jour = maintenant ?? DateTime.now();
    return _candidatures.where((c) => c.aRelancer(jour)).toList()
      ..sort((a, b) => a.prochaineRelance!.compareTo(b.prochaineRelance!));
  }

  Candidature? parId(int id) {
    for (final c in _candidatures) {
      if (c.id == id) return c;
    }
    return null;
  }

  // --- Recherche et filtre -------------------------------------------------

  void rechercher(String texte) {
    if (texte == _recherche) return;
    _recherche = texte;
    notifyListeners();
  }

  void filtrer(Statut? statut) {
    if (statut == _filtre) return;
    _filtre = statut;
    notifyListeners();
  }

  void reinitialiserFiltres() {
    _recherche = '';
    _filtre = null;
    notifyListeners();
  }

  // --- Lecture et écriture -------------------------------------------------

  /// Lit toutes les candidatures. Une erreur donne l'état [EtatChargement.erreur] :
  /// on n'affiche jamais une liste vide ou ancienne comme si la lecture avait réussi.
  ///
  /// [silencieux] évite de repasser par l'état loading après une écriture.
  Future<void> charger({bool silencieux = false}) async {
    if (!silencieux) {
      _etat = EtatChargement.chargement;
      _notifier();
    }
    try {
      final lignes = await repository.toutes();
      _candidatures = lignes;
      _etat = lignes.isEmpty ? EtatChargement.vide : EtatChargement.pret;
    } catch (_) {
      _candidatures = const [];
      _etat = EtatChargement.erreur;
    }
    _indicateurs = Indicateurs.depuis(_candidatures);
    _notifier();
  }

  /// Enregistre puis relit la base. L'exception remonte à l'écran appelant
  /// pour qu'il garde les champs saisis et affiche l'erreur.
  Future<Candidature> enregistrer(Candidature candidature) {
    return _operation(() async {
      final enregistree = await repository.enregistrer(candidature);
      await charger(silencieux: true);
      return enregistree;
    });
  }

  /// Ajoute [candidatures] à celles existantes (jeu de démonstration),
  /// puis relit la base. Renvoie le nombre de candidatures ajoutées.
  Future<int> importer(List<Candidature> candidatures) {
    return _operation(() async {
      for (final c in candidatures) {
        await repository.enregistrer(c);
      }
      await charger(silencieux: true);
      return candidatures.length;
    });
  }

  Future<void> supprimer(int id) {
    return _operation(() async {
      await repository.supprimer(id);
      await charger(silencieux: true);
    });
  }

  /// Bloque deux écritures simultanées (double appui, deux écrans…).
  Future<T> _operation<T>(Future<T> Function() action) async {
    if (_occupe) {
      throw StateError('Une opération est déjà en cours.');
    }
    _occupe = true;
    _notifier();
    try {
      return await action();
    } finally {
      _occupe = false;
      _notifier();
    }
  }

  void _notifier() {
    if (!_libere) notifyListeners();
  }

  @override
  void dispose() {
    _libere = true;
    super.dispose();
  }
}
