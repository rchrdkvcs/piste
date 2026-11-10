import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

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

Color couleurCarte(BuildContext context) => estCupertino(context)
    ? CupertinoColors.secondarySystemGroupedBackground.resolveFrom(context)
    : Theme.of(context).colorScheme.surfaceContainerLow;

BoxDecoration decorationGroupee(BuildContext context) => BoxDecoration(
  color: couleurCarte(context),
  borderRadius: BorderRadius.circular(PisteRayons.ios),
);

String libelleReglages(BuildContext context) =>
    estCupertino(context) ? 'Réglages' : 'Paramètres';

Color couleurTexteSecondaire(BuildContext context) => estCupertino(context)
    ? CupertinoColors.secondaryLabel.resolveFrom(context)
    : Theme.of(context).colorScheme.onSurfaceVariant;

bool mouvementReduit(BuildContext context) =>
    MediaQuery.maybeDisableAnimationsOf(context) ?? false;
