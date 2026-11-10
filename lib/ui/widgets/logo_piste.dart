import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// Logo Piste : un tracé en S qui part d'un point de départ et monte vers
/// une arrivée, le parcours d'une candidature.
///
/// Source unique du dessin : il sert dans l'app et à générer les icônes
/// (`tool/generer_icones_test.dart`).
class LogoPiste extends StatelessWidget {
  const LogoPiste({
    super.key,
    this.taille = 64,
    this.fond = true,
    this.arrondi = true,
    this.couleurTrace = Colors.white,
    this.echelle = 1,
  });

  final double taille;

  /// Dégradé teal derrière le tracé.
  final bool fond;

  /// Coins arrondis (logo dans l'app). Les icônes d'app restent carrées :
  /// iOS et Android appliquent leur propre masque.
  final bool arrondi;
  final Color couleurTrace;

  /// Taille du tracé dans le carré (1 : normal ; < 1 pour la zone sûre des
  /// icônes adaptatives Android).
  final double echelle;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Piste',
      image: true,
      child: SizedBox.square(
        dimension: taille,
        child: CustomPaint(
          painter: PeintreLogoPiste(
            fond: fond,
            arrondi: arrondi,
            couleurTrace: couleurTrace,
            echelle: echelle,
          ),
        ),
      ),
    );
  }
}

class PeintreLogoPiste extends CustomPainter {
  const PeintreLogoPiste({
    this.fond = true,
    this.arrondi = true,
    this.couleurTrace = Colors.white,
    this.echelle = 1,
  });

  final bool fond;
  final bool arrondi;
  final Color couleurTrace;
  final double echelle;

  static const degrade = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [PisteCouleurs.turquoise, PisteCouleurs.accentClair],
  );

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.shortestSide;
    final carre = Offset.zero & Size.square(c);

    if (fond) {
      final peinture = Paint()..shader = degrade.createShader(carre);
      if (arrondi) {
        // Proportion des icônes iOS (rayon ≈ 22,5 % du côté).
        canvas.drawRSuperellipse(
          RSuperellipse.fromRectAndRadius(carre, Radius.circular(c * 0.225)),
          peinture,
        );
      } else {
        canvas.drawRect(carre, peinture);
      }
    }

    // Calque : l'évidement de l'anneau (sans fond) ne perce que le tracé.
    canvas.saveLayer(carre, Paint());
    // Mise à l'échelle autour du centre.
    canvas.translate(c / 2, c / 2);
    canvas.scale(echelle);
    canvas.translate(-c / 2, -c / 2);

    Offset p(double x, double y) => Offset(x * c, y * c);

    final depart = p(0.31, 0.71);
    final arrivee = p(0.69, 0.29);

    // S symétrique autour du centre, tangentes verticales aux extrémités.
    final trace = Path()
      ..moveTo(depart.dx, depart.dy)
      ..cubicTo(0.31 * c, 0.43 * c, 0.69 * c, 0.57 * c, arrivee.dx, arrivee.dy);

    canvas.drawPath(
      trace,
      Paint()
        ..color = couleurTrace
        ..style = PaintingStyle.stroke
        ..strokeWidth = c * 0.08
        ..strokeCap = StrokeCap.round,
    );

    // Départ : anneau évidé. Arrivée : point plein, un peu plus grand.
    canvas.drawCircle(depart, c * 0.072, Paint()..color = couleurTrace);
    canvas.drawCircle(depart, c * 0.032, Paint()..blendMode = BlendMode.clear);
    canvas.drawCircle(arrivee, c * 0.088, Paint()..color = couleurTrace);
    canvas.restore();
  }

  @override
  bool shouldRepaint(PeintreLogoPiste old) =>
      old.fond != fond ||
      old.arrondi != arrondi ||
      old.couleurTrace != couleurTrace ||
      old.echelle != echelle;
}
