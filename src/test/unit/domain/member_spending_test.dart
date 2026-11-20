import 'package:money_follow/data/family_data.dart';
import 'package:money_follow/domain/member_spending.dart';
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

  test('shares add up to the month total (US3 scenario 3)', () {
    final shares = familyShare(d, '2026-11');
    expect(shares, hasLength(5));
    final total = shares.fold(0, (a, s) => a + s.spent);
    expect(total, monthSummary(d, '2026-11').expenses);
    expect(shares.fold<double>(0, (a, s) => a + s.share), closeTo(1, 1e-9));
    final omar = shares.firstWhere((s) => s.memberKey == 'sample-mem-3');
    expect(omar.spent, egp((protoRef['mem_spent'] as Map)['3'] as num));
  });

  test('6-month series ends at the selected month', () {
    final s = memberSeries(d, 'sample-mem-3', '2026-11');
    expect(s.map((e) => e.$1), [
      '2026-06', '2026-07', '2026-08', '2026-09', '2026-10', '2026-11',
    ]);
    expect(s.last.$2, memberSpent(d, 'sample-mem-3', '2026-11'));
  });
}
