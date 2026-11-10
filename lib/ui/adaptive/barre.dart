import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/material.dart';

import 'plateforme.dart';

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

class ActionPrincipale {
  const ActionPrincipale({
    required this.libelle,
    required this.libelleCourt,
    required this.onPressed,
  });

  final String libelle;
  final String libelleCourt;
  final VoidCallback onPressed;
}

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
  }) : assert((menu == null) == (onMenu == null));

  final String libelle;

  final String? symbole;
  final IconData? iconeMaterial;

  final IconData? iconeCupertino;

  final bool texte;

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
