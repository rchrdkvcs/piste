/// Couche d'adaptation : chaque écran décrit son contenu une fois, et ces
/// composants choisissent le natif de la plateforme.
///
/// - iOS 26+ : composants UIKit Liquid Glass via `adaptive_platform_ui`.
/// - iOS 18 et moins : équivalents Cupertino.
/// - Android : Material 3.
library;

export 'barre.dart';
export 'dialogues.dart';
export 'elements.dart';
export 'listes.dart';
export 'messages.dart';
export 'navigation.dart';
export 'page.dart';
export 'plateforme.dart';
