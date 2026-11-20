import 'package:money_follow/data/db/app_database.dart';
import 'package:money_follow/data/repositories/base_repository.dart';
import 'package:money_follow/data/repositories/transactions_repository.dart';
import 'package:money_follow/domain/builtin_categories.dart';
import 'package:test/test.dart';

import '../../fixtures/repos.dart';

void main() {
  late TestRepos r;
  setUp(() => r = TestRepos());
  tearDown(() => r.db.close());

  TxInput groceries({int amount = 25000, String note = '', String? occ}) =>
      TxInput(
        type: TxType.expense,
        amountMinor: amount,
        currency: 'EGP',
        categoryId: 'groceries',
        accountId: 'acc-cash',
        date: '2026-11-13',
        note: note,
        occasionId: occ,
      );

  test('insert stamps id/HLC and attaches the current snapshot', () async {
    await r.rates.updateRate('USD', 52000000);
    final current = await r.rates.currentSnapshot();
    final id = await r.transactions.create(groceries());
    final row = await r.transactions.byId(id);
    expect(row!.id, hasLength(36));
    expect(row.updatedAt, matches(RegExp(r'^\d{13}-\d{4}-dev$')));
    expect(row.deviceId, 'dev');
    expect(row.rateSnapshotId, current.id);
  });

  test('rejects amount <= 0 and a category of the wrong type', () async {
    expect(() => r.transactions.create(groceries(amount: 0)),
        throwsA(isA<ValidationException>()));
    expect(
        () => r.transactions.create(const TxInput(
            type: TxType.income,
            amountMinor: 100,
            currency: 'EGP',
            categoryId: 'groceries',
            accountId: 'acc-cash',
            date: '2026-11-13')),
        throwsA(isA<ValidationException>()));
  });

  test('rejects an occasion on income and a note over 60 chars', () async {
    expect(
        () => r.transactions.create(const TxInput(
            type: TxType.income,
            amountMinor: 100,
            currency: 'EGP',
            categoryId: 'salary',
            accountId: 'acc-bank',
            date: '2026-11-13',
            occasionId: 'ramadan')),
        throwsA(isA<ValidationException>()));
    expect(() => r.transactions.create(groceries(note: 'x' * 61)),
        throwsA(isA<ValidationException>()));
    await r.transactions.create(groceries(note: 'x' * 60));
  });

  test('edit updates updated_at', () async {
    final id = await r.transactions.create(groceries());
    final before = (await r.transactions.byId(id))!.updatedAt;
    r.tick();
    await r.transactions.update(id, groceries(amount: 30000));
    final after = await r.transactions.byId(id);
    expect(after!.updatedAt.compareTo(before) > 0, isTrue);
    expect(after.amountMinor, 30000);
  });

  test('delete is soft and the row leaves watchMonth', () async {
    final id = await r.transactions.create(groceries());
    expect(await r.transactions.watchMonth('2026-11').first, hasLength(1));
    await r.transactions.delete(id);
    final row = await r.transactions.byId(id);
    expect(row!.deleted, isTrue);
    expect(await r.transactions.watchMonth('2026-11').first, isEmpty);
    expect((await r.data()).transactions, isEmpty);
  });

  test('every change is recorded in the outbox', () async {
    final id = await r.transactions.create(groceries());
    await r.transactions.delete(id);
    final out = await r.db.select(r.db.syncOutbox).get();
    final mine = out.where((e) => e.rowId == id).toList();
    expect(mine.map((e) => e.op), ['insert', 'update']);
  });
}
