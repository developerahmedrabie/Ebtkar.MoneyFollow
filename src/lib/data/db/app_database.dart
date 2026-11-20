import 'dart:convert';

import 'package:drift/drift.dart';

import '../../core/money/currency.dart';
import '../../core/time/hlc.dart';
import '../../domain/builtin_categories.dart';
import '../../domain/builtin_occasions.dart';
import 'tables.dart';

export 'tables.dart';

part 'app_database.g.dart';

/// Fixed id of the first rate snapshot, so every phone seeds the same row.
const defaultRateSnapshotId = 'rates-default';

/// Stamp used for seeded rows (identical on every device).
final seedHlc = Hlc.format(0, 0, 'seed');

abstract final class SettingKeys {
  static const mainCurrency = 'main_currency';
  static const country = 'country';
  static const currentRateSnapshotId = 'current_rate_snapshot_id';
  static const occasionDatesUpdatedAt = 'occasion_dates_updated_at';
  static const occasionDatesCountry = 'occasion_dates_country';
  static const familyCreatedAt = 'family_created_at';
}

@DriftDatabase(tables: [
  Members,
  Categories,
  Accounts,
  Transactions,
  Transfers,
  RecurringItems,
  Budgets,
  RateSnapshots,
  Occasions,
  OccasionDates,
  Settings,
  SyncOutbox,
  SyncState,
  Devices,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 1;

  /// Tables whose rows are synced and recorded in the outbox.
  List<TableInfo<Table, Object?>> get syncedTables => [
        members,
        categories,
        accounts,
        transactions,
        transfers,
        recurringItems,
        budgets,
        rateSnapshots,
        occasions,
        occasionDates,
        settings,
      ];

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await customStatement(
              'CREATE UNIQUE INDEX budgets_live_category ON budgets(category_id) WHERE deleted = 0');
          await _seed();
          await createOutboxTriggers();
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );

  Future<void> _seed() async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final h = seedHlc;
    await batch((b) {
      for (var i = 0; i < builtinAccounts.length; i++) {
        final a = builtinAccounts[i];
        b.insert(
            accounts,
            AccountsCompanion.insert(
                id: a.id,
                createdAt: 0,
                updatedAt: h,
                deviceId: 'seed',
                key: a.key,
                currency: a.currencyCode,
                sortOrder: Value(i)));
      }
      b.insert(
          rateSnapshots,
          RateSnapshotsCompanion.insert(
              id: defaultRateSnapshotId,
              createdAt: 0,
              updatedAt: h,
              deviceId: 'seed',
              ratesJson: jsonEncode(Currency.defaultRates)));
      void setting(String key, String value) => b.insert(
          settings,
          SettingsCompanion.insert(
              id: key,
              createdAt: 0,
              updatedAt: h,
              deviceId: 'seed',
              value: value));
      setting(SettingKeys.mainCurrency, 'EGP');
      setting(SettingKeys.country, 'EG');
      setting(SettingKeys.currentRateSnapshotId, defaultRateSnapshotId);
      setting(SettingKeys.occasionDatesCountry, 'EG');
      setting(SettingKeys.familyCreatedAt, '$now');
      bundledEgyptOccasionDates.forEach((key, dates) {
        for (final d in dates) {
          final year = int.parse(d.substring(0, 4));
          b.insert(
              occasionDates,
              OccasionDatesCompanion.insert(
                  id: '$key|$year|EG',
                  createdAt: 0,
                  updatedAt: h,
                  deviceId: 'seed',
                  occasionKey: key,
                  year: year,
                  startDate: d,
                  source: 'bundled',
                  country: 'EG'));
        }
      });
    });
  }

  /// AFTER INSERT/UPDATE triggers that copy each non-sample change into
  /// `sync_outbox` (research R-08, data-model "Release 1.1 sync tables").
  Future<void> createOutboxTriggers() async {
    for (final t in syncedTables) {
      final name = t.actualTableName;
      final cols = t.$columns.map((c) => c.name).toList();
      final json = cols.map((c) => "'$c', NEW.$c").join(', ');
      for (final op in ['insert', 'update']) {
        await customStatement('''
CREATE TRIGGER IF NOT EXISTS outbox_${name}_$op AFTER ${op.toUpperCase()} ON $name
WHEN NEW.is_sample = 0
BEGIN
  INSERT INTO sync_outbox (table_name, row_id, op, payload_json, hlc)
  VALUES ('$name', NEW.id, '$op', json_object($json), NEW.updated_at);
END''');
      }
    }
  }
}
