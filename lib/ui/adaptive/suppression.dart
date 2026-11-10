import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import 'plateforme.dart';

class SupprimableParBalayage extends StatelessWidget {
  const SupprimableParBalayage({
    super.key,
    required this.cle,
    required this.confirmer,
    required this.child,
  });

  final Key cle;
  final Future<bool> Function() confirmer;
  final Widget child;

  @override
  Widget build(BuildContext context) => Dismissible(
    key: cle,
    direction: DismissDirection.endToStart,
    confirmDismiss: (_) => confirmer(),
    background: const _FondSuppression(),
    child: child,
  );
}

class _FondSuppression extends StatelessWidget {
  const _FondSuppression();

  @override
  Widget build(BuildContext context) {
    final cupertino = estCupertino(context);
    return Container(
      alignment: AlignmentDirectional.centerEnd,
      padding: const EdgeInsetsDirectional.only(end: 24),
      decoration: BoxDecoration(
        color: cupertino
            ? PisteCouleurs.rougeDestructif
            : Theme.of(context).colorScheme.error,
        borderRadius: BorderRadius.circular(
          cupertino ? PisteRayons.ios : PisteRayons.material,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icone(context, Icons.delete_outline, CupertinoIcons.trash),
            color: Colors.white,
          ),
          const SizedBox(width: 8),
          const Text(
            'Supprimer',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
