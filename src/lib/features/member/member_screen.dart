import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/money/currency.dart';
import '../../core/money/format.dart';
import '../../core/theme/app_theme.dart';
import '../../core/time/dates.dart';
import '../../domain/member_spending.dart';
import '../../domain/monthly_totals.dart';
import '../../l10n/l10n.dart';
import '../../providers.dart';
import '../../widgets/charts/share_bar.dart';
import '../../widgets/charts/stacked_bars.dart';
import '../../widgets/common/common.dart';
import '../../widgets/common/transaction_row.dart';
import '../common/ui.dart';
import '../sheets/member_sheet.dart';
import '../sheets/transaction_sheet.dart';

/// Member (REQUIREMENTS §7.6, prototype `renderMember`). `whole` = Whole
/// family.
class MemberScreen extends ConsumerWidget {
  const MemberScreen({super.key, required this.memberId});
  final String memberId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l;
    final c = context.mc;
    final ym = ref.watch(selectedMonthProvider);
    final key = memberId == 'whole' ? '' : memberId;
    final f = ref.watch(forecastProvider((3, key)));
    return DataBuilder(
      builder: (context, d) {
        final labels = labelsFor(context, ref, d);
        if (key.isNotEmpty && d.membersById[key] == null) {
          return Scaffold(appBar: AppBar(), body: EmptyState(l.nothing));
        }
        String m(int v) => mainMoney(context, d, v);
        final spent = memberSpent(d, key, ym);
        final total = monthSummary(d, ym).expenses;
        final prev = memberSpent(d, key, LocalDate.shiftMonth(ym, -1));
        final diff = prev == 0 ? 0 : ((spent - prev) / prev * 100).round();
        final color = hexColor(labels.memberColor(key));
        final series = memberSeries(d, key, ym);
        final byCat = <String, int>{};
        for (final t in d.inMonth(ym)) {
          if (t.type == 'expense' && matchesMember(t.memberId, key)) {
            byCat[t.categoryId] = (byCat[t.categoryId] ?? 0) + d.txMain(t);
          }
        }
        final cats = byCat.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
        final recs = d.recurring
            .where((r) => matchesMember(r.memberId, key))
            .toList();
        final txs = d
            .inMonth(ym)
            .where((t) => matchesMember(t.memberId, key))
            .toList();

        return PageScaffold(
          showBack: true,
          title: '${labels.memberAvatar(key)} ${labels.member(key)}',
          subtitle: key.isEmpty ? null : labels.role(d.membersById[key]!.role),
          actions: [
            if (key.isNotEmpty)
              IconButton(
                tooltip: l.editMember,
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => MemberSheet.show(context, memberId: key),
              ),
          ],
          children: [
            Row(
              children: [
                Expanded(
                  child: KpiTile(label: l.thisMonth, value: m(spent)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: KpiTile(
                    label: l.shareOf,
                    value: total == 0 ? '0%' : percent(spent / total * 100),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: KpiTile(
                    label: l.vsLast,
                    value: l.vsVal('${diff > 0 ? '+' : ''}$diff'),
                    valueColor: diff > 0 ? c.expense : c.income,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: KpiTile(
                    label: l.nextMonth,
                    value: f == null ? '—' : m(f.months.first.total),
                  ),
                ),
              ],
            ),
            SectionHeader(l.last6),
            AppCard(
              child: StackedBars(
                groups: [
                  for (final (month, v) in series)
                    BarGroup(monthName(month, context.lang), [
                      BarStack([
                        BarSegment(v.toDouble(), color),
                      ], topLabel: shortAmount(v, d.main)),
                    ], highlight: month == ym),
                ],
              ),
            ),
            SectionHeader(l.byCat),
            AppCard(
              child: cats.isEmpty
                  ? EmptyState(l.noExp)
                  : Column(
                      children: [
                        for (final e in cats)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              children: [
                                CatIcon(
                                  icon: labels.categoryDef(e.key).icon,
                                  color: labels.categoryDef(e.key).color,
                                  size: 32,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(labels.category(e.key)),
                                          ),
                                          Text(
                                            m(e.value),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      ProgressBar(
                                        ratio: e.value / cats.first.value,
                                        color: hexColor(
                                          labels.categoryDef(e.key).color,
                                        ),
                                        height: 6,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
            ),
            if (f != null) ...[
              SectionHeader(l.next3),
              AppCard(
                child: Column(
                  children: [
                    for (final x in f.months)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    monthLabel(x.month, context.lang),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                Text(
                                  m(x.total),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              l.fcItems(m(x.fixed), m(x.variable)),
                              style: TextStyle(fontSize: 12, color: c.muted),
                            ),
                            Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              children: [
                                for (final k in x.occasionKeys)
                                  ChipLabel(
                                    labels.occasion(
                                      k,
                                      ref.watch(occasionServiceProvider),
                                    ),
                                    tone: ChipTone.warn,
                                  ),
                                for (final r in x.items)
                                  ChipLabel(
                                    labels.recurring(r),
                                    tone:
                                        r.frequency == 'quarterly' ||
                                            r.frequency == 'yearly'
                                        ? ChipTone.warn
                                        : ChipTone.normal,
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
            SectionHeader(
              l.allRec,
              link: l.addRec,
              onLink: () => TransactionSheet.show(
                context,
                mode: SheetMode.recurring,
                presetMemberId: key,
              ),
            ),
            AppCard(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: recs.isEmpty
                  ? EmptyState(l.noRec)
                  : Column(
                      children: [
                        for (final r in recs)
                          ListTile(
                            onTap: () => TransactionSheet.show(
                              context,
                              mode: SheetMode.recurring,
                              id: r.id,
                            ),
                            leading: CatIcon(
                              icon: labels.categoryDef(r.categoryId).icon,
                              color: labels.categoryDef(r.categoryId).color,
                              size: 34,
                            ),
                            title: Text(labels.recurring(r)),
                            subtitle: Text(labels.frequency(r.frequency)),
                            trailing: AmountText(
                              income: r.type == 'income',
                              minor: r.amountMinor,
                              currency: Currency.fromCode(r.currency),
                              main: d.main,
                              mainValueMinor: d.currentMain(
                                r.amountMinor,
                                r.currency,
                              ),
                            ),
                          ),
                      ],
                    ),
            ),
            SectionHeader(
              l.memTx(monthLabel(ym, context.lang)),
              link: l.addRec,
              onLink: () => TransactionSheet.show(context, presetMemberId: key),
            ),
            AppCard(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: txs.isEmpty
                  ? EmptyState(l.noMemTx)
                  : Column(
                      children: [
                        for (final t in txs)
                          TransactionRow(
                            tx: t,
                            d: d,
                            labels: labels,
                            occasions: ref.watch(occasionServiceProvider),
                          ),
                      ],
                    ),
            ),
          ],
        );
      },
    );
  }
}
