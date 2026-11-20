import '../core/time/dates.dart';

/// contracts/backup-file.md "Backup reminder" (FR-062). Pure rules; the
/// dialog lives in the app shell.
bool shouldRemindBackup({
  required int nowMs,
  required int? lastBackupAt,
  required int? lastDataChangeAt,
  required String reminder,
  required bool sampleMode,
  required String today,
}) {
  if (sampleMode || reminder == 'off') return false;
  if (reminder.startsWith('snoozed_until:')) {
    final until = reminder.substring('snoozed_until:'.length);
    if (today.compareTo(until) < 0) return false;
  }
  if (lastDataChangeAt == null) return false; // nothing to back up yet
  if (lastBackupAt == null) return true;
  const week = 7 * 24 * 60 * 60 * 1000;
  return nowMs - lastBackupAt > week && lastDataChangeAt > lastBackupAt;
}

/// "Remind me in 3 days".
String snoozeValue(String today) =>
    'snoozed_until:${LocalDate.addDays(today, 3)}';
