# Contract: Backup file (release 1.0)

Covers FR-061, FR-062, the "Restore from backup" step in FR-063, and the edge cases for damaged, newer-version or wrong-password files.

## File

- **Extension:** `.mfbackup`
- **Media type:** `application/octet-stream`
- **Default name:** `MoneyFollow-YYYY-MM-DD.mfbackup`
- **Sharing:** shared through the system share sheet, so it can go to Files, Drive, WhatsApp, email and so on.
- **Restore:** the file is picked with the system file picker.

## Layout (binary)

```
offset  size  field
0       8     magic  "MFBACKUP" (ASCII)
8       2     container version (uint16 BE) = 1
10      1     flags: bit0 = encrypted
11      4     header length H (uint32 BE)
15      H     header JSON (UTF-8, always plaintext)
15+H    …     body = gzip(payload JSON), and if encrypted, AES-256-GCM(gzip(payload))
```

### Header JSON (plaintext, readable without the password)
```json
{
  "app": "money_follow",
  "appVersion": "1.0.0+1",
  "schemaVersion": 1,
  "createdAt": "2026-11-15T18:30:00Z",
  "deviceName": "Pixel 8",
  "counts": { "transactions": 2143, "members": 4, "recurring": 15, "categories": 2, "transfers": 12 },
  "payloadSha256": "<hex of gzip(payload) before encryption>",
  "kdf": { "alg": "argon2id", "salt": "<b64>", "memKiB": 19456, "iterations": 2, "parallelism": 1 },
  "cipher": { "alg": "aes-256-gcm", "nonce": "<b64>" }
}
```

`kdf` and `cipher` are present only when the file is encrypted. The restore screen shows `createdAt`, `deviceName`, the counts and the file size before asking for confirmation (FR-061).

### Payload JSON
```json
{
  "schemaVersion": 1,
  "tables": {
    "members": [ {row}, … ],
    "categories": [ … ],
    "accounts": [ … ],
    "transactions": [ … ],
    "transfers": [ … ],
    "recurring_items": [ … ],
    "budgets": [ … ],
    "rate_snapshots": [ … ],
    "occasions": [ … ],
    "occasion_dates": [ … ],
    "settings": [ … ]
  }
}
```

The payload follows these rules:
- **Rows:** each row keeps all its columns as named in [data-model.md](../data-model.md), including tombstones (`deleted = 1`), so that a restored phone can later sync correctly.
- **Excluded:** rows with `is_sample = 1`, device preferences, the `sync_outbox` and the PIN.

## Restore rules

| Situation | Behaviour |
|---|---|
| Magic or container version unknown, gzip/JSON invalid, SHA mismatch | Refuse: "This file is damaged or is not a MoneyFollow backup." Data unchanged. |
| `schemaVersion` > app's schema | Refuse: "This backup was made with a newer version of MoneyFollow. Update the app first." |
| `schemaVersion` < app's schema | Apply the same migrations as the database, then import. |
| Encrypted, wrong password | Refuse after GCM authentication fails: "Wrong password." Up to unlimited retries, data unchanged. |
| Valid | Confirm dialog (date, device, counts, size) → replace all family tables in **one database transaction** → regenerate the outbox → set `last_backup_at` to the file's `createdAt` → reload app. |

A restore always **replaces** the family data. It never merges, and device preferences are kept.

## Backup reminder (FR-062)
Show the reminder on app open when all of these hold:
- `now − last_backup_at > 7 days`, or there has never been a backup.
- At least one family row has changed since `last_backup_at`.
- The reminder is not snoozed or off.
- The app is not in sample mode.

The reminder offers three actions: **Back up now**, **Remind me in 3 days**, and **Don't remind me** (turns it off in Settings).
