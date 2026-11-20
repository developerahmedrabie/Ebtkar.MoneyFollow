import 'package:money_follow/data/family_data.dart';
import 'package:money_follow/domain/monthly_totals.dart';
import 'package:money_follow/domain/reports.dart';
import 'package:test/test.dart';

import '../../fixtures/reference_data.dart';

void main() {
  late FamilyData d;
  setUpAll(() async {
    final db = await referenceDatabase();
    d = await FamilyData.load(db);
    await db.close();
  });

  test('avg daily uses elapsed days for the current month', () {
    final k = monthKpis(d, '2026-11', referenceToday);
    expect(k.avgDaily, (egp(protoRef['exp_2026-11'] as num) / 13).round());
    final o = monthKpis(d, '2026-10', referenceToday);
    expect(o.avgDaily, (egp(protoRef['exp_2026-10'] as num) / 31).round());
  });

  test('vs last month %', () {
    final k = monthKpis(d, '2026-11', referenceToday);
    final nov = egp(protoRef['exp_2026-11'] as num);
    final oct = egp(protoRef['exp_2026-10'] as num);
    expect(k.vsLastPercent, ((nov - oct) / oct * 100).round());
  });

  test('category shares add up and are sorted', () {
    final s = categoryShares(d, '2026-11');
    expect(s.fold(0, (a, x) => a + x.$2), monthSummary(d, '2026-11').expenses);
    for (var i = 1; i < s.length; i++) {
      expect(s[i - 1].$2 >= s[i].$2, isTrue);
    }
    expect(s.first.$1, 'rent');
  });

  test('6-month series', () {
    final s = sixMonthSeries(d, '2026-11');
    expect(s.map((e) => e.$1).first, '2026-06');
    expect(s.last.$2, egp(protoRef['inc_2026-11'] as num));
    expect(s[4].$3, egp(protoRef['exp_2026-10'] as num));
  });
}
