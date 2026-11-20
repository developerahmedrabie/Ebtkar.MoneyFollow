/// Local calendar dates as `YYYY-MM-DD` strings and months as `YYYY-MM`.
/// No time zones: arithmetic is done in UTC on the calendar date only.
abstract final class LocalDate {
  static String _p(int n) => n.toString().padLeft(2, '0');

  static DateTime parse(String s) {
    final p = s.split('-');
    return DateTime.utc(int.parse(p[0]), int.parse(p[1]), int.parse(p[2]));
  }

  static String format(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${_p(d.month)}-${_p(d.day)}';

  /// Today's local date.
  static String today([DateTime? now]) {
    final n = now ?? DateTime.now();
    return format(DateTime.utc(n.year, n.month, n.day));
  }

  static String addDays(String s, int n) =>
      format(parse(s).add(Duration(days: n)));

  /// Whole days from [a] to [b] (negative when b is before a).
  static int daysBetween(String a, String b) =>
      parse(b).difference(parse(a)).inDays;

  /// `YYYY-MM` shifted by [k] months.
  static String shiftMonth(String ym, int k) {
    final y = int.parse(ym.substring(0, 4));
    final m = int.parse(ym.substring(5, 7));
    final total = y * 12 + (m - 1) + k;
    return '${(total ~/ 12).toString().padLeft(4, '0')}-${_p(total % 12 + 1)}';
  }

  static int daysInMonth(int year, int month) =>
      DateTime.utc(year, month + 1, 0).day;

  static int daysInMonthOf(String ym) => daysInMonth(
      int.parse(ym.substring(0, 4)), int.parse(ym.substring(5, 7)));

  /// `YYYY-MM` of a date string.
  static String monthOf(String date) => date.substring(0, 7);

  static int yearOf(String date) => int.parse(date.substring(0, 4));

  static int monthNumberOf(String date) => int.parse(date.substring(5, 7));

  static int dayOf(String date) => int.parse(date.substring(8, 10));

  static String firstOfMonth(String ym) => '$ym-01';

  static String lastOfMonth(String ym) => '$ym-${_p(daysInMonthOf(ym))}';

  /// Date with the day clamped to the month length.
  static String clampedDate(int year, int month, int day) {
    final dim = daysInMonth(year, month);
    return '${year.toString().padLeft(4, '0')}-${_p(month)}-'
        '${_p(day > dim ? dim : day)}';
  }
}
