import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../app_info.dart';
import '../../state/candidature_controller.dart';
import '../../state/preferences_controller.dart';
import '../adaptive/adaptive.dart';
import '../widgets/avatar.dart';
import '../widgets/logo_piste.dart';
import 'parametres_page.dart';

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
        final total = controller.indicateurs.total;
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
                    teinte: TeinteIcone.indigo,
                  ),
                ],
              ),
            ),
            SliverToBoxAdapter(
              child: SectionListe(
                titre: 'Application',
                lignes: [
                  LigneListe(
                    titre: libelleReglages(context),
                    iconeMaterial: Icons.settings_outlined,
                    iconeCupertino: CupertinoIcons.gear_solid,
                    teinte: TeinteIcone.gris,
                    onTap: () => ouvrirPage<void>(
                      context,
                      (_) => ParametresPage(
                        preferences: preferences,
                        controller: controller,
                      ),
                    ),
                  ),
                  LigneListe(
                    titre: 'À propos de Piste',
                    iconeMaterial: Icons.info_outline,
                    iconeCupertino: CupertinoIcons.info,
                    teinte: TeinteIcone.bleu,
                    onTap: () => afficherAPropos(
                      context,
                      nom: InfosApp.nom,
                      version: InfosApp.version,
                      description: InfosApp.description,
                      icone: const LogoPiste(taille: 48),
                    ),
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
    return MergeSemantics(
      child: Column(
        children: [
          AvatarInitiales(
            texte: nom,
            couleur: couleurAccent(context),
            taille: 80,
            lettres: 2,
            iconeVide: icone(context, Icons.person, CupertinoIcons.person_fill),
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
