# Quickstart: build, run and validate MoneyFollow v1

This is a guide for checking that the app works end to end. Implementation steps belong in `tasks.md`.

## Prerequisites (development PC)

| Tool | Location | Check |
|---|---|---|
| Flutter 3.50 (stable) / Dart 3.14 | `D:\flutter` | `flutter --version` |
| Android SDK 36, JDK 17 | `D:\Android\Sdk`, `D:\Android\jdk-17` | `flutter doctor` |
| Emulator (AVDs in `D:\Android\avd`) | see README "Emulators" | `flutter emulators` |
| GitHub Actions | `.github/workflows/android.yml` (added by tasks) | APK artifact on each push |

**Smart App Control blocks `impellerc.exe`** on the dev PC (REQUIREMENTS D-1), so local Android builds fail until it is turned off. Until then, use the CI build to get an APK, and use the steps below that don't need a local build: unit tests and `flutter analyze`.

## 1. Static checks and unit tests (no device)

```powershell
cd src
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # drift + riverpod code generation
flutter analyze                                             # expect: No issues found
flutter test test/unit                                      # domain + database tests
```

Expected: everything passes. The key suites are:

| Suite | Proves |
|---|---|
| `test/unit/money/conversion_test.dart` | FR-014/016: past rows use their own snapshot; new rate affects new rows/forecast only (User Story 4, scenario 2) |
| `test/unit/recurring/advance_due_test.dart` | REQUIREMENTS §6.5 incl. 31st → last day (User Story 2, scenario 1) |
| `test/unit/forecast/forecast_test.dart` | §6.2 on the prototype reference data set (SC-008) |
| `test/unit/occasions/predict_test.dart` | §6.3: Ramadan 6,900 → 7,800 ⇒ ≈ 8,817 (User Story 8, scenario 1); clamp 0.85–1.5 |
| `test/unit/occasions/suggest_test.dart` | §6.4 window −14 … last day |
| `test/unit/db/member_delete_test.dart`, `category_delete_test.dart` | FR-026, FR-009: no transaction lost |
| `test/unit/db/transfer_test.dart` | FR-060: balances move, income/expense totals unchanged |
| `test/unit/backup/backup_roundtrip_test.dart` | FR-061: export → import gives identical rows; wrong password / newer schema / corrupt file refused |
| `test/unit/csv/csv_export_test.dart` | [contracts/csv-export.md](./contracts/csv-export.md) incl. BOM |
| `test/unit/l10n/arb_parity_test.dart` | every key exists in `app_en.arb` and `app_ar.arb` (FR-044) |

## 2. Widget and golden tests

```powershell
flutter test test/widget
```

The golden tests render Home, Activity, the Transaction sheet, Family, Forecast and an Occasion screen at 360×800:
- in `ar` and `en`;
- in light and dark;
- at text scale 1.0 and 2.0.

They cover SC-010. Compare against `test/widget/goldens/`.

## 3. Run on an emulator or phone

```powershell
flutter run                       # debug, needs local build (blocked by SAC, see above)
# or install the CI artifact:
adb install app-release.apk
```

Then walk through the scenarios below:

| # | Steps | Expected | Covers |
|---|---|---|---|
| 1 | Fresh install → setup: Arabic, EGP/Egypt, add "Omar", choose **Explore with sample data** | Home shows sample family with "Sample data" banner, RTL layout | FR-063/064 |
| 2 | Tap **Clear sample data and start** | Empty Home; settings from setup kept | FR-064 |
| 3 | **+** → 250, Groceries, Save; time it | Appears in Recent; totals change; < 15 s | US1, SC-001 |
| 4 | Airplane mode; use every tab and add/edit/delete | Everything works | SC-004 |
| 5 | Add monthly rent due on the 31st, Mark paid | Transaction today; next due = last day of next month | US2 |
| 6 | Add 100 USD expense at 1 USD = 50; change rate to 52; add another | First counts 5,000, second 5,200; forecast uses 52 | US4, FR-016 |
| 7 | Transfer 2,000 Bank → Cash | Balances move; month income/expense unchanged | FR-060 |
| 8 | Add category "Pets", budget 1,000, use it; delete it | Moves to Other; budget gone | US9 |
| 9 | Planner › Occasions → Update; change country to United States | Christmas 25 Dec; Sham El-Nessim & Mother's Day hidden | US8 |
| 10 | Settings › Backup → Back up (with password) → share to Files; reinstall; setup step 1 → Restore | Identical data; wrong password refused | FR-061, SC-011 |
| 11 | Set device date +8 days (or debug flag) | Backup reminder shown | FR-062 |
| 12 | Turn on app lock (PIN), background and resume | Lock screen | FR-057 |
| 13 | Export CSV, open in Excel / Google Sheets | Arabic readable, 12 columns | FR-043 |
| 14 | Switch Arabic ↔ English on every screen at largest font size | No clipping or wrong mirroring | SC-010 |
| 15 | Seed 3 years (~2,000 transactions, debug menu) and open every screen | Each opens < 1 s on a mid-range phone | SC-002 |

## 4. Release 1.1: sync validation (two phones)

These scenarios run only after release 1.1 is built. They follow spec User Story 5, scenarios 1–10, and [contracts/drive-sync.md](./contracts/drive-sync.md):

1. Phones A and B are connected in mode A (one shared family account): an expense added on A appears on B within 1 minute (SC-005).
2. Both phones go offline and edit different records, then the same record: after sync, both edits survive and the latest edit wins on the shared record.
3. The `sync_stress` integration test makes 500 random offline edits across two simulated devices and checks for 0 lost or duplicated records (SC-006).
4. A reinstall followed by connecting and entering the recovery key restores 100 % of the data (SC-007).
5. Repeat scenario 1 in mode B (own accounts with a shared folder), after spike R-09 confirms the approach.
