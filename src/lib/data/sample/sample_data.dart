import 'package:drift/drift.dart';
import 'package:hijri/hijri_calendar.dart';

import '../../core/time/dates.dart';
import '../../core/time/hlc.dart';
import '../../domain/builtin_categories.dart';
import '../../domain/builtin_occasions.dart';
import '../db/app_database.dart';

/// Deterministic sample family, a port of the prototype's `demo()`.
///
/// Every random draw happens in the same order as the prototype, so with
/// anchor 2026-11-13 the numbers match the prototype exactly.
class SampleData {
  SampleData._(this.anchor);

  final String anchor;
  final members = <MembersCompanion>[];
  final recurring = <RecurringItemsCompanion>[];
  final transactions = <TransactionsCompanion>[];
  final budgets = <BudgetsCompanion>[];

  static final _hlc = Hlc.format(0, 0, 'sample');
  static const memberIds = [
    'sample-mem-1',
    'sample-mem-2',
    'sample-mem-3',
    'sample-mem-4'
  ];
  static String recId(int n) => 'sample-rec-$n';

  int _s = 11;
  double _r() {
    _s = (_s * 16807) % 2147483647;
    return _s / 2147483647;
  }

  int _round(double x) => (x + 0.5).floor();
  int _rnd(double a, double b) => _round((a + _r() * (b - a)) / 5) * 5;
  T _pick<T>(List<T> a) => a[(_r() * a.length).floor()];

  int _txId = 1;
  int _createdAt = 0;

  void _add(String type, String cat, num amount, String date, String nk,
      {String? acc,
      String cur = 'EGP',
      int? rec,
      String? mem,
      String? ev}) {
    final account = acc ?? _pick<String>(const ['cash', 'bank', 'card']);
    final scale = cur == 'KWD' ? 1000 : 100;
    transactions.add(TransactionsCompanion.insert(
      id: 'sample-tx-${_txId++}',
      createdAt: _createdAt,
      updatedAt: _hlc,
      deviceId: 'sample',
      isSample: const Value(true),
      type: type,
      amountMinor: (amount * scale).round(),
      currency: cur,
      rateSnapshotId: defaultRateSnapshotId,
      categoryId: cat,
      accountId: accountIdForKey(account),
      memberId: Value(mem),
      occasionId: Value(ev),
      date: date,
      noteKey: Value(nk),
      recurringId: Value(rec == null ? null : recId(rec)),
    ));
  }

  /// Builds the data set for [anchorDate] (`YYYY-MM-DD`, usually today).
  static SampleData generate(String anchorDate, {int? createdAt}) {
    final s = SampleData._(anchorDate)
      .._createdAt = createdAt ?? DateTime.now().millisecondsSinceEpoch;
    s._build();
    return s;
  }

  void _build() {
    final ay = LocalDate.yearOf(anchor);
    final am = LocalDate.monthNumberOf(anchor);
    final ad = LocalDate.dayOf(anchor);
    final dad = memberIds[0], mom = memberIds[1];
    final omar = memberIds[2], mariam = memberIds[3];
    final inf = {ay - 2: .72, ay - 1: .86, ay: 1.0};
    String pad(int n) => n.toString().padLeft(2, '0');

    for (var y = ay - 2; y <= ay; y++) {
      for (var m = 1; m <= (y == ay ? am : 12); m++) {
        final f = inf[y]!;
        int k(num v) => _round(v * f / 50) * 50;
        int kr(num a, num b) => _rnd(a * f, b * f);
        final now = y == ay && m == am;
        final last = now ? ad : LocalDate.daysInMonth(y, m);
        String d(int n) => '$y-${pad(m)}-${pad(n < last ? n : last)}';
        String any() => d(1 + (_r() * last).floor());
        bool due(int n) => n <= last;

        _add('income', 'salary', k(32000), d(1), 'n_salary',
            acc: 'bank', rec: 1, mem: dad);
        if (_r() > .4) {
          final amt = _round((80 + _r() * 90) / 5) * 5;
          _add('income', 'freelance', amt, d(8 + (_r() * 15).floor()),
              'n_freelance',
              acc: 'usd', cur: 'USD', mem: mom);
        }
        if (y == ay && m == 9) {
          _add('income', 'gift', 500, d(18), 'n_gift', acc: 'bank', cur: 'SAR');
        }
        if (y == ay && m == 10) {
          _add('expense', 'education', 40, d(16), 'n_course',
              acc: 'usd', cur: 'USD', mem: mom);
        }
        _add('income', 'rental', k(4500), d(5), 'n_rental_in',
            acc: 'bank', rec: 15);
        _add('expense', 'rent', k(9000), d(3), 'n_rent', acc: 'bank', rec: 2);
        _add('expense', 'education', k(2500), d(5), 'n_school',
            acc: 'bank', rec: 3, mem: omar);
        _add('expense', 'education', k(1200), d(7), 'n_ballet',
            acc: 'cash', rec: 11, mem: mariam);
        for (final w in const [7, 14, 21, 28]) {
          if (due(w)) {
            _add('expense', 'other_e', k(200), d(w), 'n_pocket',
                acc: 'cash', rec: 14, mem: omar);
          }
        }
        if (due(10)) {
          _add('expense', 'utilities', kr(1250, 1750), d(10), 'n_power',
              acc: 'card', rec: 4);
        }
        if (due(12)) {
          _add('expense', 'bills', kr(500, 600), d(12), 'n_mobile',
              acc: 'card', rec: 5);
        }
        if (due(20)) {
          _add('expense', 'fun', 5.99, d(20), 'n_stream',
              acc: 'card', rec: 6, cur: 'USD');
        }
        if (due(22)) {
          _add('expense', 'fun', k(450), d(22), 'n_football',
              acc: 'cash', rec: 12, mem: omar);
        }
        if (due(28)) {
          _add('expense', 'other_e', k(2000), d(28), 'n_help',
              acc: 'cash', rec: 7);
        }
        if (m % 3 == 0) {
          _add('expense', 'health', k(3600), d(1), 'n_gym',
              acc: 'card', rec: 8, mem: mom);
        }
        if (m % 3 == 2 && due(25)) {
          _add('expense', 'utilities', k(450), d(25), 'n_filter',
              acc: 'cash', rec: 9);
        }
        if (m == 1) {
          _add('expense', 'education', k(6000), d(10), 'n_books',
              acc: 'bank', rec: 13, mem: mariam);
        }
        if (m == 2) {
          _add('expense', 'transport', k(6000), d(15), 'n_insurance',
              acc: 'bank', rec: 10, mem: dad);
        }
        final g = now ? 4 : 7 + (_r() * 3).floor();
        const groc = ['n_super', 'n_veg', 'n_bakery', 'n_weekly'];
        for (var i = 0; i < g; i++) {
          final a = kr(300, 1500);
          _add('expense', 'groceries', a, any(), groc[i % 4]);
        }
        const trans = ['n_fuel', 'n_taxi', 'n_metro'];
        for (var i = 0; i < (now ? 2 : 5); i++) {
          final a = kr(100, 450);
          final dt = any();
          _add('expense', 'transport', a, dt, trans[i % 3],
              mem: [dad, mom, omar][i % 3]);
        }
        const din = ['n_dinner', 'n_coffee', 'n_takeaway'];
        for (var i = 0; i < (now ? 2 : 3); i++) {
          final a = kr(250, 750);
          final dt = any();
          _add('expense', 'dining', a, dt, din[i % 3],
              mem: i % 3 == 1 ? dad : null);
        }
        if (_r() > .5) {
          final a = kr(200, 1200);
          final dt = any();
          final mem = _pick<String?>([mariam, omar, null]);
          _add('expense', 'health', a, dt, 'n_pharmacy', mem: mem);
        }
        // The prototype re-evaluates `1 + floor(r() * 2)` on every check.
        for (var i = 0; i < 1 + (_r() * 2).floor(); i++) {
          final a = kr(400, 2200);
          final dt = any();
          final mem = i.isOdd ? null : _pick([mom, omar, mariam]);
          _add('expense', 'shopping', a, dt, ['n_clothes', 'n_home'][i % 2],
              mem: mem);
        }
        if (_r() > .4) {
          final a = kr(200, 800);
          _add('expense', 'fun', a, any(), 'n_outing');
        }
      }
    }

    // Occasion spending: [days from the occasion, category, amount at
    // anchor-year prices, note, member].
    final evSpend = <String, List<(int, String, int, String, String?)>>{
      'ramadan': [(-5, 'groceries', 4500, 'n_ramadan_food', null), (-3, 'fun', 350, 'n_fanous', mariam), (10, 'dining', 1200, 'n_iftar', null), (20, 'dining', 1400, 'n_iftar', null), (27, 'other_e', 600, 'n_zakat', null)],
      'eid_fitr': [(-6, 'shopping', 1800, 'n_eid_clothes', omar), (-6, 'shopping', 1600, 'n_eid_clothes', mariam), (-5, 'shopping', 1500, 'n_eid_clothes', mom), (-4, 'groceries', 1100, 'n_kahk', null), (0, 'other_e', 1500, 'n_eidiya', null), (1, 'fun', 800, 'n_outing', null)],
      'eid_adha': [(-2, 'groceries', 11000, 'n_udhiya', null), (-5, 'shopping', 1400, 'n_eid_clothes', omar), (-5, 'shopping', 1300, 'n_eid_clothes', mariam), (0, 'other_e', 1000, 'n_eidiya', null), (1, 'fun', 900, 'n_outing', null)],
      'xmas': [(-3, 'shopping', 900, 'n_xmas_gifts', null)],
      'new_year': [(0, 'dining', 1500, 'n_ny_dinner', null)],
      'sham': [(-1, 'groceries', 900, 'n_fesikh', null), (0, 'fun', 700, 'n_outing', null)],
      'school': [(-7, 'shopping', 2200, 'n_uniform', omar), (-7, 'shopping', 1800, 'n_uniform', mariam), (-5, 'education', 1300, 'n_supplies', omar)],
      'mothers': [(-2, 'shopping', 800, 'n_mom_gift', mom)],
    };
    final minDate = '${ay - 2}-01-01';
    for (final MapEntry(key: ev, value: items) in evSpend.entries) {
      for (final o in _occurrences(ev, ay)) {
        final f = inf[LocalDate.yearOf(o)];
        if (f == null) continue;
        for (final (off, cat, amt, nk, mem) in items) {
          final dt = LocalDate.addDays(o, off);
          if (dt.compareTo(minDate) < 0 || dt.compareTo(anchor) > 0) continue;
          final a = _round(amt * f * (.9 + _r() * .2) / 10) * 10;
          final acc = _pick(const ['cash', 'card']);
          _add('expense', cat, a, dt, nk, acc: acc, mem: mem, ev: ev);
        }
      }
    }

    // Recurring items (next due computed from the anchor).
    String nextMonthly(int day) {
      final ym = day > ad
          ? LocalDate.monthOf(anchor)
          : LocalDate.shiftMonth(LocalDate.monthOf(anchor), 1);
      return LocalDate.clampedDate(LocalDate.yearOf('$ym-01'),
          LocalDate.monthNumberOf('$ym-01'), day);
    }

    String nextIn(bool Function(int month) monthOk, int day) {
      var ym = LocalDate.monthOf(anchor);
      for (var i = 0; i < 24; i++) {
        final y = int.parse(ym.substring(0, 4)), mo = int.parse(ym.substring(5));
        final date = LocalDate.clampedDate(y, mo, day);
        if (monthOk(mo) && date.compareTo(anchor) > 0) return date;
        ym = LocalDate.shiftMonth(ym, 1);
      }
      return anchor;
    }

    String nextWeekly() {
      for (final w in const [7, 14, 21, 28]) {
        if (w > ad) return LocalDate.clampedDate(ay, am, w);
      }
      final ym = LocalDate.shiftMonth(LocalDate.monthOf(anchor), 1);
      return '$ym-07';
    }

    void rec(int n, String type, String cat, num amount, String nk,
        String freq, String next, String acc,
        {String cur = 'EGP', String? mem}) {
      recurring.add(RecurringItemsCompanion.insert(
        id: recId(n),
        createdAt: _createdAt,
        updatedAt: _hlc,
        deviceId: 'sample',
        isSample: const Value(true),
        type: type,
        amountMinor: (amount * 100).round(),
        currency: cur,
        categoryId: cat,
        accountId: accountIdForKey(acc),
        memberId: Value(mem),
        nameKey: Value(nk),
        frequency: freq,
        nextDue: next,
        dayOfMonth: LocalDate.dayOf(next),
      ));
    }

    rec(1, 'income', 'salary', 32000, 'n_salary', 'monthly', nextMonthly(1), 'bank', mem: dad);
    rec(2, 'expense', 'rent', 9000, 'n_rent', 'monthly', nextMonthly(3), 'bank');
    rec(3, 'expense', 'education', 2500, 'n_school', 'monthly', nextMonthly(5), 'bank', mem: omar);
    rec(4, 'expense', 'utilities', 1500, 'n_power', 'monthly', nextMonthly(10), 'card');
    rec(5, 'expense', 'bills', 550, 'n_mobile', 'monthly', nextMonthly(12), 'card');
    rec(6, 'expense', 'fun', 5.99, 'n_stream', 'monthly', nextMonthly(20), 'card', cur: 'USD');
    rec(7, 'expense', 'other_e', 2000, 'n_help', 'monthly', nextMonthly(28), 'cash');
    rec(8, 'expense', 'health', 3600, 'n_gym', 'quarterly', nextIn((m) => m % 3 == 0, 1), 'card', mem: mom);
    rec(9, 'expense', 'utilities', 450, 'n_filter', 'quarterly', nextIn((m) => m % 3 == 2, 25), 'cash');
    rec(10, 'expense', 'transport', 6000, 'n_insurance', 'yearly', nextIn((m) => m == 2, 15), 'bank', mem: dad);
    rec(11, 'expense', 'education', 1200, 'n_ballet', 'monthly', nextMonthly(7), 'cash', mem: mariam);
    rec(12, 'expense', 'fun', 450, 'n_football', 'monthly', nextMonthly(22), 'cash', mem: omar);
    rec(13, 'expense', 'education', 6000, 'n_books', 'yearly', nextIn((m) => m == 1, 10), 'bank', mem: mariam);
    rec(14, 'expense', 'other_e', 200, 'n_pocket', 'weekly', nextWeekly(), 'cash', mem: omar);
    rec(15, 'income', 'rental', 4500, 'n_rental_in', 'monthly', nextMonthly(5), 'bank');

    const roles = ['parent', 'parent', 'child', 'child'];
    const avatars = ['👨', '👩', '👦', '👧'];
    const keys = ['mem_dad', 'mem_mom', 'mem_omar', 'mem_mariam'];
    for (var i = 0; i < 4; i++) {
      members.add(MembersCompanion.insert(
        id: memberIds[i],
        createdAt: _createdAt,
        updatedAt: _hlc,
        deviceId: 'sample',
        isSample: const Value(true),
        name: '',
        nameKey: Value(keys[i]),
        role: roles[i],
        avatar: avatars[i],
        color: memberColors[i],
        sortOrder: Value(i),
      ));
    }

    const limits = {
      'groceries': 7000, 'rent': 9000, 'utilities': 2000, 'transport': 1500, //
      'education': 4000, 'health': 1000, 'dining': 1500, 'shopping': 2500,
      'fun': 1500, 'bills': 700, 'other_e': 3000,
    };
    limits.forEach((cat, v) => budgets.add(BudgetsCompanion.insert(
          id: 'sample-budget-$cat',
          createdAt: _createdAt,
          updatedAt: _hlc,
          deviceId: 'sample',
          isSample: const Value(true),
          categoryId: cat,
          limitMinor: v * 100,
        )));
  }

  /// Start dates of an occasion for the sample years (bundled Egypt dates,
  /// computed Hijri dates for other years, or the fixed day).
  List<String> _occurrences(String key, int anchorYear) {
    final def = builtinOccasionsByKey[key]!;
    final years = [anchorYear - 2, anchorYear - 1, anchorYear];
    final bundled = bundledEgyptOccasionDates[key];
    if (bundled != null) {
      final out = [...bundled];
      if (def.source == OccasionSource.hijri) {
        for (final y in years) {
          if (!out.any((d) => LocalDate.yearOf(d) == y)) {
            out.addAll(hijriStartsInYear(def.hijriMonth!, def.hijriDay!, y));
          }
        }
        out.sort();
      }
      return out;
    }
    final md = def.fallbackMonthDay('EG');
    return md == null ? const [] : [for (final y in years) '$y-$md'];
  }
}

/// Gregorian dates in [year] of Hijri [month]/[day] (Umm al-Qura tables).
List<String> hijriStartsInYear(int month, int day, int year) {
  final out = <String>[];
  for (var hy = year - 580; hy <= year - 577; hy++) {
    try {
      final g = HijriCalendar().hijriToGregorian(hy, month, day);
      if (g.year == year) out.add(LocalDate.format(DateTime.utc(g.year, g.month, g.day)));
    } catch (_) {}
  }
  return out;
}

extension SampleDataInsert on SampleData {
  /// Inserts every row (all `is_sample = 1`, so no outbox rows).
  Future<void> insertInto(AppDatabase db) => db.batch((b) {
        b.insertAll(db.members, members, mode: InsertMode.insertOrIgnore);
        b.insertAll(db.recurringItems, recurring, mode: InsertMode.insertOrIgnore);
        b.insertAll(db.transactions, transactions, mode: InsertMode.insertOrIgnore);
        b.insertAll(db.budgets, budgets, mode: InsertMode.insertOrIgnore);
      });
}
