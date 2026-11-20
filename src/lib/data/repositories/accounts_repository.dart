import 'package:drift/drift.dart';

import '../db/app_database.dart';
import 'base_repository.dart';

export '../../domain/balances.dart' show AccountBalance, accountBalances, totalInMain;

/// The 4 fixed accounts (FR-011). Balances are derived in
/// `domain/balances.dart` from the [FamilyData] snapshot.
class AccountsRepository extends BaseRepository {
  AccountsRepository(super.db, super.stamper);

  Future<List<Account>> list() => (db.select(db.accounts)
        ..where(notDeleted)
        ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
      .get();
}
