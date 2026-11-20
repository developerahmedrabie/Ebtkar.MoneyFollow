import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/money/format.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/member_spending.dart';
import '../../domain/reports.dart';
import '../../l10n/l10n.dart';
import '../../providers.dart';
import '../../widgets/charts/donut_chart.dart';
import '../../widgets/charts/pair_bars.dart';
import '../../widgets/charts/share_bar.dart';
import '../../widgets/charts/stacked_bars.dart';
import '../../widgets/common/common.dart';
import '../common/ui.dart';
import '../shell/month_selector.dart';

/// Reports (REQUIREMENTS §7.13, prototype `renderStats`).
class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l;
    final c = context.mc;
    final ym = ref.watch(selectedMonthProvider);
    final today = ref.watch(todayProvider);
    return PageScaffold(title: l.reports, children: [
      DataBuilder(builder: (context, d) {
        final labels = labelsFor(context, ref, d);
        final k = monthKpis(d, ym, today);
        final shares = categoryShares(d, ym);
        final series = sixMonthSeries(d, ym);
        final mem = familyShare(d, ym);
        String m(int v) => mainMoney(context, d, v);
        return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const Align(alignment: AlignmentDirectional.centerStart, child: MonthSelector()),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: KpiTile(label: l.income, value: m(k.income), valueColor: c.income)),
            const SizedBox(width: 10),
            Expanded(child: KpiTile(label: l.expenses, value: m(k.expenses), valueColor: c.expense)),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: KpiTile(label: l.avgDaily, value: m(k.avgDaily))),
            const SizedBox(width: 10),
            Expanded(
              child: KpiTile(
                label: l.vsLast,
                value: l.vsVal('${k.vsLastPercent > 0 ? '+' : ''}${k.vsLastPercent}'),
                valueColor: k.vsLastPercent > 0 ? c.expense : c.income,
              ),
            ),
          ]),
          SectionHeader(l.byCat),
          AppCard(
            child: shares.isEmpty
                ? EmptyState(l.noExp)
                : Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 18,
                    runSpacing: 12,
                    children: [
                      DonutChart(
                        slices: [for (final (id, v) in shares) (v.toDouble(), hexColor(labels.categoryDef(id).color))],
                        centerTop: l.spent,
                        centerValue: '${shortAmount(k.expenses, d.main)}\n${d.main.label(context.lang)}',
                      ),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 220),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          for (final (id, v) in shares.take(7))
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 3),
                              child: Row(children: [
                                Container(width: 10, height: 10, decoration: BoxDecoration(color: hexColor(labels.categoryDef(id).color), borderRadius: BorderRadius.circular(3))),
                                const SizedBox(width: 6),
                                Expanded(child: Text(labels.category(id), overflow: TextOverflow.ellipsis)),
                                Text(percent(v / k.expenses * 100), style: const TextStyle(fontWeight: FontWeight.w600)),
                              ]),
                            ),
                        ]),
                      ),
                    ],
                  ),
          ),
          SectionHeader(l.last6),
          AppCard(
            child: Column(children: [
              PairBars(data: [
                for (final (month, inc, exp) in series)
                  PairBarData(monthName(month, context.lang),
                      income: inc.toDouble(), expense: exp.toDouble(), highlight: month == ym),
              ]),
              const SizedBox(height: 6),
              ChartLegend([(c.income, l.income), (c.expense, l.expenses)]),
            ]),
          ),
          SectionHeader(l.byMember, link: l.viewAll, onLink: () => context.push('/family')),
          AppCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              ShareBar(parts: [for (final s in mem) (s.spent.toDouble(), hexColor(labels.memberColor(s.memberKey)))]),
              const SizedBox(height: 10),
              ChartLegend([
                for (final s in mem)
                  (hexColor(labels.memberColor(s.memberKey)),
                      '${labels.member(s.memberKey)} · ${(s.share * 100).round()}%'),
              ]),
            ]),
          ),
        ]);
      }),
    ]);
  }
}
