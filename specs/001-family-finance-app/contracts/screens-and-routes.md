# Contract: Screens and routes (UI contract)

These are the app's user-facing surfaces. The layout and behaviour of each screen is defined in `docs/REQUIREMENTS.md` §7 and shown in `prototype/index.html` and `docs/screens/*.png`. This file fixes the **route names and their parameters**, so tasks, deep links and tests agree.

## Shell (bottom navigation, kept in a `StatefulShellRoute`)

| Tab | Route | Screen | REQUIREMENTS § |
|---|---|---|---|
| Home | `/` | Home | 7.2 |
| Activity | `/activity?type=&member=&q=` | Transactions | 7.3 |
| (+) | modal: `AddSheet` | Transaction sheet | 7.4 |
| Planner | `/planner/:tab` (`recurring` \| `forecast` \| `occasions` \| `budgets`) | Planner | 7.8–7.12 |
| Reports | `/reports` | Reports | 7.13 |

## Pushed routes

| Route | Screen | Notes |
|---|---|---|
| `/settings` | Settings | 7.14 |
| `/settings/categories?type=expense` | Categories | 7.15 |
| `/settings/backup` | Backup & restore | FR-061/062 (new screen, design in tasks) |
| `/settings/notifications` | Notification switches | FR-022 |
| `/settings/security` | App lock | FR-057 |
| `/settings/sync` | Sync (release 1.1) | FR-053 |
| `/family` | Family | 7.5 |
| `/family/:memberId` (`whole` for Whole family) | Member | 7.6 |
| `/occasions/:key` | Occasion detail | 7.11 |
| `/setup/:step` (`language` \| `currency` \| `members` \| `start`) | First-launch setup | FR-063/064 |
| `/lock` | Lock screen | FR-057; shown on resume when the lock is on |

## Modal sheets

| Sheet | Opened with |
|---|---|
| `TransactionSheet` | `mode` (`tx` \| `recurring`), optional `id`, `presetMemberId`, `presetOccasionKey`, `presetType` |
| `TransferSheet` | optional `id`, `fromAccount` |
| `MemberSheet` | optional `memberId` |
| `CategorySheet` | optional `categoryId`, `type` |
| `OccasionSheet` | custom occasion add/edit (FR-041); built-in date adjust ±1 (FR-040) |

## Global UI rules
- **Selected month:** one app-wide selected month (`YYYY-MM`). It cannot go past the current month and is shared by Home, Activity, Budgets, Reports, Family and Member (FR-006).
- **Language:** switching language or direction rebuilds the whole app with no restart (FR-044).
- **Confirming deletes:** destructive buttons need two taps within 2.5 s (FR-002).
- **Saved changes:** every save shows a short toast (snackbar) using the strings from the prototype's i18n table.
