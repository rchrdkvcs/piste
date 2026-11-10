import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../format/dates.dart';
import 'plateforme.dart';
import 'selecteurs.dart';

class ChampTexte extends StatelessWidget {
  const ChampTexte({
    super.key,
    required this.controller,
    required this.libelle,
    required this.indication,
    this.icone,
    this.focusNode,
    this.obligatoire = false,
    this.multiligne = false,
    this.clavier,
    this.capitalisation = TextCapitalization.none,
    this.correction = true,
    this.autofill,
    this.formatage,
    this.validateur,
    this.autofocus = false,
  });

  final TextEditingController controller;
  final String libelle;
  final String indication;
  final IconData? icone;
  final FocusNode? focusNode;
  final bool obligatoire;
  final bool multiligne;
  final TextInputType? clavier;
  final TextCapitalization capitalisation;
  final bool correction;
  final Iterable<String>? autofill;
  final List<TextInputFormatter>? formatage;
  final FormFieldValidator<String>? validateur;
  final bool autofocus;

  Text get _libelle => Text(
    obligatoire ? '$libelle *' : libelle,
    semanticsLabel: obligatoire ? '$libelle, obligatoire' : libelle,
  );

  TextInputType? get _clavier => multiligne ? TextInputType.multiline : clavier;

  TextInputAction? get _action => multiligne ? null : TextInputAction.next;

  @override
  Widget build(BuildContext context) {
    if (estCupertino(context)) {
      return CupertinoTextFormFieldRow(
        controller: controller,
        focusNode: focusNode,
        prefix: multiligne ? null : _libelle,
        placeholder: multiligne ? '$libelle : $indication' : indication,
        textAlign: multiligne ? TextAlign.start : TextAlign.end,
        minLines: multiligne ? 3 : null,
        maxLines: multiligne ? 8 : 1,
        keyboardType: _clavier,
        textInputAction: _action,
        textCapitalization: capitalisation,
        autocorrect: correction,
        enableSuggestions: correction,
        autofillHints: autofill,
        inputFormatters: formatage,
        validator: validateur,
        autofocus: autofocus,
      );
    }
    final ic = icone;
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      decoration: InputDecoration(
        label: _libelle,
        hintText: indication,
        prefixIcon: ic == null ? null : Icon(ic),
        alignLabelWithHint: multiligne,
      ),
      minLines: multiligne ? 3 : null,
      maxLines: multiligne ? 8 : 1,
      keyboardType: _clavier,
      textInputAction: _action,
      textCapitalization: capitalisation,
      autocorrect: correction,
      enableSuggestions: correction,
      autofillHints: autofill,
      inputFormatters: formatage,
      validator: validateur,
      autofocus: autofocus,
    );
  }
}

class ChampChoix<T> extends StatelessWidget {
  const ChampChoix({
    super.key,
    required this.libelle,
    required this.icone,
    required this.valeur,
    required this.options,
    required this.onChanged,
  });

  final String libelle;
  final IconData icone;
  final T valeur;
  final Map<T, String> options;
  final ValueChanged<T> onChanged;

  Future<void> _choisir(BuildContext context) async {
    FocusScope.of(context).unfocus();
    final choix = await choisirParmi<T>(
      context,
      titre: libelle,
      options: options,
      selection: valeur,
    );
    if (choix != null) onChanged(choix);
  }

  @override
  Widget build(BuildContext context) {
    if (estCupertino(context)) {
      return CupertinoListTile(
        title: Text(libelle),
        additionalInfo: Text(options[valeur]!),
        trailing: const CupertinoListTileChevron(),
        onTap: () => _choisir(context),
      );
    }
    return DropdownButtonFormField<T>(
      initialValue: valeur,
      decoration: InputDecoration(labelText: libelle, prefixIcon: Icon(icone)),
      items: [
        for (final e in options.entries)
          DropdownMenuItem(value: e.key, child: Text(e.value)),
      ],
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
    );
  }
}

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
  Widget build(BuildContext context) =>
      estCupertino(context) ? _cupertino(context) : _material();

  Widget _cupertino(BuildContext context) {
    final d = date;
    return CupertinoListTile(
      title: Text(libelle),
      additionalInfo: Text(d == null ? 'Aucune' : dateCourte(d)),
      trailing: d == null
          ? const CupertinoListTileChevron()
          : Semantics(
              label: 'Effacer la date « $libelle »',
              button: true,
              excludeSemantics: true,
              child: CupertinoButton(
                padding: EdgeInsets.zero,
                minimumSize: const Size.square(44),
                onPressed: onEffacer,
                child: Icon(
                  CupertinoIcons.xmark_circle_fill,
                  size: 20,
                  color: CupertinoColors.tertiaryLabel.resolveFrom(context),
                ),
              ),
            ),
      onTap: onTap,
    );
  }

  Widget _material() {
    final d = date;
    return Semantics(
      button: true,
      label: libelle,
      value: d == null ? 'Aucune date' : dateLongue(d),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
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
