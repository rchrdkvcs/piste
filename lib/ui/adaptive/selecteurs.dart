import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../format/dates.dart';
import 'plateforme.dart';

Future<DateTime?> choisirDate(
  BuildContext context, {
  DateTime? initiale,
  required String titre,
  DateTime? premiere,
  DateTime? derniere,
}) async {
  final jour = aujourdhui();
  final min = sansHeure(premiere ?? DateTime(jour.year - 10));
  final borneMax = sansHeure(derniere ?? DateTime(jour.year + 3, 12, 31));
  final max = borneMax.isBefore(min) ? min : borneMax;
  final depart = bornerDate(initiale ?? jour, min, max);

  final choix = estCupertino(context)
      ? await AdaptiveDatePicker.show(
          context: context,
          initialDate: depart,
          firstDate: min,
          lastDate: max,
        )
      : await showDatePicker(
          context: context,
          initialDate: depart,
          firstDate: min,
          lastDate: max,
          helpText: titre,
        );
  return choix == null ? null : sansHeure(choix);
}

Future<T?> choisirParmi<T>(
  BuildContext context, {
  required String titre,
  required Map<T, String> options,
  T? selection,
}) {
  if (estCupertino(context)) {
    return showCupertinoModalPopup<T>(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: Text(titre),
        actions: [
          for (final e in options.entries)
            CupertinoActionSheetAction(
              isDefaultAction: e.key == selection,
              onPressed: () => Navigator.pop(context, e.key),
              child: Text(e.value),
            ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
      ),
    );
  }
  return showDialog<T>(
    context: context,
    builder: (context) => SimpleDialog(
      title: Text(titre),
      children: [
        for (final e in options.entries)
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, e.key),
            child: Text(e.value),
          ),
      ],
    ),
  );
}
