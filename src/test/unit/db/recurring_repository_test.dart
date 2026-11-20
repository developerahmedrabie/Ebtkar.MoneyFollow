import 'package:money_follow/data/repositories/recurring_repository.dart';
import 'package:money_follow/domain/builtin_categories.dart';
import 'package:test/test.dart';

import '../../fixtures/repos.dart';

void main() {
  late TestRepos r;
  late RecurringRepository rec;
  setUp(() {
    r = TestRepos();
    rec = RecurringRepository(r.db, r.stamper, r.settings,
        categoryType: r.categories.typeOf);
  });
  tearDown(() => r.db.close());

  RecurringInput rent(String next) => RecurringInput(
        type: TxType.expense,
        amountMinor: 900000,
        currency: 'EGP',
        categoryId: 'rent',
        accountId: 'acc-bank',
        frequency: 'monthly',
        nextDue: next,
        memberId: null,
        name: 'House rent',
      );

  test('markPaid inserts a transaction and advances next_due', () async {
    final id = await rec.create(rent('2026-11-18'));
    final txId = await rec.markPaid(id, '2026-11-13');
    final tx = await r.transactions.byId(txId);
    expect(tx!.date, '2026-11-13');
    expect(tx.recurringId, id);
    expect(tx.amountMinor, 900000);
    expect(tx.categoryId, 'rent');
    expect(tx.accountId, 'acc-bank');
    expect(tx.note, 'House rent');
    expect((await rec.byId(id))!.nextDue, '2026-12-18');
  });

  test('an overdue item sorts first in the due list', () async {
    await rec.create(rent('2026-11-20'));
    await rec.create(rent('2026-11-01'));
    await rec.create(rent('2027-01-20'));
    final due = await rec.watchDue('2026-11-13').first;
    expect(due.map((e) => e.nextDue), ['2026-11-01', '2026-11-20']);
  });

  test('stopping keeps past transactions', () async {
    final id = await rec.create(rent('2026-11-18'));
    final txId = await rec.markPaid(id, '2026-11-13');
    await rec.stop(id);
    expect(await rec.watchAll().first, isEmpty);
    expect((await r.transactions.byId(txId))!.recurringId, id);
    expect((await r.data()).transactions, hasLength(1));
  });

  test('validation', () async {
    expect(() => rec.create(const RecurringInput(
        type: TxType.expense, amountMinor: 0, currency: 'EGP', categoryId: 'rent',
        accountId: 'acc-bank', frequency: 'monthly', nextDue: '2026-12-01')),
        throwsA(anything));
    expect(() => rec.create(const RecurringInput(
        type: TxType.expense, amountMinor: 10, currency: 'EGP', categoryId: 'rent',
        accountId: 'acc-bank', frequency: 'daily', nextDue: '2026-12-01')),
        throwsA(anything));
  });
}
