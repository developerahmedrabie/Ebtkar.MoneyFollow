import '../core/time/dates.dart';
import '../data/family_data.dart';
import 'monthly_totals.dart';

class MonthKpis {
  const MonthKpis(this.income, this.expenses, this.avgDaily, this.vsLastPercent);
  final int income;
  final int expenses;
  final int avgDaily;

  /// Change of spending vs the previous month in %, 0 when there was none.
  final int vsLastPercent;
}

/// Prototype `renderStats` KPIs. The average uses the days elapsed for the
/// current month and the full month otherwise.
MonthKpis monthKpis(FamilyData d, String ym, String today) {
  final s = monthSummary(d, ym);
  final days = ym == LocalDate.monthOf(today)
      ? LocalDate.dayOf(today)
      : LocalDate.daysInMonthOf(ym);
  final prev = monthSummary(d, LocalDate.shiftMonth(ym, -1)).expenses;
  final diff = prev == 0 ? 0 : ((s.expenses - prev) / prev * 100).round();
  return MonthKpis(s.income, s.expenses, (s.expenses / days).round(), diff);
}

/// Expense totals per category, largest first.
List<(String categoryId, int amount)> categoryShares(FamilyData d, String ym) {
  final by = <String, int>{};
  for (final t in d.inMonth(ym)) {
    if (t.type == 'expense') by[t.categoryId] = (by[t.categoryId] ?? 0) + d.txMain(t);
  }
  return by.entries.map((e) => (e.key, e.value)).toList()
    ..sort((a, b) => b.$2.compareTo(a.$2));
}

/// Income and expenses for the 6 months ending at [ym], oldest first.
List<(String month, int income, int expenses)> sixMonthSeries(
    FamilyData d, String ym) => [
      for (var i = -5; i <= 0; i++)
        () {
          final m = LocalDate.shiftMonth(ym, i);
          final s = monthSummary(d, m);
          return (m, s.income, s.expenses);
        }(),
    ];
