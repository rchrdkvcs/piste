import 'package:flutter/material.dart';

import '../../format/dates.dart';

/// Champ de date Material : touche pour choisir, croix pour effacer.
class ChampDate extends StatelessWidget {
  const ChampDate({
    super.key,
    required this.libelle,
    required this.icone,
    required this.date,
    required this.onTap,
    required this.onEffacer,
  });

  final String libelle;
  final IconData icone;
  final DateTime? date;
  final VoidCallback onTap;
  final VoidCallback onEffacer;

  @override
  Widget build(BuildContext context) {
    final d = date;
    return Semantics(
      button: true,
      label: libelle,
      value: d == null ? 'Aucune date' : dateLongue(d),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: InputDecorator(
          isEmpty: d == null,
          decoration: InputDecoration(
            labelText: libelle,
            hintText: 'Choisir une date',
            prefixIcon: Icon(icone),
            suffixIcon: d == null
                ? const Icon(Icons.calendar_month_outlined)
                : IconButton(
                    tooltip: 'Effacer la date',
                    icon: const Icon(Icons.close),
                    onPressed: onEffacer,
                  ),
          ),
          child: Text(d == null ? '' : dateLongue(d)),
        ),
      ),
    );
  }
}
