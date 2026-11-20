import 'package:drift/drift.dart';

import '../../domain/builtin_categories.dart';
import '../../domain/builtin_occasions.dart';
import '../db/app_database.dart';
import 'base_repository.dart';

/// Occasion settings, custom occasions and stored dates (FR-034 – FR-041).
class OccasionsRepository extends BaseRepository {
  OccasionsRepository(super.db, super.stamper);

  Future<OccasionRow?> _row(String key) =>
      (db.select(db.occasions)..where((t) => t.id.equals(key)))
          .getSingleOrNull();

  /// Switches tracking of an occasion on or off (FR-036).
  Future<void> setEnabled(String key, bool enabled) async {
    final row = await _row(key);
    if (row == null) {
      final s = stamper.insert(id: key);
      await db.into(db.occasions).insert(OccasionsCompanion.insert(
          id: s.id,
          createdAt: s.createdAt,
          updatedAt: s.updatedAt,
          deviceId: s.deviceId,
          key: key,
          enabled: Value(enabled)));
    } else {
      final s = stamper.update();
      await (db.update(db.occasions)..where((t) => t.id.equals(key))).write(
          OccasionsCompanion(
              enabled: Value(enabled),
              updatedAt: Value(s.updatedAt),
              deviceId: Value(s.deviceId)));
    }
  }

  void _validateCustom(String name, String icon, String color, String monthDay, int days) {
    final n = name.trim();
    if (n.isEmpty || n.length > 30) throw const ValidationException('err_name');
    if (!RegExp(r'^(0[1-9]|1[0-2])-(0[1-9]|[12]\d|3[01])$').hasMatch(monthDay)) {
      throw const ValidationException('err_date');
    }
    if (days < 1 || days > 30) throw const ValidationException('err_days');
    if (!categoryIcons.contains(icon) || !categoryColors.contains(color)) {
      throw const ValidationException('err_icon');
    }
  }

  /// Custom occasion with a fixed `MM-DD` each year (FR-041).
  Future<String> createCustom(
      String name, String icon, String color, String monthDay, int days) async {
    _validateCustom(name, icon, color, monthDay, days);
    final s = stamper.insert();
    await db.into(db.occasions).insert(OccasionsCompanion.insert(
        id: s.id,
        createdAt: s.createdAt,
        updatedAt: s.updatedAt,
        deviceId: s.deviceId,
        key: s.id,
        customName: Value(name.trim()),
        icon: Value(icon),
        color: Value(color),
        customMonthDay: Value(monthDay),
        days: Value(days)));
    return s.id;
  }

  Future<void> updateCustom(String key, String name, String icon, String color,
      String monthDay, int days) async {
    _validateCustom(name, icon, color, monthDay, days);
    final s = stamper.update();
    await (db.update(db.occasions)..where((t) => t.id.equals(key))).write(
        OccasionsCompanion(
            customName: Value(name.trim()),
            icon: Value(icon),
            color: Value(color),
            customMonthDay: Value(monthDay),
            days: Value(days),
            updatedAt: Value(s.updatedAt),
            deviceId: Value(s.deviceId)));
  }

  /// Deleting unlinks tagged transactions (their spending stays in history
  /// as normal expenses) and tombstones the occasion.
  Future<void> deleteCustom(String key) => db.transaction(() async {
        final txs = await (db.select(db.transactions)
              ..where((t) => t.occasionId.equals(key)))
            .get();
        for (final t in txs) {
          final s = stamper.update();
          await (db.update(db.transactions)..where((x) => x.id.equals(t.id)))
              .write(TransactionsCompanion(
                  occasionId: const Value(null),
                  updatedAt: Value(s.updatedAt),
                  deviceId: Value(s.deviceId)));
        }
        await softDelete(db.occasions, key);
      });

  /// Moves one year's date by ±1 day (FR-040); `adjust_days ∈ {−1, 0, +1}`.
  /// For dates with no stored row (fixed/fallback/custom) a `user` row is
  /// created from [startDate].
  Future<void> adjust(String key, int year, String country, int delta,
      {required String startDate}) async {
    if (delta < -1 || delta > 1) throw const ValidationException('err_adjust');
    final id = '$key|$year|$country';
    final row = await (db.select(db.occasionDates)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    if (row == null) {
      final s = stamper.insert(id: id);
      await db.into(db.occasionDates).insert(OccasionDatesCompanion.insert(
          id: s.id,
          createdAt: s.createdAt,
          updatedAt: s.updatedAt,
          deviceId: s.deviceId,
          occasionKey: key,
          year: year,
          startDate: startDate,
          source: 'user',
          country: country,
          adjustDays: Value(delta)));
    } else {
      final s = stamper.update();
      await (db.update(db.occasionDates)..where((t) => t.id.equals(id))).write(
          OccasionDatesCompanion(
              adjustDays: Value(delta),
              deleted: const Value(false),
              updatedAt: Value(s.updatedAt),
              deviceId: Value(s.deviceId)));
    }
  }

  /// Replaces fetched dates for [country] (FR-035), keeping `adjust_days`
  /// of rows that already exist. [dates] maps occasion key → start dates.
  Future<int> replaceFetched(String country, Map<String, List<String>> dates,
      Map<String, String> sourceOf) async {
    var n = 0;
    await db.transaction(() async {
      final existing = await (db.select(db.occasionDates)
            ..where((t) => t.country.equals(country)))
          .get();
      final byId = {for (final r in existing) r.id: r};
      final keep = <String>{};
      for (final e in dates.entries) {
        for (final d in e.value.toSet()) {
          final year = int.parse(d.substring(0, 4));
          final id = '${e.key}|$year|$country';
          keep.add(id);
          n++;
          final old = byId[id];
          if (old == null) {
            final s = stamper.insert(id: id);
            await db.into(db.occasionDates).insert(OccasionDatesCompanion.insert(
                id: s.id,
                createdAt: s.createdAt,
                updatedAt: s.updatedAt,
                deviceId: s.deviceId,
                occasionKey: e.key,
                year: year,
                startDate: d,
                source: sourceOf[e.key] ?? 'aladhan',
                country: country));
          } else if (old.startDate != d || old.deleted || old.source != sourceOf[e.key]) {
            final s = stamper.update();
            await (db.update(db.occasionDates)..where((t) => t.id.equals(id)))
                .write(OccasionDatesCompanion(
                    startDate: Value(d),
                    source: Value(sourceOf[e.key] ?? old.source),
                    deleted: const Value(false),
                    updatedAt: Value(s.updatedAt),
                    deviceId: Value(s.deviceId)));
          }
        }
      }
      // Holiday rows of this country that the service no longer returns.
      for (final r in existing) {
        final def = builtinOccasionsByKey[r.occasionKey];
        if (!keep.contains(r.id) &&
            !r.deleted &&
            def?.source == OccasionSource.holiday &&
            r.source != 'user') {
          await softDelete(db.occasionDates, r.id);
        }
      }
    });
    return n;
  }
}
