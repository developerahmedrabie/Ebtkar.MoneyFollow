import 'dart:async';
import 'dart:io';
import 'dart:ui' show Locale;

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../core/log/app_log.dart';
import '../core/money/format.dart';
import '../core/time/dates.dart';
import '../data/family_data.dart';
import '../domain/budget_usage.dart';
import '../domain/category_catalog.dart';
import '../domain/occasions.dart';
import '../l10n/l10n.dart';
import '../l10n/l10n_lookup.dart';
import '../providers.dart';

/// Local reminders (FR-022): bills due tomorrow/today, occasions 30 days
/// ahead, and budget alerts at 80 % / 100 %. Everything runs on the phone.
class NotificationScheduler {
  NotificationScheduler(this.ref);

  final Ref ref;
  final _plugin = FlutterLocalNotificationsPlugin();
  bool _ready = false;
  Timer? _debounce;

  static const _details = NotificationDetails(
    android: AndroidNotificationDetails('reminders', 'Reminders',
        importance: Importance.defaultImportance),
    iOS: DarwinNotificationDetails(),
  );

  Future<void> init() async {
    if (_ready) return;
    try {
      tzdata.initializeTimeZones();
      final zone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(zone.identifier));
      await _plugin.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          iOS: DarwinInitializationSettings(
              requestAlertPermission: false,
              requestBadgePermission: false,
              requestSoundPermission: false),
        ),
      );
      _ready = true;
    } catch (e, s) {
      AppLog.instance.error(e, s);
    }
  }

  /// Asks for permission the first time a switch is turned on.
  Future<bool> requestPermission() async {
    await init();
    if (Platform.isAndroid) {
      return await _plugin
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>()
              ?.requestNotificationsPermission() ??
          true;
    }
    return await _plugin
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(alert: true, badge: true, sound: true) ??
        false;
  }

  /// Debounced (2 s) rebuild after data changes.
  void scheduleRebuild() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(seconds: 2), () => rebuild());
  }

  AppLocalizations get _l =>
      lookupAppLocalizations(Locale(ref.read(languageProvider)));

  /// Cancels everything and schedules the next 30 days at 09:00 local time.
  Future<void> rebuild() async {
    final prefs = ref.read(prefsProvider);
    if (!prefs.notifyBills && !prefs.notifyOccasions) {
      if (_ready) await _plugin.cancelAll();
      return;
    }
    await init();
    if (!_ready) return;
    final d = await ref.read(familyDataProvider.future);
    final today = ref.read(todayProvider);
    final l = _l;
    final lang = ref.read(languageProvider);
    await _plugin.cancelAll();
    var id = 1;
    final now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime at(String date) {
      final p = LocalDate.parse(date);
      return tz.TZDateTime(tz.local, p.year, p.month, p.day, 9);
    }

    Future<void> schedule(String date, String title, String body) async {
      final when = at(date);
      if (when.isBefore(now)) return;
      await _plugin.zonedSchedule(
        id: id++,
        scheduledDate: when,
        notificationDetails: _details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        title: title,
        body: body,
      );
    }

    final limit = LocalDate.addDays(today, 30);
    if (prefs.notifyBills) {
      final cat = CategoryCatalog(d.userCategories);
      for (final r in d.recurring.where((r) => r.type == 'expense')) {
        if (r.nextDue.compareTo(limit) > 0) continue;
        final name = r.name.isNotEmpty
            ? r.name
            : (r.nameKey != null ? (lookupL10nKey(l, r.nameKey!) ?? '') : cat.displayName(r.categoryId, lang));
        final amount = formatAmount(d.currentMain(r.amountMinor, r.currency), d.main, lang);
        await schedule(LocalDate.addDays(r.nextDue, -1), l.notifBillTitle(name, l.tomorrow), amount);
        await schedule(r.nextDue, l.notifBillTitle(name, l.today), amount);
      }
    }
    if (prefs.notifyOccasions) {
      final s = OccasionService(d, today);
      for (final key in s.enabledKeys) {
        final next = s.nextOccurrence(key);
        if (next == null) continue;
        final date = LocalDate.addDays(next, -30);
        if (date.compareTo(limit) > 0) continue;
        final name = s.byKey[key]!.customName ?? (lookupL10nKey(l, 'ev_$key') ?? key);
        await schedule(
            date,
            l.notifOccasionTitle(name),
            l.notifOccasionBody(formatAmount(s.predict(key).total, d.main, lang),
                formatAmount(s.putAsidePerMonth(key), d.main, lang)));
      }
    }
  }

  /// After a save: alert once when a category crosses 80 % or 100 %.
  Future<void> onTransactionSaved(FamilyData before, FamilyData after) async {
    if (!ref.read(prefsProvider).notifyBudgets) return;
    await init();
    if (!_ready) return;
    final ym = LocalDate.monthOf(ref.read(todayProvider));
    final lang = ref.read(languageProvider);
    final old = {for (final r in budgetRows(before, ym)) r.category.id: r.ratio};
    for (final r in budgetRows(after, ym)) {
      final o = old[r.category.id] ?? 0;
      for (final t in const [1.0, .8]) {
        if (o < t && r.ratio >= t) {
          await _plugin.show(
            id: 100000 + r.category.id.hashCode % 100000,
            title: _l.notifBudgetTitle(r.category.name(lang), '${(r.ratio * 100).round()}'),
            body: _l.kOf(formatAmount(r.spent, after.main, lang), formatAmount(r.limit, after.main, lang)),
            notificationDetails: _details,
          );
          break;
        }
      }
    }
  }
}

final notificationSchedulerProvider =
    Provider<NotificationScheduler>((ref) => NotificationScheduler(ref));
