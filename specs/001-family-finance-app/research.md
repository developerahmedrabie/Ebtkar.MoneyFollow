# Research: MoneyFollow v1 technical decisions

**Feature**: [spec.md](./spec.md) · **Plan**: [plan.md](./plan.md) · Date: 2026-11-15

Every "NEEDS CLARIFICATION" from the Technical Context is resolved here. Package versions are listed in [§ Package versions](#package-versions).

---

### R-01 Platform, language and project
- **Decision:** Flutter 3.50 stable / Dart 3.14, already installed at `D:\flutter`. The app is the existing project in `src/` (package `com.ebtkar.money_follow`). It targets Android 7.0+ (API 24) and iOS 15+.
- **Rationale:** the project and tooling already exist. One code base covers both phones (REQUIREMENTS NFR-09).
- **Alternatives considered:**
  - Native Kotlin plus Swift: two code bases, which doubles the work.
  - React Native: rejected because the team environment is already Flutter.

### R-02 State management
- **Decision:** Riverpod (`flutter_riverpod` with `riverpod_annotation`/generator). Providers expose drift `Stream`s, so screens update live after every write.
- **Rationale:**
  - Testable without widgets, and providers can be overridden in tests.
  - Works naturally with drift's reactive queries.
  - Can be scoped per selected month or member.
- **Alternatives considered:**
  - Bloc: more boilerplate for this many read-mostly screens.
  - Provider: weaker for derived and async state.
  - Plain `setState`: doesn't scale to roughly 20 screens.

### R-03 Local database
- **Decision:** SQLite through **drift**, using `drift_flutter` to open it and `sqlite3_flutter_libs`/bundled SQLite. Schema version 1 is described in [data-model.md](./data-model.md). Migrations use drift's `stepByStep` with schema dumps checked into `src/drift_schemas/`.
- **Rationale:**
  - Relational queries (by month, member, category or occasion) and indexes meet the 2,000+ transaction performance target (SC-002).
  - Database transactions keep delete and re-point operations atomic (FR-009, FR-026).
  - Database triggers fill the sync outbox.
  - Type-safe generated code.
- **Alternatives considered:**
  - Isar / Hive / ObjectBox: weaker relational queries and migrations. Isar's maintenance is uncertain.
  - Raw `sqflite`: no compile-time checks and no reactive streams.
  - Storing JSON in preferences, as the prototype does: doesn't scale and has no transactions.

### R-04 Money and rates representation
- **Decision:**
  - Money is stored as integer minor units plus an ISO currency code, with decimals per currency (KWD has 3).
  - Rates are stored as integer micro-units of EGP in **immutable rate snapshots**. Each transaction and transfer references the snapshot that was current when it was recorded.
  - Calculations use `Decimal`-free integer arithmetic with rounding only at display (banker's rounding off; round half up).
- **Rationale:**
  - Implements the clarification (FR-014/FR-016): past rows never change.
  - One snapshot row per rate edit avoids copying 7 rates onto every row.
  - Integer storage avoids floating-point drift in totals.
- **Alternatives considered:**
  - Storing a `double`: rounding errors.
  - Storing only the transaction's own rate: can't convert to a *changed* main currency, which needs both rates from the same moment.

### R-05 Business logic placement
- **Decision:** All REQUIREMENTS §6 calculations live in pure Dart classes in `lib/domain/` with no Flutter imports:
  - conversion, monthly totals, budget usage;
  - due-date advance;
  - forecast;
  - occasion history, prediction and suggestion;
  - account balances.

  Repositories fetch rows, and the domain services compute.
- **Rationale:** these rules carry the most risk. Pure functions can be unit tested against the prototype's reference data (SC-008), and the prototype JS is the oracle.
- **Alternatives considered:**
  - SQL-only aggregation: harder to test.
  - Logic inside widgets: untestable.

### R-06 Navigation
- **Decision:** `go_router` with a `StatefulShellRoute` for the 5-tab bottom bar. Routes are defined in [contracts/screens-and-routes.md](./contracts/screens-and-routes.md). A redirect sends users to `/setup` until setup is done, and to `/lock` while the app is locked.
- **Rationale:** each tab keeps its own back stack, and the routes double as test entry points.
- **Alternatives considered:** Navigator 2.0 by hand (verbose), auto_route (needs code generation; no advantage here).

### R-07 Localization and RTL
- **Decision:**
  - Use `flutter_localizations` + `gen-l10n` with `lib/l10n/app_en.arb` and `app_ar.arb`, seeded from the prototype's `I18N` dictionary (~350 keys).
  - `Directionality` follows the locale.
  - Numbers are formatted with `intl` `NumberFormat` using `en` digits in both languages (FR-045).
  - Use directional widgets (`EdgeInsetsDirectional`, `AlignmentDirectional`) everywhere.
  - Hijri display uses the Umm al-Qura conversion from the `hijri` package. Its result is cross-checked against the Aladhan dates, which are the stored dates.
  - A test checks that both ARB files have the same keys.
- **Rationale:** this is the official Flutter approach. ARB parity is enforceable in CI. Western digits are an explicit requirement.
- **Alternatives considered:**
  - `easy_localization`: a third-party runtime loader with no advantage here.
  - `intl` Hijri: not available; Dart `intl` has no Islamic calendar.

### R-08 Sync-ready data in 1.0 and conflict ordering
- **Decision:**
  - Ids are UUID v7.
  - `updated_at` is a **hybrid logical clock** string.
  - Deletes are soft deletes (tombstones).
  - Database triggers write a `sync_outbox` row on every change to synced tables, excluding sample rows.

  The outbox is trimmed after each backup in 1.0.
- **Rationale:**
  - The clarified release plan needs 1.1 to sync 1.0 data with no migration loss.
  - An HLC gives correct last-writer-wins even when phone clocks are wrong.
- **Alternatives considered:**
  - Auto-increment ids: they collide across phones.
  - Plain wall-clock timestamps: wrong winner when a phone's clock is off.
  - CRDT libraries: per-field merging is overkill for per-record LWW (FR-050).

### R-09 Google Drive sync design (release 1.1)
- **Decision:**
  - Use `google_sign_in` + `googleapis` (Drive v3) + `extension_google_sign_in_as_googleapis_auth`.
  - Each device writes its own append-only change files plus periodic snapshots. The design is in [contracts/drive-sync.md](./contracts/drive-sync.md).
  - **Mode A** (shared family account, default) uses `drive.appdata`.
  - **Mode B** (own accounts with a shared folder) uses `drive.file`.
- **Risk found (mode B):**
  - Under `drive.file`, an app can see only files *this user* created or opened with the app, or picked in Google Picker. A folder created by the other parent is invisible to the second parent's app until they **pick it with Google Picker**.
  - Google documents Picker for desktop and mobile apps through OAuth and a browser flow, but there is no clear native Android picker.
  - It is also undocumented whether picking a folder grants access to files the *other* user adds to it later. ([Choose Google Drive API scopes](https://developers.google.com/workspace/drive/api/guides/api-specific-auth), [Picker for desktop & mobile apps](https://developers.google.com/workspace/drive/picker/guides/desktop-mobile-picker))
- **Mitigation:**
  - Release 1.1 starts with a **2-day spike** that proves mode B on real Android and iOS phones: Picker in a Custom Tab or ASWebAuthenticationSession, returning the folder id through an app link, and then reading files the other user creates later.
  - If the spike fails, mode B falls back to the full `drive` scope. That scope is **restricted** and needs a Google security assessment (CASA), so it would add cost and time.
  - A second fallback is to ship mode A only and revisit. The product owner decides after the spike.
- **Rationale:**
  - Each device only appends its own files, so devices never overwrite each other (FR-051).
  - Per-row LWW meets FR-050.
  - Snapshots bound the time a new phone takes to restore (FR-055).
- **Alternatives considered:**
  - Uploading the SQLite file: two phones overwrite each other.
  - Firebase/Supabase: needs a server and accounts, which conflicts with "no MoneyFollow server" (NFR-08).

### R-10 Encryption (backup password and sync passphrase)
- **Decision:** the `cryptography` (+ `cryptography_flutter` for native speed) package, with:
  - AES-256-GCM for data;
  - Argon2id for password and passphrase key derivation;
  - envelope encryption for sync: a random data key wrapped by both the passphrase key and the recovery key (FR-054 clarification).

  Keys and the PIN hash are kept in `flutter_secure_storage` (Keychain / Android Keystore).
- **Rationale:**
  - These are standard, authenticated ciphers, and GCM detects wrong passwords and tampering.
  - Envelope encryption lets the passphrase change without re-encrypting the Drive data.
  - Recovery works through the second wrapped copy of the key.
- **Alternatives considered:**
  - PBKDF2: weaker against GPUs, though acceptable as a fallback if Argon2 is slow on old phones. The parameters are recorded in the file header, so they can change later.
  - Hand-rolled AES-CBC: no integrity check.

### R-11 Backup file
- **Decision:** a `.mfbackup` container with a plaintext header and a gzip JSON body, optionally AES-GCM encrypted ([contracts/backup-file.md](./contracts/backup-file.md)). It is shared with `share_plus` and opened with `file_picker`. Compression uses `dart:io` `GZipCodec`.
- **Rationale:**
  - The header lets the restore screen show the date and counts before asking for the password (FR-061).
  - JSON is version-tolerant.
  - The body reuses the snapshot format planned for 1.1 sync.
- **Alternatives considered:**
  - Copying the raw `.sqlite` file: tied to the schema, can't be filtered (sample rows), and unsafe to copy while the database is open.

### R-12 Notifications and reminders
- **Decision:** `flutter_local_notifications` with `timezone` + `flutter_timezone`, scheduled at 09:00 local time for:
  - bills due tomorrow and today;
  - occasions 30 days before;
  - budgets at 80 % / 100 %, fired right after the transaction that crosses the threshold.

  The schedule is rebuilt after every data change and on app start, for the next 30 days. The backup reminder (FR-062) is in-app and checked on open, not a notification.
- **Rationale:**
  - Local scheduling works offline and needs no server (spec Assumptions).
  - Android 13+ needs the `POST_NOTIFICATIONS` permission, requested the first time a notification switch is turned on.
  - Exact alarms are not needed, so `SCHEDULE_EXACT_ALARM` is avoided.
- **Alternatives considered:** Firebase Cloud Messaging, which needs a server.

### R-13 App lock
- **Decision:** `local_auth` for biometrics, plus a 4–6 digit PIN stored as a salted Argon2id hash in secure storage. The app locks on cold start and after 60 s in the background, and the lock screen hides content in the app switcher (`FLAG_SECURE` on Android only while locked).
- **Rationale:** a standard pattern. Biometrics always fall back to the PIN.
- **Alternatives considered:** device credential only, which some users don't set up.

### R-14 Charts
- **Decision:** small custom `CustomPainter` widgets for:
  - bars: pairs, stacked, and predicted with stripes;
  - donut;
  - share bar.
- **Rationale:**
  - The prototype's charts are simple.
  - Custom painters give exact control of RTL mirroring, the striped "predicted" bar and theming, with no dependency.
  - Golden tests lock their look.
- **Alternatives considered:** `fl_chart`, which is capable but heavier, and its RTL behaviour and stripe pattern need workarounds. Revisit if charts grow.

### R-15 Sample data (FR-064)
- **Decision:** port the prototype's `demo()` generator to Dart. It creates rows with a deterministic seed and `is_sample = 1`, dated relative to the install date: 3 years back, with yearly inflation and occasion spending. Clearing hard-deletes `is_sample = 1` rows and every row created after sample mode began, then turns sample mode off.
- **Rationale:** the same data as the prototype means the same screenshots and the same reference numbers for tests (SC-008).
- **Alternatives considered:** a bundled JSON fixture, but its fixed dates go stale.

### R-16 CSV export
- **Decision:** a hand-written RFC 4180 writer (about 30 lines) with a UTF-8 BOM ([contracts/csv-export.md](./contracts/csv-export.md)).
- **Rationale:** the format is trivial, and a dependency isn't worth it.
- **Alternatives considered:** the `csv` package (fine, but unnecessary).

### R-17 Testing strategy
- **Decision:**
  - **Unit:** `flutter test` for domain and database code, using drift's in-memory `NativeDatabase.memory()`.
  - **Widget:** widget and golden tests for RTL/LTR, light/dark and text scale 2.0 (SC-010).
  - **Integration:** `integration_test` for the quickstart flows on an emulator.
  - **Mocks:** `mocktail` for HTTP and Drive.
  - **Oracle:** the prototype's JS formulas, ported test-first.
- **Rationale:** the riskiest logic (§6 formulas, delete and re-point rules, backup round-trip) is covered without a device.
- **Note:** unit tests on Windows need a native SQLite. The `sqlite3` package's build hooks bundle it; if a hook is blocked (AVG or Smart App Control), place `sqlite3.dll` on PATH under `D:\`.

### R-18 Build and distribution under Smart App Control
- **Decision:**
  - Add a GitHub Actions workflow on Ubuntu with Java 17 and Flutter 3.50. It runs `analyze`, `test` and `build apk --release`, and uploads the APK as an artifact.
  - The developer copies the APK to the project's Drive folder (README).
  - Local builds work again once Smart App Control is turned off (D-1 is still open).
- **Rationale:** this unblocks builds today without changing PC security, and keeps CI checks on every push.
- **Alternatives considered:** turning off Smart App Control (the user's call), or building inside a Linux VM or WSL.

### R-19 Observability
- **Decision:** no analytics or remote crash reporting in v1. Errors are logged locally to a ring-buffer file (last 500 lines). Settings › About › "Share diagnostic log" lets the user send it voluntarily.
- **Rationale:** this matches "financial data stays on the device" (NFR-08) and the absence of a server. It resolves the low-impact gap left after `/speckit-clarify`.
- **Alternatives considered:** Firebase Crashlytics, which sends device data to a third party. Revisit with explicit opt-in later.

---

## Package versions

These are the latest on pub.dev on 2026-11-15, the plan date. Pin with `^` in `pubspec.yaml`; tasks re-check versions at implementation time.

| Package | Version | Published | Use | Release |
|---|---|---|---|---|
| drift / drift_dev | 2.35.4 / 2.35.3 | 2026-11-08 | Database, codegen (R-03) | 1.0 |
| drift_flutter | 0.3.1 | 2026-07-11 | Opens DB on device | 1.0 |
| build_runner | 2.17.1 | 2026-10-14 | Codegen | 1.0 (dev) |
| flutter_riverpod / riverpod_annotation / riverpod_generator | 3.5.0 / 4.0.8 / 4.0.10 | 2026-11-06 | State (R-02) | 1.0 |
| go_router | 18.1.4 | 2026-11-09 | Navigation (R-06) | 1.0 |
| intl | 0.20.3 | 2026-06-25 | Number/date formatting (R-07) | 1.0 |
| hijri | 3.0.1 | 2026-05-22 | Umm al-Qura display (R-07) | 1.0 |
| cryptography / cryptography_flutter | 2.9.0 / 2.3.4 | 2025-11-21 | AES-GCM, Argon2id (R-10) | 1.0 |
| flutter_secure_storage | 11.2.0 | 2026-09-16 | PIN hash, keys (R-10, R-13) | 1.0 |
| flutter_local_notifications | 23.0.2 | 2026-11-13 | Reminders (R-12) | 1.0 |
| timezone / flutter_timezone | 0.11.2 / 5.1.1 | 2026-10 | Scheduling (R-12) | 1.0 |
| local_auth | 3.0.2 | 2026-07-09 | Biometrics (R-13) | 1.0 |
| share_plus | 13.3.1 | 2026-10-01 | Share backup/CSV (R-11, R-16) | 1.0 |
| file_picker | 13.3.3 | 2026-11-10 | Pick backup to restore (R-11) | 1.0 |
| shared_preferences | 2.5.6 | 2026-10-05 | Device preferences | 1.0 |
| uuid | 4.6.0 | 2026-07-15 | UUID v7 ids (R-08) | 1.0 |
| http | 1.6.0 | 2025-11-10 | Date services (contracts/external-date-apis.md) | 1.0 |
| mocktail | 1.0.5 | 2026-04-10 | Test mocks (R-17) | 1.0 (dev) |
| google_sign_in | 7.2.0 | 2025-09-17 | Sign-in (R-09). The v7 API separates authentication from authorization, so request Drive scopes with `authorizationClient` | 1.1 |
| googleapis | 19.0.0 | 2026-11-12 | Drive v3 (R-09) | 1.1 |
| extension_google_sign_in_as_googleapis_auth | 3.0.0 | 2025-06-26 | Auth bridge (R-09) | 1.1 |
| workmanager | 0.10.10 | 2026-09-07 | Background sync (R-09) | 1.1 |

The existing scaffold dependency `material_ui ^1.1.0` (Flutter 3.50's split-out Material library) stays. `cupertino_icons` can be removed, because the app uses Material icons and emoji.
