
import 'package:drift/drift.dart';

import '../db/app_database.dart';
import 'backup_codec.dart';

export 'backup_codec.dart';

/// Builds and restores `.mfbackup` files (FR-061). File I/O and sharing
/// stay in the UI layer; this class only turns the database into bytes and
/// back.
class BackupService {
  BackupService(this.db, {required this.appVersion, required this.deviceName});

  final AppDatabase db;
  final String appVersion;
  final String deviceName;

  static String fileName(String today) => 'MoneyFollow-$today.mfbackup';

  /// All family rows incl. tombstones, excluding sample rows.
  Future<Map<String, List<Map<String, Object?>>>> _export() async {
    final out = <String, List<Map<String, Object?>>>{};
    for (final t in db.syncedTables) {
      final rows = await db
          .customSelect(
              'SELECT * FROM ${t.actualTableName} WHERE is_sample = 0',
              readsFrom: {t})
          .get();
      out[t.actualTableName] = [for (final r in rows) r.data];
    }
    return out;
  }

  /// Creates the backup bytes. Afterwards the 1.0 outbox is trimmed
  /// (release 1.1 keeps it while sync is connected, T137).
  Future<Uint8List> createBackup(
      {String? password, DateTime? now, bool trimOutbox = true}) async {
    final tables = await _export();
    int count(String t) => tables[t]!.where((r) => r['deleted'] == 0).length;
    final bytes = await BackupCodec.encode(
      payload: {'schemaVersion': db.schemaVersion, 'tables': tables},
      header: {
        'app': 'money_follow',
        'appVersion': appVersion,
        'schemaVersion': db.schemaVersion,
        'createdAt': (now ?? DateTime.now()).toUtc().toIso8601String(),
        'deviceName': deviceName,
        'counts': {
          'transactions': count('transactions'),
          'members': count('members'),
          'recurring': count('recurring_items'),
          'categories': count('categories'),
          'transfers': count('transfers'),
        },
      },
      password: password,
    );
    if (trimOutbox) await db.delete(db.syncOutbox).go();
    return bytes;
  }

  BackupHeader readHeader(Uint8List bytes) => BackupCodec.readHeader(bytes);

  /// Replaces all family data with the backup in ONE database transaction.
  /// Throws a [BackupError] and leaves the data unchanged on any problem.
  Future<BackupHeader> restore(Uint8List bytes, {String? password}) async {
    final header = BackupCodec.readHeader(bytes);
    final payload = await BackupCodec.decode(bytes,
        password: password, appSchemaVersion: db.schemaVersion);
    final tables = (payload['tables'] as Map).cast<String, dynamic>();
    final known = {for (final t in db.syncedTables) t.actualTableName: t};
    // Validate before touching the database.
    for (final name in tables.keys) {
      if (!known.containsKey(name) || tables[name] is! List) {
        throw BackupDamaged('table $name');
      }
    }
    await db.transaction(() async {
      for (final t in db.syncedTables) {
        await db.customStatement('DELETE FROM ${t.actualTableName}');
      }
      await db.delete(db.syncOutbox).go();
      for (final MapEntry(key: name, value: rows) in tables.entries) {
        final cols = known[name]!.$columns.map((c) => c.name).toSet();
        for (final raw in (rows as List).cast<Map<String, dynamic>>()) {
          final row = {
            for (final e in raw.entries)
              if (cols.contains(e.key)) e.key: e.value,
          };
          if (row.isEmpty) continue;
          final names = row.keys.toList();
          await db.customInsert(
            'INSERT INTO $name (${names.join(', ')}) VALUES (${List.filled(names.length, '?').join(', ')})',
            variables: [for (final n in names) _variable(row[n])],
            updates: {known[name]!},
          );
        }
      }
    });
    // The triggers re-created the outbox for the restored rows.
    db.notifyUpdates({
      for (final t in db.syncedTables) TableUpdate.onTable(t),
    });
    return header;
  }

  static Variable<Object> _variable(Object? v) => switch (v) {
        null => const Variable(null),
        final int i => Variable.withInt(i),
        final double d => Variable.withReal(d),
        final bool b => Variable.withInt(b ? 1 : 0),
        final String s => Variable.withString(s),
        _ => Variable.withString('$v'),
      };
}
