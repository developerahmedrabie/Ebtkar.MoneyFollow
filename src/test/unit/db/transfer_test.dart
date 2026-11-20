import 'package:money_follow/data/repositories/base_repository.dart';
import 'package:money_follow/data/repositories/transactions_repository.dart';
import 'package:money_follow/data/repositories/transfers_repository.dart';
import 'package:money_follow/domain/balances.dart';
import 'package:money_follow/domain/builtin_categories.dart';
import 'package:money_follow/domain/monthly_totals.dart';
import 'package:test/test.dart';

import '../../fixtures/repos.dart';

void main() {
  late TestRepos r;
  late TransfersRepository tr;
  setUp(() async {
    r = TestRepos();
    tr = TransfersRepository(r.db, r.stamper, r.settings);
    await r.transactions.create(const TxInput(
        type: TxType.income,
        amountMinor: 1000000,
        currency: 'EGP',
        categoryId: 'salary',
        accountId: 'acc-bank',
        date: '2026-11-01'));
  });
  tearDown(() => r.db.close());

  Future<Map<String, int>> balances() async => {
        for (final b in accountBalances(await r.data()))
          b.account.id: b.balanceMinor,
      };

  test('same account and non-positive amounts are refused', () async {
    expect(
        () => tr.create(const TransferInput(
            fromAccountId: 'acc-bank',
            toAccountId: 'acc-bank',
            amountOutMinor: 100,
            amountInMinor: 100,
            date: '2026-11-13')),
        throwsA(isA<ValidationException>()));
    expect(
        () => tr.create(const TransferInput(
            fromAccountId: 'acc-bank',
            toAccountId: 'acc-cash',
            amountOutMinor: 0,
            amountInMinor: 0,
            date: '2026-11-13')),
        throwsA(isA<ValidationException>()));
  });

  test('Bank 10,000 → 2,000 to Cash; month totals unchanged', () async {
    final before = monthSummary(await r.data(), '2026-11');
    final id = await tr.create(const TransferInput(
        fromAccountId: 'acc-bank',
        toAccountId: 'acc-cash',
        amountOutMinor: 200000,
        amountInMinor: 1, // ignored: same currency
        date: '2026-11-13'));
    final b = await balances();
    expect(b['acc-bank'], 800000);
    expect(b['acc-cash'], 200000);
    final after = monthSummary(await r.data(), '2026-11');
    expect(after.income, before.income);
    expect(after.expenses, before.expenses);
    expect((await tr.byId(id))!.amountInMinor, 200000);

    await tr.delete(id);
    final restored = await balances();
    expect(restored['acc-bank'], 1000000);
    expect(restored['acc-cash'], 0);
  });

  test('cross-currency 100 USD → 5,050 EGP is stored exactly', () async {
    final id = await tr.create(const TransferInput(
        fromAccountId: 'acc-usd',
        toAccountId: 'acc-bank',
        amountOutMinor: 10000,
        amountInMinor: 505000,
        date: '2026-11-13'));
    final t = await tr.byId(id);
    expect(t!.amountOutMinor, 10000);
    expect(t.amountInMinor, 505000);
    final b = await balances();
    expect(b['acc-usd'], -10000);
    expect(b['acc-bank'], 1505000);
  });
}
