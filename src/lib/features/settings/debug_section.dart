import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../data/sample/sample_data.dart';
import '../../l10n/l10n.dart';
import '../../providers.dart';
import '../../widgets/common/common.dart';

/// Debug-only tools (T139): seed ~3 years of data to profile screens.
class DebugSection extends ConsumerWidget {
  const DebugSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!kDebugMode) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: AppCard(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: ListTile(
          leading: const Icon(Icons.speed),
          title: Text(context.l.seedYears),
          onTap: () async {
            final messenger = ScaffoldMessenger.of(context);
            final data = SampleData.generate(ref.read(todayProvider));
            await data.insertInto(ref.read(dbProvider));
            messenger.showSnackBar(SnackBar(content: Text('+${data.transactions.length}')));
          },
        ),
      ),
    );
  }
}
