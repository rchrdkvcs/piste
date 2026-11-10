/// Normalisation et validation des saisies libres (lien, e-mail, téléphone).
///
/// Fonctions pures, sans dépendance à l'interface : le formulaire les
/// utilise comme validateurs et le modèle comme garde-fous.
abstract final class Saisie {
  /// Complète une adresse saisie sans protocole (`exemple.fr/offre`) avec
  /// `https://`. Une chaîne vide reste vide.
  static String normaliserLien(String brut) {
    final texte = brut.trim();
    if (texte.isEmpty) return '';
    final aProtocole = RegExp(r'^[a-zA-Z][a-zA-Z0-9+.-]*://').hasMatch(texte);
    return aProtocole ? texte : 'https://$texte';
  }

  /// Vrai si [brut] (après normalisation) est un lien web ouvrable.
  static bool lienValide(String brut) {
    final uri = Uri.tryParse(normaliserLien(brut));
    return uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.contains('.') &&
        !uri.host.startsWith('.') &&
        !uri.host.endsWith('.');
  }

  static final _email = RegExp(
    r"^[A-Za-z0-9.!#$%&'*+/=?^_`{|}~-]+@[A-Za-z0-9-]+(\.[A-Za-z0-9-]+)+$",
  );

  static String normaliserEmail(String brut) => brut.trim().toLowerCase();

  static bool emailValide(String brut) =>
      _email.hasMatch(normaliserEmail(brut));

  /// Caractères acceptés à la saisie d'un numéro.
  static final caracteresTelephone = RegExp(r'[0-9+\s.\-()]');

  /// Garde les chiffres et un `+` initial ; retire espaces et séparateurs.
  static String normaliserTelephone(String brut) {
    final texte = brut.trim();
    final chiffres = texte.replaceAll(RegExp(r'[^0-9]'), '');
    return texte.startsWith('+') ? '+$chiffres' : chiffres;
  }

  /// Numéro plausible : 6 à 15 chiffres (norme E.164), `+` facultatif.
  static bool telephoneValide(String brut) {
    if (brut.replaceAll(caracteresTelephone, '').isNotEmpty) return false;
    final n = normaliserTelephone(brut).replaceFirst('+', '').length;
    return n >= 6 && n <= 15;
  }

  /// Affichage lisible : numéro français à 10 chiffres groupé par deux,
  /// `+33` suivi de 9 chiffres groupé à la française, sinon tel quel.
  static String formaterTelephone(String brut) {
    final n = normaliserTelephone(brut);
    String paires(String s) => [
      for (var i = 0; i < s.length; i += 2)
        s.substring(i, i + 2 > s.length ? s.length : i + 2),
    ].join(' ');
    if (RegExp(r'^0\d{9}$').hasMatch(n)) return paires(n);
    if (RegExp(r'^\+33\d{9}$').hasMatch(n)) {
      return '+33 ${n[3]} ${paires(n.substring(4))}';
    }
    return brut.trim();
  }

  /// Comparaison de texte insensible à la casse et aux accents.
  static String pourRecherche(String texte) {
    const avec = 'àâäáãåçéèêëíìîïñóòôöõúùûüýÿœæ';
    const sans = 'aaaaaaceeeeiiiinooooouuuuyy';
    final buffer = StringBuffer();
    for (final rune in texte.toLowerCase().runes) {
      final c = String.fromCharCode(rune);
      final i = avec.indexOf(c);
      if (c == 'œ') {
        buffer.write('oe');
      } else if (c == 'æ') {
        buffer.write('ae');
      } else {
        buffer.write(i >= 0 && i < sans.length ? sans[i] : c);
      }
    }
    return buffer.toString().trim();
  }
}
