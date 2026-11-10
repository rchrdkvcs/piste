import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/material.dart';

import 'plateforme.dart';

Future<bool> confirmerSuppression(
  BuildContext context, {
  required String titre,
  required String message,
  required String action,
}) => _confirmer(
  context,
  titre: titre,
  message: message,
  action: action,
  destructif: true,
);

Future<bool> confirmerAction(
  BuildContext context, {
  required String titre,
  required String message,
  required String action,
}) => _confirmer(
  context,
  titre: titre,
  message: message,
  action: action,
  destructif: false,
);

Future<bool> _confirmer(
  BuildContext context, {
  required String titre,
  required String message,
  required String action,
  required bool destructif,
}) async {
  if (estCupertino(context)) {
    var confirme = false;
    await AdaptiveAlertDialog.show(
      context: context,
      title: titre,
      message: message,
      actions: [
        AlertAction(
          title: 'Annuler',
          style: AlertActionStyle.cancel,
          onPressed: () {},
        ),
        AlertAction(
          title: action,
          style: destructif
              ? AlertActionStyle.destructive
              : AlertActionStyle.primary,
          onPressed: () => confirme = true,
        ),
      ],
    );
    return confirme;
  }
  final ok = await showDialog<bool>(
    context: context,
    builder: (context) {
      final scheme = Theme.of(context).colorScheme;
      return AlertDialog(
        icon: destructif
            ? Icon(Icons.delete_outline, color: scheme.error)
            : null,
        title: Text(titre),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: destructif ? scheme.error : null,
              foregroundColor: destructif ? scheme.onError : null,
              minimumSize: const Size(0, 40),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(action),
          ),
        ],
      );
    },
  );
  return ok ?? false;
}

Future<String?> demanderTexte(
  BuildContext context, {
  required String titre,
  required String champ,
  required String action,
  String? message,
  String valeur = '',
}) async {
  if (estCupertino(context)) {
    return AdaptiveAlertDialog.inputShow(
      context: context,
      title: titre,
      message: message,
      input: AdaptiveAlertDialogInput(placeholder: champ, initialValue: valeur),
      actions: [
        AlertAction(
          title: 'Annuler',
          style: AlertActionStyle.cancel,
          onPressed: () {},
        ),
        AlertAction(title: action, onPressed: () {}),
      ],
    );
  }
  return showDialog<String>(
    context: context,
    builder: (context) => _DialogueTexte(
      titre: titre,
      champ: champ,
      action: action,
      message: message,
      valeur: valeur,
    ),
  );
}

class _DialogueTexte extends StatefulWidget {
  const _DialogueTexte({
    required this.titre,
    required this.champ,
    required this.action,
    required this.valeur,
    this.message,
  });

  final String titre;
  final String champ;
  final String action;
  final String? message;
  final String valeur;

  @override
  State<_DialogueTexte> createState() => _DialogueTexteState();
}

class _DialogueTexteState extends State<_DialogueTexte> {
  late final _texte = TextEditingController(text: widget.valeur);

  @override
  void dispose() {
    _texte.dispose();
    super.dispose();
  }

  void _valider() => Navigator.pop(context, _texte.text);

  @override
  Widget build(BuildContext context) {
    final message = widget.message;
    return AlertDialog(
      title: Text(widget.titre),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (message != null) ...[Text(message), const SizedBox(height: 16)],
          TextField(
            controller: _texte,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(labelText: widget.champ),
            onSubmitted: (_) => _valider(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(minimumSize: const Size(0, 40)),
          onPressed: _valider,
          child: Text(widget.action),
        ),
      ],
    );
  }
}

Future<void> afficherAPropos(
  BuildContext context, {
  required String nom,
  required String version,
  required String description,
  required Widget icone,
}) async {
  if (estCupertino(context)) {
    await AdaptiveAlertDialog.show(
      context: context,
      title: '$nom $version',
      message: description,
      actions: [AlertAction(title: 'OK', onPressed: () {})],
    );
    return;
  }
  showAboutDialog(
    context: context,
    applicationName: nom,
    applicationVersion: version,
    applicationIcon: icone,
    children: [Text(description)],
  );
}
