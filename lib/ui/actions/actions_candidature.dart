import 'package:flutter/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/candidature.dart';
import '../../state/candidature_controller.dart';
import '../adaptive/adaptive.dart';

Future<bool> supprimerAvecConfirmation(
  BuildContext context,
  CandidatureController controller,
  Candidature c,
) async {
  final ok = await confirmerSuppression(
    context,
    titre: 'Supprimer la candidature ${c.entreprise} ?',
    message: '« ${c.poste} » sera supprimée définitivement de cet appareil.',
    action: 'Supprimer',
  );
  if (!ok || !context.mounted) return false;
  return executerAvecRetour(
    context,
    () => controller.supprimer(c.id!),
    succes: 'Candidature supprimée',
    titreErreur: 'Suppression impossible.',
    messageErreur: 'La candidature est conservée. Réessaie dans un instant.',
  );
}

Future<void> ouvrirExterne(
  BuildContext context,
  Uri uri, {
  required String erreur,
}) async {
  var ouvert = false;
  try {
    ouvert = await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (_) {
    ouvert = false;
  }
  if (!ouvert && context.mounted) {
    await afficherErreur(
      context,
      titre: 'Ouverture impossible.',
      message: erreur,
    );
  }
}
