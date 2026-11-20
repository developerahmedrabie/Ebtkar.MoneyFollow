import 'package:drift/native.dart';
import 'package:money_follow/core/time/hlc.dart';
import 'package:money_follow/data/db/app_database.dart';
import 'package:money_follow/data/family_data.dart';
import 'package:money_follow/data/repositories/base_repository.dart';
import 'package:money_follow/data/repositories/categories_repository.dart';
import 'package:money_follow/data/repositories/rates_repository.dart';
import 'package:money_follow/data/repositories/settings_repository.dart';
import 'package:money_follow/data/repositories/transactions_repository.dart';

/// Repositories over an in-memory database, with a controllable clock.
class TestRepos {
  TestRepos([AppDatabase? database])
      : db = database ?? AppDatabase(NativeDatabase.memory()) {
    stamper = Stamper(
        deviceId: 'dev',
        hlc: Hlc(deviceId: 'dev', wallClock: () => clock),
        clock: () => clock);
    settings = SettingsRepository(db, stamper);
    rates = RatesRepository(db, stamper, settings);
    categories = CategoriesRepository(db, stamper);
    transactions = TransactionsRepository(db, stamper, settings,
        categoryType: categories.typeOf);
  }

  final AppDatabase db;
  int clock = 1000;
  late final Stamper stamper;
  late final SettingsRepository settings;
  late final RatesRepository rates;
  late final CategoriesRepository categories;
  late final TransactionsRepository transactions;

  Future<FamilyData> data() => FamilyData.load(db);

  void tick([int ms = 1]) => clock += ms;
}
