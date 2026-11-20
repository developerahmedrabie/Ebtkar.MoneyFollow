import 'package:money_follow/data/sample/sample_data.dart';
import 'package:test/test.dart';

import '../../fixtures/reference_data.dart';

void main() {
  test('generates the same transactions as the prototype demo()', () async {
    final s = SampleData.generate(referenceToday, createdAt: 1);
    expect(s.transactions.length, protoRef['txCount']);
    // Sum of raw amounts in their own currency units.
    var total = 0.0;
    for (final t in s.transactions) {
      total += t.amountMinor.value / 100;
    }
    expect(total, closeTo((protoRef['txSum'] as num).toDouble(), 0.01));
    expect(s.members, hasLength(4));
    expect(s.recurring, hasLength(15));
    expect(s.budgets, hasLength(11));
  });

  test('recurring next due dates match the prototype', () {
    final s = SampleData.generate(referenceToday, createdAt: 1);
    final next = {
      for (final r in s.recurring) r.id.value: r.nextDue.value,
    };
    expect(next['sample-rec-1'], '2026-12-01');
    expect(next['sample-rec-6'], '2026-11-20');
    expect(next['sample-rec-8'], '2026-12-01');
    expect(next['sample-rec-9'], '2026-11-25');
    expect(next['sample-rec-10'], '2027-02-15');
    expect(next['sample-rec-13'], '2027-01-10');
    expect(next['sample-rec-14'], '2026-11-14');
  });

  test('is deterministic and every row is sample', () async {
    final db = await referenceDatabase();
    addTearDown(db.close);
    final rows = await db.select(db.transactions).get();
    expect(rows.every((r) => r.isSample), isTrue);
    final outbox = await db.select(db.syncOutbox).get();
    expect(outbox.where((e) => e.tableName_ != 'settings'), isEmpty);
    final count = await db
        .customSelect('SELECT COUNT(*) c FROM transactions WHERE is_sample = 1')
        .getSingle();
    expect(count.read<int>('c'), protoRef['txCount']);
  });
}
