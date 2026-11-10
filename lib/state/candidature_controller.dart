import 'package:flutter/foundation.dart';

import '../data/candidature_repository.dart';
import '../models/candidature.dart';
import '../models/saisie.dart';
import 'indicateurs.dart';

enum EtatChargement { chargement, pret, vide, erreur }

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
  bool get lisible =>
      _etat == EtatChargement.pret || _etat == EtatChargement.vide;
  List<Candidature> get candidatures => List.unmodifiable(_candidatures);
  String get recherche => _recherche;
  Statut? get filtre => _filtre;
  bool get occupe => _occupe;

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

  Indicateurs get indicateurs => _indicateurs;

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

  Future<Candidature> enregistrer(Candidature candidature) {
    return _operation(() async {
      final enregistree = await repository.enregistrer(candidature);
      await charger(silencieux: true);
      return enregistree;
    });
  }

  Future<int> importer(List<Candidature> candidatures) {
    return _operation(() async {
      await repository.enregistrerTous(candidatures);
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
