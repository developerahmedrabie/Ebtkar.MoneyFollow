import '../core/time/dates.dart';

const frequencies = ['weekly', 'monthly', 'quarterly', 'yearly'];

/// FR-021: weekly 52/12, monthly 1, quarterly 1/3, yearly 1/12.
const perMonth = {
  'weekly': 52 / 12,
  'monthly': 1.0,
  'quarterly': 1 / 3,
  'yearly': 1 / 12,
};

/// REQUIREMENTS §6.5 (prototype `addFreq`): weekly +7 days, otherwise +1/+3/
/// +12 months on day `min(dayOfMonth, days in target month)`.
String advanceDue(String date, String frequency, int? dayOfMonth) {
  if (frequency == 'weekly') return LocalDate.addDays(date, 7);
  final k = switch (frequency) {
    'monthly' => 1,
    'quarterly' => 3,
    'yearly' => 12,
    _ => throw ArgumentError('frequency $frequency'),
  };
  final ym = LocalDate.shiftMonth(LocalDate.monthOf(date), k);
  final y = int.parse(ym.substring(0, 4));
  final m = int.parse(ym.substring(5, 7));
  return LocalDate.clampedDate(y, m, dayOfMonth ?? LocalDate.dayOf(date));
}

/// Due dates of an item within [from, to] (prototype `occurrences`).
List<String> occurrencesInRange(
    String nextDue, String frequency, int dayOfMonth, String from, String to) {
  final out = <String>[];
  var d = nextDue;
  var guard = 0;
  while (d.compareTo(to) <= 0 && guard++ < 500) {
    if (d.compareTo(from) >= 0) out.add(d);
    d = advanceDue(d, frequency, dayOfMonth);
  }
  return out;
}

/// Monthly equivalent in minor units.
double monthlyEquivalent(int amountMinor, String frequency) =>
    amountMinor * (perMonth[frequency] ?? 1);

enum DueKind { overdue, today, tomorrow, soon, later }

/// Prototype `dueChip`: Overdue N d / Due today / Tomorrow / In N days
/// (≤ 7) / a date.
({DueKind kind, int days}) dueLabel(String nextDue, String today) {
  final n = LocalDate.daysBetween(today, nextDue);
  if (n < 0) return (kind: DueKind.overdue, days: -n);
  if (n == 0) return (kind: DueKind.today, days: 0);
  if (n == 1) return (kind: DueKind.tomorrow, days: 1);
  if (n <= 7) return (kind: DueKind.soon, days: n);
  return (kind: DueKind.later, days: n);
}
