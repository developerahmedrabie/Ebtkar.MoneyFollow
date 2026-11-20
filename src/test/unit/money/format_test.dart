import 'package:intl/date_symbol_data_local.dart';
import 'package:money_follow/core/money/currency.dart';
import 'package:money_follow/core/money/format.dart';
import 'package:test/test.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('ar');
    await initializeDateFormatting('en_US');
  });

  test('formatAmount groups, signs and isolates', () {
    expect(formatAmount(125050, Currency.egp, 'en'), '${lri}1,251$pdi EGP');
    expect(formatAmount(-125000, Currency.egp, 'ar'),
        '$lri${minusSign}1,250$pdi ج.م');
    expect(formatAmount(500, Currency.egp, 'en', sign: true),
        '$lri+5$pdi EGP');
  });

  test('formatExact keeps needed decimals only', () {
    expect(formatExact(599, Currency.usd), '5.99');
    expect(formatExact(25000, Currency.egp), '250');
    expect(formatExact(3125, Currency.kwd), '3.125');
    expect(formatExact(3100, Currency.kwd), '3.1');
  });

  test('formatSignedCell shows a foreign currency label', () {
    expect(formatSignedCell(false, 599, Currency.usd, Currency.egp, 'en'),
        '$lri${minusSign}5.99$pdi USD');
    expect(formatSignedCell(true, 25000, Currency.egp, Currency.egp, 'en'),
        '$lri+250$pdi');
  });

  test('shortAmount', () {
    expect(shortAmount(120000, Currency.egp), '1.2k');
    expect(shortAmount(1250000, Currency.egp), '13k');
    expect(shortAmount(45000, Currency.egp), '450');
  });

  test('dates use Western digits in Arabic', () {
    final m = monthLabel('2026-11', 'ar');
    expect(m, contains('2026'));
    expect(m, isNot(contains('٢')));
    expect(monthLabel('2026-11', 'en'), 'Nov 2026');
    expect(dateShort('2026-11-13', 'en'), 'Nov 13');
    expect(dateShort('2026-11-13', 'ar'), contains('13'));
  });

  test('dayLabel', () {
    String f(String d) => dayLabel(d, '2026-11-13', 'en',
        todayText: 'Today', yesterdayText: 'Yesterday');
    expect(f('2026-11-13'), 'Today');
    expect(f('2026-11-12'), 'Yesterday');
    expect(f('2026-11-10'), 'Tue, Nov 10');
  });
}
