# Data Model: MoneyFollow (version 1)

**Feature**: [spec.md](./spec.md) · **Plan**: [plan.md](./plan.md) · **Research**: [research.md](./research.md)

All family data lives in one local SQLite database (drift). The design is **sync-ready from release 1.0**, so release 1.1 can add Google Drive sync without migrating data (spec Assumptions, "Release plan").

## Conventions (all synced tables)

| Column | Type | Rule |
|---|---|---|
| `id` | TEXT (UUID v7) | Primary key, generated on the device. Never reused. Time-ordered, so new rows sort last. |
| `created_at` | INTEGER (UTC ms) | Set once. |
| `updated_at` | TEXT (HLC) | Hybrid logical clock `"<ms>-<counter>-<deviceId>"`, set on every change. Strings compare in order. Used for last-writer-wins in 1.1 (R-08). |
| `device_id` | TEXT | Device that made the last change. |
| `deleted` | INTEGER (0/1) | Soft delete (tombstone). All queries filter `deleted = 0`. Rows are never physically removed in 1.0. |
| `is_sample` | INTEGER (0/1) | 1 for sample data (FR-064). Never synced and never backed up. "Clear sample data" hard-deletes these rows and anything created while exploring. |

**Money** is stored as `INTEGER` minor units with a currency code (`amount_minor`, `currency`). The number of decimals comes from the currency table: EGP, USD, EUR, SAR, AED and GBP use 2; KWD uses 3. Floating point is never used for stored money.

**Exchange rates** are stored as `INTEGER` micro-units (`rate_micros` = value of 1 unit in the reference currency EGP × 1,000,000).

## Entities

### Member (`members`)
| Field | Type | Rules |
|---|---|---|
| name | TEXT | Required, trimmed, 1–30 chars (FR-025). |
| name_key | TEXT? | Translation key for sample/built-in names (shown translated). Cleared when the user renames. |
| role | TEXT | `parent` \| `child` \| `other`. |
| avatar | TEXT | One of 9 emoji (REQUIREMENTS Appendix / prototype `AVATARS`). |
| color | TEXT | `#RRGGBB`. Auto-assigned: first unused colour of the 8-colour palette. |
| sort_order | INTEGER | Display order. |

"Whole family" is **not a row**. It is represented by `member_id = NULL` everywhere.
**Delete** (FR-026) does three things in one database transaction: sets `member_id = NULL` on the member's transactions and recurring items, then tombstones the member.

### Category (`categories`): user categories only
| Field | Type | Rules |
|---|---|---|
| type | TEXT | `expense` \| `income`. Immutable after creation (FR-008). |
| name | TEXT | 1–20 chars, unique within type (case-insensitive, whitespace-collapsed) against user categories and built-in `en`/`ar` names. |
| icon | TEXT | One of 24 emoji. |
| color | TEXT | One of 12 colours. |

**Built-in categories are code constants, not rows.** There are 11 expense and 5 income categories, with stable ids such as `groceries` and `other_e`. Every category reference is a `TEXT category_id` that resolves to either a built-in id or a user category's UUID.
**Delete** (FR-009) runs in one database transaction:
1. Re-point transactions and recurring items to `other_e` or `other_i`.
2. Delete the category's budget row.
3. Tombstone the category.

### Account (`accounts`)
| Field | Type | Rules |
|---|---|---|
| key | TEXT | `cash` \| `bank` \| `card` \| `usd` (fixed set in v1, FR-011). |
| currency | TEXT | `EGP` for cash, bank and card (follows the main currency at setup); `USD` for the Dollar account. |
| sort_order | INTEGER | |

The 4 rows are seeded at setup with fixed ids, so phones that sync later agree on them. **Balance is derived** (never stored):

```
income − expenses + transfers in − transfers out
```

The sum is taken in the account's own currency.

### Transaction (`transactions`)
| Field | Type | Rules |
|---|---|---|
| type | TEXT | `expense` \| `income`. |
| amount_minor | INTEGER | > 0 (FR-001). |
| currency | TEXT | One of 7 codes (FR-012). |
| rate_snapshot_id | TEXT → rate_snapshots.id | Rates in force when recorded (FR-016). |
| category_id | TEXT | Built-in id or user category id; must match `type`. |
| account_id | TEXT → accounts.id | |
| member_id | TEXT? → members.id | NULL = Whole family. |
| occasion_id | TEXT? | Built-in occasion key or custom occasion id; expenses only (FR-037). |
| date | TEXT `YYYY-MM-DD` | Local calendar date (no time zone). |
| note | TEXT | ≤ 60 chars, may be empty. |
| note_key | TEXT? | Translation key for sample notes. |
| recurring_id | TEXT? → recurring_items.id | Set when created by Mark paid or "Repeat" (FR-018, FR-020). |

Indexes: `(date)`, `(member_id, date)`, `(category_id, date)`, `(occasion_id)`, `(account_id)`.

### Transfer (`transfers`), new in this spec (FR-060)
| Field | Type | Rules |
|---|---|---|
| from_account_id / to_account_id | TEXT | Must differ. |
| amount_out_minor | INTEGER | > 0, in the from-account's currency. |
| amount_in_minor | INTEGER | > 0, in the to-account's currency. Equals `amount_out` when the currencies match; otherwise entered by the user, or pre-filled from the current rate. |
| rate_snapshot_id | TEXT | For "≈" display only. |
| date, note | | As for transactions. |

Transfers are **excluded** from every income, expense, budget, report and forecast query. They affect only account balances and appear in Activity under their own filter.

### Recurring item (`recurring_items`)
| Field | Type | Rules |
|---|---|---|
| type, amount_minor, currency, category_id, account_id, member_id | | As for transactions. |
| name | TEXT | ≤ 60 chars; `name_key` for sample names. |
| frequency | TEXT | `weekly` \| `monthly` \| `quarterly` \| `yearly`. |
| next_due | TEXT `YYYY-MM-DD` | |
| day_of_month | INTEGER 1–31 | Anchor used when advancing (REQUIREMENTS §6.5). |

**State transitions:**

```
active ──Mark paid──► active (next_due advanced; a transaction is inserted with recurring_id)
active ──Stop repeating──► tombstoned (past transactions keep recurring_id for history)
```

Advancing the due date:
- **weekly:** +7 days.
- **otherwise:** +1, +3 or +12 months, using day `min(day_of_month, days in the target month)`.

### Budget (`budgets`)
| Field | Type | Rules |
|---|---|---|
| category_id | TEXT | Expense category (built-in or user). Unique among non-deleted rows. |
| limit_minor | INTEGER | In the main currency; > 0. Clearing the limit tombstones the row. |

Budgets are monthly and apply to whichever month is viewed (FR-024).

### Rate snapshot (`rate_snapshots`)
| Field | Type | Rules |
|---|---|---|
| rates_json | TEXT | `{"EGP":1000000,"USD":50000000,…}` (micro-units of EGP). |
| created_at | | |

Snapshots are immutable. Editing any rate (FR-014) creates a new snapshot, which becomes "current" (pointer in `settings`). Conversion of a stored amount to the main currency `M`:

```
value_M = amount × rates[cur] / rates[M]     (both from the row's snapshot)
```

Forecasts, unpaid recurring items and current account "≈" values use the **current** snapshot (FR-014 clarification).

### Occasion (`occasions`): custom occasions plus per-occasion settings
| Field | Type | Rules |
|---|---|---|
| key | TEXT | Built-in key (`ramadan`, `eid_fitr`, `eid_adha`, `xmas`, `new_year`, `sham`, `mothers`, `school`) or a UUID for a custom occasion. |
| enabled | INTEGER | FR-036. |
| custom_name, icon, color | TEXT? | Custom occasions only (FR-041). |
| custom_month_day | TEXT? `MM-DD` | Custom occasions: fixed date each year. |
| days | INTEGER? | Duration; custom occasions only (built-in durations are constants). |

Built-in definitions (source, Hijri month/day, holiday match rule, fixed `MM-DD`, duration, countries, icon, colour) are **code constants** that mirror the prototype's `EVENTS`.

### Occasion date (`occasion_dates`)
| Field | Type | Rules |
|---|---|---|
| occasion_key | TEXT | |
| year | INTEGER | Gregorian year of the start date. |
| start_date | TEXT `YYYY-MM-DD` | |
| source | TEXT | `bundled` \| `aladhan` \| `nager` \| `fixed` \| `user`. |
| country | TEXT | Country it was fetched for. |
| adjust_days | INTEGER | −1, 0 or +1, set by the user (FR-040). Effective date = `start_date + adjust_days`. |

Unique on `(occasion_key, year, country)`. A refresh (FR-035) replaces rows from `aladhan` and `nager` and keeps `adjust_days`.

### Settings (`settings`): synced family settings (key–value)
Keys:
- `main_currency`
- `country`
- `current_rate_snapshot_id`
- `occasion_dates_updated_at`
- `family_created_at`

Each key is a row with the standard sync columns, so last-writer-wins applies per key.

### Device preferences (shared_preferences / secure storage): **not synced** (FR-056)
- `language` (`ar` | `en`)
- `theme` (`system` | `light` | `dark`)
- `setup_completed`
- `sample_mode`
- `last_backup_at`
- `backup_reminder` (`on` | `snoozed_until` | `off`)
- `notifications.{bills,budgets,occasions}`
- `app_lock` (`off` | `pin` | `biometric`): the PIN hash is kept in secure storage.
- `sync.*` (1.1): `mode`, `account`, `wifi_only`, `last_sync_at`, `folder_id`.

### Release 1.1 sync tables (created in 1.0 schema v1 so no migration is needed later)
- `sync_outbox(seq INTEGER PK AUTOINCREMENT, table_name, row_id, op, payload_json, hlc)`: filled by database triggers on every insert or update to a synced table, except rows with `is_sample = 1`. The 1.0 app records the outbox and trims it after each backup, so it never grows unbounded.
- `sync_state(peer_device_id PK, last_seq_seen, last_sync_at)`
- `devices(id PK, name, platform, last_seen_at)`

## Derived values (not stored)

These follow REQUIREMENTS §6 exactly:
- Monthly income and expense totals.
- Budget usage.
- Member spending and share.
- Account balances.
- Forecast months, using the variable average, fixed bills and occasion predictions (§6.2).
- Occasion history and prediction (§6.3).
- Tag suggestion (§6.4).

They are computed in pure Dart services over query results (R-05) and covered by unit tests against the prototype's reference data.

## Validation summary

| Rule | Source |
|---|---|
| amount > 0; category chosen and of matching type | FR-001 |
| transfer accounts differ; amounts > 0 | FR-060 |
| member name 1–30; category name 1–20, unique per type incl. built-ins (en+ar) | FR-008, FR-025 |
| occasion only on expenses | FR-001, FR-037 |
| budget limit > 0 or none | FR-023 |
| rate > 0 | FR-014 |
| adjust_days ∈ {−1, 0, +1} | FR-040 |
