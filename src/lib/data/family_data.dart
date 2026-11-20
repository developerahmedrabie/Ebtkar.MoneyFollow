import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';

import '../core/money/currency.dart';
import '../domain/conversion.dart';
import 'db/app_database.dart';

/// An immutable snapshot of all live (not deleted) family data. Domain
/// services compute every derived value from it (data-model "Derived
/// values"), exactly like the prototype computes from `state`.
class FamilyData {
  FamilyData({
    required this.transactions,
    required this.transfers,
    required this.recurring,
    required this.members,
    required this.userCategories,
    required this.budgets,
    required this.accounts,
    required this.rates,
    required this.mainCurrency,
    required this.country,
    required this.occasions,
    required this.occasionDates,
    required this.settings,
  });

  final List<TxRow> transactions;
  final List<Transfer> transfers;
  final List<RecurringItem> recurring;
  final List<Member> members;
  final List<UserCategory> userCategories;
  final List<Budget> budgets;
  final List<Account> accounts;
  final RatesBook rates;
  final String mainCurrency;
  final String country;
  final List<OccasionRow> occasions;
  final List<OccasionDate> occasionDates;
  final Map<String, String> settings;

  Currency get main => Currency.fromCode(mainCurrency);

  /// A transaction in the main currency using its own snapshot (FR-016).
  int txMain(TxRow t) =>
      rates.rowToMain(t.amountMinor, t.currency, t.rateSnapshotId, mainCurrency);

  /// Any amount in the main currency at the current rates (FR-014).
  int currentMain(int amountMinor, String currency) =>
      rates.currentToMain(amountMinor, currency, mainCurrency);

  late final Map<String, Member> membersById = {
    for (final m in members) m.id: m,
  };

  late final Map<String, List<TxRow>> _byMonth = () {
    final out = <String, List<TxRow>>{};
    for (final t in transactions) {
      (out[t.date.substring(0, 7)] ??= []).add(t);
    }
    return out;
  }();

  /// Transactions of a `YYYY-MM` month (prototype `inMonth`).
  List<TxRow> inMonth(String ym) => _byMonth[ym] ?? const [];

  static Future<FamilyData> load(AppDatabase db) async {
    Future<List<T>> live<T extends Object>(
        TableInfo<Table, T> t) async {
      final rows = await (db.select(t)
            ..where((tbl) => (tbl as SyncColumns).deleted.equals(false)))
          .get();
      return rows;
    }

    final settingsRows = await live(db.settings);
    final settings = {for (final s in settingsRows) s.id: s.value};
    final snaps = await db.select(db.rateSnapshots).get();
    Rates toRates(RateSnapshot s) => Rates(
        s.id,
        (jsonDecode(s.ratesJson) as Map<String, dynamic>)
            .map((k, v) => MapEntry(k, (v as num).toInt())));
    final byId = {for (final s in snaps) s.id: toRates(s)};
    final currentId =
        settings[SettingKeys.currentRateSnapshotId] ?? defaultRateSnapshotId;
    final current = byId[currentId] ?? Rates.defaults();

    final txs = await (db.select(db.transactions)
          ..where((t) => t.deleted.equals(false))
          ..orderBy([
            (t) => OrderingTerm.desc(t.date),
            (t) => OrderingTerm.desc(t.createdAt),
            (t) => OrderingTerm.desc(t.id),
          ]))
        .get();
    final members = await (db.select(db.members)
          ..where((t) => t.deleted.equals(false))
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .get();

    return FamilyData(
      transactions: txs,
      transfers: await live(db.transfers),
      recurring: await live(db.recurringItems),
      members: members,
      userCategories: await live(db.categories),
      budgets: await live(db.budgets),
      accounts: await (db.select(db.accounts)
            ..where((t) => t.deleted.equals(false))
            ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
          .get(),
      rates: RatesBook(current, byId),
      mainCurrency: settings[SettingKeys.mainCurrency] ?? 'EGP',
      country: settings[SettingKeys.country] ?? 'EG',
      occasions: await live(db.occasions),
      occasionDates: await live(db.occasionDates),
      settings: settings,
    );
  }

  /// Reloads whenever any family table changes.
  static Stream<FamilyData> watch(AppDatabase db) {
    final tables = db.syncedTables;
    late StreamController<FamilyData> c;
    StreamSubscription<Set<TableUpdate>>? sub;
    var loading = false, again = false;
    Future<void> reload() async {
      if (loading) {
        again = true;
        return;
      }
      loading = true;
      do {
        again = false;
        try {
          final d = await load(db);
          if (!c.isClosed) c.add(d);
        } catch (e, s) {
          if (!c.isClosed) c.addError(e, s);
        }
      } while (again);
      loading = false;
    }

    c = StreamController<FamilyData>(
      onListen: () {
        reload();
        sub = db
            .tableUpdates(TableUpdateQuery.onAllTables(tables))
            .listen((_) => reload());
      },
      onCancel: () => sub?.cancel(),
    );
    return c.stream;
  }
}
