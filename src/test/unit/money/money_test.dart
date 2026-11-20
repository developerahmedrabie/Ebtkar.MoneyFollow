import 'package:money_follow/core/money/currency.dart';
import 'package:money_follow/core/money/money.dart';
import 'package:test/test.dart';

void main() {
  group('Money.fromDecimalString', () {
    test('parses grouping and one decimal', () {
      final m = Money.fromDecimalString('1,250.5', Currency.egp);
      expect(m.minor, 125050);
      expect(m.toDecimalString(), '1250.50');
    });

    test('KWD uses 3 decimals', () {
      final m = Money.fromDecimalString('3.125', Currency.kwd);
      expect(m.minor, 3125);
      expect(m.toDecimalString(), '3.125');
      expect(() => Money.fromDecimalString('1.1234', Currency.kwd),
          throwsFormatException);
    });

    test('rejects 0 and negatives', () {
      expect(() => Money.fromDecimalString('0', Currency.egp),
          throwsFormatException);
      expect(() => Money.fromDecimalString('-5', Currency.egp),
          throwsFormatException);
      expect(Money.tryParse('0.00', Currency.usd), isNull);
    });

    test('accepts Arabic digits and decimal separator', () {
      expect(Money.fromDecimalString('١٢٥٠٫٥', Currency.egp).minor, 125050);
    });

    test('rejects text and too many decimals', () {
      expect(Money.tryParse('abc', Currency.egp), isNull);
      expect(Money.tryParse('5.999', Currency.usd), isNull);
      expect(Money.tryParse('5.990', Currency.usd)?.minor, 599);
    });
  });

  test('arithmetic and comparison', () {
    const a = Money(1000, Currency.egp);
    const b = Money(250, Currency.egp);
    expect((a - b).minor, 750);
    expect((a + b).minor, 1250);
    expect(a > b, isTrue);
    expect(() => a + const Money(1, Currency.usd), throwsArgumentError);
  });
}
