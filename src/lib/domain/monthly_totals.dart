import '../data/db/app_database.dart';
import '../data/family_data.dart';

/// Month summary for the Home card (prototype `renderHome`).
class MonthSummary {
  const MonthSummary(this.income, this.expenses);

  /// Main-currency minor units.
  final int income;
  final int expenses;

  int get net => income - expenses;

  /// Saved % of income, or over % when spending exceeds income; null when
  /// there is no income.
  int? get savingsRatePercent =>
      income <= 0 ? null : ((income - expenses) / income * 100).round();
}

/// Sum of [type] rows in the main currency, each with its own snapshot.
int sumMain(FamilyData d, Iterable<TxRow> rows, String type) {
  var s = 0;
  for (final t in rows) {
    if (t.type == type) s += d.txMain(t);
  }
  return s;
}

MonthSummary monthSummary(FamilyData d, String ym) {
  final rows = d.inMonth(ym);
  return MonthSummary(sumMain(d, rows, 'income'), sumMain(d, rows, 'expense'));
}

/// Prototype `memSpent`: [memberKey] null = everyone, '' = whole family
/// only, otherwise a member id.
int memberSpent(FamilyData d, String? memberKey, String ym) {
  var s = 0;
  for (final t in d.inMonth(ym)) {
    if (t.type == 'expense' && matchesMember(t.memberId, memberKey)) {
      s += d.txMain(t);
    }
  }
  return s;
}

/// Prototype `ofMem`.
bool matchesMember(String? rowMemberId, String? memberKey) =>
    memberKey == null || (rowMemberId ?? '') == memberKey;
