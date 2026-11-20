import 'package:intl/intl.dart';

import '../time/dates.dart';
import 'currency.dart';
import 'money.dart';

/// Left-to-right isolate, so a minus sign stays on the left in Arabic
/// (prototype `money()`).
const lri = '⁦';
const pdi = '⁩';

/// Unicode minus used for negative amounts.
const minusSign = '−';

final _grouped = NumberFormat('#,##0', 'en_US');

String _intlLocale(String lang) => lang == 'ar' ? 'ar' : 'en_US';

/// Whole-number amount in [currency] minor units, grouped, Western digits
/// (prototype `fmtN`).
String formatWhole(int minor, Currency currency) {
  final v = minor.abs();
  final whole = (v + currency.scale ~/ 2) ~/ currency.scale;
  return _grouped.format(whole);
}

/// Amount with up to the currency's decimals, trailing zeros removed
/// (prototype `fmtA`).
String formatExact(int minor, Currency currency) {
  final v = minor.abs();
  final whole = _grouped.format(v ~/ currency.scale);
  final frac = (v % currency.scale)
      .toString()
      .padLeft(currency.decimals, '0')
      .replaceFirst(RegExp(r'0+$'), '');
  return frac.isEmpty ? whole : '$whole.$frac';
}

/// Total in the main currency: `⁦−1,250⁩ ج.م` (prototype `money(n, sign)`).
String formatAmount(int minor, Currency currency, String lang,
    {bool sign = false, bool showCurrency = true}) {
  final s = StringBuffer(lri);
  if (sign && minor > 0) s.write('+');
  if (minor < 0) s.write(minusSign);
  s
    ..write(formatWhole(minor, currency))
    ..write(pdi);
  if (showCurrency) s.write(' ${currency.label(lang)}');
  return s.toString();
}

/// "≈ 5,000 ج.م".
String formatApprox(int minor, Currency currency, String lang) =>
    '≈ ${formatAmount(minor, currency, lang)}';

/// Signed amount in its own currency (prototype `amtCell`, first line).
/// The currency label is shown only when it isn't the main currency.
String formatSignedCell(bool income, int minor, Currency currency,
    Currency main, String lang) {
  final s = '$lri${income ? '+' : minusSign}${formatExact(minor, currency)}$pdi';
  return currency == main ? s : '$s ${currency.label(lang)}';
}

/// 1.2k / 12k (prototype `short`); input is minor units.
String shortAmount(int minor, Currency currency) {
  final n = minor / currency.scale;
  if (n.abs() >= 1000) {
    final k = n / 1000;
    return '${n >= 10000 ? k.toStringAsFixed(0) : k.toStringAsFixed(1)}k';
  }
  return n.round().toString();
}

String _latin(String s) => normalizeDigits(s);

/// "Nov 2026" in English, "نوفمبر 2026" in Arabic.
String monthLabel(String ym, String lang) {
  final d = DateTime(int.parse(ym.substring(0, 4)), int.parse(ym.substring(5, 7)));
  final f = lang == 'ar'
      ? DateFormat('MMMM y', _intlLocale(lang))
      : DateFormat('MMM y', _intlLocale(lang));
  return _latin(f.format(d));
}

/// Full month name only.
String monthName(String ym, String lang) {
  final d = DateTime(int.parse(ym.substring(0, 4)), int.parse(ym.substring(5, 7)));
  return _latin(DateFormat('MMMM', _intlLocale(lang)).format(d));
}

DateTime _dt(String date) {
  final p = LocalDate.parse(date);
  return DateTime(p.year, p.month, p.day);
}

/// "Nov 13" / "13 نوفمبر" (prototype `dateShort`).
String dateShort(String date, String lang) =>
    _latin(DateFormat(lang == 'ar' ? 'd MMM' : 'MMM d', _intlLocale(lang))
        .format(_dt(date)));

/// "13 November 2026" (prototype `longDate`).
String longDate(String date, String lang) => _latin(
    DateFormat(lang == 'ar' ? 'd MMMM y' : 'MMMM d, y', _intlLocale(lang))
        .format(_dt(date)));

/// Today / Yesterday / "Fri, Nov 13" (prototype `dayLabel`).
String dayLabel(String date, String today, String lang,
    {required String todayText, required String yesterdayText}) {
  if (date == today) return todayText;
  if (date == LocalDate.addDays(today, -1)) return yesterdayText;
  return _latin(DateFormat(
          lang == 'ar' ? 'EEE، d MMM' : 'EEE, MMM d', _intlLocale(lang))
      .format(_dt(date)));
}

/// Percent with no decimals, Western digits.
String percent(num p) => '${p.round()}%';
