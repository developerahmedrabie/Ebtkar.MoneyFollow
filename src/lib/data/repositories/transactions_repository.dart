import 'package:drift/drift.dart';

import '../../domain/builtin_categories.dart';
import '../db/app_database.dart';
import 'base_repository.dart';
import 'settings_repository.dart';

/// Input for creating or editing a transaction.
class TxInput {
  const TxInput({
    required this.type,
    required this.amountMinor,
    required this.currency,
    required this.categoryId,
    required this.accountId,
    required this.date,
    this.memberId,
    this.occasionId,
    this.note = '',
    this.recurringId,
  });

  final TxType type;
  final int amountMinor;
  final String currency;
  final String categoryId;
  final String accountId;
  final String date;
  final String? memberId;
  final String? occasionId;
  final String note;
  final String? recurringId;
}

class TransactionsRepository extends BaseRepository {
  TransactionsRepository(super.db, super.stamper, this.settings,
      {required this.categoryType});

  final SettingsRepository settings;

  /// Resolves a category id to its type (built-in or user), null if unknown.
  final Future<TxType?> Function(String categoryId) categoryType;

  Future<void> _validate(TxInput i) async {
    if (i.amountMinor <= 0) throw const ValidationException('err_amount');
    final t = await categoryType(i.categoryId);
    if (t == null || t != i.type) throw const ValidationException('err_cat');
    if (i.occasionId != null && i.type != TxType.expense) {
      throw const ValidationException('err_occasion_income');
    }
    if (i.note.length > 60) throw const ValidationException('err_note');
  }

  Future<String> _currentSnapshotId() async =>
      await settings.read(SettingKeys.currentRateSnapshotId) ??
      defaultRateSnapshotId;

  Future<String> create(TxInput i, {bool isSample = false}) async {
    await _validate(i);
    final s = stamper.insert();
    await db.into(db.transactions).insert(TransactionsCompanion.insert(
          id: s.id,
          createdAt: s.createdAt,
          updatedAt: s.updatedAt,
          deviceId: s.deviceId,
          isSample: Value(isSample),
          type: i.type.name,
          amountMinor: i.amountMinor,
          currency: i.currency,
          rateSnapshotId: await _currentSnapshotId(),
          categoryId: i.categoryId,
          accountId: i.accountId,
          memberId: Value(i.memberId),
          occasionId: Value(i.occasionId),
          date: i.date,
          note: Value(i.note.trim()),
          recurringId: Value(i.recurringId),
        ));
    return s.id;
  }

  /// Edits a row. The rate snapshot is kept unless the amount or currency
  /// changed (then the current rates apply, FR-016).
  Future<void> update(String id, TxInput i) async {
    await _validate(i);
    final old = await (db.select(db.transactions)..where((t) => t.id.equals(id)))
        .getSingle();
    final snap = old.amountMinor == i.amountMinor && old.currency == i.currency
        ? old.rateSnapshotId
        : await _currentSnapshotId();
    final s = stamper.update();
    await (db.update(db.transactions)..where((t) => t.id.equals(id))).write(
      TransactionsCompanion(
        type: Value(i.type.name),
        amountMinor: Value(i.amountMinor),
        currency: Value(i.currency),
        rateSnapshotId: Value(snap),
        categoryId: Value(i.categoryId),
        accountId: Value(i.accountId),
        memberId: Value(i.memberId),
        occasionId: Value(i.occasionId),
        date: Value(i.date),
        note: Value(i.note.trim()),
        // a user-edited note replaces the sample translation key
        noteKey: i.note.trim().isEmpty ? const Value.absent() : const Value(null),
        updatedAt: Value(s.updatedAt),
        deviceId: Value(s.deviceId),
      ),
    );
  }

  Future<void> delete(String id) => softDelete(db.transactions, id);

  Future<TxRow?> byId(String id) =>
      (db.select(db.transactions)..where((t) => t.id.equals(id)))
          .getSingleOrNull();

  /// Live transactions of a month, newest first.
  Stream<List<TxRow>> watchMonth(String ym) => (db.select(db.transactions)
        ..where((t) => notDeleted(t) & t.date.like('$ym-%'))
        ..orderBy([
          (t) => OrderingTerm.desc(t.date),
          (t) => OrderingTerm.desc(t.createdAt),
        ]))
      .watch();
}
