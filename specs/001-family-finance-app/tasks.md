---
description: "Task list for MoneyFollow Family Finance App (version 1)"
---

# Tasks: MoneyFollow Family Finance App (version 1)

**Input**: Design documents from `specs/001-family-finance-app/`

**Prerequisites**: [plan.md](./plan.md), [spec.md](./spec.md), [research.md](./research.md), [data-model.md](./data-model.md), [contracts/](./contracts/), [quickstart.md](./quickstart.md)

**Tests**: Included for domain rules, data rules and file formats. plan.md principle P3 asks for the money and §6 formulas to be written test-first against the prototype, and quickstart.md §1–2 names the suites. Screens are covered by a few widget and golden tests, not a full suite.

**Organization**: Tasks are grouped by user story, in delivery order:
1. Release 1.0 stories by priority (US1 → US2, US3, US4, US6 → US7, US8, US9, US10).
2. Release 1.0 completion: backup, setup, notifications, app lock.
3. Release 1.1: US5 sync.
4. Polish.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependency on an unfinished task)
- **[Story]**: User story from spec.md (US1 … US10)
- All app paths are under `src/` (the Flutter project). Tests are under `src/test/` and `src/integration_test/`.

## Reference material for every task

- **Behaviour and layout:** `prototype/index.html`, including its JS functions `forecast`, `predict`, `evHistory`, `suggestEv`, `addFreq`, `demo`, `syncEvents`, `markPaid` and the `I18N` dictionary.
- **Screens:** `docs/REQUIREMENTS.md` §7 and `docs/screens/*.png`.
- **Formulas:** `docs/REQUIREMENTS.md` §6.
- **Schema:** [data-model.md](./data-model.md).

When a task says "port from prototype `X`", reproduce `X`'s logic exactly in Dart.

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Dependencies, tooling, platform configuration and CI.

- [X] T001 Update `src/pubspec.yaml`:
  - **Add dependencies:** drift ^2.35.4, drift_flutter ^0.3.1, flutter_riverpod ^3.5.0, riverpod_annotation ^4.0.8, go_router ^18.1.4, intl ^0.20.3, hijri ^3.0.1, cryptography ^2.9.0, cryptography_flutter ^2.3.4, flutter_secure_storage ^11.2.0, flutter_local_notifications ^23.0.2, timezone ^0.11.2, flutter_timezone ^5.1.1, local_auth ^3.0.2, share_plus ^13.3.1, file_picker ^13.3.3, shared_preferences ^2.5.6, uuid ^4.6.0, http ^1.6.0, and `flutter_localizations: sdk: flutter`.
  - **Add dev_dependencies:** drift_dev ^2.35.3, build_runner ^2.17.1, riverpod_generator ^4.0.10, mocktail ^1.0.5, and `integration_test: sdk: flutter`.
  - **Keep** `material_ui`. **Remove** `cupertino_icons`.
  - **Set** `flutter: generate: true`.
  - Then run `flutter pub get`.
- [X] T002 [P] Create `src/l10n.yaml` with:
  - `arb-dir: lib/l10n`
  - `template-arb-file: app_en.arb`
  - `output-localization-file: app_localizations.dart`
  - `nullable-getter: false`
- [X] T003 [P] Create `src/build.yaml` configuring drift with `store_date_time_values_as_text: false` and `named_parameters: true`, and set riverpod_generator defaults.
- [X] T004 [P] Tighten `src/analysis_options.yaml`:
  - Enable the `strict-casts`, `strict-inference` and `strict-raw-types` analyzer options.
  - Enable the lints `prefer_const_constructors`, `directives_ordering`, `avoid_print` and `use_build_context_synchronously`.
  - Exclude `**/*.g.dart`.
- [X] T005 [P] Create the folder skeleton from plan.md "Project Structure": `src/lib/{core,data,domain,features,widgets,services,l10n}`, `src/test/{unit,widget,fixtures}`, `src/integration_test/` and `src/drift_schemas/`, each with a `.gitkeep`. Delete the counter demo in `src/lib/main.dart` and `src/test/widget_test.dart`.
- [X] T006 [P] Android config:
  - In `src/android/app/build.gradle.kts`, set `minSdk = 24`.
  - In `src/android/app/src/main/AndroidManifest.xml`, add `INTERNET`, `POST_NOTIFICATIONS`, `USE_BIOMETRIC` and `RECEIVE_BOOT_COMPLETED`, plus the flutter_local_notifications receivers.
  - Change `MainActivity.kt` to extend `FlutterFragmentActivity`, which local_auth requires.
- [X] T007 [P] iOS config:
  - In `src/ios/Runner/Info.plist`, add `NSFaceIDUsageDescription` (Arabic and English text) and `CFBundleLocalizations` [ar, en].
  - Set `platform :ios, '15.0'` in `src/ios/Podfile`.
- [X] T008 [P] Create `.github/workflows/android.yml`, per research R-18. On push and PR to `main`:
  1. ubuntu-latest, Java 17 (temurin), `subosito/flutter-action` with Flutter 3.50.0 stable.
  2. Working directory `src`: `flutter pub get`, `dart run build_runner build --delete-conflicting-outputs`, `flutter analyze`, `flutter test`, `flutter build apk --release`.
  3. Upload `src/build/app/outputs/flutter-apk/app-release.apk` as an artifact.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core types, the full schema v1 (sync-ready, per data-model.md), localization, theme, app shell and shared widgets. Every story depends on these.

**⚠️ CRITICAL**: No user story work can begin until this phase is complete.

### Core types

- [ ] T009 [P] Create `src/lib/core/money/currency.dart`. The `Currency` enum covers EGP, USD, EUR, SAR, AED, GBP and KWD, with `decimals` (KWD = 3, the others 2), an Arabic and English label (`ج.م`/`EGP` …), Arabic and English full names (from prototype `CURRENCIES`), and the default rates in micro-EGP (from prototype `DEFAULT_RATES`: EGP 1, USD 50, EUR 54, SAR 13.3, AED 13.6, GBP 63, KWD 162).
- [ ] T010 [P] Create `src/lib/core/money/money.dart`: an immutable `Money(int minor, Currency currency)` with `+`, `-`, comparisons, `fromDecimalString` (parses user input; rejects ≤ 0 where required) and `toDecimalString`. Never use `double` for stored amounts.
- [ ] T011 [P] Create `src/lib/core/time/hlc.dart`: a hybrid logical clock producing `"<ms 13 digits>-<counter 4 digits>-<deviceId>"`, with `send()` and `receive(remote)` per contracts/drive-sync.md "Clock". The strings must compare in order.
- [ ] T012 [P] Create `src/lib/core/ids.dart`: `newId()` returning a UUID v7 (`uuid` package).
- [ ] T013 [P] Create `src/lib/core/time/dates.dart`. `LocalDate` helpers on `YYYY-MM-DD` strings: `parse`, `format`, `addDays`, `daysBetween`, `shiftMonth(ym, k)`, `daysInMonth`, `monthOf`. Use local calendar dates with no time zone math; port the prototype date helpers.
- [ ] T014 [P] Unit tests for T010, T011 and T013:
  - `src/test/unit/money/money_test.dart`: parsing "1,250.5", KWD 3 decimals, rejects 0 and negatives.
  - `src/test/unit/time/hlc_test.dart`: ordering is monotonic when the wall clock moves backwards, and `receive()` advances past the remote time.
  - `src/test/unit/time/dates_test.dart`: shiftMonth across years, daysInMonth for February in a leap year.

### Built-in definitions (code constants)

- [ ] T015 [P] Create `src/lib/domain/builtin_categories.dart` with the 11 expense and 5 income categories from prototype `CATS`: id, en, ar, icon, colour, and type. Ids must stay stable: `groceries`, `rent`, `utilities`, `transport`, `education`, `health`, `dining`, `shopping`, `fun`, `bills`, `other_e`, `salary`, `freelance`, `rental`, `gift`, `other_i`.
- [ ] T016 [P] Create `src/lib/domain/builtin_occasions.dart`, from prototype `EVENTS`, `COUNTRIES` and `BUNDLED_EV`:
  - **Occasion definitions:** `ramadan` (hijri 9/1, 30 days), `eid_fitr` (hijri 10/1, 3), `eid_adha` (hijri 12/10, 4), `xmas` (holiday `^Christmas Day`, fallback 01-07 for EG, otherwise 12-25), `new_year` (fixed 12-31), `sham` (holiday `Easter Monday`, EG only), `mothers` (fixed 03-21, EG/SA/AE/KW), `school` (fixed 09-15, 7 days). Each also has an icon and colour.
  - **Countries:** EG, SA, AE, KW, US, GB.
  - **Bundled Egypt dates** for 2024–2027.

### Database (schema v1, all tables, sync-ready)

- [ ] T017 Create `src/lib/data/db/tables.dart` with drift tables exactly as in data-model.md: `members`, `categories`, `accounts`, `transactions`, `transfers`, `recurring_items`, `budgets`, `rate_snapshots`, `occasions`, `occasion_dates`, `settings`, `sync_outbox`, `sync_state`, `devices`.
  - **Sync columns** on every synced table: `id` TEXT PK (UUID v7), `created_at` INTEGER, `updated_at` TEXT (HLC), `device_id` TEXT, `deleted` INTEGER default 0, `is_sample` INTEGER default 0.
  - **Money columns** are INTEGER minor units.
  - **Indexes:** transactions `(date)`, `(member_id, date)`, `(category_id, date)`, `(occasion_id)`, `(account_id)`.
  - **Unique keys:** `occasion_dates (occasion_key, year, country)`, and `budgets(category_id)` among non-deleted rows.
- [ ] T018 Create `src/lib/data/db/app_database.dart` (drift `@DriftDatabase`, `schemaVersion = 1`):
  - **Open** the database with `drift_flutter` `driftDatabase(name: 'moneyfollow')`.
  - **Outbox triggers:** `AFTER INSERT`/`AFTER UPDATE` triggers on every synced table insert a `sync_outbox` row (`table_name`, `row_id`, `op`, `payload_json` = `json_object(...)` of the row, `hlc` = `NEW.updated_at`) when `NEW.is_sample = 0`.
  - **Seed in `onCreate`:** the 4 accounts with fixed ids `acc-cash`, `acc-bank`, `acc-card`, `acc-usd` (currencies EGP, EGP, EGP, USD), and the first rate snapshot from `Currency` defaults.
  - **Seed settings:** `main_currency=EGP`, `country=EG`, `current_rate_snapshot_id`, and the bundled occasion dates from T016 with `source='bundled'`.
- [ ] T019 Generate the schema dump with `dart run drift_dev make-migrations` into `src/drift_schemas/` and add `src/test/unit/db/schema_test.dart`. The test opens `NativeDatabase.memory()`, checks that all 14 tables and the triggers exist, checks that inserting a transaction writes exactly one `sync_outbox` row, and checks that a row with `is_sample = 1` writes none.
- [ ] T020 Create `src/lib/data/repositories/base_repository.dart`:
  - **`stampInsert`/`stampUpdate`:** fill `id` (new UUID v7 on insert), `created_at`, `updated_at` (`Hlc.send()`) and `device_id` (from device prefs).
  - **`softDelete(table, id)`:** sets `deleted = 1` and stamps the row.
  - **Query filter:** a `notDeleted` filter expression that every repository query must use.
- [ ] T021 [P] Create `src/lib/data/prefs/device_prefs.dart`, a wrapper around shared_preferences with typed getters and setters. Keys: `language` (`ar` | `en`), `theme` (`system` | `light` | `dark`), `setup_completed`, `sample_mode`, `sample_started_at`, `device_id` (generated once), `last_backup_at`, `backup_reminder` (`on` | `snoozed_until:<date>` | `off`), `notifications.bills`, `notifications.budgets`, `notifications.occasions`, `app_lock` (`off` | `pin` | `biometric`). Also create `src/lib/data/prefs/secure_store.dart`, wrapping flutter_secure_storage (PIN hash, keys).
- [ ] T022 Create `src/lib/data/repositories/settings_repository.dart`: key/value read/watch/write on the `settings` table for `main_currency`, `country`, `current_rate_snapshot_id` and `occasion_dates_updated_at`.
- [ ] T023 Create `src/lib/data/repositories/rates_repository.dart`, which holds the rate snapshots:
  - **Reads:** `currentSnapshot()`, `watchCurrent()` and `snapshotById()`.
  - **`updateRate(currency, valueInMain)`:** creates a NEW immutable snapshot copied from the current one with the changed rate (rate > 0), then points `current_rate_snapshot_id` at it.
- [ ] T024 Create `src/lib/domain/conversion.dart`:
  - `toMain(amountMinor, currency, snapshot, mainCurrency)` implements `value_M = amount × rates[cur] / rates[M]`, both rates from the given snapshot, rounding half-up to the main currency's decimals.
  - Also add helpers for "current" conversion, used by forecasts and balances.
- [ ] T025 Write `src/test/unit/money/conversion_test.dart` for FR-014 and FR-016:
  - A 100 USD expense recorded under snapshot S1 (USD = 50) stays 5,000 EGP after the rate changes to 52 (snapshot S2).
  - A new 100 USD row under S2 = 5,200.
  - Changing the main currency to USD converts past rows with their own snapshot.
  - KWD rounding to 3 decimals.

### Localization, formatting, theme

- [ ] T026 [P] Create `src/lib/l10n/app_en.arb` and `src/lib/l10n/app_ar.arb` by porting **every** key of prototype `I18N.en` and `I18N.ar`. Convert `{x}` placeholders to ICU `{x}` with `placeholders` metadata. Add new keys for transfers, backup, setup, sample banner, notifications, app lock, custom occasions and the sync screens, with Arabic text.
- [ ] T027 [P] Write `src/test/unit/l10n/arb_parity_test.dart`. It checks that `app_en.arb` and `app_ar.arb` have identical key sets and identical placeholder names per key (FR-044).
- [ ] T028 [P] Create `src/lib/core/money/format.dart`:
  - **Amounts:** `formatAmount` (Western digits, grouping, currency label per language, `−` sign, wrapped in Unicode LRI…PDI isolates as in prototype `money()`), `formatApprox` ("≈ …"), and `shortAmount` (prototype `short`: 1.2k / 12k).
  - **Dates:** `monthLabel`, `dayLabel` (Today / Yesterday / date) and `dateShort`, all with `intl` and Western digits in Arabic (`ar-EG-u-nu-latn` behaviour).
  - **Tests:** add them in `src/test/unit/money/format_test.dart`.
- [ ] T029 [P] Create `src/lib/core/theme/app_theme.dart`:
  - Build light and dark `ThemeData` from the prototype `:root` CSS tokens (primary teal, income, expense, warn, surface, line, muted).
  - Add a `ThemeExtension` with the money colours and the budget colours: primary under 80 %, warn from 80 % to 100 %, expense over 100 %.

### App shell and shared widgets

- [ ] T030 Create `src/lib/main.dart` and `src/lib/app.dart`:
  - **Bootstrap:** `main.dart` initializes `DevicePrefs`, opens `AppDatabase` and runs `ProviderScope`.
  - **App widget:** `app.dart` builds `MaterialApp.router` with the localization delegates, `supportedLocales` [ar, en], locale and theme mode from prefs, and RTL from the locale. A language change rebuilds the app immediately with no restart (FR-044).
  - Also create `src/lib/providers.dart` with providers for db, prefs, the repositories and `selectedMonthProvider`.
- [ ] T031 Create `src/lib/features/shell/router.dart` with all routes and parameters from contracts/screens-and-routes.md, using placeholder screens for now:
  - A `StatefulShellRoute.indexedStack` for Home, Activity, Planner and Reports.
  - Redirects: to `/setup/language` when `setup_completed` is false, and to `/lock` while locked.
- [ ] T032 Create `src/lib/features/shell/app_shell.dart`: a bottom bar with Home, Activity, a centred **+** button, Planner and Reports (prototype `.nav`). The **+** button opens `TransactionSheet`.
- [ ] T033 [P] Create `src/lib/features/shell/month_selector.dart`: the `‹ Month YYYY ›` control bound to `selectedMonthProvider`. The next button is disabled at the current month (FR-006).
- [ ] T034 [P] Create the shared widgets in `src/lib/widgets/common/`:
  - `cat_icon.dart` (icon in a tinted rounded square)
  - `member_avatar.dart`
  - `chip_label.dart` (normal / ok / warn)
  - `section_header.dart` (title plus link)
  - `empty_state.dart`
  - `confirm_twice_button.dart`: the first tap changes the label to "Tap again to confirm" and resets after 2.5 s (FR-002).
  - `toast.dart`: a SnackBar helper.
  - `amount_text.dart`: red/green with sign and "≈" line.
- [ ] T035 [P] Create the charts in `src/lib/widgets/charts/`, all `CustomPainter`s mirrored for RTL (research R-14):
  - `pair_bars.dart`: income vs expense columns.
  - `stacked_bars.dart`: segments per series, with an optional value label on top.
  - `predicted_bar.dart`: striped fill with a dashed outline, as prototype `.pred`.
  - `donut_chart.dart`: centre text plus legend.
  - `share_bar.dart`.
- [ ] T036 [P] Golden tests for T035 in `src/test/widget/charts_golden_test.dart`, in ar and en, light and dark.

### Sample/reference data and logging

- [ ] T037 Create `src/lib/data/sample/sample_data.dart` by porting prototype `demo(lang)` to Dart as `SampleData.generate(anchorDate)`. It must be deterministic (fixed seed), generating:
  - members Dad, Mom, Omar, Mariam;
  - recurring items 1–15;
  - transactions from `anchor − 34 months`, with inflation 0.72 / 0.86 / 1.0 per year;
  - occasion spending (`EV_SPEND`);
  - budgets.

  All rows get `is_sample = 1` and `name_key`/`note_key` translation keys. It also has `insertInto(AppDatabase)`.
- [ ] T038 Create `src/test/fixtures/reference_data.dart`. It builds an in-memory database seeded with `SampleData.generate(DateTime(2026, 11, 13))` (the prototype's `TODAY`), plus the expected numbers that later tests assert. Read those numbers from the prototype in a browser and record each with a comment saying where it came from.
- [ ] T039 [P] Create `src/lib/core/log/app_log.dart` (research R-19): a ring-buffer file log keeping the last 500 lines in the app documents directory, with `log`, `error` and `readAll`. Catch uncaught errors in `main.dart` with `FlutterError.onError` and `PlatformDispatcher.instance.onError`.

**Checkpoint**: The app opens to an empty shell in Arabic or English with the database created. `flutter test` passes T014, T019, T025, T027, T028 and T036.

---

## Phase 3: User Story 1 - Record and review income and expenses (Priority: P1) 🎯 MVP

**Goal**: Add, edit, delete, browse, search and filter transactions, see the month summary on Home, switch language, and use the app fully offline.

**Independent Test**: In airplane mode, add 10 expenses and 2 incomes across two months, restart the app, switch the language, and check totals, lists, search and filters (spec US1 scenarios 1–6).

### Tests for User Story 1

- [ ] T040 [P] [US1] Write `src/test/unit/db/transactions_repository_test.dart` covering:
  - insert stamps `id`/HLC and attaches `current_rate_snapshot_id`;
  - rejects `amount_minor <= 0` and a category whose type doesn't match;
  - rejects `occasion_id` on income;
  - "note ≤ 60 chars";
  - edit updates `updated_at`;
  - delete is soft (`deleted = 1`) and disappears from `watchMonth`.
- [ ] T041 [P] [US1] Write `src/test/unit/domain/monthly_totals_test.dart`: income, expenses, net and savings-rate message for 2026-11 and 2026-10 on the reference data (T038), matching the prototype Home card.

### Implementation for User Story 1

- [ ] T042 [US1] Create `src/lib/data/repositories/transactions_repository.dart`:
  - **Watch:** `watchMonth(ym, {type, memberKey, query})`, sorted by date descending then created_at descending. `memberKey` is `all`, `whole` (member_id IS NULL) or an id. The search covers the note, the translated note key and the category name in both languages.
  - **`create`/`update`:** validate "amount > 0", the category type match, and "occasion only on expenses", then attach the current rate snapshot.
  - **`delete`:** soft delete.
- [ ] T043 [P] [US1] Create `src/lib/data/repositories/accounts_repository.dart`: list the 4 accounts. Derive `balance(accountId)` in the account's currency as income − expenses (transfers are added in US4), using the stored snapshot whenever a row's currency differs from the account's. Also derive `totalInMain()` from the current rates.
- [ ] T044 [P] [US1] Create `src/lib/domain/monthly_totals.dart`: `MonthSummary(income, expenses, net, savingsRatePercent)` computed from rows plus `conversion.toMain` with each row's snapshot (FR-016).
- [ ] T045 [US1] Create `src/lib/features/sheets/transaction_sheet.dart`, a modal bottom sheet in `mode: tx` (prototype `#sheet`):
  - **Fields:**
    - Expense/Income segment.
    - A large amount field with currency picker and live "≈ main" line (FR-015).
    - A category grid of the categories of that type, built-in for now.
    - A "For" member chips row (Whole family plus members, preset from `presetMemberId`).
    - Date (default today).
    - Account (default Cash).
    - Note (max 60).
  - **Validation errors:** "Enter an amount greater than 0" and "Choose a category".
  - **Saving:** Save sets the selected month to the transaction's month and shows a toast.
  - **Edit mode:** loads the row and shows a Delete button using `ConfirmTwiceButton`.
  - **Extension point:** leave clear slots for the Repeat (US2), Occasion (US8) and transfer (US4) features.
- [ ] T046 [US1] Create `src/lib/widgets/common/transaction_row.dart`, from prototype `txRow`:
  - category icon;
  - title (note, or category name);
  - subtitle: category · account · 🔁 if recurring · member · occasion tag;
  - amount via `AmountText`.

  Tapping it opens the sheet in edit mode.
- [ ] T047 [US1] Create `src/lib/features/home/home_screen.dart`:
  - header: "Home finance", app name, a language toggle (ع/EN) and the settings button;
  - month selector;
  - hero card: net balance, income and expense pills, and the savings message (`saved_pct` / `over_pct` / `no_income`);
  - Recent: the last 5 transactions, with "See all" opening Activity.

  Sections for the family strip, Coming up and budgets are added by US3, US2/US7/US8 and US6 respectively, through separate widget files.
- [ ] T048 [US1] Create `src/lib/features/activity/activity_screen.dart`:
  - title and month selector;
  - an All / Expenses / Income segment;
  - a search field;
  - a member filter chip row (Everyone, Whole family, members);
  - the list grouped by day with each day's net (`dayLabel`);
  - the empty state "Nothing found".
- [ ] T049 [US1] Create `src/lib/features/settings/settings_screen.dart`:
  - **Accounts:** each balance in its own currency with "≈ main" for non-main currencies, plus the total in the main currency.
  - **Preferences:** language, and theme (System / Light / Dark).

  Leave rows for later stories, wired to placeholder routes: family members, categories, main currency, exchange rates, backup, notifications, security and export.
- [ ] T050 [US1] Write the widget test `src/test/widget/add_transaction_test.dart` for US1 scenarios 1–3:
  1. Add 250 Groceries; it appears in Recent and the net changes by 250.
  2. Saving with amount 0 or no category shows the errors.
  3. Delete needs two taps.
- [ ] T051 [US1] Write the widget test `src/test/widget/rtl_switch_test.dart`: switching the language rebuilds Home in `TextDirection.rtl` with Arabic strings and Western digits (US1 scenario 5).

**Checkpoint**: US1 works on its own (MVP): an offline tracker in two languages.

---

## Phase 4: User Story 2 - Track recurring bills and income (Priority: P2)

**Goal**: Recurring items with frequencies, a due-in-30-days list, Mark paid / Received, monthly equivalents, and Repeat on new transactions.

**Independent Test**: Add a monthly rent due in 5 days and a weekly pocket money item. Both appear under "Due in the next 30 days" and on Home. Mark rent paid and check the new transaction and the next due date (spec US2 scenarios 1–4).

### Tests for User Story 2

- [ ] T052 [P] [US2] Write `src/test/unit/recurring/advance_due_test.dart`, a port of prototype `addFreq` covering:
  - weekly +7;
  - monthly from the 31st in January → 28/29 February → 31 March (the anchor `day_of_month` is kept);
  - quarterly;
  - yearly 29 Feb → 28 Feb.
- [ ] T053 [P] [US2] Write `src/test/unit/db/recurring_repository_test.dart`:
  - `markPaid` inserts a transaction dated today with `recurring_id`, the same amount, currency, category, account and member, and advances `next_due`, all in one database transaction;
  - an overdue item sorts first;
  - stopping an item soft-deletes it and keeps its past transactions.

### Implementation for User Story 2

- [ ] T054 [P] [US2] Create `src/lib/domain/recurring.dart`:
  - `advanceDue(date, frequency, dayOfMonth)`;
  - `occurrencesInRange(item, from, to)` (port of prototype `occurrences`);
  - `monthlyEquivalent` using weekly 52/12, monthly 1, quarterly 1/3, yearly 1/12 (FR-021);
  - `dueLabel(nextDue, today)`, returning Overdue N d / Due today / Tomorrow / In N days / date (prototype `dueChip`).
- [ ] T055 [US2] Create `src/lib/data/repositories/recurring_repository.dart`:
  - **Watch:** `watchAll()` and `watchDue(days: 30)`, which includes overdue items and sorts by `next_due`.
  - **Edit:** `create`/`update`. Validation: amount > 0; "name ≤ 60 chars"; `frequency` ∈ {weekly, monthly, quarterly, yearly}; `day_of_month` 1–31, taken from the next due date.
  - **`markPaid`:** one database transaction.
  - **`stop`:** soft delete.
- [ ] T056 [US2] Extend `src/lib/features/sheets/transaction_sheet.dart`:
  - **`mode: recurring`:** title "New/Edit recurring item", "Next due date" label, a required "Repeats" select, "Name" instead of Note, no occasion field, and delete labelled "Stop repeating".
  - **New transaction:** a "Repeat" select (Doesn't repeat / Weekly / Monthly / Every 3 months / Yearly). A chosen frequency also creates a recurring item due one period after the date (FR-018), with the toast "Added and scheduled to repeat".
- [ ] T057 [US2] Create `src/lib/features/planner/planner_screen.dart`, with tabs Recurring · Forecast · Occasions · Budgets bound to the `/planner/:tab` route. The other tabs show placeholders until their stories land.
- [ ] T058 [US2] Create `src/lib/features/planner/recurring_tab.dart`:
  - **KPIs:** "Fixed bills / month" and "Recurring income / month".
  - **"Due in the next 30 days":** rows with a due chip, amount, and a **Mark paid** / **Received** button that calls `markPaid` and shows the toast "Recorded: {name}".
  - **"All recurring":** expenses and income groups sorted by monthly cost, each row with a frequency chip, "Next {date}" and member. Tapping a row opens the sheet in recurring mode, and "+ Add" opens a new one.
- [ ] T059 [US2] Create `src/lib/features/home/coming_up_card.dart` and add it to the Home screen. It shows the "Due in 30 days" total and up to 3 upcoming expense bills with due chip and member, and "View all" goes to `/planner/recurring`. The "Expected next month" KPI and the next-occasion row are filled in by US7 and US8; hide them until their providers exist.

**Checkpoint**: US1 and US2 work on their own.

---

## Phase 5: User Story 3 - Follow each family member's spending (Priority: P2)

**Goal**: Members (add, edit, remove), assigning spending to them, the Family screen and the Member screen. Forecast parts come in US7.

**Independent Test**: Add 2 children, assign expenses and one recurring item to each, and check the Family and Member screens, the Activity member filter and Reports "by member" (spec US3 scenarios 1–3).

### Tests for User Story 3

- [ ] T060 [P] [US3] Write `src/test/unit/db/members_repository_test.dart`:
  - name rules "Required, trimmed, 1–30 chars";
  - the first unused colour of the 8-colour palette is auto-assigned;
  - removing a member with 12 transactions and 1 recurring item sets `member_id = NULL` on all 13 rows and tombstones the member, in one database transaction (FR-026).
- [ ] T061 [P] [US3] Write `src/test/unit/domain/member_spending_test.dart`: per-member spending, share % and 6-month series for 2026-11 on the reference data. The shares must add up to the month's total expenses (US3 scenario 3).

### Implementation for User Story 3

- [ ] T062 [US3] Create `src/lib/data/repositories/members_repository.dart` with `watchAll`, `create(name, role, avatar)` (role ∈ {parent, child, other}; avatar ∈ the 9 avatars in prototype `AVATARS`; colour from `MEM_COLORS`), `update` (clears `name_key` when renamed) and `remove` (re-point, then tombstone).
- [ ] T063 [P] [US3] Create `src/lib/domain/member_spending.dart` with `memberSpent(memberKey, ym)`, `familyShare(ym)` and `memberSeries(memberKey, endYm, 6)`. Its `memberKey` covers Whole family (null).
- [ ] T064 [US3] Create `src/lib/features/sheets/member_sheet.dart` (prototype `#msheet`):
  - Name (max 30, error "Enter a name").
  - Role segment (Parent / Child / Other).
  - Avatar grid.
  - Save.
  - In edit mode, "Remove member" via `ConfirmTwiceButton`, with the hint "Removing a member keeps their transactions and moves them to Whole family."
- [ ] T065 [US3] Wire members into `src/lib/features/sheets/transaction_sheet.dart` and `src/lib/features/activity/activity_screen.dart`:
  - The "For" chips list the real members, and the selected chip scrolls into view.
  - The Activity member filter lists the real members.
- [ ] T066 [US3] Create `src/lib/features/home/family_strip.dart` and add it to Home: a horizontal chip per member plus Whole family (avatar, name, `shortAmount` spent this month). Tapping a chip opens `/family/:memberId`, and "View all" opens `/family`.
- [ ] T067 [US3] Create `src/lib/features/family/family_screen.dart`:
  - "Who spent this month": `ShareBar` with a legend showing amount and %.
  - Members list: avatar, name, role, spent this month. Its "Next month ≈" line is added in US7.
  - "+ Add member", opening `MemberSheet`.
  - "Spending per member · last 6 months": `StackedBars` with a total on top and a colour legend.
- [ ] T068 [US3] Create `src/lib/features/member/member_screen.dart`:
  - Header with avatar, name, role, and an edit button (hidden for Whole family).
  - KPIs: spent this month, share of family, vs last month. "Expected next month" is added in US7.
  - Last 6 months bars in the member's colour.
  - Spending by category bars.
  - The member's recurring items and the selected month's transactions, each section with "+ Add" opening the sheet with `presetMemberId` (FR-028).
- [ ] T069 [US3] Add a "Family members" row with an "{n} members" chip to `src/lib/features/settings/settings_screen.dart`, opening `/family`.

**Checkpoint**: US1–US3 work on their own.

---

## Phase 6: User Story 4 - Use more than one currency, and transfers (Priority: P2)

**Goal**: Main currency choice, exchange rate editing as snapshots, multi-currency account balances, and transfers between accounts (FR-012 – FR-016, FR-060).

**Independent Test**: With EGP main and 1 USD = 50, add 5.99 USD and 100 USD expenses and check the "≈" values and totals. Change the rate to 52: past totals stay the same and new rows use 52. Transfer 2,000 Bank → Cash and 100 USD → Bank receiving 5,050 EGP (spec US4 scenarios 1–5).

### Tests for User Story 4

- [ ] T070 [P] [US4] Write `src/test/unit/db/transfer_test.dart`:
  - from == to is refused, and amounts must be > 0;
  - Bank 10,000 → transfer 2,000 to Cash gives Bank 8,000 and Cash +2,000;
  - the month's income and expense totals are unchanged;
  - a cross-currency transfer of 100 USD → 5,050 EGP is stored exactly;
  - a soft-deleted transfer restores the balances.
- [ ] T071 [P] [US4] Extend `src/test/unit/money/conversion_test.dart` with account balances: the Dollar account balance in USD and its current-rate "≈", and the total in main currency after a rate change.

### Implementation for User Story 4

- [ ] T072 [US4] Create `src/lib/data/repositories/transfers_repository.dart`:
  - **`create`/`update`:** validation `from_account_id != to_account_id`, `amount_out_minor > 0`, `amount_in_minor > 0`; when the currencies match, `amount_in = amount_out`. Attach the current snapshot.
  - **`delete`:** soft delete.
  - **`watchMonth(ym)`.**
- [ ] T073 [US4] Update `src/lib/data/repositories/accounts_repository.dart`: balance = income − expenses + transfers in − transfers out, in the account's currency. Make sure every income, expense, budget, report and forecast query ignores transfers.
- [ ] T074 [US4] Create `src/lib/features/sheets/transfer_sheet.dart`:
  - from-account and to-account selects (same account refused);
  - amount sent;
  - when the currencies differ, an "amount received" field pre-filled from the current rate and editable;
  - date and note;
  - Save, and Delete (tap twice).

  Open it from Settings › Accounts (a "Transfer" button) and from a "Transfer" option on the **+** sheet's type segment.
- [ ] T075 [US4] Update `src/lib/features/activity/activity_screen.dart` and `src/lib/widgets/common/transaction_row.dart`: add a "Transfers" filter option, and show transfer rows with a ⇄ icon, "From → To" and a neutral amount. The day net excludes transfers.
- [ ] T076 [US4] Create `src/lib/features/settings/rates_section.dart`, inside the Settings screen:
  - a "Main currency" select (7 currencies with full names);
  - "Exchange rates" rows "1 USD = [50] EGP" for every non-main currency, saved on submit through `RatesRepository.updateRate` (rate > 0, otherwise revert), with the toast "Exchange rate updated";
  - the `rates_hint` text.
- [ ] T077 [US4] In `src/lib/features/sheets/transaction_sheet.dart`, `src/lib/widgets/common/amount_text.dart` and `src/lib/features/settings/settings_screen.dart`, make sure the live "≈" line, `AmountText` and the account rows follow FR-015: a foreign amount shows its original value plus "≈ main". Past rows use their snapshot; the live "≈" and balances use the current rates.

**Checkpoint**: US1–US4 work on their own.

---

## Phase 7: User Story 6 - Set and watch monthly budgets (Priority: P2)

**Goal**: A monthly limit per expense category, usage with colours, and the top 3 on Home.

**Independent Test**: Set Groceries = 7,000 and Shopping = 2,500, add spending to reach 85 % and 110 %, and check the colours and text on Home and in Budgets (spec US6 scenarios 1–2).

### Tests for User Story 6

- [ ] T078 [P] [US6] Write `src/test/unit/domain/budget_usage_test.dart`:
  - usage %, left, and over for the selected month on the reference data;
  - colour thresholds: < 80 % primary, 80–100 % warn, > 100 % over;
  - rows sorted by % used, descending;
  - transfers are ignored.

### Implementation for User Story 6

- [ ] T079 [P] [US6] Create `src/lib/data/repositories/budgets_repository.dart` with `watchAll` and `setLimit(categoryId, limitMinor)` (`limit_minor > 0`; empty or 0 tombstones the row). There is one live row per expense category.
- [ ] T080 [P] [US6] Create `src/lib/domain/budget_usage.dart` with `BudgetRow(category, spent, limit, ratio)`, `rows(ym, {limit})`, `total(ym)` and `barColor(ratio)`.
- [ ] T081 [US6] Create `src/lib/features/planner/budgets_tab.dart`:
  - the month selector;
  - the "Total budget" card: %, bar, "{v} spent", "{v} left of {t}";
  - "Monthly limits" rows, each with icon, name, %, a coloured bar, "{a} of {b}" and "{v} left" or "{v} over";
  - **Edit**, which switches to numeric inputs for every expense category with the placeholder "No limit", and **Done**, which saves with the toast "Budgets updated";
  - the empty state "No budgets set. Tap Edit to add limits."
- [ ] T082 [US6] Create `src/lib/features/home/budgets_card.dart` and add it to Home: the 3 budgets closest to or over their limit, with "Manage" going to `/planner/budgets`, and the empty state "No budgets set".

**Checkpoint**: US1–US4 and US6 work on their own.

---

## Phase 8: User Story 7 - See the next months before they happen (Priority: P3)

**Goal**: A 3/6-month forecast with fixed bills, occasions, day-to-day, income and savings, plus "Higher than usual". Per-member forecasts on the Family and Member screens.

**Independent Test**: With known recurring items and 3 months of history, each month's figures equal REQUIREMENTS §6.2. A yearly insurance due in March flags March as "Higher than usual" (spec US7 scenarios 1–2).

### Tests for User Story 7

- [ ] T083 [P] [US7] Write `src/test/unit/forecast/forecast_test.dart`, a port of prototype `forecast(n, mem)` run on the reference data with occasion predictions stubbed to 0. Assert, for whole family, one member and whole-family-only:
  - `varAvg` = the average of the last 3 full months' expenses that are neither recurring nor occasion-tagged;
  - per month: fixed, income, total, savings;
  - `high` = total > 1.05 × the period average AND (a quarterly/yearly bill OR an occasion).

  Then repeat the run with the real predictor (after T096) for SC-008.

### Implementation for User Story 7

- [ ] T084 [US7] Create `src/lib/domain/forecast.dart`:
  - `Forecast.compute(n, {memberKey, today, occasionPredictor})` returning `ForecastMonth(m, fixed, occasions, occasionKeys, variable, total, income, savings, oddItems, items, high)` and `avg`. It uses the current rates (FR-014).
  - Define the `OccasionPredictor` interface here, with a default that returns 0 until US8.
- [ ] T085 [US7] Create `src/lib/features/planner/forecast_tab.dart`:
  - a 3/6-month toggle;
  - the "Expected spending" card with "Average expected spending / month" and `PairBars`, where the spending side is stacked (fixed solid, occasions warn, day-to-day at 40 % opacity), plus a legend;
  - one card per month: fixed, "Occasions (estimated) · names", day-to-day, expected income, and expected savings (red when < 0);
  - "Higher than usual · Includes …" when `high`;
  - the `fc_hint` text with the day-to-day value.
- [ ] T086 [US7] Add the "Expected next month" KPI to `src/lib/features/home/coming_up_card.dart`, as `forecast(1).months[0].total`.
- [ ] T087 [US7] Extend `src/lib/features/family/family_screen.dart` with:
  - "Next month ≈ {v}" on each member row;
  - the "Expected spending · next 3 months" grid of members × 3 months with a Total row, where cells are warn-coloured when they include a quarterly/yearly bill or an occasion;
  - the `fam_fc_hint` text.
- [ ] T088 [US7] Extend `src/lib/features/member/member_screen.dart` with:
  - the "Expected next month" KPI;
  - the "Expected next 3 months" list: each month's total, "{f} fixed + {v} day-to-day", and chips for included occasions and bills (warn for quarterly/yearly).

**Checkpoint**: The forecast works with occasions counted as 0, and US8 fills them in.

---

## Phase 9: User Story 8 - Plan for yearly occasions (Priority: P3)

**Goal**:
- Occasion dates per country from Aladhan and Nager.Date, with bundled offline dates.
- Switching occasions on and off, and tagging expenses with auto-suggestion.
- Prediction from previous years.
- The Occasions tab and the occasion detail screen.
- ±1 day adjustment and custom occasions.
- Feeding predictions into the forecast.

**Independent Test**: With 3 years of tagged Ramadan spending, the expected amount matches §6.3. Changing the country to United States moves Christmas to 25 Dec and hides Sham El-Nessim and Mother's Day. With no internet, Update keeps the saved dates (spec US8 scenarios 1–5).

### Tests for User Story 8

- [ ] T089 [P] [US8] Write `src/test/unit/occasions/predict_test.dart`, a port of prototype `evHistory` and `predict`:
  - the nearest-occurrence grouping;
  - the last 3 occurrences before the next one;
  - the yearly change limited to 0.85–1.5;
  - with one year of history, g = 1;
  - Ramadan 6,900 → 7,800 ⇒ ≈ 8,817 (US8 scenario 1);
  - the per-category and per-member breakdown scaled by expected ÷ last;
  - a member filter;
  - the reference-data values for Ramadan and Eid al-Adha.
- [ ] T090 [P] [US8] Write `src/test/unit/occasions/suggest_test.dart`, a port of prototype `suggestEv`: the window runs from 14 days before the start to the last day, the closest occasion wins, there is no suggestion outside every window, and switched-off occasions are ignored.
- [ ] T091 [P] [US8] Write `src/test/unit/occasions/date_services_test.dart`, using mocktail `http.Client`, against contracts/external-date-apis.md:
  - Aladhan `data.gregorian.date` parsing and the Hijri year range;
  - Nager "Christmas Day" / "Easter Monday" matching;
  - an empty list, 404 or 204 means "no holiday data" (SA/AE/KW);
  - a partial failure keeps the old rows;
  - a total failure changes nothing;
  - `adjust_days` is preserved on refresh.

### Implementation for User Story 8

- [ ] T092 [P] [US8] Create `src/lib/data/remote/aladhan_client.dart` and `src/lib/data/remote/nager_client.dart` per contracts/external-date-apis.md, with a 10 s timeout, no retries, the header `User-Agent: MoneyFollow/<version>`, and at most 6 requests at a time.
- [ ] T093 [US8] Create `src/lib/data/repositories/occasions_repository.dart`:
  - **Dates:** `effectiveDates(key)`, where effective date = `start_date + adjust_days`. Built-in fixed occasions are generated for years −3…+2; holiday occasions use the stored rows for the current country or else the fallback; Hijri occasions use the stored rows.
  - **Settings:** `setEnabled(key, bool)`; `availableFor(country)`, filtering by the `countries` list; `adjust(key, year, delta)` with "adjust_days ∈ {−1, 0, +1}".
  - **Custom occasions:** create, update and delete (name, icon, colour, `MM-DD`, days ≥ 1).
- [ ] T094 [US8] Create `src/lib/data/remote/occasion_dates_service.dart`, a port of prototype `syncEvents`:
  - fetch Gregorian years `thisYear−3 … thisYear+1`;
  - replace `aladhan`/`nager` rows for the country, keeping `adjust_days`;
  - set `occasion_dates_updated_at`;
  - return a result of updated (count) / noHolidayData / failed.

  Changing the country in settings triggers a refresh automatically (FR-035).
- [ ] T095 [P] [US8] Create `src/lib/domain/occasions.dart` with `nextOccurrence(key, today)`, `history(key, memberKey)`, `predict(key, memberKey)`, returning `{total, last, hist, g}`, `suggest(date)`, `putAsidePerMonth`, which divides by the months until the occasion (minimum 1), and `hijriLabel(date, lang)` using the `hijri` package (Umm al-Qura).
- [ ] T096 [US8] Implement `OccasionPredictor` in `src/lib/domain/occasion_predictor.dart` using T095, and register it in `src/lib/providers.dart` so that `Forecast.compute` includes occasions in the month where each one starts and excludes `occasion_id` rows from the day-to-day average (US7 scenario 2, FR-030, REQUIREMENTS §6.2). Then re-run T083 with the real predictor.
- [ ] T097 [US8] Extend `src/lib/features/sheets/transaction_sheet.dart`:
  - **Occasion select** (expenses only): None plus enabled occasions, with icon and name.
  - **Default:** `suggest(date)` for new transactions, re-suggested when the date changes unless the user picked one themselves (FR-037).
  - **Presets:** `presetOccasionKey` from the occasion screen.
- [ ] T098 [US8] Create `src/lib/features/planner/occasions_tab.dart`:
  - **KPIs:** "Occasions · next 12 months" total, and "Next occasion" with the days left.
  - **"Next 12 months" list:** icon, name, a countdown chip (warn within 30 days, "Happening now" during the occasion), date, "≈ expected", and "Last time {v} · ↑/↓ %". Tapping a row opens `/occasions/:key`.
  - **`ev_hint`** text.
  - **"Dates" card:** a country select (6 countries), the sources note, "Built-in dates" or "Updated {date}", and an **Update** button showing the "Updating…" state and the result toasts `ev_synced`, `ev_no_holiday` or `ev_sync_fail`.
  - **"Tracked occasions":** switches for the occasions available in the country, each with its source label, plus "+ Add occasion" (custom).
- [ ] T099 [US8] Create `src/lib/features/occasion_detail/occasion_screen.dart`:
  - **Header:** icon, name, source.
  - **Hero** in the occasion's colour: expected amount, long date, days left, the Hijri date for Hijri occasions, and "Put aside {v} a month to be ready".
  - **"Previous years vs expected":** bars, with `PredictedBar` for the expected year.
  - **"Expected by category":** each with "Last time {v}".
  - **"Who spent last time":** legend.
  - **"Last time · {year}":** transactions, with "+ Add" opening the sheet with `presetOccasionKey`.
  - **Hint:** `ev_hint_d` or `ev_hint_one`, and the empty state `ev_none`.
  - **Adjust date ±1 day** for the next occurrence, through `OccasionSheet` (FR-040).
- [ ] T100 [US8] Create `src/lib/features/sheets/occasion_sheet.dart`:
  - **Custom occasion add/edit:** name (1–30), icon (from the category icon set), colour, date `MM-DD`, and days (1–30).
  - **Delete:** tap twice. Tagged transactions keep their tag text in history but lose their link to the occasion.
  - **Built-in mode:** shows only the ±1 day adjustment for a chosen year.
- [ ] T101 [US8] Add the next-occasion row (icon, name, countdown chip, date, "≈ expected" in warn colour) to `src/lib/features/home/coming_up_card.dart`, and the occasion tag (icon + name) to `src/lib/widgets/common/transaction_row.dart`.

**Checkpoint**: The forecast includes occasions, and US7 and US8 are complete.

---

## Phase 10: User Story 9 - Add own categories (Priority: P3)

**Goal**: User categories alongside the locked built-in ones, available everywhere, and deleted without losing history.

**Independent Test**: Add "Pets", use it in an expense and a budget, rename it, delete it, and check that its transactions moved to "Other" (spec US9 scenarios 1–3).

### Tests for User Story 9

- [ ] T102 [P] [US9] Write `src/test/unit/db/categories_repository_test.dart`:
  - the name rules "1–20 chars, unique within type (case-insensitive, whitespace-collapsed) against user categories and built-in `en`/`ar` names", so that "groceries" and "البقالة" are refused as expense names while "Pets" is allowed once as expense and once as income;
  - the type can't change after creation;
  - delete re-points transactions and recurring items to `other_e`/`other_i`, removes the budget and tombstones the category, all in one database transaction (FR-009).

### Implementation for User Story 9

- [ ] T103 [US9] Create `src/lib/data/repositories/categories_repository.dart` with `watchUser(type)`, `create(type, name, icon, color)` (icon ∈ the 24 `CAT_ICONS`; colour ∈ the 12 `CAT_COLORS`, from the prototype), `update(id, name, icon, color)`, `delete(id)` and `usageCounts()`.
- [ ] T104 [US9] Create `src/lib/domain/category_catalog.dart`, which merges the built-in categories (T015) with the user categories: `of(type)` lists built-in first, `byId(id)`, and `displayName(id, lang)`, which shows a user category's name as typed (REQUIREMENTS FR-CAT-06). Replace every direct use of `builtin_categories` in the sheet, budgets, reports, member and occasion breakdowns, search and CSV with this catalog (FR-010).
- [ ] T105 [US9] Create `src/lib/features/settings/categories_screen.dart`:
  - an Expenses/Income segment;
  - "Your categories": rows with icon, name, "Used in {n} transactions" or "Not used yet", and a chevron that opens the sheet, plus the empty state `no_my_cats` and "+ Add category";
  - "Built-in categories": rows with 🔒 "Built-in" that can't be tapped;
  - the `cats_hint` text.

  Also add the Settings row "Categories" with the chip "{b} built-in · {c} yours".
- [ ] T106 [US9] Create `src/lib/features/sheets/category_sheet.dart`:
  - a live preview (large icon and name);
  - a Type segment, shown for new categories only;
  - Name (max 20), with the errors `err_name` and `err_cat_dup`;
  - a grid of 24 icons and 12 colour swatches;
  - Save;
  - in edit mode, "Delete category" (tap twice) with the hint `del_cat_hint`.

**Checkpoint**: US9 works on its own.

---

## Phase 11: User Story 10 - Understand spending and export it (Priority: P3)

**Goal**: The Reports screen and CSV export.

**Independent Test**: Every report figure equals manual totals, and the CSV opens in a spreadsheet app with readable Arabic (spec US10 scenarios 1–2).

### Tests for User Story 10

- [ ] T107 [P] [US10] Write `src/test/unit/domain/reports_test.dart`:
  - average daily spend uses the days elapsed for the current month (13 on 2026-11-13) and the full month otherwise;
  - "vs last month" %;
  - category shares (top 7);
  - the 6-month income and expense series.
- [ ] T108 [P] [US10] Write `src/test/unit/csv/csv_export_test.dart` against contracts/csv-export.md:
  - the UTF-8 BOM, CRLF and RFC 4180 quoting;
  - the 12 columns in order, with the `amount_<MAIN>` header;
  - transfers as `type = transfer` with `to_account`;
  - amounts converted with each row's snapshot;
  - sample and deleted rows excluded.

### Implementation for User Story 10

- [ ] T109 [P] [US10] Create `src/lib/domain/reports.dart` with `MonthKpis(income, expenses, avgDaily, vsLastPercent)`, `categoryShares(ym)` and `sixMonthSeries(ym)`.
- [ ] T110 [US10] Create `src/lib/features/reports/reports_screen.dart`:
  - the month selector;
  - 4 KPIs;
  - "Spending by category": `DonutChart` with "Spent", the total in the centre, and a top-7 legend with %;
  - "Last 6 months": `PairBars`, with the selected month highlighted;
  - "Spending by member": `ShareBar` with a legend, and "View all" going to `/family`.
- [ ] T111 [P] [US10] Create `src/lib/data/export/csv_writer.dart` per contracts/csv-export.md, about 30 lines and with no package.
- [ ] T112 [US10] Add an "Export CSV" button to Settings › Data in `src/lib/features/settings/settings_screen.dart`. It writes `moneyfollow-transactions-YYYY-MM-DD.csv` to a temporary folder and shares it with `share_plus`.

**Checkpoint**: All release 1.0 user stories work on their own.

---

## Phase 12: Release 1.0 completion: backup, first launch, notifications, app lock

**Purpose**: Release 1.0 requirements that span stories:
- FR-061 – FR-064, which are US1 acceptance scenarios 7–9;
- FR-022, notifications for US2, US6 and US8;
- FR-057, app lock.

### Backup file (FR-061, FR-062)

- [ ] T113 [P] [US1] Create `src/lib/core/crypto/kdf.dart` and `src/lib/core/crypto/aead.dart`. They provide Argon2id (memory 19,456 KiB, 2 iterations, parallelism 1, 16-byte salt) and AES-256-GCM (12-byte nonce) through `cryptography`/`cryptography_flutter`, with `deriveKey(password, salt)`, `encrypt(key, plaintext) → (nonce, ciphertext+tag)` and `decrypt`, which throws `WrongKey` when GCM authentication fails.
- [ ] T114 [US1] Create `src/lib/data/backup/backup_codec.dart` per contracts/backup-file.md:
  - **Layout:** the `MFBACKUP` magic, container version 1, flags, the header length, the plaintext header JSON (app, appVersion, schemaVersion, createdAt, deviceName, counts, payloadSha256, kdf, cipher), and the body = gzip(payload JSON), optionally AES-GCM encrypted.
  - **Payload:** all family tables including tombstones, and excluding `is_sample = 1`, device prefs, `sync_outbox` and the PIN.
- [ ] T115 [US1] Write `src/test/unit/backup/backup_roundtrip_test.dart`:
  - export then import into an empty database gives identical rows, with and without a password;
  - a wrong password → `WrongPassword` and the data is unchanged;
  - `schemaVersion` 2 → `NewerVersion`;
  - truncated bytes or a bad magic → `Damaged`;
  - a SHA mismatch → `Damaged`;
  - sample rows are never included.
- [ ] T116 [US1] Create `src/lib/data/backup/backup_service.dart`:
  - **`createBackup({password})`:** returns the file path `MoneyFollow-YYYY-MM-DD.mfbackup` and sets `last_backup_at`.
  - **`readHeader(file)`.**
  - **`restore(file, {password})`:** replaces all family tables in ONE database transaction, trims `sync_outbox`, sets `last_backup_at`, and reloads the providers.
- [ ] T117 [US1] Create `src/lib/features/settings/backup_screen.dart`:
  - **"Back up now":** a dialog with an optional password and confirmation, then the share sheet via `share_plus`.
  - **"Restore from backup":** `file_picker`, then a password prompt if the file is encrypted, then a confirm dialog showing date, device, counts and size and saying it replaces the current data.
  - **Status:** "Last backup {date}".
  - **"Backup reminder" switch.**
  - **Errors:** clear messages for Damaged, NewerVersion and WrongPassword.
- [ ] T118 [US1] Create `src/lib/services/backup_reminder.dart` and show the reminder dialog on app open in `src/lib/app.dart`. The rules come from contracts/backup-file.md "Backup reminder": more than 7 days since the last backup or never backed up; data changed since then; not snoozed or off; not in sample mode. The actions are "Back up now", "Remind me in 3 days" and "Don't remind me". Add a unit test in `src/test/unit/backup/backup_reminder_test.dart`.

### First launch and sample data (FR-063, FR-064)

- [ ] T119 [US1] Create `src/lib/features/setup/setup_flow.dart` with the steps `/setup/language`, `/setup/currency`, `/setup/members` and `/setup/start`:
  1. **Language** (ar/en) plus "Restore from backup", which uses T116.
  2. **Main currency and country**, defaulting from the device locale/region with fallback EGP and Egypt; this also triggers the occasion date refresh when online.
  3. **Members** (optional), using `MemberSheet`.
  4. **Start:** "Explore with sample data" or "Start with my own data".

  Every step has a "Skip" option. Finishing sets `setup_completed`.
- [ ] T120 [US1] Create `src/lib/data/sample/sample_mode_service.dart`:
  - **`start()`:** inserts `SampleData.generate(today)` and sets `sample_mode` and `sample_started_at`.
  - **`clear()`:** hard-deletes every `is_sample = 1` row AND every row with `created_at >= sample_started_at`, keeps the setup choices (settings, members added in setup), and turns sample mode off.

  Sample rows never enter the outbox (T018 trigger), the backup (T114), or the reminder (T118).
- [ ] T121 [US1] Create `src/lib/features/shell/sample_banner.dart`: a visible "Sample data" banner on every shell screen while `sample_mode` is on, with "Clear sample data and start" behind a warning dialog. Add the widget test `src/test/widget/sample_mode_test.dart` for US1 scenario 9.

### Notifications (FR-022)

- [ ] T122 [P] Create `src/lib/services/notification_scheduler.dart`:
  - **Setup:** initialize `flutter_local_notifications`, `timezone` and `flutter_timezone`.
  - **`rebuild()`:** cancels everything and schedules, for the next 30 days at 09:00 local time, the bill due tomorrow and today [US2] and each occasion 30 days before with "put aside" [US8].
  - **`onTransactionSaved()`:** fires an immediate budget notification when a category crosses 80 % or 100 % in the current month [US6].
  - **Switches:** each type respects its `notifications.*` switch.
  - **Calls:** `rebuild()` runs on app start and after data changes (debounced 2 s).
- [ ] T123 Create `src/lib/features/settings/notifications_screen.dart`, with three switches (bills, budgets, occasions). The first time one is turned on, request `POST_NOTIFICATIONS` on Android 13+ or the iOS permission.

### App lock (FR-057)

- [ ] T124 [P] Create `src/lib/services/app_lock.dart`:
  - **PIN:** 4–6 digits, stored as a salted Argon2id hash in `secure_store`.
  - **Biometrics** via `local_auth`, always with the PIN as fallback.
  - **When to lock:** on cold start, and on resume after 60 s or more in the background.
  - **App switcher:** hide content while locked (`FLAG_SECURE` on Android while locked).
- [ ] T125 Create `src/lib/features/settings/security_screen.dart` (Off / PIN / PIN + biometrics; set and change the PIN with confirmation) and `src/lib/features/lock/lock_screen.dart` (PIN pad and biometric button). The router redirects to `/lock` while locked.

### Diagnostics (research R-19)

- [ ] T126 [P] Add Settings › About to `src/lib/features/settings/settings_screen.dart`: the app version, and "Share diagnostic log", which shares `AppLog.readAll()` as a text file.

**Checkpoint**: Release 1.0 is feature-complete. Run quickstart.md §1–3.

---

## Phase 13: User Story 5 - Sync family devices through Google Drive (Priority: P2, release 1.1)

**Goal**: Optional Google Drive sync in two modes, end-to-end encrypted with a recovery key, per-row last-writer-wins, and restore on a new phone (FR-049 – FR-056, FR-058).

**Independent Test**: On two phones connected to the same Drive, add, edit and delete records on each, including offline, then sync and compare. Reinstall and restore with the recovery key (spec US5 scenarios 1–10; quickstart §4).

**Blocking first step**: T127 decides how mode B works. If it fails, the product owner chooses between the restricted `drive` scope and shipping mode A only (plan.md Complexity Tracking).

- [ ] T127 [US5] **Spike (2 days)** at `src/integration_test/spike_drive_mode_b_test.dart` and in notes `specs/001-family-finance-app/spike-drive-mode-b.md`:
  1. On a real Android phone and a real iPhone, parent A's app creates the `MoneyFollow` folder with `drive.file` and shares it with B's account (`role: writer`).
  2. B selects the folder through Google Picker in a Custom Tab or ASWebAuthenticationSession, and the folder id returns through an app link.
  3. Verify that B's app can list and read files A creates **afterwards**, and that A can read B's.
  4. Record the result and the decision.
- [ ] T128 [P] [US5] Add the dependencies `google_sign_in` ^7.2.0, `googleapis` ^19.0.0, `extension_google_sign_in_as_googleapis_auth` ^3.0.0 and `workmanager` ^0.10.10 to `src/pubspec.yaml`. Configure the OAuth clients for Android (SHA-1 for debug and release) and iOS (`GIDClientID`, URL scheme in `Info.plist`), and document the setup in `README.md`.
- [ ] T129 [P] [US5] Create `src/lib/data/sync/sync_crypto.dart` for envelope encryption:
  - **`setupFamilyKeys(passphrase)`:** a random 256-bit data key (DK) wrapped by the Argon2id(passphrase) key and by a random 32-byte **recovery key**, rendered as 8 groups of base32.
  - **`unlockWithPassphrase` / `unlockWithRecoveryKey`.**
  - **`changePassphrase`:** rewraps the DK only.

  Unlocked keys are kept in `secure_store`. Add tests in `src/test/unit/sync/sync_crypto_test.dart`: either secret unlocks; a wrong one fails; changing the passphrase keeps the DK.
- [ ] T130 [US5] Create `src/lib/data/sync/drive_store.dart` for the folder layout in contracts/drive-sync.md:
  - **Mode A** (`drive.appdata`, `appDataFolder`) and **mode B** (`drive.file`, the shared folder chosen in T127).
  - **Files:** `family.json`, `snapshots/`, `changes/<deviceId>/<seq8>.mfchg`, `devices/<deviceId>.json`.
  - **Atomic uploads:** upload under a temporary name, then rename.
  - **Errors** mapped to `offline`, `auth_revoked`, `quota`, `locked` and `mode_mismatch`.
- [ ] T131 [US5] Create `src/lib/data/sync/sync_engine.dart` per the "Algorithm" in contracts/drive-sync.md:
  1. **Push:** outbox entries above `lastUploadedSeq`, in batches of at most 500 changes or 256 KB.
  2. **Pull:** other devices' files with `seq > last_seq_seen`.
  3. **Apply:** upsert only if `incoming.hlc > local.hlc`, without writing to the outbox (suppress the triggers with a session flag).
  4. **Snapshot:** after 500 applied changes, then delete change files that every device has seen.
  5. **New device:** import the newest snapshot, apply later changes, and assign a new `deviceId`.
  6. **Clock:** call `Hlc.receive` on every incoming HLC.
- [ ] T132 [US5] Write `src/test/unit/sync/sync_engine_test.dart` with a fake in-memory `DriveStore` and two databases:
  - different records edited offline → both kept;
  - the same record → the later HLC wins on both;
  - a delete propagates;
  - an interruption mid-push followed by a retry → no loss or duplicates;
  - a new device restores from snapshot plus changes;
  - sample rows are never synced.
- [ ] T133 [US5] Write `src/integration_test/sync_stress_test.dart`: 500 random offline create/update/delete operations across two simulated devices, then sync both until they match, asserting 0 lost or duplicated rows and identical tables (SC-006).
- [ ] T134 [US5] Create `src/lib/services/sync_scheduler.dart`. It triggers sync:
  - on app open and resume;
  - 5 s after the last local change (debounced);
  - on pull-to-refresh, wired into the Home and Activity `RefreshIndicator`;
  - on "Sync now";
  - in the background about every 6 h: Android uses `workmanager` with a network constraint (unmetered when "Wi-Fi only" is on), and iOS uses BGTaskScheduler on a best-effort basis.
- [ ] T135 [US5] Create `src/lib/features/settings/sync_screen.dart` (FR-053, FR-058):
  - **Connect wizard:** choose mode A or B, sign in with Google, then create or join the family.
    - Creating: set the passphrase, show the recovery key, and require the "I saved it" confirmation.
    - Joining: enter the passphrase or the recovery key.
    - In mode B: share the folder (enter the partner's email) or pick a shared folder.
  - **Status line:** "Synced 2 minutes ago", "Waiting for internet", or "Sync failed – tap to retry".
  - **Controls:** the mode in use, the account, "Sync now", the device list (name, last sync), the "Sync on Wi-Fi only" switch, "Change passphrase", and Disconnect (stops syncing and keeps local data).
- [ ] T136 [US5] Add "Restore from Google Drive" to setup step 1 in `src/lib/features/setup/setup_flow.dart` (FR-055): sign in, unlock with the passphrase or recovery key, and import the snapshot plus changes.
- [ ] T137 [US5] Remove the 1.0 outbox trimming after backup in `src/lib/data/backup/backup_service.dart` once sync is connected. Keep trimming when sync is off. Release 1.0 still trims after each backup.

**Checkpoint**: Release 1.1 is complete. Run quickstart.md §4.

---

## Phase 14: Polish & Cross-Cutting Concerns

- [ ] T138 [P] Write golden tests for Home, Activity, the Transaction sheet, Family, Member, Forecast, Occasions, the Occasion detail screen, Budgets, Reports, Settings and Categories, at 360×800 in ar and en, light and dark, and text scale 1.0 and 2.0, in `src/test/widget/screens_golden_test.dart` (SC-010).
- [ ] T139 [P] Add a debug-only "Seed 3 years" action in `src/lib/features/settings/debug_section.dart` that inserts about 2,000 transactions. Profile every screen on a mid-range Android phone and confirm each opens in under 1 s (SC-002); add indexes or query fixes as needed.
- [ ] T140 [P] Accessibility pass across `src/lib/features/**`:
  - every icon-only button has a semantic label from l10n;
  - tap targets are at least 48 dp;
  - colour is never the only signal: amounts carry signs, budget rows show %, chips have text.
- [ ] T141 [P] Write `src/integration_test/app_flows_test.dart`, automating quickstart.md §3 rows 1–13 on an emulator.
- [ ] T142 Release signing: add the keystore config in `src/android/key.properties` (git-ignored) and `src/android/app/build.gradle.kts`. Add a CI secret step to `.github/workflows/android.yml` that builds a signed release APK.
- [ ] T143 [P] Update `docs/REQUIREMENTS.md` and regenerate the screenshots under `docs/screens/`, adding the new screens: transfer sheet, backup, setup, sample banner, notifications, security, and sync for 1.1 (project rule P7). Update `README.md` with the build and test commands from quickstart.md.
- [ ] T144 Run the full quickstart.md validation (§1–3 for release 1.0, §4 for 1.1), record the results in `specs/001-family-finance-app/checklists/release-validation.md`, and copy the release APK to the project Google Drive folder from the README.

---

## Dependencies & Execution Order

### Phase dependencies

- **Phase 1 Setup:** no dependencies.
- **Phase 2 Foundational:** needs Setup. **It blocks all stories.**
- **Phases 3–11, the release 1.0 stories:** need Foundational. Suggested order: US1 → US2 → US3 → US4 → US6 → US7 → US8 → US9 → US10.
- **Phase 12, release 1.0 completion:** needs US1. T119 uses `MemberSheet` (US3), and the notification scheduler (T122) reads data from US2, US6 and US8.
- **Phase 13, US5 sync (release 1.1):** needs all of release 1.0. T127 (the spike) blocks T130–T136.
- **Phase 14, Polish:** after the stories you intend to ship. T143 and T144 run per release.

### User story dependencies

| Story | Depends on | Notes |
|---|---|---|
| US1 (P1) | Foundational | MVP |
| US2 (P2) | Foundational, US1 sheet (T045) | Adds recurring mode and Repeat to the sheet |
| US3 (P2) | Foundational, US1 sheet and Activity | Forecast parts of Family and Member are added in US7 |
| US4 (P2) | Foundational, US1 accounts (T043) | Transfers change balance queries |
| US6 (P2) | Foundational | Works with built-in categories; user categories join after US9 |
| US7 (P3) | US2 (recurring), US3 screens (T087, T088) | Occasions are 0 until US8 |
| US8 (P3) | US7 (`OccasionPredictor` in T084) | Fills in the forecast's occasion segment |
| US9 (P3) | Foundational, US6 (budgets list) | T104 switches all screens to the merged catalog |
| US10 (P3) | Foundational, US4 (transfers in CSV) | |
| US5 (P2, 1.1) | Release 1.0 complete | Starts with spike T127 |

### Within each story
Write the tests first and make sure they fail, then do repositories and domain code, then screens and sheets, then integrate into Home and Settings.

### Parallel opportunities
- **Setup:** T002–T008 are all [P].
- **Foundational:** T009–T016, T021, T026–T029 and T033–T036 are [P]. The DB chain T017 → T018 → T019 → T020 → T022 → T023 → T024 → T025 is sequential.
- **Each story:** its test tasks are [P], and domain files marked [P] are separate from the repositories.
- **After US1, with more than one developer:** US2, US3, US4, US6 and US9 can proceed in parallel.

---

## Parallel Example: User Story 1

```bash
# Tests first (parallel):
Task: "T040 transactions_repository_test.dart"
Task: "T041 monthly_totals_test.dart"

# Then independent implementation files (parallel):
Task: "T043 accounts_repository.dart"
Task: "T044 domain/monthly_totals.dart"

# Then sequential UI: T045 sheet → T046 row → T047 Home → T048 Activity → T049 Settings → T050/T051 widget tests
```

## Parallel Example: User Story 8

```bash
Task: "T089 predict_test.dart"
Task: "T090 suggest_test.dart"
Task: "T091 date_services_test.dart"
Task: "T092 aladhan_client.dart + nager_client.dart"
Task: "T095 domain/occasions.dart"
```

---

## Implementation Strategy

### MVP first (User Story 1)
1. Phase 1 Setup, then Phase 2 Foundational.
2. Phase 3 US1. **STOP and validate**: an offline tracker in Arabic and English with month browsing, search and filters. Get the APK from CI and demo it.

### Release 1.0 (incremental)
3. US2 recurring → US3 family → US4 currency and transfers → US6 budgets. Each one is demoable on its own.
4. US7 forecast → US8 occasions → US9 categories → US10 reports and CSV.
5. Phase 12: backup, setup with sample data, notifications, app lock → quickstart §1–3 → **ship 1.0**.

### Release 1.1
6. Spike T127, and the product owner decides mode B → Phase 13 sync → quickstart §4 → **ship 1.1**.

### Notes
- `[P]` means a different file with no dependency on an unfinished task.
- Commit after each task or logical group, and stop at any checkpoint to validate.
- Local Android builds are blocked by Smart App Control (D-1), so use the CI APK (T008) until that is resolved.
