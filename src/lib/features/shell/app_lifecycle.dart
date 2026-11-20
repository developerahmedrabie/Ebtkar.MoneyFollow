import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../l10n/l10n.dart';
import '../../providers.dart';
import '../../services/app_lock.dart';
import '../../services/app_lock_state.dart';
import '../../services/backup_reminder.dart';
import '../../services/notification_scheduler.dart';
import '../settings/backup_screen.dart';

/// App-wide side effects: re-lock after 60 s in the background (FR-057),
/// backup reminder on open (FR-062), notifications rebuild (FR-022).
class AppLifecycle extends ConsumerStatefulWidget {
  const AppLifecycle({super.key, required this.router, required this.child});
  final GoRouter router;
  final Widget child;

  @override
  ConsumerState<AppLifecycle> createState() => _AppLifecycleState();
}

class _AppLifecycleState extends ConsumerState<AppLifecycle> with WidgetsBindingObserver {
  DateTime? _pausedAt;
  bool _reminderChecked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationSchedulerProvider).scheduleRebuild();
      _maybeRemind();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _pausedAt = DateTime.now();
    } else if (state == AppLifecycleState.resumed) {
      final p = _pausedAt;
      if (p != null && DateTime.now().difference(p) >= AppLockService.relockAfter) {
        ref.read(appLockProvider.notifier).lock();
      }
      _pausedAt = null;
      _maybeRemind();
    }
  }

  Future<void> _maybeRemind() async {
    if (_reminderChecked) return;
    final prefs = ref.read(prefsProvider);
    if (!ref.read(setupProvider).completed || ref.read(appLockProvider).locked) return;
    final today = ref.read(todayProvider);
    if (!shouldRemindBackup(
      nowMs: DateTime.now().millisecondsSinceEpoch,
      lastBackupAt: prefs.lastBackupAt,
      lastDataChangeAt: prefs.lastDataChangeAt,
      reminder: prefs.backupReminder,
      sampleMode: prefs.sampleMode,
      today: today,
    )) {
      return;
    }
    _reminderChecked = true;
    final ctx = widget.router.routerDelegate.navigatorKey.currentContext;
    if (ctx == null) return;
    final l = ctx.l;
    final choice = await showDialog<String>(
      context: ctx,
      builder: (c) => AlertDialog(
        title: Text(l.reminderTitle),
        content: Text(l.reminderBody),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, 'off'), child: Text(l.dontRemind)),
          TextButton(onPressed: () => Navigator.pop(c, 'snooze'), child: Text(l.remind3Days)),
          FilledButton(onPressed: () => Navigator.pop(c, 'now'), child: Text(l.backupNow)),
        ],
      ),
    );
    switch (choice) {
      case 'off':
        await prefs.setBackupReminder('off');
      case 'snooze':
        await prefs.setBackupReminder(snoozeValue(today));
      case 'now':
        final c2 = widget.router.routerDelegate.navigatorKey.currentContext;
        if (c2 != null && c2.mounted) await backupNow(c2, ref);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Rebuild reminders whenever family data changes.
    ref.listen(familyDataProvider, (prev, next) {
      final before = prev?.value, after = next.value;
      if (before != null && after != null) {
        ref.read(notificationSchedulerProvider)
          ..scheduleRebuild()
          ..onTransactionSaved(before, after);
      }
    });
    return widget.child;
  }
}
