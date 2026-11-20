import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/time/dates.dart';
import 'data/db/app_database.dart';
import 'data/family_data.dart';
import 'data/prefs/device_prefs.dart';
import 'package:http/http.dart' as http;

import 'data/remote/date_clients.dart';
import 'data/remote/occasion_dates_service.dart';
import 'data/repositories/base_repository.dart';
import 'data/repositories/budgets_repository.dart';
import 'data/repositories/categories_repository.dart';
import 'data/repositories/members_repository.dart';
import 'data/repositories/occasions_repository.dart';
import 'data/repositories/recurring_repository.dart';
import 'data/repositories/transactions_repository.dart';
import 'data/repositories/transfers_repository.dart';
import 'domain/category_catalog.dart';
import 'domain/forecast.dart';
import 'domain/occasion_predictor.dart';
import 'domain/occasions.dart';
import 'data/repositories/rates_repository.dart';
import 'data/repositories/settings_repository.dart';

/// Overridden in `main.dart` (and in tests).
final prefsProvider =
    Provider<DevicePrefs>((ref) => throw UnimplementedError('prefs'));
final dbProvider =
    Provider<AppDatabase>((ref) => throw UnimplementedError('db'));

/// Today's local date (`YYYY-MM-DD`); overridable in tests.
final todayProvider = Provider<String>((ref) => LocalDate.today());

final stamperProvider = Provider<Stamper>(
    (ref) => Stamper(deviceId: ref.watch(prefsProvider).deviceId));

final settingsRepoProvider = Provider<SettingsRepository>((ref) =>
    SettingsRepository(ref.watch(dbProvider), ref.watch(stamperProvider)));

final ratesRepoProvider = Provider<RatesRepository>((ref) => RatesRepository(
    ref.watch(dbProvider),
    ref.watch(stamperProvider),
    ref.watch(settingsRepoProvider)));

/// All live family data, reloaded on every change.
final familyDataProvider = StreamProvider<FamilyData>(
    (ref) => FamilyData.watch(ref.watch(dbProvider)));

/// UI language (`ar` | `en`), stored per device.
class LanguageNotifier extends Notifier<String> {
  @override
  String build() => ref.watch(prefsProvider).language ?? 'ar';

  Future<void> set(String lang) async {
    await ref.read(prefsProvider).setLanguage(lang);
    state = lang;
  }

  Future<void> toggle() => set(state == 'ar' ? 'en' : 'ar');
}

final languageProvider =
    NotifierProvider<LanguageNotifier, String>(LanguageNotifier.new);

/// `system` | `light` | `dark`.
class ThemeNotifier extends Notifier<String> {
  @override
  String build() => ref.watch(prefsProvider).theme;

  Future<void> set(String v) async {
    await ref.read(prefsProvider).setTheme(v);
    state = v;
  }
}

final themeProvider = NotifierProvider<ThemeNotifier, String>(ThemeNotifier.new);

/// The app-wide selected month (FR-006); never after the current month.
class SelectedMonthNotifier extends Notifier<String> {
  @override
  String build() => LocalDate.monthOf(ref.watch(todayProvider));

  String get _current => LocalDate.monthOf(ref.read(todayProvider));

  bool get canGoNext => LocalDate.shiftMonth(state, 1).compareTo(_current) <= 0;

  void shift(int k) {
    final next = LocalDate.shiftMonth(state, k);
    if (next.compareTo(_current) <= 0) state = next;
  }

  void set(String ym) {
    state = ym.compareTo(_current) > 0 ? _current : ym;
  }
}

final selectedMonthProvider =
    NotifierProvider<SelectedMonthNotifier, String>(SelectedMonthNotifier.new);

/// Device setup and sample-mode flags, rebuilt when they change.
class SetupState {
  const SetupState({required this.completed, required this.sampleMode});
  final bool completed;
  final bool sampleMode;
}

class SetupNotifier extends Notifier<SetupState> {
  @override
  SetupState build() {
    final p = ref.watch(prefsProvider);
    return SetupState(completed: p.setupCompleted, sampleMode: p.sampleMode);
  }

  Future<void> complete() async {
    await ref.read(prefsProvider).setSetupCompleted(true);
    state = SetupState(completed: true, sampleMode: state.sampleMode);
  }

  void refresh() {
    final p = ref.read(prefsProvider);
    state = SetupState(completed: p.setupCompleted, sampleMode: p.sampleMode);
  }
}

final setupProvider =
    NotifierProvider<SetupNotifier, SetupState>(SetupNotifier.new);

// ---- Repositories ----

final categoriesRepoProvider = Provider<CategoriesRepository>((ref) =>
    CategoriesRepository(ref.watch(dbProvider), ref.watch(stamperProvider)));

final transactionsRepoProvider = Provider<TransactionsRepository>((ref) =>
    TransactionsRepository(ref.watch(dbProvider), ref.watch(stamperProvider),
        ref.watch(settingsRepoProvider),
        categoryType: ref.watch(categoriesRepoProvider).typeOf));

final recurringRepoProvider = Provider<RecurringRepository>((ref) =>
    RecurringRepository(ref.watch(dbProvider), ref.watch(stamperProvider),
        ref.watch(settingsRepoProvider),
        categoryType: ref.watch(categoriesRepoProvider).typeOf));

final membersRepoProvider = Provider<MembersRepository>((ref) =>
    MembersRepository(ref.watch(dbProvider), ref.watch(stamperProvider)));

final transfersRepoProvider = Provider<TransfersRepository>((ref) =>
    TransfersRepository(ref.watch(dbProvider), ref.watch(stamperProvider),
        ref.watch(settingsRepoProvider)));

final budgetsRepoProvider = Provider<BudgetsRepository>((ref) =>
    BudgetsRepository(ref.watch(dbProvider), ref.watch(stamperProvider)));

final occasionsRepoProvider = Provider<OccasionsRepository>((ref) =>
    OccasionsRepository(ref.watch(dbProvider), ref.watch(stamperProvider)));

final httpClientProvider = Provider<http.Client>((ref) {
  final c = http.Client();
  ref.onDispose(c.close);
  return c;
});

final occasionDatesServiceProvider = Provider<OccasionDatesService>((ref) {
  final h = DateHttp(ref.watch(httpClientProvider));
  return OccasionDatesService(AladhanClient(h), NagerClient(h),
      ref.watch(occasionsRepoProvider), ref.watch(settingsRepoProvider));
});

// ---- Derived (domain) ----

final catalogProvider = Provider<CategoryCatalog>((ref) => CategoryCatalog(
    ref.watch(familyDataProvider).value?.userCategories ?? const []));

final occasionServiceProvider = Provider<OccasionService?>((ref) {
  final d = ref.watch(familyDataProvider).value;
  return d == null ? null : OccasionService(d, ref.watch(todayProvider));
});

/// Forecast with occasions for everyone ([memberKey] null), a member id, or
/// '' for whole-family items.
final forecastProvider =
    Provider.family<Forecast?, (int, String?)>((ref, args) {
  final d = ref.watch(familyDataProvider).value;
  final occ = ref.watch(occasionServiceProvider);
  if (d == null || occ == null) return null;
  return Forecast.compute(d, args.$1,
      memberKey: args.$2,
      today: ref.watch(todayProvider),
      occasionPredictor: ServiceOccasionPredictor(occ));
});
