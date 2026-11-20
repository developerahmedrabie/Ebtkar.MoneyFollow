import 'package:drift/drift.dart';

import '../../core/ids.dart';
import '../../core/time/hlc.dart';
import '../db/app_database.dart';

/// Fills the sync columns on every write (data-model "Conventions").
class Stamper {
  Stamper({required this.deviceId, Hlc? hlc, int Function()? clock})
      : hlc = hlc ?? Hlc(deviceId: deviceId),
        _clock = clock ?? (() => DateTime.now().millisecondsSinceEpoch);

  final String deviceId;
  final Hlc hlc;
  final int Function() _clock;

  int nowMs() => _clock();

  ({String id, int createdAt, String updatedAt, String deviceId}) insert(
          {String? id}) =>
      (
        id: id ?? newId(),
        createdAt: _clock(),
        updatedAt: hlc.send(),
        deviceId: deviceId,
      );

  ({String updatedAt, String deviceId}) update() =>
      (updatedAt: hlc.send(), deviceId: deviceId);
}

/// Base for repositories: database, stamping, soft delete and the
/// "not deleted" filter that every query must use.
abstract class BaseRepository {
  BaseRepository(this.db, this.stamper);

  final AppDatabase db;
  final Stamper stamper;

  /// Filter for live rows.
  Expression<bool> notDeleted(SyncColumns t) => t.deleted.equals(false);

  /// Sets `deleted = 1` and stamps the row.
  Future<void> softDelete(TableInfo<Table, Object?> table, String id) async {
    final s = stamper.update();
    await db.customUpdate(
      'UPDATE ${table.actualTableName} SET deleted = 1, updated_at = ?, device_id = ? WHERE id = ?',
      variables: [
        Variable.withString(s.updatedAt),
        Variable.withString(s.deviceId),
        Variable.withString(id),
      ],
      updates: {table},
    );
  }
}

/// Thrown when input breaks a data rule; [code] is an l10n key.
class ValidationException implements Exception {
  const ValidationException(this.code, [this.detail]);
  final String code;
  final String? detail;
  @override
  String toString() => 'ValidationException($code${detail == null ? '' : ': $detail'})';
}
