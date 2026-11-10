import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// Vrai sur iOS (et macOS) : les écrans prennent alors les composants
/// Cupertino ou UIKit.
///
/// `estCupertino` lit `Theme.of(context).platform`, ce qui permet de forcer
/// la plateforme dans les tests.
bool estCupertino(BuildContext context) {
  final plateforme = Theme.of(context).platform;
  return plateforme == TargetPlatform.iOS || plateforme == TargetPlatform.macOS;
}

IconData icone(BuildContext context, IconData material, IconData cupertino) =>
    estCupertino(context) ? cupertino : material;

Color couleurAccent(BuildContext context) => estCupertino(context)
    ? PisteCouleurs.accentIos.resolveFrom(context)
    : Theme.of(context).colorScheme.primary;

Color couleurErreur(BuildContext context) => estCupertino(context)
    ? CupertinoColors.systemRed.resolveFrom(context)
    : Theme.of(context).colorScheme.error;

/// Fond des cartes : couleur système groupée sur iOS, surface Material sinon.
Color couleurCarte(BuildContext context) => estCupertino(context)
    ? CupertinoColors.secondarySystemGroupedBackground.resolveFrom(context)
    : Theme.of(context).colorScheme.surfaceContainerLow;

Color couleurTexteSecondaire(BuildContext context) => estCupertino(context)
    ? CupertinoColors.secondaryLabel.resolveFrom(context)
    : Theme.of(context).colorScheme.onSurfaceVariant;

/// Le mouvement est-il réduit dans les réglages d'accessibilité ?
bool mouvementReduit(BuildContext context) =>
    MediaQuery.maybeDisableAnimationsOf(context) ?? false;
