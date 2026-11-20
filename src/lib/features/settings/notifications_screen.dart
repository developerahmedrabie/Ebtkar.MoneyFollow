import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../l10n/l10n.dart';
import '../../providers.dart';
import '../../services/notification_scheduler.dart';
import '../../widgets/common/common.dart';
import '../common/ui.dart';

/// Notification switches (FR-022).
class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  Future<void> _set(Future<void> Function(bool) setter, bool v) async {
    if (v && !await ref.read(notificationSchedulerProvider).requestPermission()) return;
    await setter(v);
    setState(() {});
    ref.read(notificationSchedulerProvider).scheduleRebuild();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final p = ref.watch(prefsProvider);
    return PageScaffold(showBack: true, title: l.notifications, children: [
      AppCard(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Column(children: [
          SwitchListTile(
            title: Text(l.notifBills),
            subtitle: Text(l.notifBillsHint),
            value: p.notifyBills,
            onChanged: (v) => _set(p.setNotifyBills, v),
          ),
          SwitchListTile(
            title: Text(l.notifBudgets),
            subtitle: Text(l.notifBudgetsHint),
            value: p.notifyBudgets,
            onChanged: (v) => _set(p.setNotifyBudgets, v),
          ),
          SwitchListTile(
            title: Text(l.notifOccasions),
            subtitle: Text(l.notifOccasionsHint),
            value: p.notifyOccasions,
            onChanged: (v) => _set(p.setNotifyOccasions, v),
          ),
        ]),
      ),
    ]);
  }
}
