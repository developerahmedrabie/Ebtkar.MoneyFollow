import 'package:drift/drift.dart';

import '../db/app_database.dart';
import 'base_repository.dart';

/// Synced family settings (key/value rows in `settings`).
class SettingsRepository extends BaseRepository {
  SettingsRepository(super.db, super.stamper);

  Future<String?> read(String key) async {
    final row = await (db.select(db.settings)
          ..where((t) => t.id.equals(key) & notDeleted(t)))
        .getSingleOrNull();
    return row?.value;
  }

  Stream<String?> watch(String key) => (db.select(db.settings)
        ..where((t) => t.id.equals(key) & notDeleted(t)))
      .watchSingleOrNull()
      .map((r) => r?.value);

  Future<void> write(String key, String value) async {
    final existing = await (db.select(db.settings)
          ..where((t) => t.id.equals(key)))
        .getSingleOrNull();
    if (existing == null) {
      final s = stamper.insert(id: key);
      await db.into(db.settings).insert(SettingsCompanion.insert(
          id: s.id,
          createdAt: s.createdAt,
          updatedAt: s.updatedAt,
          deviceId: s.deviceId,
          value: value));
    } else {
      if (existing.value == value && !existing.deleted) return;
      final s = stamper.update();
      await (db.update(db.settings)..where((t) => t.id.equals(key))).write(
          SettingsCompanion(
              value: Value(value),
              deleted: const Value(false),
              updatedAt: Value(s.updatedAt),
              deviceId: Value(s.deviceId)));
    }
  }

  Future<String> mainCurrency() async =>
      await read(SettingKeys.mainCurrency) ?? 'EGP';
  Stream<String> watchMainCurrency() =>
      watch(SettingKeys.mainCurrency).map((v) => v ?? 'EGP');

  Future<String> country() async => await read(SettingKeys.country) ?? 'EG';
  Stream<String> watchCountry() =>
      watch(SettingKeys.country).map((v) => v ?? 'EG');
}
