/// Built-in yearly occasions (prototype `EVENTS`, `COUNTRIES`, `BUNDLED_EV`).
library;

enum OccasionSource { hijri, holiday, fixed, custom }

class OccasionDef {
  const OccasionDef({
    required this.key,
    required this.source,
    required this.days,
    required this.icon,
    required this.color,
    this.hijriMonth,
    this.hijriDay,
    this.holidayPattern,
    this.monthDay,
    this.countries,
  });

  final String key;
  final OccasionSource source;
  final int days;
  final String icon;
  final String color;
  final int? hijriMonth;
  final int? hijriDay;

  /// Regex matched against the Nager.Date holiday `name`.
  final String? holidayPattern;

  /// `MM-DD` for fixed occasions.
  final String? monthDay;

  /// null = every country.
  final List<String>? countries;

  bool availableIn(String country) =>
      countries == null || countries!.contains(country);

  /// Fixed date used when there is no holiday data (prototype `fb`).
  String? fallbackMonthDay(String country) {
    if (monthDay != null) return monthDay;
    if (key == 'xmas') return country == 'EG' ? '01-07' : '12-25';
    return null;
  }

  RegExp? get holidayRegExp =>
      holidayPattern == null ? null : RegExp(holidayPattern!);
}

const builtinOccasions = <OccasionDef>[
  OccasionDef(key: 'ramadan', source: OccasionSource.hijri, hijriMonth: 9, hijriDay: 1, days: 30, icon: '🌙', color: '#7c3aed'),
  OccasionDef(key: 'eid_fitr', source: OccasionSource.hijri, hijriMonth: 10, hijriDay: 1, days: 3, icon: '🍪', color: '#16a34a'),
  OccasionDef(key: 'eid_adha', source: OccasionSource.hijri, hijriMonth: 12, hijriDay: 10, days: 4, icon: '🐑', color: '#b45309'),
  OccasionDef(key: 'xmas', source: OccasionSource.holiday, holidayPattern: r'^Christmas Day', days: 1, icon: '🎄', color: '#dc2626'),
  OccasionDef(key: 'new_year', source: OccasionSource.fixed, monthDay: '12-31', days: 1, icon: '🎆', color: '#0ea5e9'),
  OccasionDef(key: 'sham', source: OccasionSource.holiday, holidayPattern: r'Easter Monday', countries: ['EG'], days: 1, icon: '🌸', color: '#65a30d'),
  OccasionDef(key: 'mothers', source: OccasionSource.fixed, monthDay: '03-21', countries: ['EG', 'SA', 'AE', 'KW'], days: 1, icon: '💐', color: '#db2777'),
  OccasionDef(key: 'school', source: OccasionSource.fixed, monthDay: '09-15', days: 7, icon: '🎒', color: '#2563eb'),
];

final Map<String, OccasionDef> builtinOccasionsByKey = {
  for (final o in builtinOccasions) o.key: o,
};

bool isBuiltinOccasion(String key) => builtinOccasionsByKey.containsKey(key);

const supportedCountries = <String>['EG', 'SA', 'AE', 'KW', 'US', 'GB'];

/// Egypt dates fetched from api.aladhan.com and date.nager.at on 2026-11-14;
/// used offline until the user taps Update.
const bundledEgyptOccasionDates = <String, List<String>>{
  'ramadan': ['2024-03-11', '2025-03-01', '2026-02-18', '2027-02-08'],
  'eid_fitr': ['2024-04-10', '2025-03-30', '2026-03-20', '2027-03-09'],
  'eid_adha': ['2024-06-16', '2025-06-06', '2026-05-27', '2027-05-16'],
  'xmas': ['2024-01-07', '2025-01-07', '2026-01-07', '2027-01-07'],
  'sham': ['2024-05-06', '2025-04-21', '2026-04-13', '2027-05-03'],
};
