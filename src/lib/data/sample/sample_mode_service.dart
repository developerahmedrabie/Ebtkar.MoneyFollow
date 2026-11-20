import 'package:drift/drift.dart' show TableUpdate;

import '../db/app_database.dart';
import 'sample_data.dart';

/// "Explore with sample data" / "Clear sample data and start" (FR-064).
/// Device flags (sample_mode, sample_started_at) are kept by the caller.
class SampleModeService {
  SampleModeService(this.db);
  final AppDatabase db;

  /// Inserts the sample family anchored at [today]. Returns the start time.
  Future<int> start(String today, {int? nowMs}) async {
    final now = nowMs ?? DateTime.now().millisecondsSinceEpoch;
    await SampleData.generate(today, createdAt: now).insertInto(db);
    return now;
  }

  /// Hard-deletes every sample row and every row created while exploring
  /// (`created_at >= startedAt`), except setup choices: settings and the
  /// members in [keepMemberIds].
  Future<void> clear(int startedAt, {Set<String> keepMemberIds = const {}}) =>
      db.transaction(() async {
        for (final t in db.syncedTables) {
          final name = t.actualTableName;
          if (name == 'settings' || name == 'accounts') {
            await db.customStatement('DELETE FROM $name WHERE is_sample = 1');
            continue;
          }
          if (name == 'rate_snapshots' || name == 'occasion_dates') {
            // keep rate/date changes: they are setup-like choices
            await db.customStatement('DELETE FROM $name WHERE is_sample = 1');
            continue;
          }
          final keep = name == 'members' && keepMemberIds.isNotEmpty
              ? ' AND id NOT IN (${keepMemberIds.map((e) => "'${e.replaceAll("'", "''")}'").join(',')})'
              : '';
          await db.customStatement(
              'DELETE FROM $name WHERE (is_sample = 1 OR created_at >= ?)$keep',
              [startedAt]);
        }
        // Nothing made while exploring is synced or backed up.
        await db.customStatement('DELETE FROM sync_outbox');
        db.notifyUpdates({for (final t in db.syncedTables) TableUpdate.onTable(t)});
      });
}
