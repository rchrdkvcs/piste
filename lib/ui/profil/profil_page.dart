import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../state/candidature_controller.dart';
import '../../state/preferences_controller.dart';
import '../../theme/typo.dart';
import '../adaptive/adaptive.dart';
import 'parametres_page.dart';

/// Profil local : Piste fonctionne sans compte, le prénom sert uniquement
/// à personnaliser l'accueil.
class ProfilPage extends StatelessWidget {
  const ProfilPage({
    super.key,
    required this.preferences,
    required this.controller,
  });

  final PreferencesController preferences;
  final CandidatureController controller;

  Future<void> _modifierPrenom(BuildContext context) async {
    final prenom = await demanderTexte(
      context,
      titre: 'Ton prénom',
      message: 'Il s’affiche sur l’accueil. Il reste sur cet appareil.',
      champ: 'Prénom',
      action: 'Enregistrer',
      valeur: preferences.prenom,
    );
    if (prenom != null) await preferences.changerPrenom(prenom);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([preferences, controller]),
      builder: (context, _) {
        final nom = preferences.prenom;
        final total = controller.total;
        return AdaptivePage(
          titre: 'Profil',
          slivers: [
            Marge(
              haut: 8,
              sliver: SliverToBoxAdapter(child: _entete(context, nom)),
            ),
            SliverToBoxAdapter(
              child: SectionListe(
                titre: 'Mes informations',
                lignes: [
                  LigneListe(
                    titre: 'Prénom',
                    detail: nom.isEmpty ? 'Ajouter' : nom,
                    iconeMaterial: Icons.person_outline,
                    iconeCupertino: CupertinoIcons.person_fill,
                    onTap: () => _modifierPrenom(context),
                  ),
                  LigneListe(
                    titre: 'Candidatures enregistrées',
                    detail: '$total',
                    iconeMaterial: Icons.work_outline,
                    iconeCupertino: CupertinoIcons.briefcase_fill,
                    couleurIcone: CupertinoColors.systemIndigo,
                  ),
                ],
              ),
            ),
            SliverToBoxAdapter(
              child: SectionListe(
                titre: 'Application',
                lignes: [
                  LigneListe(
                    titre: estCupertino(context) ? 'Réglages' : 'Paramètres',
                    iconeMaterial: Icons.settings_outlined,
                    iconeCupertino: CupertinoIcons.gear_solid,
                    couleurIcone: CupertinoColors.systemGrey,
                    onTap: () => ouvrirPage<void>(
                      context,
                      (_) => ParametresPage(preferences: preferences),
                    ),
                  ),
                  LigneListe(
                    titre: 'À propos de Piste',
                    iconeMaterial: Icons.info_outline,
                    iconeCupertino: CupertinoIcons.info,
                    couleurIcone: CupertinoColors.systemBlue,
                    onTap: () => afficherAPropos(context),
                  ),
                ],
                pied:
                    'Tes données restent sur cet appareil : ni compte, '
                    'ni serveur.',
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _entete(BuildContext context, String nom) {
    final accent = couleurAccent(context);
    final initiales = nom.isEmpty
        ? null
        : nom
              .split(RegExp(r'\s+'))
              .where((m) => m.isNotEmpty)
              .take(2)
              .map((m) => m.characters.first.toUpperCase())
              .join();
    return MergeSemantics(
      child: Column(
        children: [
          ExcludeSemantics(
            child: CircleAvatar(
              radius: 40,
              backgroundColor: accent.withValues(alpha: 0.14),
              foregroundColor: accent,
              child: initiales == null
                  ? Icon(
                      icone(context, Icons.person, CupertinoIcons.person_fill),
                      size: 40,
                    )
                  : Text(
                      initiales,
                      textScaler: TextScaler.noScaling,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 12),
          Text(nom.isEmpty ? 'Ton profil' : nom, style: Typo.titre(context)),
          const SizedBox(height: 2),
          Text('Profil local, sans compte', style: Typo.secondaire(context)),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
