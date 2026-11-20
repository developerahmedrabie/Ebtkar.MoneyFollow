import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/money/format.dart';
import '../../core/theme/app_theme.dart';
import '../../core/time/dates.dart';
import '../../domain/member_spending.dart';
import '../../l10n/l10n.dart';
import '../../providers.dart';
import '../../widgets/charts/share_bar.dart';
import '../../widgets/charts/stacked_bars.dart';
import '../../widgets/common/common.dart';
import '../common/ui.dart';
import '../sheets/member_sheet.dart';

/// Family (REQUIREMENTS §7.5, prototype `renderFamily`).
class FamilyScreen extends ConsumerWidget {
  const FamilyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l;
    final c = context.mc;
    final ym = ref.watch(selectedMonthProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l.family, style: const TextStyle(fontWeight: FontWeight.w800))),
      body: DataBuilder(builder: (context, d) {
        final labels = labelsFor(context, ref, d);
        final shares = familyShare(d, ym);
        final keys = allMemberKeys(d);
        String m(int v) => mainMoney(context, d, v);
        final fcs = {for (final k in keys) k: ref.watch(forecastProvider((3, k)))};
        final total = [0, 1, 2].map((i) => keys.fold(0, (a, k) => a + (fcs[k]?.months[i].total ?? 0))).toList();

        return ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 32), children: [
          SectionHeader('${l.famShare} · ${monthLabel(ym, context.lang)}'),
          AppCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              ShareBar(parts: [
                for (final s in shares) (s.spent.toDouble(), hexColor(labels.memberColor(s.memberKey))),
              ]),
              const SizedBox(height: 10),
              ChartLegend([
                for (final s in shares)
                  (hexColor(labels.memberColor(s.memberKey)),
                      '${labels.member(s.memberKey)} · ${m(s.spent)} · ${(s.share * 100).round()}%'),
              ]),
            ]),
          ),
          SectionHeader(l.members, link: l.addMember, onLink: () => MemberSheet.show(context)),
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Column(children: [
              for (final s in shares)
                ListTile(
                  onTap: () => context.push('/family/${s.memberKey.isEmpty ? 'whole' : s.memberKey}'),
                  leading: MemberAvatar(avatar: labels.memberAvatar(s.memberKey), color: labels.memberColor(s.memberKey), size: 40),
                  title: Text(labels.member(s.memberKey), style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text([
                    if (s.memberKey.isNotEmpty) labels.role(d.membersById[s.memberKey]!.role),
                    if (fcs[s.memberKey] != null) l.nextMonthS(m(fcs[s.memberKey]!.months.first.total)),
                  ].join(' · ')),
                  trailing: Text(m(s.spent), style: const TextStyle(fontWeight: FontWeight.w700)),
                ),
            ]),
          ),
          SectionHeader(l.overTime),
          AppCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              StackedBars(groups: [
                for (var i = -5; i <= 0; i++)
                  () {
                    final month = LocalDate.shiftMonth(ym, i);
                    final segs = [
                      for (final k in keys)
                        BarSegment(memberSeries(d, k, month, 1).first.$2.toDouble(), hexColor(labels.memberColor(k))),
                    ];
                    final sum = segs.fold<double>(0, (a, s) => a + s.value);
                    return BarGroup(monthName(month, context.lang), [
                      BarStack(segs, topLabel: shortAmount(sum.round(), d.main)),
                    ], highlight: i == 0);
                  }(),
              ]),
              const SizedBox(height: 8),
              ChartLegend([for (final k in keys) (hexColor(labels.memberColor(k)), labels.member(k))]),
            ]),
          ),
          SectionHeader(l.famFc),
          AppCard(
            child: Table(
              columnWidths: const {0: FlexColumnWidth(1.6)},
              children: [
                TableRow(children: [
                  const SizedBox.shrink(),
                  for (var i = 1; i <= 3; i++)
                    Text(monthName(LocalDate.shiftMonth(LocalDate.monthOf(ref.watch(todayProvider)), i), context.lang),
                        textAlign: TextAlign.end, style: TextStyle(fontSize: 12, color: c.muted)),
                ]),
                for (final k in keys)
                  TableRow(children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Text('${labels.memberAvatar(k)} ${labels.member(k)}', overflow: TextOverflow.ellipsis),
                    ),
                    for (var i = 0; i < 3; i++)
                      () {
                        final fm = fcs[k]?.months[i];
                        final odd = fm != null && (fm.oddItems.isNotEmpty || fm.occasionKeys.isNotEmpty);
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Text(shortAmount(fm?.total ?? 0, d.main),
                              textAlign: TextAlign.end,
                              style: TextStyle(color: odd ? c.warn : null, fontWeight: odd ? FontWeight.w700 : null)),
                        );
                      }(),
                  ]),
                TableRow(children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Text(l.total, style: const TextStyle(fontWeight: FontWeight.w800)),
                  ),
                  for (final t in total)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Text(shortAmount(t, d.main),
                          textAlign: TextAlign.end, style: const TextStyle(fontWeight: FontWeight.w800)),
                    ),
                ]),
              ],
            ),
          ),
          HintText(l.famFcHint),
        ]);
      }),
    );
  }
}
