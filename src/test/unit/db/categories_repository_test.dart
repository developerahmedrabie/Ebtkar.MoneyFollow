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

  Matcher fails(String code) =>
      throwsA(isA<ValidationException>().having((e) => e.code, 'code', code));

  test('name rules: 1–20 chars, unique per type incl. built-in en/ar', () async {
    expect(() => r.categories.create(TxType.expense, 'groceries', '🐾', '#ef4444'),
        fails('err_cat_dup'));
    expect(() => r.categories.create(TxType.expense, 'البقالة', '🐾', '#ef4444'),
        fails('err_cat_dup'));
    expect(() => r.categories.create(TxType.expense, '   ', '🐾', '#ef4444'),
        fails('err_name'));
    expect(() => r.categories.create(TxType.expense, 'x' * 21, '🐾', '#ef4444'),
        fails('err_name'));
    await r.categories.create(TxType.expense, 'Pets', '🐾', '#ef4444');
    await r.categories.create(TxType.income, 'Pets', '🐾', '#ef4444');
    expect(() => r.categories.create(TxType.expense, ' pets  ', '🐾', '#ef4444'),
        fails('err_cat_dup'));
  });

  test('type cannot change; rename keeps type', () async {
    final id = await r.categories.create(TxType.expense, 'Pets', '🐾', '#ef4444');
    await r.categories.update(id, 'Pet care', '🧸', '#2563eb');
    expect(await r.categories.typeOf(id), TxType.expense);
  });

  test('delete re-points rows to Other, removes budget, tombstones', () async {
    final id = await r.categories.create(TxType.expense, 'Pets', '🐾', '#ef4444');
    final tx = await r.transactions.create(TxInput(
        type: TxType.expense,
        amountMinor: 1000,
        currency: 'EGP',
        categoryId: id,
        accountId: 'acc-cash',
        date: '2026-11-13'));
    await r.db.into(r.db.recurringItems).insert(RecurringItemsCompanion.insert(
        id: 'rec1',
        createdAt: 1,
        updatedAt: 'x',
        deviceId: 'd',
        type: 'expense',
        amountMinor: 500,
        currency: 'EGP',
        categoryId: id,
        accountId: 'acc-cash',
        frequency: 'monthly',
        nextDue: '2026-12-01',
        dayOfMonth: 1));
    await r.db.into(r.db.budgets).insert(BudgetsCompanion.insert(
        id: 'b1',
        createdAt: 1,
        updatedAt: 'x',
        deviceId: 'd',
        categoryId: id,
        limitMinor: 100000));
    await r.categories.delete(id);
    expect((await r.transactions.byId(tx))!.categoryId, 'other_e');
    final rec = await (r.db.select(r.db.recurringItems)
          ..where((t) => t.id.equals('rec1')))
        .getSingle();
    expect(rec.categoryId, 'other_e');
    final b = await r.db.select(r.db.budgets).getSingle();
    expect(b.deleted, isTrue);
    expect(await r.categories.typeOf(id), isNull);
    expect(await r.transactions.watchMonth('2026-11').first, hasLength(1));
  });
}
