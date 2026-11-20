import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/monthly_totals.dart';
import '../../l10n/l10n.dart';
import '../../providers.dart';
import '../../widgets/common/common.dart';
import '../../widgets/common/transaction_row.dart';
import '../common/ui.dart';
import '../shell/month_selector.dart';
import 'budgets_card.dart';
import 'coming_up_card.dart';
import 'family_strip.dart';

/// Home (REQUIREMENTS §7.2, prototype `renderHome`).
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l;
    final c = context.mc;
    final ym = ref.watch(selectedMonthProvider);
    return Scaffold(
      appBar: AppBar(
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(l.appSub, style: TextStyle(fontSize: 12, color: c.muted)),
          const Text('MoneyFollow', style: TextStyle(fontWeight: FontWeight.w800)),
        ]),
        actions: [
          TextButton(
            onPressed: () => ref.read(languageProvider.notifier).toggle(),
            child: Text(context.lang == 'ar' ? 'EN' : 'ع',
                semanticsLabel: l.language,
                style: const TextStyle(fontWeight: FontWeight.w800)),
          ),
          IconButton(
            tooltip: l.settings,
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: DataBuilder(builder: (context, d) {
        final s = monthSummary(d, ym);
        final labels = labelsFor(context, ref, d);
        final recent = d.inMonth(ym).take(5).toList();
        final rate = s.savingsRatePercent;
        final msg = rate == null
            ? l.noIncome
            : (rate >= 0 ? l.savedPct('$rate') : l.overPct('${-rate}'));
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
          children: [
            const Align(alignment: AlignmentDirectional.centerStart, child: MonthSelector()),
            const SizedBox(height: 12),
            AppCard(
              color: c.primary,
              child: DefaultTextStyle(
                style: TextStyle(color: c.onPrimary),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(l.netBalance, style: TextStyle(color: c.onPrimary.withAlpha(210))),
                  const SizedBox(height: 4),
                  Text(mainMoney(context, d, s.net),
                      style: TextStyle(
                          fontSize: 30, fontWeight: FontWeight.w800, color: c.onPrimary)),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(child: _Pill(label: l.income, value: mainMoney(context, d, s.income), up: true)),
                    const SizedBox(width: 10),
                    Expanded(child: _Pill(label: l.expenses, value: mainMoney(context, d, s.expenses), up: false)),
                  ]),
                  const SizedBox(height: 10),
                  Text(msg, style: TextStyle(fontSize: 12.5, color: c.onPrimary.withAlpha(220))),
                ]),
              ),
            ),
            const FamilyStrip(),
            const ComingUpCard(),
            const BudgetsCard(),
            SectionHeader(l.recent,
                link: l.seeAll, onLink: () => StatefulNavigationShell.maybeOf(context)?.goBranch(1)),
            AppCard(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: recent.isEmpty
                  ? EmptyState(l.noTxMonth)
                  : Column(children: [
                      for (final t in recent)
                        TransactionRow(tx: t, d: d, labels: labels, occasions: ref.watch(occasionServiceProvider)),
                    ]),
            ),
          ],
        );
      }),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.value, required this.up});
  final String label, value;
  final bool up;

  @override
  Widget build(BuildContext context) {
    final c = context.mc;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: c.onPrimary.withAlpha(36), borderRadius: BorderRadius.circular(12)),
      child: Row(children: [
        Icon(up ? Icons.south_west : Icons.north_east, size: 16, color: c.onPrimary),
        const SizedBox(width: 6),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: TextStyle(fontSize: 11, color: c.onPrimary.withAlpha(210))),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: AlignmentDirectional.centerStart,
              child: Text(value,
                  style: TextStyle(fontWeight: FontWeight.w700, color: c.onPrimary)),
            ),
          ]),
        ),
      ]),
    );
  }
}
