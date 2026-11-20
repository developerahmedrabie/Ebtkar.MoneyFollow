# Contract: Google Drive sync (release 1.1)

Covers FR-049 – FR-056, FR-058, and User Story 5. Release 1.0 only prepares the data (UUIDs, HLC, tombstones and the outbox in [data-model.md](../data-model.md)). Nothing in this file runs in 1.0.

## Sync location

| Mode (FR-058) | Scope | Root |
|---|---|---|
| **A: shared family account** (default) | `https://www.googleapis.com/auth/drive.appdata` | Drive `appDataFolder` (hidden). |
| **B: own accounts + shared folder** | `https://www.googleapis.com/auth/drive.file` | A folder named `MoneyFollow` that parent 1's app creates. Parent 1 shares it with parent 2 (Drive permissions API, role `writer`), and parent 2 selects it once (R-09). |

Both scopes are non-sensitive, so no Google security assessment is needed.

## Folder layout (same in both modes)

```
<root>/
  family.json                      # family id, created_at, encryption header (wrapped keys), format version
  snapshots/<snapshotId>.mfsnap    # full encrypted dump (same body format as the backup payload), newest wins
  changes/<deviceId>/<seq8>.mfchg  # encrypted batch of outbox entries, seq zero-padded, never rewritten
  devices/<deviceId>.json          # name, platform, last_sync_at (plaintext metadata, no financial data)
```

## Encryption (FR-054 and its clarification)

The data is protected with envelope encryption:
- **Data key:** a random 256-bit data key (DK) encrypts every snapshot and change file with AES-256-GCM, using a fresh nonce per file.
- **Wrapping:** `family.json` stores the DK wrapped twice:
  - with a key derived from the **family passphrase** (Argon2id: salt, memory 19 MiB, 2 iterations);
  - with the **recovery key**, 32 random bytes shown once as 8 groups of base32 for the user to print or save.
- **Changing the passphrase** rewraps the DK only. The data files are not re-encrypted.
- **Unlocking:** either the passphrase or the recovery key unwraps the DK. Unlocked keys are kept in the phone's secure storage.

## Change file (`.mfchg`, decrypted JSON)

```json
{ "deviceId": "…", "fromSeq": 1201, "toSeq": 1250,
  "changes": [ { "seq": 1201, "table": "transactions", "id": "<uuid>", "hlc": "1763231400000-0003-<dev>",
                 "op": "upsert", "row": { …all columns… } } ] }
```

`op` is `upsert` or `delete`; a delete is an upsert with `deleted = 1`. Batches hold at most 500 changes or 256 KB.

## Algorithm (each sync run)

1. **Push:** upload outbox entries above `lastUploadedSeq` as new change files, then advance `lastUploadedSeq`.
2. **Pull:** list `changes/*/`. For each other device, download files with `seq > sync_state.last_seq_seen`.
3. **Apply:** for each change, upsert the row **only if** `incoming.hlc > local.hlc` (last writer wins per row, FR-050). Applying never writes to the outbox, so changes don't echo back. Unknown tables and columns are ignored, which keeps older apps compatible.
4. **Snapshot:** when this device's total applied changes since the last snapshot exceed 500, write a new snapshot. Change files fully covered by **all** devices' `last_seq_seen` and older than the snapshot are then deleted.
5. **New device or reinstall (FR-055):**
   1. Download the newest snapshot and import it.
   2. Apply the change files after it.
   3. Assign a new `deviceId`.
6. **Interruption safety (FR-051):** a file is uploaded under a temporary name and renamed on completion, and `seq` values are never reused. Applying is idempotent, because the same HLC is ignored.

## Clock
The HLC takes the maximum of the local wall clock and the largest HLC seen, then increments a counter. This keeps ordering correct even when phone clocks disagree by minutes.

## Triggers (FR-052)
Sync runs:
- when the app opens or resumes;
- 5 s after the last local change (debounced);
- on pull-to-refresh;
- on "Sync now";
- in the background every ~6 h. On Android this uses WorkManager with a network constraint, honouring Wi-Fi only. On iOS it uses BGTaskScheduler on a best-effort basis.

## Errors (shown in Settings › Sync, FR-053)
`offline` → "Waiting for internet" · `auth_revoked` → "Reconnect Google account" · `quota` → "Google Drive is full" · `locked` → "Enter family passphrase" · `mode_mismatch` → explains the two set-ups (spec edge case). In every case local data is untouched.
