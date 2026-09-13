class LicensePlateFormat {
  LicensePlateFormat._();

  static const example = 'ABC-1234';
  static const _letterCount = 3;
  static const _digitCount = 4;
  static final _valid = RegExp(r'^[A-Z]{3}-\d{4}$');

  static String display(String raw) {
    final letters = StringBuffer();
    final digits = StringBuffer();
    for (final unit in raw.toUpperCase().codeUnits) {
      final isLetter = unit >= 65 && unit <= 90;
      final isDigit = unit >= 48 && unit <= 57;
      if (letters.length < _letterCount) {
        if (isLetter) letters.writeCharCode(unit);
        continue;
      }
      if (isDigit && digits.length < _digitCount) {
        digits.writeCharCode(unit);
      }
    }
    final letterPart = letters.toString();
    final digitPart = digits.toString();
    if (digitPart.isEmpty) return letterPart;
    return '$letterPart-$digitPart';
  }

  static String normalize(String raw) => display(raw);

  static bool isValid(String raw) => _valid.hasMatch(display(raw));
}
