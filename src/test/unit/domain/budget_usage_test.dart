import 'package:money_follow/data/family_data.dart';
import 'package:money_follow/data/repositories/budgets_repository.dart';
import 'package:money_follow/data/repositories/transfers_repository.dart';
import 'package:money_follow/domain/budget_usage.dart';
import 'package:test/test.dart';

import '../../fixtures/reference_data.dart';
import '../../fixtures/repos.dart';

void main() {
  test('usage for 2026-11 matches the prototype and sorts by % used', () async {
    final db = await referenceDatabase();
    final d = await FamilyData.load(db);
    await db.close();
    final rows = budgetRows(d, '2026-11');
    final ref = protoRef['budget_nov'] as Map<String, dynamic>;
    expect(rows, hasLength(11));
    for (final r in rows) {
      expect(r.spent, egp(ref[r.category.id] as num), reason: r.category.id);
    }
    for (var i = 1; i < rows.length; i++) {
      expect(rows[i - 1].ratio >= rows[i].ratio, isTrue);
    }
    expect(rows.first.category.id, 'rent'); // 9,000 of 9,000
    expect(budgetRows(d, '2026-11', limit: 3), hasLength(3));
  });

  test('colour thresholds', () {
    expect(budgetLevel(.79), BudgetLevel.ok);
    expect(budgetLevel(.8), BudgetLevel.warn);
    expect(budgetLevel(1.0), BudgetLevel.warn);
    expect(budgetLevel(1.01), BudgetLevel.over);
  });

  test('setLimit: 0 removes the budget; transfers are ignored', () async {
    final r = TestRepos();
    addTearDown(r.db.close);
    final b = BudgetsRepository(r.db, r.stamper);
    await b.setLimit('groceries', 700000);
    await b.setLimit('groceries', 800000);
    expect((await r.data()).budgets.single.limitMinor, 800000);
    await TransfersRepository(r.db, r.stamper, r.settings).create(
        const TransferInput(
            fromAccountId: 'acc-bank',
            toAccountId: 'acc-cash',
            amountOutMinor: 50000,
            amountInMinor: 50000,
            date: '2026-11-13'));
    expect(budgetRows(await r.data(), '2026-11').single.spent, 0);
    await b.setLimit('groceries', 0);
    expect((await r.data()).budgets, isEmpty);
  });
}
