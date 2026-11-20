# Implementation Plan: MoneyFollow Family Finance App (version 1)

**Branch**: `main` (Spec Kit feature id `001-family-finance-app`; no branch hook configured) | **Date**: 2026-11-15 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `specs/001-family-finance-app/spec.md`

## Summary

Build the MoneyFollow phone app (Android + iOS) from the clarified spec. The spec has 10 user stories and FR-001 – FR-064, and the prototype in `prototype/index.html` is the visual and behavioural reference. Delivery is in two releases:

- **Release 1.0** is a complete offline family-finance app on one phone. It covers:
  - transactions, transfers, recurring items, budgets, family members, multi-currency with per-transaction rate snapshots, forecast, yearly occasions with prediction, user categories, reports and CSV;
  - Arabic/English RTL;
  - first-launch setup with sample data;
  - backup file + reminder, notifications, app lock.
- **Release 1.1** adds Google Drive sync between the family's phones: shared family account (default) or each parent's own account, end-to-end encrypted with a recovery key.

Technical approach:
- Flutter 3.50 with Riverpod and go_router.
- A drift (SQLite) database designed **sync-ready from day one**: UUID v7 ids, a hybrid logical clock, tombstones, and a trigger-fed outbox.
- All REQUIREMENTS §6 calculations in pure, unit-tested Dart services, ported test-first from the prototype.

## Technical Context

**Language/Version**: Dart 3.14 / Flutter 3.50 stable (`D:\flutter`)

**Primary Dependencies**:
- **1.0:** drift (+ drift_flutter), flutter_riverpod (+ riverpod_generator), go_router, intl + flutter_localizations, hijri, cryptography, flutter_secure_storage, flutter_local_notifications (+ timezone), local_auth, share_plus, file_picker, shared_preferences, uuid, http.
- **1.1:** google_sign_in, googleapis, extension_google_sign_in_as_googleapis_auth, workmanager.

Versions are in [research.md § Package versions](./research.md#package-versions).

**Storage**:
- Local SQLite through drift. This holds family data, schema v1 in [data-model.md](./data-model.md).
- shared_preferences holds device preferences.
- flutter_secure_storage holds the PIN hash and keys.
- Google Drive is used in 1.1 for sync files only.

**Testing**: `flutter test`, split into:
- unit tests (domain + in-memory drift);
- widget and golden tests (ar/en × light/dark × text scale);
- `integration_test` on an emulator;
- `mocktail` for HTTP and Drive.

**Target Platform**: Android 7.0+ (API 24, target 36) and iOS 15+, phones only.

**Project Type**: Mobile app with no backend. External services: Aladhan and Nager.Date (read-only) and Google Drive (1.1).

**Performance Goals**:
- Every screen opens in under 1 s with ~2,000 transactions on a mid-range phone (SC-002).
- Adding an expense takes under 15 s (SC-001).
- A backup of 3 years of data takes under 10 s (SC-011).
- Sync propagates in under 1 min (SC-005, 1.1).

**Constraints**:
- Fully offline (SC-004) and no MoneyFollow server (NFR-08).
- Arabic-first RTL with Western digits.
- Past amounts never change when rates change (FR-016).
- Release 1.0 data must sync in 1.1 without migration loss.
- Builds: Smart App Control blocks local Android builds, so APKs come from GitHub Actions (R-18). All dev tooling stays on drive D.

**Scale/Scope**:
- One family per install, ≤ 5 devices, ~10 years of data (~7,000 transactions).
- About 22 screens and sheets.
- About 350 UI strings × 2 languages.
- 64 functional requirements.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

`.specify/memory/constitution.md` is still the **unfilled template** (no ratified principles). Until `/speckit-constitution` is run, this plan gates against the project's standing rules from `docs/REQUIREMENTS.md` §10 and the clarified spec:

| # | Interim principle | Pre-research | Post-design | Evidence |
|---|---|---|---|---|
| P1 | **Offline-first, no own server**: every 1.0 feature works in airplane mode, and family data leaves the phone only through files the user saves or their own Drive | ✅ | ✅ | R-03, R-09, R-19 (no analytics); contracts list only Aladhan, Nager and Drive |
| P2 | **Arabic-first RTL parity**: every string in ar+en, directional layout, Western digits | ✅ | ✅ | R-07; ARB parity test; golden tests in quickstart §2 |
| P3 | **Money correctness**: integer minor units, immutable rate snapshots, §6 formulas test-first against the prototype | ✅ | ✅ | R-04, R-05; data-model "Rate snapshot"; quickstart §1 suites |
| P4 | **Never lose user data**: soft deletes, re-pointing instead of cascading deletes, transactional writes, backup round-trip tested | ✅ | ✅ | data-model delete rules; contracts/backup-file.md restore rules |
| P5 | **Sync-ready from 1.0**: UUID v7, HLC, tombstones, outbox in schema v1 | ✅ | ✅ | R-08; data-model "Release 1.1 sync tables" |
| P6 | **Privacy and security**: encryption for backups (optional) and sync (mandatory), least-privilege Drive scopes, app lock | ✅ | ⚠️ | R-09 risk: mode B may need a restricted scope. Handled by the 1.1 spike and the product owner's decision (see Complexity Tracking) |
| P7 | **Keep REQUIREMENTS.md and screenshots current** (project rule) | ✅ | ✅ | Spec decisions were copied into REQUIREMENTS §11 / §12 |

**Gate result**: PASS. There are no unjustified violations. P6 has one *conditional* risk, which is recorded below and does not affect release 1.0.

## Project Structure

### Documentation (this feature)

```text
specs/001-family-finance-app/
├── spec.md              # Clarified specification
├── plan.md              # This file
├── research.md          # Phase 0: decisions R-01 … R-19, package versions
├── data-model.md        # Phase 1: schema v1, sync-ready conventions
├── quickstart.md        # Phase 1: build, run and validation guide
├── contracts/
│   ├── screens-and-routes.md   # UI routes and sheet parameters
│   ├── backup-file.md          # .mfbackup format and restore rules
│   ├── csv-export.md           # CSV columns and encoding
│   ├── external-date-apis.md   # Aladhan and Nager.Date usage
│   └── drive-sync.md           # Release 1.1 Drive layout, encryption, algorithm
├── checklists/requirements.md
└── tasks.md             # Phase 2 (/speckit-tasks; not created here)
```

### Source Code (repository root)

The Flutter app lives in the existing `src/` project. The `prototype/` folder stays as the reference.

```text
src/
├── pubspec.yaml
├── l10n.yaml
├── drift_schemas/                 # drift schema dumps per version (migration tests)
├── lib/
│   ├── main.dart                  # bootstrap: DB, prefs, ProviderScope, router
│   ├── app.dart                   # MaterialApp.router, theme, locale/RTL
│   ├── l10n/                      # app_en.arb, app_ar.arb (from prototype I18N)
│   ├── core/
│   │   ├── money/                 # Money, Currency (decimals), formatting, conversion
│   │   ├── time/                  # Hlc, clock, month helpers, due-date advance
│   │   ├── ids.dart               # UUID v7
│   │   ├── crypto/                # Argon2id, AES-GCM, envelope keys
│   │   └── theme/                 # tokens from prototype CSS (light/dark)
│   ├── data/
│   │   ├── db/                    # drift database, tables, triggers, migrations
│   │   ├── repositories/          # transactions, transfers, recurring, members, categories,
│   │   │                          #   budgets, rates, occasions, settings
│   │   ├── prefs/                 # device preferences + secure storage
│   │   ├── remote/                # Aladhan + Nager clients
│   │   ├── backup/                # .mfbackup writer/reader
│   │   ├── export/                # CSV writer
│   │   ├── sample/                # sample data generator (port of prototype demo())
│   │   └── sync/                  # release 1.1: drive client, outbox push/pull, snapshots
│   ├── domain/                    # pure Dart: built-in categories & occasions, totals,
│   │                              #   budgets, balances, forecast, occasion predict/suggest
│   ├── features/
│   │   ├── shell/                 # bottom bar, month selector, add (+)
│   │   ├── home/  activity/  planner/ (recurring, forecast, occasions, budgets)
│   │   ├── occasion_detail/  family/  member/  reports/
│   │   ├── sheets/                # transaction, transfer, member, category, occasion sheets
│   │   ├── settings/              # settings, categories, backup, notifications, security, sync
│   │   ├── setup/                 # first-launch steps + sample choice
│   │   └── lock/
│   ├── widgets/charts/            # bar, stacked, predicted, donut, share bar (CustomPainter)
│   └── services/                  # notifications scheduler, app lock, backup reminder
├── test/
│   ├── unit/                      # money, recurring, forecast, occasions, db, backup, csv, l10n
│   ├── widget/                    # screens + goldens (ar/en, light/dark, 2.0x text)
│   └── fixtures/                  # prototype reference data set + expected numbers
└── integration_test/              # quickstart §3 flows; sync_stress (1.1)

.github/workflows/android.yml      # analyze, test, build apk, upload artifact (R-18)
```

**Structure Decision**: a single Flutter project in `src/` (mobile, no backend). The code is layered as:

```
core → data → domain → features
```

`domain` has no Flutter imports, so the §6 rules are unit tested in isolation. Features are organized per screen, matching `docs/REQUIREMENTS.md` §7. The `sync/` folder is empty in 1.0 apart from the outbox, which lives in `db/`.

## Phase summary

| Phase | Output | Status |
|---|---|---|
| 0 Research | [research.md](./research.md): R-01 … R-19, all unknowns resolved, versions pinned | ✅ |
| 1 Design | [data-model.md](./data-model.md), [contracts/](./contracts/), [quickstart.md](./quickstart.md) | ✅ |
| 2 Tasks | `tasks.md` via `/speckit-tasks`, ordered by release (1.0 first) and user-story priority | Next |

## Complexity Tracking

| Item | Why Needed | Simpler Alternative Rejected Because |
|---|---|---|
| Sync scaffolding in 1.0 (HLC, tombstones, outbox triggers) before sync ships | Clarified release plan: 1.1 must sync 1.0 data without migration loss | Adding it in 1.1 would need rewriting ids and timestamps of existing rows, which risks the data loss P4 forbids |
| Immutable rate snapshots table | FR-016 clarification: past totals must not change when rates or the main currency change | Storing only the row's own rate can't convert to a changed main currency |
| Mode B Drive sync may need the restricted `drive` scope (P6 ⚠️) | FR-058: support each parent's own Google account | `drive.file` may not reach the other parent's files without Google Picker (no native Android picker). A 2-day spike at the start of 1.1 decides; fallback is mode A only. Product owner to confirm |
| Custom chart painters instead of a chart library | Exact RTL mirroring and the striped "predicted" bar from the prototype | fl_chart needs workarounds for both; revisit if charts grow |
