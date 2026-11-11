import 'dart:ui';

import 'package:flutter/cupertino.dart';

import 'typo.dart';

class TitreBarre extends StatelessWidget {
  const TitreBarre({
    super.key,
    required this.titre,
    required this.visible,
    required this.gauche,
    required this.droite,
  });

  final String titre;
  final bool visible;
  final double gauche;
  final double droite;

  @override
  Widget build(BuildContext context) {
    final style = Typo.corpsGras(
      context,
    ).copyWith(color: CupertinoColors.label.resolveFrom(context), height: 1.2);
    return IgnorePointer(
      child: ExcludeSemantics(
        excluding: !visible,
        child: AnimatedOpacity(
          opacity: visible ? 1 : 0,
          duration: const Duration(milliseconds: 180),
          child: LayoutBuilder(
            builder: (context, contraintes) {
              final mesure = TextPainter(
                text: TextSpan(text: titre, style: style),
                textDirection: TextDirection.ltr,
                textScaler: MediaQuery.textScalerOf(context),
                maxLines: 1,
              )..layout();
              final marge = gauche > droite ? gauche : droite;
              final centre = mesure.width <= contraintes.maxWidth - 2 * marge;
              mesure.dispose();
              return Padding(
                padding: centre
                    ? EdgeInsets.symmetric(horizontal: marge)
                    : EdgeInsets.only(left: gauche, right: droite),
                child: Center(
                  child: Text(
                    titre,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: style,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class FondBarre extends StatelessWidget {
  const FondBarre({super.key, required this.visible});

  final bool visible;

  @override
  Widget build(BuildContext context) {
    final hauteur = MediaQuery.paddingOf(context).top;
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: hauteur,
      child: IgnorePointer(
        child: AnimatedOpacity(
          opacity: visible ? 1 : 0,
          duration: const Duration(milliseconds: 180),
          child: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGroupedBackground
                      .resolveFrom(context)
                      .withValues(alpha: 0.82),
                  border: Border(
                    bottom: BorderSide(
                      color: CupertinoColors.separator.resolveFrom(context),
                      width: 0,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
