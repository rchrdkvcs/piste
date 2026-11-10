import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

Future<void> main() => integrationDriver(
  onScreenshot: (nom, octets, [args]) async {
    final fichier = File('build/captures/$nom.png');
    await fichier.create(recursive: true);
    await fichier.writeAsBytes(octets);
    return true;
  },
);
