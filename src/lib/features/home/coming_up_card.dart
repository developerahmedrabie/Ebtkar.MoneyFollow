import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/money/format.dart';
import '../../core/theme/app_theme.dart';
import '../../core/time/dates.dart';
import '../../domain/recurring.dart';
import '../../l10n/l10n.dart';
import '../../providers.dart';
import '../../widgets/common/common.dart';
import '../common/ui.dart';

/// Due chip text and tone (prototype `dueChip`).
(String, ChipTone) dueChip(BuildContext context, String nextDue, String today) {
  final l = context.l;
  final r = dueLabel(nextDue, today);
  return switch (r.kind) {
    DueKind.overdue => (l.overdue('${r.days}'), ChipTone.bad),
    DueKind.today => (l.dueToday, ChipTone.warn),
    DueKind.tomorrow => (l.tomorrow, ChipTone.warn),
    DueKind.soon => (l.inDays('${r.days}'), ChipTone.warn),
    DueKind.later => (dateShort(nextDue, context.lang), ChipTone.normal),
  };
}

/// "Coming up" on Home: due in 30 days, expected next month, next bills and
/// the next occasion.
class ComingUpCard extends ConsumerWidget {
  const ComingUpCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l;
    final c = context.mc;
    final d = ref.watch(familyDataProvider).value;
    if (d == null) return const SizedBox.shrink();
    final today = ref.watch(todayProvider);
    final labels = labelsFor(context, ref, d);
    final lim = LocalDate.addDays(today, 30);
    final due = d.recurring.where((r) => r.nextDue.compareTo(lim) <= 0).toList()
      ..sort((a, b) => a.nextDue.compareTo(b.nextDue));
    final dueTotal = due
        .where((r) => r.type == 'expense')
        .fold(0, (a, r) => a + d.currentMain(r.amountMinor, r.currency));
    final f = ref.watch(forecastProvider((1, null)));
    final occ = ref.watch(occasionServiceProvider);
    final nextOcc = occ?.upcoming().firstOrNull;
    final bills = due.where((r) => r.type == 'expense').take(3).toList();

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      SectionHeader(l.comingUp, link: l.viewAll, onLink: () => context.go('/planner/recurring')),
      Row(children: [
        Expanded(child: KpiTile(label: l.dueIn30, value: mainMoney(context, d, dueTotal), valueColor: c.expense)),
        if (f != null) ...[
          const SizedBox(width: 10),
          Expanded(child: KpiTile(label: l.nextMonth, value: mainMoney(context, d, f.months.first.total))),
        ],
      ]),
      if (bills.isNotEmpty || nextOcc != null) ...[
        const SizedBox(height: 10),
        AppCard(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Column(children: [
            for (final r in bills)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(children: [
                  CatIcon(icon: labels.categoryDef(r.categoryId).icon, color: labels.categoryDef(r.categoryId).color, size: 36),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(labels.recurring(r), maxLines: 1, overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      Row(children: [
                        ChipLabel(dueChip(context, r.nextDue, today).$1, tone: dueChip(context, r.nextDue, today).$2),
                        if (r.memberId != null) ...[
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text('${labels.memberAvatar(r.memberId)} ${labels.member(r.memberId)}',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 12, color: c.muted)),
                          ),
                        ],
                      ]),
                    ]),
                  ),
                  Text(mainMoney(context, d, d.currentMain(r.amountMinor, r.currency)),
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                ]),
              ),
            if (nextOcc != null && occ != null)
              InkWell(
                onTap: () => context.push('/occasions/${nextOcc.$1}'),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(children: [
                    CatIcon(icon: occ.byKey[nextOcc.$1]!.icon, color: occ.byKey[nextOcc.$1]!.color, size: 36),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(labels.occasion(nextOcc.$1, occ),
                            style: const TextStyle(fontWeight: FontWeight.w600)),
                        Row(children: [
                          _countdown(context, occ.isHappening(nextOcc.$1), nextOcc.$2, today),
                          const SizedBox(width: 6),
                          Text(dateShort(nextOcc.$2, context.lang), style: TextStyle(fontSize: 12, color: c.muted)),
                        ]),
                      ]),
                    ),
                    Text(formatApprox(occ.predict(nextOcc.$1).total, d.main, context.lang),
                        style: TextStyle(fontWeight: FontWeight.w700, color: c.warn)),
                  ]),
                ),
              ),
          ]),
        ),
      ],
    ]);
  }
}

Widget _countdown(BuildContext context, bool now, String date, String today) {
  final l = context.l;
  if (now) return ChipLabel(l.evNow, tone: ChipTone.warn);
  final n = LocalDate.daysBetween(today, date);
  return ChipLabel(l.daysLeft('$n'), tone: n <= 30 ? ChipTone.warn : ChipTone.normal);
}

/// Exposed for the Occasions tab.
Widget occasionCountdown(BuildContext context, bool now, String date, String today) =>
    _countdown(context, now, date, today);
