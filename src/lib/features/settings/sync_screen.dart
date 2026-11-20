import 'package:material_ui/material_ui.dart';

import '../../l10n/l10n.dart';
import '../../widgets/common/common.dart';
import '../common/ui.dart';

/// Google Drive sync arrives in release 1.1 (US5, T127 – T137). Release 1.0
/// shows what is coming; the database already records every change.
class SyncScreen extends StatelessWidget {
  const SyncScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return PageScaffold(showBack: true, title: l.syncTitle, children: [
      AppCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Icon(Icons.cloud_sync_outlined, size: 40),
          const SizedBox(height: 10),
          Text(l.syncComing),
          const SizedBox(height: 10),
          Text('• ${l.syncModeA}\n• ${l.syncModeB}'),
        ]),
      ),
    ]);
  }
}
