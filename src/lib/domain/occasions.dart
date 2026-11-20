import 'dart:math' as math;

import 'package:hijri/hijri_calendar.dart';

import '../core/time/dates.dart';
import '../data/db/app_database.dart';
import '../data/family_data.dart';
import 'builtin_occasions.dart';
import 'monthly_totals.dart';

/// A built-in or custom occasion as shown in the app.
class OccasionInfo {
  const OccasionInfo({
    required this.key,
    required this.source,
    required this.days,
    required this.icon,
    required this.color,
    this.customName,
    this.def,
    this.monthDay,
  });

  final String key;
  final OccasionSource source;
  final int days;
  final String icon;
  final String color;
  final String? customName;
  final OccasionDef? def;
  final String? monthDay;

  bool get isCustom => def == null;
}

/// One past occurrence and what was spent on it (prototype `evHistory`).
class OccasionHistory {
  OccasionHistory(this.date);
  final String date;
  int total = 0;
  final Map<String, int> byCategory = {};
  final Map<String, int> byMember = {};
  final List<TxRow> transactions = [];
}

class OccasionPrediction {
  const OccasionPrediction(this.total, this.last, this.history, this.growth);

  /// Expected spending, main-currency minor units.
  final int total;
  final OccasionHistory? last;
  final List<OccasionHistory> history;

  /// Average year-over-year change, clamped to 0.85–1.5.
  final double growth;

  /// Per-category expectation, scaled by expected ÷ last.
  Map<String, int> get expectedByCategory {
    final l = last;
    if (l == null || l.total == 0) return const {};
    final k = total / l.total;
    return l.byCategory.map((c, v) => MapEntry(c, (v * k).round()));
  }
}

/// All occasion rules for one data snapshot (REQUIREMENTS §6.3, §6.4).
class OccasionService {
  OccasionService(this.d, this.today);

  final FamilyData d;
  final String today;

  late final Map<String, OccasionRow> _rows = {
    for (final o in d.occasions) o.key: o,
  };

  /// Built-ins available in the country, then custom occasions.
  late final List<OccasionInfo> all = [
    for (final b in builtinOccasions)
      if (b.availableIn(d.country))
        OccasionInfo(
            key: b.key,
            source: b.source,
            days: b.days,
            icon: b.icon,
            color: b.color,
            def: b,
            monthDay: b.monthDay),
    for (final o in d.occasions)
      if (!isBuiltinOccasion(o.key) && o.customMonthDay != null)
        OccasionInfo(
            key: o.key,
            source: OccasionSource.custom,
            days: o.days ?? 1,
            icon: o.icon ?? '📅',
            color: o.color ?? '#2563eb',
            customName: o.customName,
            monthDay: o.customMonthDay),
  ];

  late final Map<String, OccasionInfo> byKey = {for (final o in all) o.key: o};

  bool isEnabled(String key) =>
      byKey.containsKey(key) && (_rows[key]?.enabled ?? true);

  /// Enabled occasions (prototype `evIds`).
  List<String> get enabledKeys =>
      [for (final o in all) if (isEnabled(o.key)) o.key];

  int get _thisYear => LocalDate.yearOf(today);

  /// Effective start dates (start_date + adjust_days), sorted
  /// (prototype `evDates`).
  List<String> dates(String key) => _dates[key] ??= _computeDates(key);
  final Map<String, List<String>> _dates = {};

  List<String> _computeDates(String key) {
    final o = byKey[key];
    if (o == null) return const [];
    final years = [for (var y = _thisYear - 3; y <= _thisYear + 2; y++) y];
    final rows = d.occasionDates.where((r) => r.occasionKey == key).toList();
    final adjust = {
      for (final r in rows)
        if (r.country == d.country) r.year: r.adjustDays,
    };
    String eff(String date, int year) =>
        LocalDate.addDays(date, adjust[year] ?? 0);

    List<String> fromRows(Iterable<OccasionDate> rs) {
      final byYear = <int, OccasionDate>{};
      for (final r in rs) {
        // prefer the current country's row for each year
        final prev = byYear[r.year];
        if (prev == null || (prev.country != d.country && r.country == d.country)) {
          byYear[r.year] = r;
        }
      }
      return [for (final r in byYear.values) eff(r.startDate, r.year)]..sort();
    }

    switch (o.source) {
      case OccasionSource.hijri:
        final out = fromRows(rows);
        // Years with no stored row: compute from the Umm al-Qura tables.
        for (final y in years) {
          if (!out.any((x) => LocalDate.yearOf(x) == y)) {
            for (final g in _hijriInYear(o.def!.hijriMonth!, o.def!.hijriDay!, y)) {
              out.add(eff(g, y));
            }
          }
        }
        return out..sort();
      case OccasionSource.holiday:
        final datesCountry = d.settings[SettingKeys.occasionDatesCountry] ?? 'EG';
        final mine = rows.where((r) => r.country == d.country);
        if (datesCountry == d.country && mine.isNotEmpty) return fromRows(mine);
        final md = o.def!.fallbackMonthDay(d.country);
        if (md == null) return const [];
        return [for (final y in years) eff('$y-$md', y)];
      case OccasionSource.fixed:
      case OccasionSource.custom:
        final md = o.monthDay!;
        return [
          for (final y in years)
            eff(LocalDate.clampedDate(y, int.parse(md.substring(0, 2)),
                int.parse(md.substring(3, 5))), y),
        ];
    }
  }

  static List<String> _hijriInYear(int month, int day, int year) {
    final out = <String>[];
    for (var hy = year - 580; hy <= year - 577; hy++) {
      try {
        final g = HijriCalendar().hijriToGregorian(hy, month, day);
        if (g.year == year) {
          out.add(LocalDate.format(DateTime.utc(g.year, g.month, g.day)));
        }
      } catch (_) {}
    }
    return out;
  }

  /// First start date whose last day is today or later (prototype `nextOcc`).
  String? nextOccurrence(String key) {
    final days = byKey[key]?.days ?? 1;
    for (final x in dates(key)) {
      if (LocalDate.addDays(x, days - 1).compareTo(today) >= 0) return x;
    }
    return null;
  }

  bool isHappening(String key) {
    final n = nextOccurrence(key);
    return n != null && n.compareTo(today) <= 0;
  }

  static String? _nearest(List<String> list, String date) {
    String? best;
    var bd = 1 << 30;
    for (final o in list) {
      final k = LocalDate.daysBetween(o, date).abs();
      if (k < bd) {
        bd = k;
        best = o;
      }
    }
    return best;
  }

  /// Spending per past occurrence from tagged expenses.
  List<OccasionHistory> history(String key, {String? memberKey}) {
    final occ = dates(key);
    if (occ.isEmpty) return const [];
    final by = <String, OccasionHistory>{};
    for (final t in d.transactions) {
      if (t.occasionId != key ||
          t.type != 'expense' ||
          !matchesMember(t.memberId, memberKey)) {
        continue;
      }
      final o = _nearest(occ, t.date)!;
      final v = d.txMain(t);
      final h = by[o] ??= OccasionHistory(o);
      h.total += v;
      h.byCategory[t.categoryId] = (h.byCategory[t.categoryId] ?? 0) + v;
      final mk = t.memberId ?? '';
      h.byMember[mk] = (h.byMember[mk] ?? 0) + v;
      h.transactions.add(t);
    }
    return by.values.toList()..sort((a, b) => a.date.compareTo(b.date));
  }

  final Map<String, OccasionPrediction> _pred = {};

  /// Expected = last × average year-over-year change of the last 3
  /// occurrences, clamped 0.85–1.5 (prototype `predict`).
  OccasionPrediction predict(String key, {String? memberKey}) =>
      _pred['$key|${memberKey ?? '*'}'] ??= _predict(key, memberKey);

  OccasionPrediction _predict(String key, String? memberKey) {
    final nxt = nextOccurrence(key);
    var hist = history(key, memberKey: memberKey)
        .where((o) => nxt == null || o.date.compareTo(nxt) < 0)
        .toList();
    if (hist.length > 3) hist = hist.sublist(hist.length - 3);
    var g = 1.0;
    if (hist.length > 1) {
      final r = <double>[];
      for (var i = 1; i < hist.length; i++) {
        if (hist[i - 1].total > 0) r.add(hist[i].total / hist[i - 1].total);
      }
      if (r.isNotEmpty) {
        g = math.min(1.5, math.max(.85, r.reduce((a, b) => a + b) / r.length));
      }
    }
    final last = hist.isEmpty ? null : hist.last;
    return OccasionPrediction(
        last == null ? 0 : (last.total * g).round(), last, hist, g);
  }

  /// Occasion to pre-select for an expense on [date]: from 14 days before
  /// the start to its last day, closest wins (prototype `suggestEv`, §6.4).
  String? suggest(String date) {
    String? best;
    var bd = 1 << 30;
    for (final key in enabledKeys) {
      final o = _nearest(dates(key), date);
      if (o == null) continue;
      final k = LocalDate.daysBetween(o, date);
      if (k >= -14 && k <= byKey[key]!.days - 1 && k.abs() < bd) {
        bd = k.abs();
        best = key;
      }
    }
    return best;
  }

  /// "Put aside {v} a month": expected ÷ months until the occasion (≥ 1).
  int putAsidePerMonth(String key, {String? memberKey}) {
    final n = nextOccurrence(key);
    final p = predict(key, memberKey: memberKey).total;
    if (n == null) return p;
    final months = (LocalDate.yearOf(n) - LocalDate.yearOf(today)) * 12 +
        LocalDate.monthNumberOf(n) -
        LocalDate.monthNumberOf(today);
    return (p / math.max(1, months)).round();
  }

  /// Upcoming occurrences of enabled occasions within 12 months, soonest
  /// first.
  List<(String key, String date)> upcoming({int months = 12}) {
    final limit = LocalDate.addDays(today, months * 30 + 5);
    final out = <(String, String)>[];
    for (final k in enabledKeys) {
      final n = nextOccurrence(k);
      if (n != null && n.compareTo(limit) <= 0) out.add((k, n));
    }
    out.sort((a, b) => a.$2.compareTo(b.$2));
    return out;
  }
}

/// Hijri date label, e.g. "1 Ramadan 1448" (Umm al-Qura).
String hijriLabel(String date, String lang) {
  final p = LocalDate.parse(date);
  HijriCalendar.setLocal(lang == 'ar' ? 'ar' : 'en');
  final h = HijriCalendar.fromDate(DateTime(p.year, p.month, p.day));
  final s = h.toFormat('dd MMMM yyyy');
  return s.replaceAllMapped(RegExp('[٠-٩]'),
      (m) => (m[0]!.codeUnitAt(0) - 0x0660).toString());
}
