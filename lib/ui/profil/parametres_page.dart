import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../state/preferences_controller.dart';
import '../../theme/typo.dart';
import '../adaptive/adaptive.dart';
import '../widgets/logo_piste.dart';

const versionApplication = '1.0.0';

class ParametresPage extends StatelessWidget {
  const ParametresPage({super.key, required this.preferences});

  final PreferencesController preferences;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: preferences,
      builder: (context, _) {
        return AdaptivePage(
          titre: estCupertino(context) ? 'Réglages' : 'Paramètres',
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
            const SliverToBoxAdapter(
              child: SectionListe(
                titre: 'Données',
                lignes: [
                  LigneListe(
                    titre: 'Stockage',
                    detail: 'Sur cet appareil',
                    iconeMaterial: Icons.storage_outlined,
                    iconeCupertino: CupertinoIcons.tray_full_fill,
                    couleurIcone: CupertinoColors.systemGreen,
                  ),
                ],
                pied:
                    'Les candidatures sont enregistrées localement. Elles '
                    'sont effacées si l’app est désinstallée.',
              ),
            ),
            SliverToBoxAdapter(
              child: SectionListe(
                titre: 'À propos',
                lignes: [
                  const LigneListe(
                    titre: 'Version',
                    detail: versionApplication,
                    iconeMaterial: Icons.info_outline,
                    iconeCupertino: CupertinoIcons.info,
                    couleurIcone: CupertinoColors.systemGrey,
                  ),
                  LigneListe(
                    titre: 'Licences open source',
                    iconeMaterial: Icons.description_outlined,
                    iconeCupertino: CupertinoIcons.doc_text_fill,
                    couleurIcone: CupertinoColors.systemGrey,
                    onTap: () => showLicensePage(
                      context: context,
                      applicationName: 'Piste',
                      applicationVersion: versionApplication,
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
                      Text('Piste', style: Typo.corpsGras(context)),
                      Text(
                        'Version $versionApplication',
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

void afficherAPropos(BuildContext context) {
  const description =
      'Piste centralise le suivi de tes candidatures. Les données sont '
      'enregistrées uniquement sur cet appareil.';
  if (estCupertino(context)) {
    AdaptiveAlertDialog.show(
      context: context,
      title: 'Piste $versionApplication',
      message: description,
      actions: [AlertAction(title: 'OK', onPressed: () {})],
    );
    return;
  }
  showAboutDialog(
    context: context,
    applicationName: 'Piste',
    applicationVersion: versionApplication,
    applicationIcon: const LogoPiste(taille: 48),
    children: const [Text(description)],
  );
}
