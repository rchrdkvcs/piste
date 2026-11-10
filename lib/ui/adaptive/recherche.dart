import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'plateforme.dart';

class ChampRecherche extends StatelessWidget {
  const ChampRecherche({
    super.key,
    required this.controller,
    required this.indication,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String indication;
  final ValueChanged<String> onChanged;

  void _effacer() {
    controller.clear();
    onChanged('');
  }

  @override
  Widget build(BuildContext context) {
    if (estCupertino(context)) {
      return CupertinoSearchTextField(
        controller: controller,
        placeholder: indication,
        onChanged: onChanged,
        onSuffixTap: _effacer,
      );
    }
    return ValueListenableBuilder(
      valueListenable: controller,
      builder: (context, valeur, _) => SearchBar(
        controller: controller,
        hintText: indication,
        elevation: const WidgetStatePropertyAll(0),
        leading: const Icon(Icons.search),
        onChanged: onChanged,
        trailing: [
          if (valeur.text.isNotEmpty)
            IconButton(
              tooltip: 'Effacer la recherche',
              icon: const Icon(Icons.close),
              onPressed: _effacer,
            ),
        ],
      ),
    );
  }
}
