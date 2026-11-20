import 'package:drift/native.dart';
import 'package:money_follow/data/db/app_database.dart';
import 'package:money_follow/data/repositories/base_repository.dart';
import 'package:money_follow/data/repositories/rates_repository.dart';
import 'package:money_follow/data/repositories/settings_repository.dart';
import 'package:money_follow/domain/conversion.dart';
import 'package:test/test.dart';

void main() {
  group('toMain', () {
    final r = Rates.defaults();

    test('100 USD at 50 = 5,000 EGP', () {
      expect(toMain(10000, 'USD', r, 'EGP'), 500000);
    });

    test('5.99 USD = 299.50 EGP', () {
      expect(toMain(599, 'USD', r, 'EGP'), 29950);
    });

    test('KWD rounding to 3 decimals', () {
      // 100 EGP / 162 = 0.617283... KWD -> 0.617
      expect(toMain(10000, 'EGP', r, 'KWD'), 617);
      // 1 KWD = 162 EGP
      expect(toMain(1000, 'KWD', r, 'EGP'), 16200);
    });

    test('same currency is unchanged', () {
      expect(toMain(12345, 'EGP', r, 'EGP'), 12345);
    });
  });

  group('snapshots (FR-014, FR-016)', () {
    late AppDatabase db;
    late RatesRepository rates;
    late SettingsRepository settings;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      final st = Stamper(deviceId: 'dev');
      settings = SettingsRepository(db, st);
      rates = RatesRepository(db, st, settings);
    });
    tearDown(() => db.close());

    test('past rows keep their own snapshot after a rate change', () async {
      final s1 = await rates.currentSnapshot();
      // 100 USD recorded under S1 (USD = 50)
      const amount = 10000;
      final s2 = await rates.updateRate('USD', 52000000); // 1 USD = 52 EGP
      expect(s2.id, isNot(s1.id));
      final book = await rates.book();
      expect(book.current.id, s2.id);
      expect(book.rowToMain(amount, 'USD', s1.id, 'EGP'), 500000);
      // a new 100 USD row under S2 = 5,200
      expect(book.rowToMain(amount, 'USD', s2.id, 'EGP'), 520000);
      // forecasts use the current rate
      expect(book.currentToMain(amount, 'USD', 'EGP'), 520000);
    });

    test('changing main currency to USD converts past rows with their snapshot',
        () async {
      final s1 = await rates.currentSnapshot();
      await rates.updateRate('USD', 52000000);
      final book = await rates.book();
      // 5,000 EGP recorded under S1 is 100 USD, not 96.15
      expect(book.rowToMain(500000, 'EGP', s1.id, 'USD'), 10000);
      expect(book.currentToMain(520000, 'EGP', 'USD'), 10000);
    });

    test('rate must be > 0', () async {
      expect(() => rates.updateRate('USD', 0),
          throwsA(isA<ValidationException>()));
    });

    test('rate expressed in a non-EGP main currency', () async {
      await settings.write(SettingKeys.mainCurrency, 'USD');
      // 1 EUR = 1.1 USD
      final r = await rates.updateRate('EUR', 1100000);
      expect(r.valueInMainMicros('EUR', 'USD'), 1100000);
      expect(toMain(10000, 'EUR', r, 'USD'), 11000);
    });
  });
}
