import 'package:drift/drift.dart';

import '../../domain/builtin_categories.dart';
import '../db/app_database.dart';
import 'base_repository.dart';

/// User categories (FR-008, FR-009). Built-in ones are code constants.
class CategoriesRepository extends BaseRepository {
  CategoriesRepository(super.db, super.stamper);

  static String normalize(String s) =>
      s.trim().replaceAll(RegExp(r'\s+'), ' ').toLowerCase();

  Stream<List<UserCategory>> watchUser(TxType type) => (db.select(db.categories)
        ..where((t) => notDeleted(t) & t.type.equals(type.name))
        ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
      .watch();

  /// Type of a built-in or live user category; null when unknown.
  Future<TxType?> typeOf(String id) async {
    final b = builtinCategoriesById[id];
    if (b != null) return b.type;
    final c = await (db.select(db.categories)
          ..where((t) => t.id.equals(id) & notDeleted(t)))
        .getSingleOrNull();
    return c == null ? null : TxType.parse(c.type);
  }

  /// "1–20 chars, unique within type (case-insensitive, whitespace-collapsed)
  /// against user categories and built-in en/ar names".
  Future<String> _validName(TxType type, String name, {String? exceptId}) async {
    final trimmed = name.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (trimmed.isEmpty) throw const ValidationException('err_name');
    if (trimmed.length > 20) throw const ValidationException('err_name');
    final n = normalize(trimmed);
    for (final b in builtinCategoriesOf(type)) {
      if (normalize(b.en) == n || normalize(b.ar) == n) {
        throw const ValidationException('err_cat_dup');
      }
    }
    final users = await (db.select(db.categories)
          ..where((t) => notDeleted(t) & t.type.equals(type.name)))
        .get();
    if (users.any((u) => u.id != exceptId && normalize(u.name) == n)) {
      throw const ValidationException('err_cat_dup');
    }
    return trimmed;
  }

  Future<String> create(TxType type, String name, String icon, String color) async {
    final n = await _validName(type, name);
    if (!categoryIcons.contains(icon) || !categoryColors.contains(color)) {
      throw const ValidationException('err_cat');
    }
    final s = stamper.insert();
    await db.into(db.categories).insert(CategoriesCompanion.insert(
        id: s.id,
        createdAt: s.createdAt,
        updatedAt: s.updatedAt,
        deviceId: s.deviceId,
        type: type.name,
        name: n,
        icon: icon,
        color: color));
    return s.id;
  }

  /// The type can't change after creation (FR-008).
  Future<void> update(String id, String name, String icon, String color) async {
    final c = await (db.select(db.categories)..where((t) => t.id.equals(id)))
        .getSingle();
    final n = await _validName(TxType.parse(c.type), name, exceptId: id);
    final s = stamper.update();
    await (db.update(db.categories)..where((t) => t.id.equals(id))).write(
        CategoriesCompanion(
            name: Value(n),
            icon: Value(icon),
            color: Value(color),
            updatedAt: Value(s.updatedAt),
            deviceId: Value(s.deviceId)));
  }

  /// FR-009: re-point transactions and recurring items to Other, remove the
  /// budget, tombstone the category — one database transaction.
  Future<void> delete(String id) async {
    final c = await (db.select(db.categories)..where((t) => t.id.equals(id)))
        .getSingle();
    final other = otherCategoryId(TxType.parse(c.type));
    await db.transaction(() async {
      final txs = await (db.select(db.transactions)
            ..where((t) => t.categoryId.equals(id)))
          .get();
      for (final t in txs) {
        final s = stamper.update();
        await (db.update(db.transactions)..where((x) => x.id.equals(t.id)))
            .write(TransactionsCompanion(
                categoryId: Value(other),
                updatedAt: Value(s.updatedAt),
                deviceId: Value(s.deviceId)));
      }
      final recs = await (db.select(db.recurringItems)
            ..where((t) => t.categoryId.equals(id)))
          .get();
      for (final r in recs) {
        final s = stamper.update();
        await (db.update(db.recurringItems)..where((x) => x.id.equals(r.id)))
            .write(RecurringItemsCompanion(
                categoryId: Value(other),
                updatedAt: Value(s.updatedAt),
                deviceId: Value(s.deviceId)));
      }
      final budgets = await (db.select(db.budgets)
            ..where((t) => t.categoryId.equals(id) & notDeleted(t)))
          .get();
      for (final b in budgets) {
        await softDelete(db.budgets, b.id);
      }
      await softDelete(db.categories, id);
    });
  }

  /// Live transactions per category id.
  Future<Map<String, int>> usageCounts() async {
    final rows = await db
        .customSelect(
            'SELECT category_id, COUNT(*) AS n FROM transactions WHERE deleted = 0 GROUP BY category_id',
            readsFrom: {db.transactions})
        .get();
    return {for (final r in rows) r.read<String>('category_id'): r.read<int>('n')};
  }
}
