import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/theme/app_theme.dart';
import '../../data/sample/sample_mode_service.dart';
import '../../l10n/l10n.dart';
import '../../providers.dart';

/// "Sample data" banner shown on every shell screen in sample mode (FR-064).
class SampleBanner extends ConsumerWidget {
  const SampleBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(setupProvider).sampleMode) return const SizedBox.shrink();
    final l = context.l;
    final c = context.mc;
    return Material(
      color: c.warnSoft,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(children: [
            Icon(Icons.science_outlined, color: c.warn, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(l.sampleBanner,
                  style: TextStyle(color: c.warn, fontWeight: FontWeight.w700)),
            ),
            TextButton(
              onPressed: () => clearSampleData(context, ref),
              child: Text(l.clearSample, maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          ]),
        ),
      ),
    );
  }
}

/// Asks first, then clears sample data (keeps setup choices).
Future<void> clearSampleData(BuildContext context, WidgetRef ref) async {
  final l = context.l;
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(l.clearSampleTitle),
      content: Text(l.clearSampleBody),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l.cancel)),
        FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l.clear)),
      ],
    ),
  );
  if (ok != true) return;
  final prefs = ref.read(prefsProvider);
  final started = prefs.sampleStartedAt ?? 0;
  final keep = (await ref.read(membersRepoProvider).all())
      .where((m) => !m.isSample && m.createdAt < started)
      .map((m) => m.id)
      .toSet();
  await SampleModeService(ref.read(dbProvider)).clear(started, keepMemberIds: keep);
  await prefs.setSampleMode(false);
  await prefs.setSampleStartedAt(null);
  ref.read(setupProvider.notifier).refresh();
}
