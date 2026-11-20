import '../../core/time/dates.dart';
import '../../domain/builtin_occasions.dart';
import '../db/app_database.dart';
import '../repositories/occasions_repository.dart';
import '../repositories/settings_repository.dart';
import 'date_clients.dart';

enum DatesRefreshStatus { updated, noHolidayData, failed }

class DatesRefreshResult {
  const DatesRefreshResult(this.status, this.count);
  final DatesRefreshStatus status;
  final int count;
}

/// Port of prototype `syncEvents` (FR-033 – FR-035).
class OccasionDatesService {
  OccasionDatesService(this.aladhan, this.nager, this.occasions, this.settings);

  final AladhanClient aladhan;
  final NagerClient nager;
  final OccasionsRepository occasions;
  final SettingsRepository settings;

  Future<DatesRefreshResult> refresh(String country, String today) async {
    final y0 = LocalDate.yearOf(today) - 3, y1 = y0 + 4;
    final out = <String, List<String>>{};
    void push(String key, String d) {
      final y = LocalDate.yearOf(d);
      if (y >= y0 && y <= y1) (out[key] ??= []).add(d);
    }

    var ok = 0;
    var holidayData = false;
    var nagerOk = false;
    final jobs = <Future<void>>[];

    for (final o in builtinOccasions.where((o) => o.source == OccasionSource.hijri)) {
      for (var hy = y0 - 580; hy <= y1 - 578; hy++) {
        jobs.add(aladhan.hijriToGregorian(o.hijriDay!, o.hijriMonth!, hy).then((d) {
          ok++;
          if (d != null) push(o.key, d);
        }, onError: (Object _) {}));
      }
    }
    for (var y = y0; y <= y1; y++) {
      jobs.add(nager.publicHolidays(y, country).then((list) {
        ok++;
        nagerOk = true;
        if (list.isNotEmpty) holidayData = true;
        for (final o in builtinOccasions.where((o) => o.source == OccasionSource.holiday)) {
          if (!o.availableIn(country)) continue;
          final re = o.holidayRegExp!;
          for (final h in list) {
            if (re.hasMatch(h.name)) {
              push(o.key, h.date);
              break;
            }
          }
        }
      }, onError: (Object _) {}));
    }
    await Future.wait(jobs);
    if (ok == 0) return const DatesRefreshResult(DatesRefreshStatus.failed, 0);

    // Holiday occasions are replaced only when Nager answered; failed Hijri
    // occasions keep their old rows (partial failure).
    final sources = <String, String>{};
    for (final o in builtinOccasions) {
      sources[o.key] = o.source == OccasionSource.hijri ? 'aladhan' : 'nager';
    }
    final toStore = <String, List<String>>{
      for (final e in out.entries)
        if (builtinOccasionsByKey[e.key]!.source == OccasionSource.hijri ||
            nagerOk)
          e.key: (e.value.toSet().toList()..sort()),
    };
    final n = await occasions.replaceFetched(country, toStore, sources);
    await settings.write(SettingKeys.occasionDatesUpdatedAt, today);
    if (nagerOk) await settings.write(SettingKeys.occasionDatesCountry, country);
    return DatesRefreshResult(
        holidayData ? DatesRefreshStatus.updated : DatesRefreshStatus.noHolidayData,
        n);
  }
}
