import 'package:intl/intl.dart';

final _dateLongue = DateFormat.yMMMMd('fr_FR');
final _dateCourte = DateFormat.yMMMd('fr_FR');

String dateLongue(DateTime date) => _dateLongue.format(date);
String dateCourte(DateTime date) => _dateCourte.format(date);

/// Date du jour, sans heure.
DateTime aujourdhui([DateTime? maintenant]) {
  final n = maintenant ?? DateTime.now();
  return DateTime(n.year, n.month, n.day);
}

/// Écart en jours civils entre aujourd'hui et [date] (négatif si passée).
int joursAvant(DateTime date, [DateTime? maintenant]) {
  final jour = DateTime.utc(date.year, date.month, date.day);
  final a = aujourdhui(maintenant);
  return jour.difference(DateTime.utc(a.year, a.month, a.day)).inDays;
}

/// « aujourd'hui », « hier », « il y a 3 jours », « demain », « dans 5 jours ».
String echeanceRelative(DateTime date, [DateTime? maintenant]) {
  final j = joursAvant(date, maintenant);
  return switch (j) {
    0 => 'aujourd’hui',
    -1 => 'hier',
    1 => 'demain',
    < 0 => 'il y a ${-j} jours',
    _ => 'dans $j jours',
  };
}
