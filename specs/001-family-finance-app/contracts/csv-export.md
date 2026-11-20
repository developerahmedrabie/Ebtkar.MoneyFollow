# Contract: CSV export (FR-043)

- **File:** `moneyfollow-transactions-YYYY-MM-DD.csv`, shared through the system share sheet.
- **Encoding:** UTF-8 **with BOM** (`EF BB BF`), so Excel shows Arabic correctly.
- **Format:** comma separator, CRLF line endings, RFC 4180 quoting. Every text field is quoted and `"` is doubled.
- **Rows:** all non-deleted, non-sample transactions **and transfers**, sorted by `date` and then `created_at`.

| # | Column | Example | Notes |
|---|---|---|---|
| 1 | `date` | `2026-11-12` | ISO date |
| 2 | `type` | `expense` | `expense` \| `income` \| `transfer` |
| 3 | `category` | `"Groceries"` | Name in the current app language; empty for transfers |
| 4 | `amount` | `850.00` | In its own currency, `.` decimal, currency's decimals, no grouping |
| 5 | `currency` | `EGP` | |
| 6 | `amount_<MAIN>` | `850.00` | Converted with the row's stored rate snapshot (FR-016); header uses the main currency code, e.g. `amount_EGP` |
| 7 | `account` | `"Card"` | For transfers: from-account |
| 8 | `to_account` | `""` | Transfers only |
| 9 | `member` | `"Omar"` | Empty = Whole family |
| 10 | `occasion` | `"Ramadan"` | Empty when none |
| 11 | `note` | `"Vet visit"` | |
| 12 | `recurring` | `yes` | `yes` when created from a recurring item |

The column order is fixed. Future versions may only **append** columns.
