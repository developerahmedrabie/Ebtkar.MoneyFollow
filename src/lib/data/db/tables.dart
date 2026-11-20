import 'package:drift/drift.dart';

/// Columns shared by every synced table (data-model "Conventions").
mixin SyncColumns on Table {
  /// UUID v7 (or a fixed id for seeded rows).
  TextColumn get id => text()();

  /// UTC milliseconds, set once.
  IntColumn get createdAt => integer()();

  /// HLC timestamp, set on every change.
  TextColumn get updatedAt => text()();
  TextColumn get deviceId => text()();
  BoolColumn get deleted => boolean().withDefault(const Constant(false))();
  BoolColumn get isSample => boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('Member')
class Members extends Table with SyncColumns {
  TextColumn get name => text().withLength(min: 0, max: 30)();
  TextColumn get nameKey => text().nullable()();
  TextColumn get role => text()();
  TextColumn get avatar => text()();
  TextColumn get color => text()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
}

/// User categories only; built-in ones are code constants.
@DataClassName('UserCategory')
class Categories extends Table with SyncColumns {
  TextColumn get type => text()();
  TextColumn get name => text().withLength(min: 1, max: 20)();
  TextColumn get icon => text()();
  TextColumn get color => text()();
}

@DataClassName('Account')
class Accounts extends Table with SyncColumns {
  TextColumn get key => text()();
  TextColumn get currency => text()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
}

@DataClassName('TxRow')
@TableIndex(name: 'tx_date', columns: {#date})
@TableIndex(name: 'tx_member_date', columns: {#memberId, #date})
@TableIndex(name: 'tx_category_date', columns: {#categoryId, #date})
@TableIndex(name: 'tx_occasion', columns: {#occasionId})
@TableIndex(name: 'tx_account', columns: {#accountId})
class Transactions extends Table with SyncColumns {
  TextColumn get type => text()();
  IntColumn get amountMinor => integer()();
  TextColumn get currency => text()();
  TextColumn get rateSnapshotId => text()();
  TextColumn get categoryId => text()();
  TextColumn get accountId => text()();
  TextColumn get memberId => text().nullable()();
  TextColumn get occasionId => text().nullable()();
  TextColumn get date => text()();
  TextColumn get note => text().withDefault(const Constant(''))();
  TextColumn get noteKey => text().nullable()();
  TextColumn get recurringId => text().nullable()();
}

@DataClassName('Transfer')
@TableIndex(name: 'transfer_date', columns: {#date})
class Transfers extends Table with SyncColumns {
  TextColumn get fromAccountId => text()();
  TextColumn get toAccountId => text()();
  IntColumn get amountOutMinor => integer()();
  IntColumn get amountInMinor => integer()();
  TextColumn get rateSnapshotId => text()();
  TextColumn get date => text()();
  TextColumn get note => text().withDefault(const Constant(''))();
}

@DataClassName('RecurringItem')
class RecurringItems extends Table with SyncColumns {
  TextColumn get type => text()();
  IntColumn get amountMinor => integer()();
  TextColumn get currency => text()();
  TextColumn get categoryId => text()();
  TextColumn get accountId => text()();
  TextColumn get memberId => text().nullable()();
  TextColumn get name => text().withDefault(const Constant(''))();
  TextColumn get nameKey => text().nullable()();
  TextColumn get frequency => text()();
  TextColumn get nextDue => text()();
  IntColumn get dayOfMonth => integer()();
}

@DataClassName('Budget')
class Budgets extends Table with SyncColumns {
  TextColumn get categoryId => text()();
  IntColumn get limitMinor => integer()();
}

@DataClassName('RateSnapshot')
class RateSnapshots extends Table with SyncColumns {
  /// `{"EGP":1000000,"USD":50000000,…}` micro-units of EGP.
  TextColumn get ratesJson => text()();
}

/// Custom occasions plus per-occasion settings for built-in ones.
/// `id` equals `key`.
@DataClassName('OccasionRow')
class Occasions extends Table with SyncColumns {
  TextColumn get key => text()();
  BoolColumn get enabled => boolean().withDefault(const Constant(true))();
  TextColumn get customName => text().nullable()();
  TextColumn get icon => text().nullable()();
  TextColumn get color => text().nullable()();
  TextColumn get customMonthDay => text().nullable()();
  IntColumn get days => integer().nullable()();
}

/// `id` = `<occasion_key>|<year>|<country>` so devices agree.
@DataClassName('OccasionDate')
class OccasionDates extends Table with SyncColumns {
  TextColumn get occasionKey => text()();
  IntColumn get year => integer()();
  TextColumn get startDate => text()();
  TextColumn get source => text()();
  TextColumn get country => text()();
  IntColumn get adjustDays => integer().withDefault(const Constant(0))();

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
        {occasionKey, year, country},
      ];
}

/// Synced family settings; `id` is the setting key.
@DataClassName('SettingRow')
class Settings extends Table with SyncColumns {
  TextColumn get value => text()();
}

@DataClassName('OutboxEntry')
class SyncOutbox extends Table {
  IntColumn get seq => integer().autoIncrement()();
  TextColumn get tableName_ => text().named('table_name')();
  TextColumn get rowId => text()();
  TextColumn get op => text()();
  TextColumn get payloadJson => text()();
  TextColumn get hlc => text()();
}

@DataClassName('SyncStateRow')
class SyncState extends Table {
  TextColumn get peerDeviceId => text()();
  IntColumn get lastSeqSeen => integer().withDefault(const Constant(0))();
  IntColumn get lastSyncAt => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {peerDeviceId};
}

@DataClassName('DeviceRow')
class Devices extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get platform => text()();
  IntColumn get lastSeenAt => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
