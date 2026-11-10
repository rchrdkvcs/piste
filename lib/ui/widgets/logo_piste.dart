import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

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

  final bool fond;

  final bool arrondi;
  final Color couleurTrace;

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
        canvas.drawRSuperellipse(
          RSuperellipse.fromRectAndRadius(carre, Radius.circular(c * 0.225)),
          peinture,
        );
      } else {
        canvas.drawRect(carre, peinture);
      }
    }

    canvas.saveLayer(carre, Paint());
    canvas.translate(c / 2, c / 2);
    canvas.scale(echelle);
    canvas.translate(-c / 2, -c / 2);

    Offset p(double x, double y) => Offset(x * c, y * c);

    final depart = p(0.31, 0.71);
    final arrivee = p(0.69, 0.29);

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
