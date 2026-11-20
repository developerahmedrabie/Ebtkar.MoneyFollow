import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:money_follow/data/db/app_database.dart';
import 'package:test/test.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  Future<List<String>> names(String type) async {
    final rows = await db
        .customSelect('SELECT name FROM sqlite_master WHERE type = ?',
            variables: [Variable.withString(type)])
        .get();
    return rows.map((r) => r.read<String>('name')).toList();
  }

  test('creates all 14 tables and the outbox triggers', () async {
    final tables = await names('table');
    for (final t in [
      'members',
      'categories',
      'accounts',
      'transactions',
      'transfers',
      'recurring_items',
      'budgets',
      'rate_snapshots',
      'occasions',
      'occasion_dates',
      'settings',
      'sync_outbox',
      'sync_state',
      'devices',
    ]) {
      expect(tables, contains(t));
    }
    final triggers = await names('trigger');
    expect(triggers, hasLength(22)); // 11 synced tables × insert/update
    expect(triggers, contains('outbox_transactions_insert'));
  });

  test('seeds accounts, the default rate snapshot and settings', () async {
    final accounts = await db.select(db.accounts).get();
    expect(accounts.map((a) => a.id),
        containsAll(['acc-cash', 'acc-bank', 'acc-card', 'acc-usd']));
    final snap = await db.select(db.rateSnapshots).getSingle();
    expect(snap.id, defaultRateSnapshotId);
    final s = await db.select(db.settings).get();
    expect(s.firstWhere((r) => r.id == SettingKeys.mainCurrency).value, 'EGP');
    final dates = await db.select(db.occasionDates).get();
    expect(dates.where((d) => d.occasionKey == 'ramadan'), hasLength(4));
  });

  Future<int> outboxCount() async =>
      (await db.select(db.syncOutbox).get()).length;

  TransactionsCompanion tx(String id, {bool sample = false}) =>
      TransactionsCompanion.insert(
        id: id,
        createdAt: 1,
        updatedAt: '0000000000001-0000-dev',
        deviceId: 'dev',
        isSample: Value(sample),
        type: 'expense',
        amountMinor: 25000,
        currency: 'EGP',
        rateSnapshotId: defaultRateSnapshotId,
        categoryId: 'groceries',
        accountId: 'acc-cash',
        date: '2026-11-13',
      );

  test('inserting a transaction writes exactly one outbox row', () async {
    final before = await outboxCount();
    await db.into(db.transactions).insert(tx('t1'));
    expect(await outboxCount(), before + 1);
    final e = (await db.select(db.syncOutbox).get()).last;
    expect(e.tableName_, 'transactions');
    expect(e.rowId, 't1');
    expect(e.op, 'insert');
    expect(e.payloadJson, contains('"amount_minor":25000'));
  });

  test('a sample row writes no outbox row', () async {
    final before = await outboxCount();
    await db.into(db.transactions).insert(tx('s1', sample: true));
    expect(await outboxCount(), before);
  });

  test('only one live budget per category', () async {
    BudgetsCompanion b(String id, {bool deleted = false}) =>
        BudgetsCompanion.insert(
            id: id,
            createdAt: 1,
            updatedAt: 'x',
            deviceId: 'd',
            deleted: Value(deleted),
            categoryId: 'groceries',
            limitMinor: 700000);
    await db.into(db.budgets).insert(b('b1', deleted: true));
    await db.into(db.budgets).insert(b('b2'));
    expect(() => db.into(db.budgets).insert(b('b3')), throwsA(anything));
  });
}
