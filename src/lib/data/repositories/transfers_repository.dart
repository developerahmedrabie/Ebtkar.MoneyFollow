import 'package:drift/drift.dart';

import '../db/app_database.dart';
import 'base_repository.dart';
import 'settings_repository.dart';

class TransferInput {
  const TransferInput({
    required this.fromAccountId,
    required this.toAccountId,
    required this.amountOutMinor,
    required this.amountInMinor,
    required this.date,
    this.note = '',
  });
  final String fromAccountId;
  final String toAccountId;
  final int amountOutMinor;
  final int amountInMinor;
  final String date;
  final String note;
}

/// Transfers between accounts (FR-060). They affect balances only.
class TransfersRepository extends BaseRepository {
  TransfersRepository(super.db, super.stamper, this.settings);

  final SettingsRepository settings;

  Future<TransferInput> _validate(TransferInput i) async {
    if (i.fromAccountId == i.toAccountId) {
      throw const ValidationException('err_same_account');
    }
    if (i.amountOutMinor <= 0 || i.amountInMinor <= 0) {
      throw const ValidationException('err_amount');
    }
    if (i.note.length > 60) throw const ValidationException('err_note');
    final accs = await (db.select(db.accounts)
          ..where((t) => t.id.isIn([i.fromAccountId, i.toAccountId])))
        .get();
    if (accs.length != 2) throw const ValidationException('err_account');
    final from = accs.firstWhere((a) => a.id == i.fromAccountId);
    final to = accs.firstWhere((a) => a.id == i.toAccountId);
    // Same currency: the received amount equals the sent amount.
    return from.currency == to.currency
        ? TransferInput(
            fromAccountId: i.fromAccountId,
            toAccountId: i.toAccountId,
            amountOutMinor: i.amountOutMinor,
            amountInMinor: i.amountOutMinor,
            date: i.date,
            note: i.note)
        : i;
  }

  Future<String> create(TransferInput input) async {
    final i = await _validate(input);
    final s = stamper.insert();
    await db.into(db.transfers).insert(TransfersCompanion.insert(
        id: s.id,
        createdAt: s.createdAt,
        updatedAt: s.updatedAt,
        deviceId: s.deviceId,
        fromAccountId: i.fromAccountId,
        toAccountId: i.toAccountId,
        amountOutMinor: i.amountOutMinor,
        amountInMinor: i.amountInMinor,
        rateSnapshotId: await settings.read(SettingKeys.currentRateSnapshotId) ??
            defaultRateSnapshotId,
        date: i.date,
        note: Value(i.note.trim())));
    return s.id;
  }

  Future<void> update(String id, TransferInput input) async {
    final i = await _validate(input);
    final s = stamper.update();
    await (db.update(db.transfers)..where((t) => t.id.equals(id))).write(
        TransfersCompanion(
            fromAccountId: Value(i.fromAccountId),
            toAccountId: Value(i.toAccountId),
            amountOutMinor: Value(i.amountOutMinor),
            amountInMinor: Value(i.amountInMinor),
            date: Value(i.date),
            note: Value(i.note.trim()),
            updatedAt: Value(s.updatedAt),
            deviceId: Value(s.deviceId)));
  }

  Future<void> delete(String id) => softDelete(db.transfers, id);

  Future<Transfer?> byId(String id) =>
      (db.select(db.transfers)..where((t) => t.id.equals(id))).getSingleOrNull();

  Stream<List<Transfer>> watchMonth(String ym) => (db.select(db.transfers)
        ..where((t) => notDeleted(t) & t.date.like('$ym-%'))
        ..orderBy([(t) => OrderingTerm.desc(t.date)]))
      .watch();
}
