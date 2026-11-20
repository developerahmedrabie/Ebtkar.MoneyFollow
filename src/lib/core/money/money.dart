import 'currency.dart';

/// An amount in integer minor units of one currency. Never a double.
class Money implements Comparable<Money> {
  const Money(this.minor, this.currency);

  const Money.zero(this.currency) : minor = 0;

  final int minor;
  final Currency currency;

  Money operator +(Money other) {
    _same(other);
    return Money(minor + other.minor, currency);
  }

  Money operator -(Money other) {
    _same(other);
    return Money(minor - other.minor, currency);
  }

  Money operator -() => Money(-minor, currency);

  bool operator <(Money o) => compareTo(o) < 0;
  bool operator >(Money o) => compareTo(o) > 0;
  bool operator <=(Money o) => compareTo(o) <= 0;
  bool operator >=(Money o) => compareTo(o) >= 0;

  bool get isPositive => minor > 0;
  bool get isZero => minor == 0;

  @override
  int compareTo(Money other) {
    _same(other);
    return minor.compareTo(other.minor);
  }

  void _same(Money other) {
    if (other.currency != currency) {
      throw ArgumentError('Currency mismatch: $currency vs ${other.currency}');
    }
  }

  @override
  bool operator ==(Object other) =>
      other is Money && other.minor == minor && other.currency == currency;

  @override
  int get hashCode => Object.hash(minor, currency);

  /// Plain decimal string, e.g. `1250.50`, `-3.125`.
  String toDecimalString() => minorToDecimalString(minor, currency);

  @override
  String toString() => '${toDecimalString()} ${currency.code}';

  /// Parses user input such as `1,250.5`, `١٢٥٠٫٥` or ` 250 `.
  /// Throws [FormatException] for invalid text, too many decimals, or
  /// (when [requirePositive]) a value ≤ 0.
  static Money fromDecimalString(String input, Currency currency,
      {bool requirePositive = true}) {
    final minor = parseMinor(input, currency.decimals);
    if (requirePositive && minor <= 0) {
      throw const FormatException('Amount must be greater than 0');
    }
    return Money(minor, currency);
  }

  /// Like [fromDecimalString] but returns null instead of throwing.
  static Money? tryParse(String input, Currency currency,
      {bool requirePositive = true}) {
    try {
      return fromDecimalString(input, currency,
          requirePositive: requirePositive);
    } on FormatException {
      return null;
    }
  }
}

const _arabicDigits = '٠١٢٣٤٥٦٧٨٩';
const _persianDigits = '۰۱۲۳۴۵۶۷۸۹';

/// Normalizes Arabic/Persian digits and separators to ASCII.
String normalizeDigits(String s) {
  final b = StringBuffer();
  for (final ch in s.split('')) {
    var i = _arabicDigits.indexOf(ch);
    if (i < 0) i = _persianDigits.indexOf(ch);
    if (i >= 0) {
      b.write(i);
    } else if (ch == '٫') {
      b.write('.');
    } else if (ch == '٬' || ch == '،') {
      b.write(',');
    } else {
      b.write(ch);
    }
  }
  return b.toString();
}

/// Parses a decimal string into minor units with [decimals] places.
int parseMinor(String input, int decimals) {
  var s =
      normalizeDigits(input).trim().replaceAll(',', '').replaceAll(' ', '');
  var negative = false;
  if (s.startsWith('-') || s.startsWith('−')) {
    negative = true;
    s = s.substring(1);
  }
  if (!RegExp(r'^(\d+(\.\d*)?|\.\d+)$').hasMatch(s)) {
    throw FormatException('Not a number: $input');
  }
  final parts = s.split('.');
  final whole = parts[0].isEmpty ? '0' : parts[0];
  var frac = parts.length > 1 ? parts[1] : '';
  if (frac.length > decimals) {
    // Trailing zeros beyond the precision are fine ("5.990").
    if (frac.substring(decimals).replaceAll('0', '').isNotEmpty) {
      throw FormatException('Too many decimals: $input');
    }
    frac = frac.substring(0, decimals);
  }
  frac = frac.padRight(decimals, '0');
  final value = BigInt.parse(whole) * BigInt.from(10).pow(decimals) +
      (decimals == 0 ? BigInt.zero : BigInt.parse(frac));
  if (value > BigInt.one << 52) {
    throw FormatException('Amount too large: $input');
  }
  final v = value.toInt();
  return negative ? -v : v;
}

String minorToDecimalString(int minor, Currency currency) {
  final neg = minor < 0;
  final abs = minor.abs();
  final whole = abs ~/ currency.scale;
  final frac =
      (abs % currency.scale).toString().padLeft(currency.decimals, '0');
  return '${neg ? '-' : ''}$whole.$frac';
}
