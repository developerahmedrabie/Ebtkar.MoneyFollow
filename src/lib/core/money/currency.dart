/// The 7 supported currencies (FR-012). Rates are micro-units of EGP
/// (value of 1 unit in EGP × 1,000,000), the reference currency.
enum Currency {
  egp(2, 'EGP', 'ج.م', 'Egyptian pound', 'جنيه مصري', 1000000),
  usd(2, 'USD', 'دولار', 'US dollar', 'دولار أمريكي', 50000000),
  eur(2, 'EUR', 'يورو', 'Euro', 'يورو', 54000000),
  sar(2, 'SAR', 'ر.س', 'Saudi riyal', 'ريال سعودي', 13300000),
  aed(2, 'AED', 'د.إ', 'UAE dirham', 'درهم إماراتي', 13600000),
  gbp(2, 'GBP', 'إسترليني', 'British pound', 'جنيه إسترليني', 63000000),
  kwd(3, 'KWD', 'د.ك', 'Kuwaiti dinar', 'دينار كويتي', 162000000);

  const Currency(this.decimals, this.labelEn, this.labelAr, this.nameEn,
      this.nameAr, this.defaultRateMicros);

  final int decimals;
  final String labelEn;
  final String labelAr;
  final String nameEn;
  final String nameAr;
  final int defaultRateMicros;

  /// ISO code, e.g. `EGP`.
  String get code => labelEn;

  /// 10^decimals.
  int get scale => decimals == 3 ? 1000 : 100;

  String label(String lang) => lang == 'ar' ? labelAr : labelEn;
  String fullName(String lang) => lang == 'ar' ? nameAr : nameEn;

  static Currency fromCode(String code) => Currency.values.firstWhere(
      (c) => c.code == code,
      orElse: () => throw ArgumentError('Unknown currency $code'));

  static Map<String, int> get defaultRates =>
      {for (final c in Currency.values) c.code: c.defaultRateMicros};
}
