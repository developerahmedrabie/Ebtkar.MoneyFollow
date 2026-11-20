import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/money/format.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/member_spending.dart';
import '../../domain/monthly_totals.dart';
import '../../l10n/l10n.dart';
import '../../providers.dart';
import '../../widgets/common/common.dart';
import '../common/ui.dart';

/// Horizontal chips: each member + Whole family with this month's spending.
class FamilyStrip extends ConsumerWidget {
  const FamilyStrip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l;
    final c = context.mc;
    final d = ref.watch(familyDataProvider).value;
    if (d == null) return const SizedBox.shrink();
    final ym = ref.watch(selectedMonthProvider);
    final labels = labelsFor(context, ref, d);
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      SectionHeader(l.family, link: l.viewAll, onLink: () => context.push('/family')),
      SizedBox(
        height: 64,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            for (final k in allMemberKeys(d))
              Padding(
                padding: const EdgeInsetsDirectional.only(end: 8),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => context.push('/family/${k.isEmpty ? 'whole' : k}'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                        color: c.surface,
                        border: Border.all(color: c.line),
                        borderRadius: BorderRadius.circular(16)),
                    child: Row(children: [
                      MemberAvatar(avatar: labels.memberAvatar(k), color: labels.memberColor(k)),
                      const SizedBox(width: 8),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(labels.member(k), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                          Text(shortAmount(memberSpent(d, k, ym), d.main),
                              style: TextStyle(fontSize: 12, color: c.muted)),
                        ],
                      ),
                    ]),
                  ),
                ),
              ),
          ],
        ),
      ),
    ]);
  }
}
