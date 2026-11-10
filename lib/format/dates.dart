import 'package:intl/intl.dart';

final _dateLongue = DateFormat.yMMMMd('fr_FR');
final _dateCourte = DateFormat.yMMMd('fr_FR');

String dateLongue(DateTime date) => _dateLongue.format(date);
String dateCourte(DateTime date) => _dateCourte.format(date);

DateTime sansHeure(DateTime date) => DateTime(date.year, date.month, date.day);

DateTime aujourdhui([DateTime? maintenant]) =>
    sansHeure(maintenant ?? DateTime.now());

DateTime bornerDate(DateTime date, DateTime min, DateTime max) {
  final jour = sansHeure(date);
  if (jour.isBefore(min)) return min;
  if (jour.isAfter(max)) return max;
  return jour;
}

int joursAvant(DateTime date, [DateTime? maintenant]) {
  final jour = DateTime.utc(date.year, date.month, date.day);
  final a = aujourdhui(maintenant);
  return jour.difference(DateTime.utc(a.year, a.month, a.day)).inDays;
}

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
