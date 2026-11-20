import 'package:money_follow/data/family_data.dart';
import 'package:money_follow/domain/monthly_totals.dart';
import 'package:test/test.dart';

import '../../fixtures/reference_data.dart';

void main() {
  late FamilyData d;
  setUpAll(() async {
    final db = await referenceDatabase();
    d = await FamilyData.load(db);
    await db.close();
  });

  for (final ym in ['2026-11', '2026-10']) {
    test('income and expenses for $ym match the prototype Home card', () {
      final s = monthSummary(d, ym);
      expect(s.income, egp(protoRef['inc_$ym'] as num));
      expect(s.expenses, egp(protoRef['exp_$ym'] as num));
      expect(s.net, s.income - s.expenses);
    });
  }

  test('savings rate message', () {
    const s = MonthSummary(3650000, 2346000);
    expect(s.savingsRatePercent, 36); // 13,040 / 36,500 = 35.7 %
    expect(const MonthSummary(0, 100).savingsRatePercent, isNull);
    expect(const MonthSummary(100, 150).savingsRatePercent, -50);
  });

  test('member spending matches the prototype (2026-11)', () {
    final ref = protoRef['mem_spent'] as Map<String, dynamic>;
    final ids = {
      '1': 'sample-mem-1',
      '2': 'sample-mem-2',
      '3': 'sample-mem-3',
      '4': 'sample-mem-4',
      'null': '',
    };
    ids.forEach((k, key) {
      expect(memberSpent(d, key, '2026-11'), egp(ref[k] as num), reason: k);
    });
    final total = ids.values.fold(0, (a, k) => a + memberSpent(d, k, '2026-11'));
    expect(total, monthSummary(d, '2026-11').expenses);
  });
}
