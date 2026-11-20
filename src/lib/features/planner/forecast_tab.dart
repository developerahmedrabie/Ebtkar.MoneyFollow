import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/money/format.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/l10n.dart';
import '../../providers.dart';
import '../../widgets/charts/pair_bars.dart';
import '../../widgets/charts/stacked_bars.dart';
import '../../widgets/common/common.dart';
import '../common/ui.dart';

/// Planner › Forecast (REQUIREMENTS §7.9, §6.2).
class ForecastTab extends ConsumerStatefulWidget {
  const ForecastTab({super.key});

  @override
  ConsumerState<ForecastTab> createState() => _ForecastTabState();
}

class _ForecastTabState extends ConsumerState<ForecastTab> {
  int _n = 3;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final c = context.mc;
    return DataBuilder(builder: (context, d) {
      final f = ref.watch(forecastProvider((_n, null)));
      final occ = ref.watch(occasionServiceProvider);
      if (f == null) return const SizedBox.shrink();
      final labels = labelsFor(context, ref, d);
      String m(int v) => mainMoney(context, d, v);
      return ListView(padding: const EdgeInsets.fromLTRB(16, 12, 16, 32), children: [
        Segments<int>(
          value: _n,
          items: [(3, l.m3), (6, l.m6)],
          onChanged: (v) => setState(() => _n = v),
        ),
        const SizedBox(height: 12),
        AppCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(l.fcTitle, style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(l.fcAvg, style: TextStyle(fontSize: 12, color: c.muted)),
            Text(m(f.average.round()), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            PairBars(data: [
              for (final x in f.months)
                PairBarData(monthName(x.month, context.lang),
                    income: x.income.toDouble(),
                    expenseSegments: [
                      BarSegment(x.fixed.toDouble(), c.expense),
                      BarSegment(x.occasions.toDouble(), c.warn),
                      BarSegment(x.variable.toDouble(), c.expense.withAlpha(102)),
                    ]),
            ]),
            const SizedBox(height: 8),
            ChartLegend([
              (c.income, l.expIncome),
              (c.expense, l.fixed),
              (c.warn, l.occasions),
              (c.expense.withAlpha(102), l.variableS),
            ]),
          ]),
        ),
        for (final x in f.months) ...[
          const SizedBox(height: 12),
          AppCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Row(children: [
                Expanded(
                    child: Text(monthLabel(x.month, context.lang),
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16))),
                if (x.high) ChipLabel(l.higher, tone: ChipTone.warn),
              ]),
              const SizedBox(height: 8),
              _line(l.fixed, m(x.fixed)),
              if (x.occasions > 0)
                _line('${l.fcOcc} · ${x.occasionKeys.map((k) => labels.occasion(k, occ)).join('، ')}',
                    m(x.occasions), color: c.warn),
              _line(l.variable, m(x.variable)),
              const Divider(height: 18),
              _line(l.expIncome, m(x.income), color: c.income),
              _line(l.expSavings, m(x.savings),
                  color: x.savings < 0 ? c.expense : c.income, bold: true),
              if (x.high)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                      l.includes([
                        ...x.oddItems.map(labels.recurring),
                        ...x.occasionKeys.map((k) => labels.occasion(k, occ)),
                      ].join('، ')),
                      style: TextStyle(fontSize: 12, color: c.warn)),
                ),
            ]),
          ),
        ],
        HintText(l.fcHint(m(f.variableAverage))),
      ]);
    });
  }

  Widget _line(String label, String value, {Color? color, bool bold = false}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(children: [
          Expanded(child: Text(label, maxLines: 2, overflow: TextOverflow.ellipsis)),
          Text(value,
              style: TextStyle(
                  color: color, fontWeight: bold ? FontWeight.w800 : FontWeight.w600)),
        ]),
      );
}
