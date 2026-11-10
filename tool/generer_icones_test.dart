// Génère les images sources des icônes à partir de `LogoPiste`.
//
//   flutter test tool/generer_icones_test.dart
//   dart run flutter_launcher_icons
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:piste/theme/app_theme.dart';
import 'package:piste/ui/widgets/logo_piste.dart';

Future<void> exporter(String nom, PeintreLogoPiste peintre) async {
  const taille = 1024.0;
  final enregistreur = ui.PictureRecorder();
  peintre.paint(Canvas(enregistreur), const Size.square(taille));
  final image = await enregistreur.endRecording().toImage(
    taille.toInt(),
    taille.toInt(),
  );
  final octets = await image.toByteData(format: ui.ImageByteFormat.png);
  await File('assets/icone/$nom.png')
      .writeAsBytes(octets!.buffer.asUint8List());
}

void main() {
  test('exporter les icônes', () async {
    // iOS clair et icône de base : dégradé plein cadre.
    await exporter('icone', const PeintreLogoPiste(arrondi: false));
    // iOS sombre : fond transparent, tracé turquoise.
    await exporter(
      'icone_ios_sombre',
      const PeintreLogoPiste(
        fond: false,
        couleurTrace: PisteCouleurs.turquoise,
      ),
    );
    // iOS teinté : niveaux de gris sur fond transparent.
    await exporter('icone_ios_teinte', const PeintreLogoPiste(fond: false));
    // Android adaptatif : tracé dans la zone sûre (66 %), fond séparé.
    await exporter(
      'icone_android_premier_plan',
      const PeintreLogoPiste(fond: false, echelle: 0.62),
    );
    await exporter(
      'icone_android_fond',
      const PeintreLogoPiste(arrondi: false, echelle: 0),
    );
  });
}
