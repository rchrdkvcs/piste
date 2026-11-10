import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/material.dart';

import 'plateforme.dart';

/// Option d'un menu de barre : `UIMenu` natif sur iOS 26, `PopupMenuButton`
/// sur Android.
class OptionMenu {
  const OptionMenu({
    required this.libelle,
    this.symbole,
    this.selectionnee = false,
    this.destructive = false,
  });

  final String libelle;
  final String? symbole;
  final bool selectionnee;
  final bool destructive;
}

/// Action de la barre de navigation, décrite une fois pour les deux
/// plateformes.
class ActionBarre {
  const ActionBarre({
    required this.libelle,
    this.symbole,
    this.iconeMaterial,
    this.iconeCupertino,
    this.texte = false,
    this.principale = false,
    this.onPressed,
    this.menu,
    this.onMenu,
    this.seulementIos = false,
  }) : assert((menu == null) == (onMenu == null));

  /// Action déjà portée sur Android par un autre composant (bouton
  /// flottant, chips de filtre) : elle n'apparaît que dans la barre iOS.
  final bool seulementIos;

  /// Nom lu par VoiceOver / TalkBack et info-bulle Android.
  final String libelle;

  /// SF Symbol (iOS 26+).
  final String? symbole;
  final IconData? iconeMaterial;

  /// Icône iOS 18 et moins.
  final IconData? iconeCupertino;

  /// Affiche le libellé au lieu d'une icône (« Modifier »).
  final bool texte;

  /// Bulle teintée Liquid Glass (iOS 26).
  final bool principale;
  final VoidCallback? onPressed;
  final List<OptionMenu>? menu;
  final ValueChanged<int>? onMenu;

  AdaptiveAppBarAction versIos(BuildContext context) {
    final options = menu;
    final rappel = onMenu;
    return AdaptiveAppBarAction(
      iosSymbol: texte ? null : symbole,
      icon: iconeCupertino,
      title: texte ? libelle : null,
      label: libelle,
      prominent: principale,
      tintColor: principale ? couleurAccent(context) : null,
      onPressed: onPressed ?? () {},
      menuItems: options == null
          ? null
          : [
              for (final o in options)
                AdaptivePopupMenuItem<int>(
                  label: o.libelle,
                  icon: o.selectionnee ? 'checkmark' : o.symbole,
                  isDestructive: o.destructive,
                ),
            ],
      onMenuItemSelected: rappel == null ? null : (i, _) => rappel(i),
    );
  }

  Widget versMaterial(BuildContext context) {
    final options = menu;
    if (options != null) {
      return PopupMenuButton<int>(
        tooltip: libelle,
        icon: Icon(iconeMaterial ?? Icons.more_vert),
        onSelected: onMenu,
        itemBuilder: (context) => [
          for (final (i, o) in options.indexed)
            PopupMenuItem<int>(
              value: i,
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  o.selectionnee ? Icons.check : null,
                  color: o.destructive ? couleurErreur(context) : null,
                ),
                title: Text(
                  o.libelle,
                  style: o.destructive
                      ? TextStyle(color: couleurErreur(context))
                      : null,
                ),
              ),
            ),
        ],
      );
    }
    if (texte || iconeMaterial == null) {
      return TextButton(onPressed: onPressed, child: Text(libelle));
    }
    return IconButton(
      tooltip: libelle,
      icon: Icon(iconeMaterial),
      onPressed: onPressed,
    );
  }
}
