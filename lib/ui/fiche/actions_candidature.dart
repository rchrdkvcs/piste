import 'package:flutter/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/candidature.dart';
import '../../state/candidature_controller.dart';
import '../adaptive/adaptive.dart';

/// Demande confirmation, supprime, puis informe. Renvoie `true` si la
/// candidature a été supprimée (la liste valide alors le balayage, la fiche
/// se ferme).
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
  try {
    await controller.supprimer(c.id!);
    if (context.mounted) afficherInfo(context, 'Candidature supprimée');
    return true;
  } catch (_) {
    if (context.mounted) {
      await afficherErreur(
        context,
        titre: 'Suppression impossible.',
        message: 'La candidature est conservée. Réessaie dans un instant.',
      );
    }
    return false;
  }
}

/// Ouvre un lien web, un e-mail (`mailto:`) ou un appel (`tel:`) dans
/// l'application dédiée. Affiche une erreur si rien ne peut l'ouvrir.
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
