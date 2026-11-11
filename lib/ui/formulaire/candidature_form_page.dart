import 'package:flutter/widgets.dart';

import '../../models/candidature.dart';
import '../../state/candidature_controller.dart';
import '../adaptive/adaptive.dart';
import 'champs_candidature.dart';
import 'sections_candidature.dart';

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
    final ok = await executerAvecRetour(
      context,
      () => widget.controller.enregistrer(_champs.lire(DateTime.now())),
      succes: _edition ? 'Modifications enregistrées' : 'Candidature ajoutée',
      titreErreur: 'Enregistrement impossible.',
      messageErreur: 'Ta saisie est conservée. Réessaie dans un instant.',
    );
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop();
    } else {
      setState(() => _enCours = false);
    }
  }

  Future<void> _choisirDate({required bool relance}) async {
    final bornes = _champs.bornes(relance: relance);
    final date = await choisirDate(
      context,
      initiale: bornes.initiale,
      titre: relance ? libelleRelance : libelleDateEnvoi,
      premiere: bornes.premiere,
      derniere: bornes.derniere,
    );
    if (date == null || !mounted) return;
    setState(() => _champs.appliquerDate(date, relance: relance));
  }

  void _effacerDate({required bool relance}) =>
      setState(() => _champs.appliquerDate(null, relance: relance));

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
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _quitter();
      },
      child: Form(
        key: _formKey,
        child: ListenableBuilder(
          listenable: _champs.saisie,
          builder: (context, _) => PageSaisie(
            titre: _edition
                ? 'Modifier la candidature'
                : 'Nouvelle candidature',
            enCours: _enCours,
            fermableParGlissement: !_enCours && !_champs.modifie,
            onAnnuler: _quitter,
            onEnregistrer: _enregistrer,
            sections: sectionsCandidature(
              _champs,
              edition: _edition,
              onStatut: (s) => setState(() => _champs.statut = s),
              onDate: _choisirDate,
              onEffacerDate: _effacerDate,
            ),
          ),
        ),
      ),
    );
  }
}
