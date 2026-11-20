import '../core/money/currency.dart';

/// An immutable set of exchange rates: micro-units of EGP per 1 unit.
class Rates {
  const Rates(this.id, this.micros);

  final String id;
  final Map<String, int> micros;

  int of(String code) =>
      micros[code] ?? Currency.fromCode(code).defaultRateMicros;

  /// "1 [cur] = X [main]" as micro-units of [main].
  int valueInMainMicros(String cur, String main) =>
      _divRound(BigInt.from(of(cur)) * BigInt.from(1000000),
              BigInt.from(of(main)))
          .toInt();

  Rates withRate(String newId, String code, int microsEgp) =>
      Rates(newId, {...micros, code: microsEgp});

  static Rates defaults([String id = 'rates-default']) =>
      Rates(id, Currency.defaultRates);
}

/// `value_M = amount × rates[cur] / rates[M]` (data-model "Rate snapshot"),
/// converting minor units and rounding half away from zero to the main
/// currency's decimals.
int toMain(int amountMinor, String currency, Rates rates, String main) {
  if (currency == main) return amountMinor;
  final from = Currency.fromCode(currency);
  final to = Currency.fromCode(main);
  final num = BigInt.from(amountMinor) *
      BigInt.from(rates.of(currency)) *
      BigInt.from(to.scale);
  final den = BigInt.from(rates.of(main)) * BigInt.from(from.scale);
  return _divRound(num, den).toInt();
}

/// Converts with the given (usually current) rates between any currencies.
int convert(int amountMinor, String from, String to, Rates rates) =>
    toMain(amountMinor, from, rates, to);

BigInt _divRound(BigInt num, BigInt den) {
  final neg = num.isNegative != den.isNegative;
  final n = num.abs();
  final d = den.abs();
  final q = (n * BigInt.two + d) ~/ (d * BigInt.two);
  return neg ? -q : q;
}

/// A row that can be converted with its own snapshot (FR-016).
abstract interface class HasAmount {
  int get amountMinor;
  String get currency;
  String get rateSnapshotId;
}

/// Looks up snapshots by id; falls back to [current] for unknown ids.
class RatesBook {
  RatesBook(this.current, Map<String, Rates> byId)
      : _byId = {...byId, current.id: current};

  final Rates current;
  final Map<String, Rates> _byId;

  Rates byId(String id) => _byId[id] ?? current;

  /// Amount in [main] using the row's own snapshot.
  int rowToMain(int amountMinor, String currency, String snapshotId,
          String main) =>
      toMain(amountMinor, currency, byId(snapshotId), main);

  /// Amount in [main] using the current snapshot (forecasts, "≈").
  int currentToMain(int amountMinor, String currency, String main) =>
      toMain(amountMinor, currency, current, main);
}
