import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Préférences légères (thème, prénom affiché). Les candidatures, elles,
/// vivent dans SQLite : shared_preferences n'est pas fait pour des données
/// métier.
class PreferencesController extends ChangeNotifier {
  static const _cleTheme = 'theme';

  /// Clé historique : conservée pour ne pas perdre le prénom déjà saisi.
  static const _clePrenom = 'nom';

  SharedPreferences? _prefs;
  ThemeMode _themeMode = ThemeMode.system;
  String _prenom = '';

  ThemeMode get themeMode => _themeMode;
  String get prenom => _prenom;

  Future<void> charger() async {
    final prefs = _prefs = await SharedPreferences.getInstance();
    _themeMode =
        ThemeMode.values.asNameMap()[prefs.getString(_cleTheme)] ??
        ThemeMode.system;
    _prenom = prefs.getString(_clePrenom) ?? '';
    notifyListeners();
  }

  Future<void> changerTheme(ThemeMode mode) async {
    if (mode == _themeMode) return;
    _themeMode = mode;
    notifyListeners();
    await _prefs?.setString(_cleTheme, mode.name);
  }

  Future<void> changerPrenom(String prenom) async {
    final propre = prenom.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (propre == _prenom) return;
    _prenom = propre;
    notifyListeners();
    await _prefs?.setString(_clePrenom, propre);
  }
}
