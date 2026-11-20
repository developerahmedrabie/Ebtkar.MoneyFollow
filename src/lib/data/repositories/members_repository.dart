import 'package:drift/drift.dart';

import '../../domain/builtin_categories.dart';
import '../db/app_database.dart';
import 'base_repository.dart';

const memberRoles = ['parent', 'child', 'other'];

class MembersRepository extends BaseRepository {
  MembersRepository(super.db, super.stamper);

  Stream<List<Member>> watchAll() => (db.select(db.members)
        ..where(notDeleted)
        ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
      .watch();

  Future<List<Member>> all() => (db.select(db.members)
        ..where(notDeleted)
        ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
      .get();

  /// "Required, trimmed, 1–30 chars".
  String _name(String name) {
    final n = name.trim();
    if (n.isEmpty || n.length > 30) throw const ValidationException('err_name');
    return n;
  }

  void _check(String role, String avatar) {
    if (!memberRoles.contains(role)) throw const ValidationException('err_role');
    if (!memberAvatars.contains(avatar)) {
      throw const ValidationException('err_avatar');
    }
  }

  /// The first colour of the 8-colour palette not used by a live member.
  Future<String> _nextColor() async {
    final used = (await all()).map((m) => m.color).toSet();
    return memberColors.firstWhere((c) => !used.contains(c),
        orElse: () => memberColors[used.length % memberColors.length]);
  }

  Future<String> create(String name, String role, String avatar,
      {bool isSample = false}) async {
    final n = _name(name);
    _check(role, avatar);
    final existing = await all();
    final s = stamper.insert();
    await db.into(db.members).insert(MembersCompanion.insert(
        id: s.id,
        createdAt: s.createdAt,
        updatedAt: s.updatedAt,
        deviceId: s.deviceId,
        isSample: Value(isSample),
        name: n,
        role: role,
        avatar: avatar,
        color: await _nextColor(),
        sortOrder: Value(existing.isEmpty
            ? 0
            : existing.map((m) => m.sortOrder).reduce((a, b) => a > b ? a : b) +
                1)));
    return s.id;
  }

  /// Renaming clears `name_key` (sample names become the typed name).
  Future<void> update(String id, String name, String role, String avatar) async {
    final n = _name(name);
    _check(role, avatar);
    final s = stamper.update();
    await (db.update(db.members)..where((t) => t.id.equals(id))).write(
        MembersCompanion(
            name: Value(n),
            nameKey: const Value(null),
            role: Value(role),
            avatar: Value(avatar),
            updatedAt: Value(s.updatedAt),
            deviceId: Value(s.deviceId)));
  }

  /// FR-026: move the member's transactions and recurring items to Whole
  /// family (member_id = NULL), then tombstone — one database transaction.
  Future<void> remove(String id) => db.transaction(() async {
        final txs = await (db.select(db.transactions)
              ..where((t) => t.memberId.equals(id)))
            .get();
        for (final t in txs) {
          final s = stamper.update();
          await (db.update(db.transactions)..where((x) => x.id.equals(t.id)))
              .write(TransactionsCompanion(
                  memberId: const Value(null),
                  updatedAt: Value(s.updatedAt),
                  deviceId: Value(s.deviceId)));
        }
        final recs = await (db.select(db.recurringItems)
              ..where((t) => t.memberId.equals(id)))
            .get();
        for (final r in recs) {
          final s = stamper.update();
          await (db.update(db.recurringItems)..where((x) => x.id.equals(r.id)))
              .write(RecurringItemsCompanion(
                  memberId: const Value(null),
                  updatedAt: Value(s.updatedAt),
                  deviceId: Value(s.deviceId)));
        }
        await softDelete(db.members, id);
      });
}
