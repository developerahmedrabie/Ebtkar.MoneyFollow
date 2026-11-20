import 'package:money_follow/services/backup_reminder.dart';
import 'package:test/test.dart';

void main() {
  const day = 24 * 60 * 60 * 1000;
  const now = 100 * day;

  bool remind({
    int? last,
    int? changed = now - day,
    String reminder = 'on',
    bool sample = false,
    String today = '2026-11-13',
  }) =>
      shouldRemindBackup(
          nowMs: now,
          lastBackupAt: last,
          lastDataChangeAt: changed,
          reminder: reminder,
          sampleMode: sample,
          today: today);

  test('never backed up with data → remind', () => expect(remind(), isTrue));
  test('no data yet → no reminder', () => expect(remind(changed: null), isFalse));
  test('backed up 8 days ago, changed since → remind',
      () => expect(remind(last: now - 8 * day), isTrue));
  test('backed up 6 days ago → no', () => expect(remind(last: now - 6 * day), isFalse));
  test('no change since backup → no',
      () => expect(remind(last: now - 8 * day, changed: now - 9 * day), isFalse));
  test('off and sample mode → no', () {
    expect(remind(reminder: 'off'), isFalse);
    expect(remind(sample: true), isFalse);
  });
  test('snoozed for 3 days', () {
    final v = snoozeValue('2026-11-13');
    expect(v, 'snoozed_until:2026-11-16');
    expect(remind(reminder: v, today: '2026-11-15'), isFalse);
    expect(remind(reminder: v, today: '2026-11-16'), isTrue);
  });
}
