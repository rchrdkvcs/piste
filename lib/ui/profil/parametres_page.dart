import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../app_info.dart';
import '../../data/exemples.dart';
import '../../format/texte.dart';
import '../../state/candidature_controller.dart';
import '../../state/preferences_controller.dart';
import '../adaptive/adaptive.dart';
import '../widgets/logo_piste.dart';

class ParametresPage extends StatelessWidget {
  const ParametresPage({
    super.key,
    required this.preferences,
    required this.controller,
  });

  final PreferencesController preferences;
  final CandidatureController controller;

  Future<void> _importerExemples(BuildContext context) async {
    final exemples = candidaturesExemple(DateTime.now());
    final confirme = await confirmerAction(
      context,
      titre: 'Importer le jeu de données ?',
      message:
          '${pluriel(exemples.length, 'candidature')} d’exemple seront '
          'ajoutées à tes candidatures existantes.',
      action: 'Importer',
    );
    if (!confirme || !context.mounted) return;
    await executerAvecRetour(
      context,
      () => controller.importer(exemples),
      succes: '${pluriel(exemples.length, 'candidature')} importées',
      titreErreur: 'Import impossible.',
      messageErreur: 'Réessaie dans un instant.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: preferences,
      builder: (context, _) {
        return AdaptivePage(
          titre: libelleReglages(context),
          grandTitre: false,
          slivers: [
            Marge(
              haut: 16,
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsetsDirectional.only(
                        start: 4,
                        bottom: 8,
                      ),
                      child: Semantics(
                        header: true,
                        child: Text('Apparence', style: Typo.legende(context)),
                      ),
                    ),
                    Segments<ThemeMode>(
                      valeur: preferences.themeMode,
                      options: const {
                        ThemeMode.system: 'Automatique',
                        ThemeMode.light: 'Clair',
                        ThemeMode.dark: 'Sombre',
                      },
                      onChanged: preferences.changerTheme,
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.only(
                        start: 4,
                        top: 8,
                      ),
                      child: Text(
                        'Automatique suit le réglage de l’appareil.',
                        style: Typo.legende(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SectionListe(
                titre: 'Données',
                lignes: [
                  const LigneListe(
                    titre: 'Stockage',
                    detail: 'Sur cet appareil',
                    iconeMaterial: Icons.storage_outlined,
                    iconeCupertino: CupertinoIcons.tray_full_fill,
                    teinte: TeinteIcone.vert,
                  ),
                  LigneListe(
                    titre: 'Importer le jeu de données',
                    iconeMaterial: Icons.download_outlined,
                    iconeCupertino: CupertinoIcons.tray_arrow_down_fill,
                    teinte: TeinteIcone.bleu,
                    onTap: () => _importerExemples(context),
                  ),
                ],
                pied:
                    'Les candidatures sont enregistrées localement. Elles '
                    'sont effacées si l’app est désinstallée. Le jeu de '
                    'données ajoute des candidatures d’exemple pour '
                    'découvrir l’app.',
              ),
            ),
            SliverToBoxAdapter(
              child: SectionListe(
                titre: 'À propos',
                lignes: [
                  const LigneListe(
                    titre: 'Version',
                    detail: InfosApp.version,
                    iconeMaterial: Icons.info_outline,
                    iconeCupertino: CupertinoIcons.info,
                    teinte: TeinteIcone.gris,
                  ),
                  LigneListe(
                    titre: 'Licences open source',
                    iconeMaterial: Icons.description_outlined,
                    iconeCupertino: CupertinoIcons.doc_text_fill,
                    teinte: TeinteIcone.gris,
                    onTap: () => showLicensePage(
                      context: context,
                      applicationName: InfosApp.nom,
                      applicationVersion: InfosApp.version,
                    ),
                  ),
                ],
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 40),
                child: MergeSemantics(
                  child: Column(
                    children: [
                      const LogoPiste(taille: 56),
                      const SizedBox(height: 10),
                      Text(InfosApp.nom, style: Typo.corpsGras(context)),
                      Text(
                        'Version ${InfosApp.version}',
                        style: Typo.legende(context),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
