import 'package:flutter/cupertino.dart';

import '../../format/dates.dart';
import '../../models/candidature.dart';
import '../../state/candidature_controller.dart';
import '../adaptive/adaptive.dart';
import 'actions_formulaire.dart';
import 'champs_candidature.dart';
import 'formulaire_cupertino.dart';
import 'formulaire_material.dart';

/// Ouvre le formulaire : création si [initiale] est nul, modification sinon.
Future<void> ouvrirFormulaire(
  BuildContext context,
  CandidatureController controller, {
  Candidature? initiale,
}) {
  return ouvrirModale<void>(
    context,
    (_) => CandidatureFormPage(controller: controller, initiale: initiale),
  );
}

/// Formulaire partagé par la création et la modification : validation,
/// enregistrement et garde contre la perte de saisie. L'affichage est
/// délégué à [FormulaireCupertino] ou [FormulaireMaterial].
class CandidatureFormPage extends StatefulWidget {
  const CandidatureFormPage({
    super.key,
    required this.controller,
    this.initiale,
  });

  final CandidatureController controller;
  final Candidature? initiale;

  @override
  State<CandidatureFormPage> createState() => _CandidatureFormPageState();
}

class _CandidatureFormPageState extends State<CandidatureFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final _champs = ChampsCandidature(widget.initiale);
  bool _enCours = false;

  bool get _edition => widget.initiale != null;

  @override
  void dispose() {
    _champs.dispose();
    super.dispose();
  }

  Future<void> _enregistrer() async {
    if (_enCours) return;
    if (!_formKey.currentState!.validate()) {
      _champs.focaliserPremiereErreur();
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() => _enCours = true);
    try {
      await widget.controller.enregistrer(_champs.lire(DateTime.now()));
      if (!mounted) return;
      afficherInfo(
        context,
        _edition ? 'Modifications enregistrées' : 'Candidature ajoutée',
      );
      Navigator.of(context).pop();
    } catch (_) {
      // Les champs restent remplis : l'utilisateur peut réessayer.
      if (mounted) {
        await afficherErreur(
          context,
          titre: 'Enregistrement impossible.',
          message: 'Ta saisie est conservée. Réessaie dans un instant.',
        );
      }
    } finally {
      if (mounted) setState(() => _enCours = false);
    }
  }

  /// Date d'envoi : jamais dans le futur. Relance : jamais avant l'envoi.
  Future<void> _choisirDate({required bool relance}) async {
    final c = _champs;
    final date = await choisirDate(
      context,
      initiale: relance ? (c.relance ?? c.suggestionRelance()) : c.dateEnvoi,
      titre: relance ? 'Prochaine relance' : 'Date d’envoi',
      premiere: relance ? c.dateEnvoi : null,
      derniere: relance ? null : aujourdhui(),
    );
    if (date == null || !mounted) return;
    setState(() => relance ? c.relance = date : c.changerDateEnvoi(date));
  }

  void _effacerDate({required bool relance}) => setState(
    () => relance ? _champs.relance = null : _champs.dateEnvoi = null,
  );

  /// Statut sur iOS : feuille d'actions (aucune vue native dans la liste
  /// défilante du formulaire).
  Future<void> _choisirStatutIos() async {
    FocusScope.of(context).unfocus();
    final choix = await showCupertinoModalPopup<Statut>(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Statut'),
        actions: [
          for (final s in Statut.values)
            CupertinoActionSheetAction(
              isDefaultAction: s == _champs.statut,
              onPressed: () => Navigator.pop(context, s),
              child: Text(s.libelle),
            ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
      ),
    );
    if (choix != null) setState(() => _champs.statut = choix);
  }

  /// Quitter sans enregistrer : confirmation si des changements seraient
  /// perdus.
  Future<void> _quitter() async {
    if (_enCours) return;
    if (_champs.modifie) {
      final abandonner = await confirmerSuppression(
        context,
        titre: _edition
            ? 'Abandonner les modifications ?'
            : 'Abandonner la candidature ?',
        message: 'Ta saisie sera perdue.',
        action: 'Abandonner',
      );
      if (!abandonner || !mounted) return;
    }
    // `pop` ferme la page même quand `PopScope.canPop` est faux.
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final actions = ActionsFormulaire(
      titre: _edition ? 'Modifier la candidature' : 'Nouvelle candidature',
      edition: _edition,
      enCours: _enCours,
      annuler: _quitter,
      enregistrer: _enregistrer,
      changerStatut: (s) => setState(() => _champs.statut = s),
      choisirStatutIos: _choisirStatutIos,
      choisirDate: _choisirDate,
      effacerDate: _effacerDate,
    );
    return PopScope(
      // Glissement de la feuille iOS ou retour Android : même garde que le
      // bouton Fermer.
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _quitter();
      },
      child: Form(
        key: _formKey,
        child: estCupertino(context)
            ? FormulaireCupertino(champs: _champs, actions: actions)
            : FormulaireMaterial(champs: _champs, actions: actions),
      ),
    );
  }
}
