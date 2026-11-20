import 'dart:convert';

import '../../domain/conversion.dart';
import '../db/app_database.dart';
import 'base_repository.dart';
import 'settings_repository.dart';

/// Immutable rate snapshots (FR-014, FR-016).
class RatesRepository extends BaseRepository {
  RatesRepository(super.db, super.stamper, this.settings);

  final SettingsRepository settings;

  static Rates _toRates(RateSnapshot s) => Rates(
      s.id,
      (jsonDecode(s.ratesJson) as Map<String, dynamic>)
          .map((k, v) => MapEntry(k, (v as num).toInt())));

  Future<Rates?> snapshotById(String id) async {
    final row = await (db.select(db.rateSnapshots)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : _toRates(row);
  }

  Future<Rates> currentSnapshot() async {
    final id = await settings.read(SettingKeys.currentRateSnapshotId) ??
        defaultRateSnapshotId;
    return await snapshotById(id) ?? Rates.defaults();
  }

  Stream<Rates> watchCurrent() => settings
      .watch(SettingKeys.currentRateSnapshotId)
      .asyncMap((id) async =>
          await snapshotById(id ?? defaultRateSnapshotId) ?? Rates.defaults());

  /// All snapshots (they are few: one per rate edit).
  Stream<RatesBook> watchBook() =>
      db.select(db.rateSnapshots).watch().asyncMap((rows) async {
        final current = await currentSnapshot();
        return RatesBook(current, {for (final r in rows) r.id: _toRates(r)});
      });

  Future<RatesBook> book() async {
    final rows = await db.select(db.rateSnapshots).get();
    return RatesBook(
        await currentSnapshot(), {for (final r in rows) r.id: _toRates(r)});
  }

  /// Sets "1 [currency] = [valueInMainMicros]/1e6 [main]" by creating a new
  /// snapshot copied from the current one (rate > 0).
  Future<Rates> updateRate(String currency, int valueInMainMicros,
      {String? main}) async {
    if (valueInMainMicros <= 0) {
      throw const ValidationException('err_rate');
    }
    final m = main ?? await settings.mainCurrency();
    final cur = await currentSnapshot();
    if (currency == m) return cur;
    final microsEgp =
        (BigInt.from(valueInMainMicros) * BigInt.from(cur.of(m)) ~/
                BigInt.from(1000000))
            .toInt();
    final s = stamper.insert();
    final next = cur.withRate(s.id, currency, microsEgp < 1 ? 1 : microsEgp);
    await db.transaction(() async {
      await db.into(db.rateSnapshots).insert(RateSnapshotsCompanion.insert(
          id: s.id,
          createdAt: s.createdAt,
          updatedAt: s.updatedAt,
          deviceId: s.deviceId,
          ratesJson: jsonEncode(next.micros)));
      await settings.write(SettingKeys.currentRateSnapshotId, s.id);
    });
    return next;
  }
}
