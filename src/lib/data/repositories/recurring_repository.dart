import 'package:drift/drift.dart';

import '../../core/time/dates.dart';
import '../../domain/builtin_categories.dart';
import '../../domain/recurring.dart';
import '../db/app_database.dart';
import 'base_repository.dart';
import 'settings_repository.dart';

class RecurringInput {
  const RecurringInput({
    required this.type,
    required this.amountMinor,
    required this.currency,
    required this.categoryId,
    required this.accountId,
    required this.frequency,
    required this.nextDue,
    this.memberId,
    this.name = '',
  });

  final TxType type;
  final int amountMinor;
  final String currency;
  final String categoryId;
  final String accountId;
  final String frequency;
  final String nextDue;
  final String? memberId;
  final String name;
}

class RecurringRepository extends BaseRepository {
  RecurringRepository(super.db, super.stamper, this.settings,
      {required this.categoryType});

  final SettingsRepository settings;
  final Future<TxType?> Function(String) categoryType;

  Future<void> _validate(RecurringInput i) async {
    if (i.amountMinor <= 0) throw const ValidationException('err_amount');
    if (i.name.length > 60) throw const ValidationException('err_name');
    if (!frequencies.contains(i.frequency)) {
      throw const ValidationException('err_frequency');
    }
    if (await categoryType(i.categoryId) != i.type) {
      throw const ValidationException('err_cat');
    }
  }

  /// All live items, by next due date.
  Stream<List<RecurringItem>> watchAll() => (db.select(db.recurringItems)
        ..where(notDeleted)
        ..orderBy([(t) => OrderingTerm.asc(t.nextDue)]))
      .watch();

  /// Due within [days] of [today], overdue items included, soonest first.
  Stream<List<RecurringItem>> watchDue(String today, {int days = 30}) {
    final lim = LocalDate.addDays(today, days);
    return (db.select(db.recurringItems)
          ..where((t) => notDeleted(t) & t.nextDue.isSmallerOrEqualValue(lim))
          ..orderBy([(t) => OrderingTerm.asc(t.nextDue)]))
        .watch();
  }

  Future<RecurringItem?> byId(String id) =>
      (db.select(db.recurringItems)..where((t) => t.id.equals(id)))
          .getSingleOrNull();

  Future<String> create(RecurringInput i) async {
    await _validate(i);
    final s = stamper.insert();
    await db.into(db.recurringItems).insert(RecurringItemsCompanion.insert(
          id: s.id,
          createdAt: s.createdAt,
          updatedAt: s.updatedAt,
          deviceId: s.deviceId,
          type: i.type.name,
          amountMinor: i.amountMinor,
          currency: i.currency,
          categoryId: i.categoryId,
          accountId: i.accountId,
          memberId: Value(i.memberId),
          name: Value(i.name.trim()),
          frequency: i.frequency,
          nextDue: i.nextDue,
          dayOfMonth: LocalDate.dayOf(i.nextDue),
        ));
    return s.id;
  }

  Future<void> update(String id, RecurringInput i) async {
    await _validate(i);
    final s = stamper.update();
    await (db.update(db.recurringItems)..where((t) => t.id.equals(id))).write(
      RecurringItemsCompanion(
        type: Value(i.type.name),
        amountMinor: Value(i.amountMinor),
        currency: Value(i.currency),
        categoryId: Value(i.categoryId),
        accountId: Value(i.accountId),
        memberId: Value(i.memberId),
        name: Value(i.name.trim()),
        nameKey: i.name.trim().isEmpty ? const Value.absent() : const Value(null),
        frequency: Value(i.frequency),
        nextDue: Value(i.nextDue),
        dayOfMonth: Value(LocalDate.dayOf(i.nextDue)),
        updatedAt: Value(s.updatedAt),
        deviceId: Value(s.deviceId),
      ),
    );
  }

  /// FR-020 (prototype `markPaid`): records a transaction dated [today]
  /// and advances `next_due`, in one database transaction.
  Future<String> markPaid(String id, String today) async {
    return db.transaction(() async {
      final r = await (db.select(db.recurringItems)
            ..where((t) => t.id.equals(id)))
          .getSingle();
      final snap = await settings.read(SettingKeys.currentRateSnapshotId) ??
          defaultRateSnapshotId;
      final s = stamper.insert();
      await db.into(db.transactions).insert(TransactionsCompanion.insert(
            id: s.id,
            createdAt: s.createdAt,
            updatedAt: s.updatedAt,
            deviceId: s.deviceId,
            isSample: Value(r.isSample),
            type: r.type,
            amountMinor: r.amountMinor,
            currency: r.currency,
            rateSnapshotId: snap,
            categoryId: r.categoryId,
            accountId: r.accountId,
            memberId: Value(r.memberId),
            date: today,
            note: Value(r.name),
            noteKey: Value(r.nameKey),
            recurringId: Value(r.id),
          ));
      final u = stamper.update();
      await (db.update(db.recurringItems)..where((t) => t.id.equals(id)))
          .write(RecurringItemsCompanion(
              nextDue: Value(advanceDue(r.nextDue, r.frequency, r.dayOfMonth)),
              updatedAt: Value(u.updatedAt),
              deviceId: Value(u.deviceId)));
      return s.id;
    });
  }

  /// "Stop repeating": soft delete; past transactions keep `recurring_id`.
  Future<void> stop(String id) => softDelete(db.recurringItems, id);
}
