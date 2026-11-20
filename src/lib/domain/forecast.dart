import '../core/time/dates.dart';
import '../data/db/app_database.dart';
import '../data/family_data.dart';
import 'monthly_totals.dart';
import 'recurring.dart';

/// Expected occasion spending for the forecast (filled in by US8).
abstract interface class OccasionPredictor {
  /// Enabled occasions starting in month [ym] with their expected amount
  /// (main-currency minor units) for [memberKey].
  List<(String key, int amount)> occasionsIn(String ym, String? memberKey);
}

/// Counts occasions as 0 (before US8).
class NoOccasions implements OccasionPredictor {
  const NoOccasions();
  @override
  List<(String, int)> occasionsIn(String ym, String? memberKey) => const [];
}

class ForecastMonth {
  ForecastMonth(this.month);
  final String month;
  int fixed = 0;
  int occasions = 0;
  final List<String> occasionKeys = [];
  int variable = 0;
  int income = 0;

  /// Expense items in the month, and the quarterly/yearly ones.
  final List<RecurringItem> items = [];
  final List<RecurringItem> oddItems = [];
  bool high = false;

  int get total => fixed + variable + occasions;
  int get savings => income - total;
}

class Forecast {
  Forecast(this.variableAverage, this.months, this.average);

  /// Day-to-day average per month (minor units).
  final int variableAverage;
  final List<ForecastMonth> months;
  final double average;

  /// REQUIREMENTS §6.2 (prototype `forecast(n, mem)`). [memberKey]: null =
  /// everyone, '' = whole-family items only, otherwise a member id.
  /// Amounts use the current rates (FR-014).
  static Forecast compute(
    FamilyData d,
    int n, {
    String? memberKey,
    required String today,
    OccasionPredictor occasionPredictor = const NoOccasions(),
  }) {
    final thisM = LocalDate.monthOf(today);
    var varSum = 0;
    for (var k = 1; k <= 3; k++) {
      for (final t in d.inMonth(LocalDate.shiftMonth(thisM, -k))) {
        if (t.type == 'expense' &&
            t.recurringId == null &&
            t.occasionId == null &&
            matchesMember(t.memberId, memberKey)) {
          varSum += d.txMain(t);
        }
      }
    }
    final varAvg = (varSum / 3).round();

    final months = <ForecastMonth>[];
    for (var i = 0; i < n; i++) {
      final m = LocalDate.shiftMonth(thisM, i + 1);
      final fm = ForecastMonth(m)..variable = varAvg;
      for (final r in d.recurring) {
        if (!matchesMember(r.memberId, memberKey)) continue;
        final occ = occurrencesInRange(
            r.nextDue, r.frequency, r.dayOfMonth, '$m-01', '$m-31');
        for (final _ in occ) {
          final v = d.currentMain(r.amountMinor, r.currency);
          if (r.type == 'expense') {
            fm.fixed += v;
            if (!fm.items.contains(r)) fm.items.add(r);
            if (r.frequency == 'quarterly' || r.frequency == 'yearly') {
              fm.oddItems.add(r);
            }
          } else {
            fm.income += v;
          }
        }
      }
      for (final (key, amount) in occasionPredictor.occasionsIn(m, memberKey)) {
        if (amount > 0) {
          fm.occasions += amount;
          fm.occasionKeys.add(key);
        }
      }
      months.add(fm);
    }
    final avg = months.isEmpty
        ? 0.0
        : months.fold(0, (a, x) => a + x.total) / months.length;
    for (final x in months) {
      x.high = x.total > avg * 1.05 &&
          (x.oddItems.isNotEmpty || x.occasionKeys.isNotEmpty);
    }
    return Forecast(varAvg, months, avg);
  }
}
