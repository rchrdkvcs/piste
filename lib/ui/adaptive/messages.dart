import 'dart:async';
import 'dart:ui';

import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'plateforme.dart';

/// Message de réussite : SnackBar sur Android, bannière flottante sur iOS.
void afficherInfo(BuildContext context, String message) {
  if (!estCupertino(context)) {
    ScaffoldMessenger.maybeOf(context)
      ?..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
    return;
  }
  unawaited(HapticFeedback.lightImpact());
  final overlay = Overlay.of(context, rootOverlay: true);
  late final OverlayEntry entree;
  entree = OverlayEntry(
    builder: (_) => _BanniereIos(message: message, onTermine: entree.remove),
  );
  overlay.insert(entree);
}

/// Message d'erreur : SnackBar sur Android, alerte native sur iOS.
Future<void> afficherErreur(
  BuildContext context, {
  required String titre,
  required String message,
}) async {
  if (!estCupertino(context)) {
    final scheme = Theme.of(context).colorScheme;
    ScaffoldMessenger.maybeOf(context)
      ?..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: scheme.errorContainer,
          behavior: SnackBarBehavior.floating,
          content: Text(
            '$titre $message',
            style: TextStyle(color: scheme.onErrorContainer),
          ),
        ),
      );
    return;
  }
  unawaited(HapticFeedback.heavyImpact());
  await AdaptiveAlertDialog.show(
    context: context,
    title: titre,
    message: message,
    actions: [AlertAction(title: 'OK', onPressed: () {})],
  );
}

class _BanniereIos extends StatefulWidget {
  const _BanniereIos({required this.message, required this.onTermine});

  final String message;
  final VoidCallback onTermine;

  @override
  State<_BanniereIos> createState() => _BanniereIosState();
}

class _BanniereIosState extends State<_BanniereIos>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animation = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
    reverseDuration: const Duration(milliseconds: 150),
  );
  Timer? _minuteur;

  @override
  void initState() {
    super.initState();
    _animation.forward();
    _minuteur = Timer(const Duration(milliseconds: 2400), () async {
      await _animation.reverse();
      widget.onTermine();
    });
  }

  @override
  void dispose() {
    _minuteur?.cancel();
    _animation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final courbe = CurvedAnimation(
      parent: _animation,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeOut,
    );
    // Mouvement réduit : fondu seul, sans glissement.
    final decalage = mouvementReduit(context) ? 0.0 : -12.0;
    return Positioned(
      top: MediaQuery.paddingOf(context).top + 8,
      left: 24,
      right: 24,
      child: FadeTransition(
        opacity: courbe,
        child: AnimatedBuilder(
          animation: courbe,
          builder: (context, child) => Transform.translate(
            offset: Offset(0, decalage * (1 - courbe.value)),
            child: child,
          ),
          child: Center(
            child: Semantics(
              liveRegion: true,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),
                    color: CupertinoColors.secondarySystemBackground
                        .resolveFrom(context)
                        .withValues(alpha: 0.88),
                    child: DefaultTextStyle(
                      style: CupertinoTheme.of(context).textTheme.textStyle
                          .copyWith(fontWeight: FontWeight.w600, fontSize: 15),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            CupertinoIcons.check_mark_circled_solid,
                            color: CupertinoColors.systemGreen,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Flexible(child: Text(widget.message)),
                        ],
                      ),
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
