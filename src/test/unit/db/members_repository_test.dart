import 'package:money_follow/data/repositories/base_repository.dart';
import 'package:money_follow/data/repositories/members_repository.dart';
import 'package:money_follow/data/repositories/recurring_repository.dart';
import 'package:money_follow/data/repositories/transactions_repository.dart';
import 'package:money_follow/domain/builtin_categories.dart';
import 'package:test/test.dart';

import '../../fixtures/repos.dart';

void main() {
  late TestRepos r;
  late MembersRepository mem;
  setUp(() {
    r = TestRepos();
    mem = MembersRepository(r.db, r.stamper);
  });
  tearDown(() => r.db.close());

  test('name rules: required, trimmed, 1–30 chars', () async {
    expect(() => mem.create('  ', 'child', '👦'),
        throwsA(isA<ValidationException>()));
    expect(() => mem.create('x' * 31, 'child', '👦'),
        throwsA(isA<ValidationException>()));
    final id = await mem.create('  Omar ', 'child', '👦');
    expect((await mem.all()).single.name, 'Omar');
    expect((await mem.all()).single.id, id);
  });

  test('first unused colour is auto-assigned', () async {
    await mem.create('A', 'parent', '👨');
    final b = await mem.create('B', 'parent', '👩');
    expect((await mem.all()).map((m) => m.color).toList(),
        [memberColors[0], memberColors[1]]);
    await mem.remove(b);
    await mem.create('C', 'child', '👧');
    expect((await mem.all()).last.color, memberColors[1]);
  });

  test('removing moves 12 transactions + 1 recurring item to Whole family',
      () async {
    final id = await mem.create('Omar', 'child', '👦');
    for (var i = 0; i < 12; i++) {
      await r.transactions.create(TxInput(
          type: TxType.expense,
          amountMinor: 1000 + i,
          currency: 'EGP',
          categoryId: 'fun',
          accountId: 'acc-cash',
          date: '2026-11-0${1 + i % 9}',
          memberId: id));
    }
    final rec = RecurringRepository(r.db, r.stamper, r.settings,
        categoryType: r.categories.typeOf);
    await rec.create(RecurringInput(
        type: TxType.expense,
        amountMinor: 20000,
        currency: 'EGP',
        categoryId: 'other_e',
        accountId: 'acc-cash',
        frequency: 'weekly',
        nextDue: '2026-11-14',
        memberId: id));
    await mem.remove(id);
    final d = await r.data();
    expect(d.transactions, hasLength(12));
    expect(d.transactions.every((t) => t.memberId == null), isTrue);
    expect(d.recurring.single.memberId, isNull);
    expect(d.members, isEmpty);
    final m = await (r.db.select(r.db.members)).getSingle();
    expect(m.deleted, isTrue);
  });
}
