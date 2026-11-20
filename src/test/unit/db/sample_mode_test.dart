import 'package:money_follow/data/repositories/members_repository.dart';
import 'package:money_follow/data/repositories/transactions_repository.dart';
import 'package:money_follow/data/sample/sample_mode_service.dart';
import 'package:money_follow/domain/builtin_categories.dart';
import 'package:test/test.dart';

import '../../fixtures/repos.dart';

void main() {
  test('clear removes sample rows and rows made while exploring', () async {
    final r = TestRepos();
    addTearDown(r.db.close);
    final members = MembersRepository(r.db, r.stamper);
    final keep = await members.create('Omar', 'child', '👦'); // added in setup
    r.clock = 5000;
    final s = SampleModeService(r.db);
    final started = await s.start('2026-11-13', nowMs: 5000);
    expect((await r.data()).transactions.length, greaterThan(1000));
    r.clock = 6000;
    await r.transactions.create(const TxInput(
        type: TxType.expense, amountMinor: 100, currency: 'EGP',
        categoryId: 'fun', accountId: 'acc-cash', date: '2026-11-13'));
    await s.clear(started, keepMemberIds: {keep});
    final d = await r.data();
    expect(d.transactions, isEmpty);
    expect(d.recurring, isEmpty);
    expect(d.budgets, isEmpty);
    expect(d.members.map((m) => m.id), [keep]);
    expect(d.accounts, hasLength(4));
    expect(d.settings['main_currency'], 'EGP');
  });
}
