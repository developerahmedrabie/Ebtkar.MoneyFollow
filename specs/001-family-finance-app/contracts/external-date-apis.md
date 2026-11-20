# Contract: External date services consumed (FR-033 – FR-035)

Both services are free, need no key, are called over HTTPS, and are **optional at runtime**: on any failure the app keeps the saved or bundled dates and shows `ev_sync_fail` (spec User Story 8, scenario 4). Calls run only when the user taps **Update** or changes the country. There is no background polling.

## 1. Aladhan: Hijri → Gregorian

```
GET https://api.aladhan.com/v1/hToG/{DD}-{MM}-{HYYYY}
```

| Occasion | DD-MM |
|---|---|
| Ramadan | `01-09` |
| Eid al-Fitr | `01-10` |
| Eid al-Adha | `10-12` |

- **Range:** the Hijri years whose dates fall within Gregorian `[thisYear − 3, thisYear + 1]`. For each occasion that is roughly `HYYYY ∈ [gy − 580, gy − 578]` (see the prototype `syncEvents`).
- **Response used:** `data.gregorian.date` (`DD-MM-YYYY`). Everything else is ignored.
- **Validation:** HTTP 200, `code == 200`, and a date that parses and falls in range. Otherwise the occasion is skipped.

## 2. Nager.Date: public holidays

```
GET https://date.nager.at/api/v3/PublicHolidays/{year}/{countryCode}
```

- **Years:** `thisYear − 3 … thisYear + 1`.
- **Country codes:** `EG`, `SA`, `AE`, `KW`, `US`, `GB`. Nager has no data for SA, AE and KW: it returns an empty list or 204/404, which is treated as "no holiday data" and shows `ev_no_holiday`.
- **Matching:**
  - Christmas: `name` starts with `"Christmas Day"`. If there is no match, use 7 Jan for EG and 25 Dec otherwise.
  - Sham El-Nessim: `name` contains `"Easter Monday"`, EG only.

## Client rules
- **Requests:** at most 6 at a time, a 10 s timeout each, and no retries inside one Update.
- **Partial failures** are allowed. Successful results replace the stored `aladhan`/`nager` rows for that country, failed occasions keep their old rows, and user `adjust_days` values are preserved.
- **Identification:** a `User-Agent: MoneyFollow/<version>` header is sent. No personal data is sent (NFR-08).
- **Bundled fallback:** the prototype's `BUNDLED_EV` Egypt dates for 2024–2027 are seeded with `source = bundled`.
