import 'package:money_follow/data/family_data.dart';
import 'package:money_follow/domain/occasions.dart';
import 'package:test/test.dart';

import '../../fixtures/reference_data.dart';
import '../../fixtures/repos.dart';

void main() {
  late FamilyData d;
  late OccasionService s;
  setUpAll(() async {
    final db = await referenceDatabase();
    d = await FamilyData.load(db);
    await db.close();
    s = OccasionService(d, referenceToday);
  });

  for (final key in ['ramadan', 'eid_adha', 'eid_fitr', 'school']) {
    test('$key history and prediction match the prototype', () {
      final ref = protoRef['pred_$key'] as Map<String, dynamic>;
      final p = s.predict(key);
      final hist = (ref['hist'] as List).cast<List<dynamic>>();
      expect(p.history.map((h) => h.date), hist.map((h) => h[0]));
      expect(p.history.map((h) => h.total), hist.map((h) => egp(h[1] as num)));
      expect(p.total, closeTo(egp(ref['total'] as num), 1));
      expect(p.last!.total, egp(ref['last'] as num));
    });
  }

  test('Ramadan 6,900 → 7,800 ⇒ ≈ 8,817 (US8 scenario 1)', () async {
    final r = TestRepos();
    addTearDown(r.db.close);
    // Ramadan 2025-03-01 and 2026-02-18 (bundled dates)
    await r.db.customStatement('''
INSERT INTO transactions (id, created_at, updated_at, device_id, type, amount_minor, currency,
  rate_snapshot_id, category_id, account_id, occasion_id, date)
VALUES ('a',1,'x','d','expense',690000,'EGP','rates-default','groceries','acc-cash','ramadan','2025-02-26'),
       ('b',1,'x','d','expense',780000,'EGP','rates-default','groceries','acc-cash','ramadan','2026-02-15')''');
    final p = OccasionService(await r.data(), '2026-11-13').predict('ramadan');
    expect(p.history, hasLength(2));
    expect(p.growth, closeTo(7800 / 6900, 1e-9));
    expect(p.total, closeTo(881739, 1)); // 7,800 × 1.1304 = 8,817.39
  });

  test('one year of history ⇒ g = 1; growth is clamped to 0.85–1.5', () async {
    final r = TestRepos();
    addTearDown(r.db.close);
    await r.db.customStatement('''
INSERT INTO transactions (id, created_at, updated_at, device_id, type, amount_minor, currency,
  rate_snapshot_id, category_id, account_id, occasion_id, date)
VALUES ('a',1,'x','d','expense',100000,'EGP','rates-default','groceries','acc-cash','eid_adha','2026-05-25')''');
    var p = OccasionService(await r.data(), '2026-11-13').predict('eid_adha');
    expect(p.growth, 1);
    expect(p.total, 100000);
    await r.db.customStatement('''
INSERT INTO transactions (id, created_at, updated_at, device_id, type, amount_minor, currency,
  rate_snapshot_id, category_id, account_id, occasion_id, date)
VALUES ('b',1,'x','d','expense',10000,'EGP','rates-default','groceries','acc-cash','eid_adha','2025-06-05')''');
    p = OccasionService(await r.data(), '2026-11-13').predict('eid_adha');
    expect(p.growth, 1.5);
  });

  test('member filter and per-category breakdown', () {
    final all = s.predict('eid_fitr');
    final omar = s.predict('eid_fitr', memberKey: 'sample-mem-3');
    expect(omar.total, lessThan(all.total));
    expect(omar.last!.byCategory.keys, ['shopping']);
    final byCat = all.expectedByCategory;
    expect(byCat.values.fold(0, (a, b) => a + b), closeTo(all.total, 10));
  });
}
