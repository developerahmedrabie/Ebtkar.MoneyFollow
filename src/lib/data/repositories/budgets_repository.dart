import 'package:drift/drift.dart';

import '../db/app_database.dart';
import 'base_repository.dart';

/// One live monthly limit per expense category (FR-023).
class BudgetsRepository extends BaseRepository {
  BudgetsRepository(super.db, super.stamper);

  Stream<List<Budget>> watchAll() =>
      (db.select(db.budgets)..where(notDeleted)).watch();

  /// `limit_minor > 0`; null or 0 removes the limit (tombstones the row).
  Future<void> setLimit(String categoryId, int? limitMinor) async {
    if (limitMinor != null && limitMinor < 0) {
      throw const ValidationException('err_amount');
    }
    final live = await (db.select(db.budgets)
          ..where((t) => t.categoryId.equals(categoryId) & notDeleted(t)))
        .getSingleOrNull();
    if (limitMinor == null || limitMinor == 0) {
      if (live != null) await softDelete(db.budgets, live.id);
      return;
    }
    if (live == null) {
      final s = stamper.insert();
      await db.into(db.budgets).insert(BudgetsCompanion.insert(
          id: s.id,
          createdAt: s.createdAt,
          updatedAt: s.updatedAt,
          deviceId: s.deviceId,
          categoryId: categoryId,
          limitMinor: limitMinor));
    } else if (live.limitMinor != limitMinor) {
      final s = stamper.update();
      await (db.update(db.budgets)..where((t) => t.id.equals(live.id))).write(
          BudgetsCompanion(
              limitMinor: Value(limitMinor),
              updatedAt: Value(s.updatedAt),
              deviceId: Value(s.deviceId)));
    }
  }

  /// Saves all limits at once (the Budgets tab "Done").
  Future<void> setAll(Map<String, int?> limits) => db.transaction(() async {
        for (final e in limits.entries) {
          await setLimit(e.key, e.value);
        }
      });
}
