import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/money/format.dart';
import '../../core/theme/app_theme.dart';
import '../../core/time/dates.dart';
import '../../domain/builtin_occasions.dart';
import '../../domain/occasions.dart';
import '../../l10n/l10n.dart';
import '../../providers.dart';
import '../../widgets/charts/predicted_bar.dart';
import '../../widgets/charts/share_bar.dart';
import '../../widgets/charts/stacked_bars.dart';
import '../../widgets/common/common.dart';
import '../../widgets/common/transaction_row.dart';
import '../common/ui.dart';
import '../sheets/occasion_sheet.dart';
import '../sheets/transaction_sheet.dart';

/// Occasion detail (REQUIREMENTS §7.11, prototype `renderEvent`).
class OccasionScreen extends ConsumerWidget {
  const OccasionScreen({super.key, required this.occasionKey});
  final String occasionKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l;
    final c = context.mc;
    final today = ref.watch(todayProvider);
    final s = ref.watch(occasionServiceProvider);
    final d = ref.watch(familyDataProvider).value;
    if (s == null || d == null || s.byKey[occasionKey] == null) {
      return Scaffold(appBar: AppBar(), body: const SizedBox.shrink());
    }
    final o = s.byKey[occasionKey]!;
    final labels = labelsFor(context, ref, d);
    final p = s.predict(occasionKey);
    final next = s.nextOccurrence(occasionKey);
    final color = hexColor(o.color);
    String m(int v) => mainMoney(context, d, v);

    return PageScaffold(
      showBack: true,
      title: labels.occasion(occasionKey, s),
      subtitle: labels.occasionSource(o.source),
      actions: [
        if (next != null)
          IconButton(
            tooltip: l.adjustDate,
            icon: const Icon(Icons.edit_calendar_outlined),
            onPressed: () => OccasionSheet.show(context, occasionKey: occasionKey, adjustOnly: true),
          ),
        if (o.isCustom)
          IconButton(
            tooltip: l.editOccasion,
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => OccasionSheet.show(context, occasionKey: occasionKey),
          ),
      ],
      children: [
        AppCard(
          color: color,
          child: DefaultTextStyle(
            style: const TextStyle(color: Colors.white),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text(o.icon, style: const TextStyle(fontSize: 30)),
                const SizedBox(width: 10),
                Expanded(child: Text(l.evExpected, style: const TextStyle(color: Colors.white70))),
              ]),
              const SizedBox(height: 6),
              Text(formatApprox(p.total, d.main, context.lang),
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white)),
              if (next != null) ...[
                const SizedBox(height: 6),
                Text(
                    '${longDate(next, context.lang)} · ${s.isHappening(occasionKey) ? l.evNow : l.daysLeft('${LocalDate.daysBetween(today, next)}')}',
                    style: const TextStyle(color: Colors.white)),
                if (o.source == OccasionSource.hijri)
                  Text(hijriLabel(next, context.lang), style: const TextStyle(color: Colors.white70)),
                const SizedBox(height: 8),
                Text(l.evSave(m(s.putAsidePerMonth(occasionKey))),
                    style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.white)),
              ],
            ]),
          ),
        ),
        if (p.history.isEmpty) ...[
          const SizedBox(height: 12),
          AppCard(child: EmptyState(l.evNone)),
        ] else ...[
          SectionHeader(l.evPrev),
          AppCard(
            child: PredictedBars(color: color, years: [
              for (final h in p.history)
                ('${LocalDate.yearOf(h.date)}', h.total.toDouble(), false,
                    shortAmount(h.total, d.main)),
              if (next != null)
                ('${LocalDate.yearOf(next)}', p.total.toDouble(), true,
                    shortAmount(p.total, d.main)),
            ]),
          ),
          HintText(p.history.length > 1
              ? l.evHintD(m(p.last!.total), '×${p.growth.toStringAsFixed(2)}')
              : l.evHintOne),
          SectionHeader(l.evByCat),
          AppCard(
            child: Column(children: [
              for (final e in (p.expectedByCategory.entries.toList()..sort((a, b) => b.value.compareTo(a.value))))
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(children: [
                    CatIcon(icon: labels.categoryDef(e.key).icon, color: labels.categoryDef(e.key).color, size: 34),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(labels.category(e.key), style: const TextStyle(fontWeight: FontWeight.w600)),
                        Text(l.evLast(m(p.last!.byCategory[e.key] ?? 0)),
                            style: TextStyle(fontSize: 12, color: c.muted)),
                      ]),
                    ),
                    Text(formatApprox(e.value, d.main, context.lang), style: const TextStyle(fontWeight: FontWeight.w700)),
                  ]),
                ),
            ]),
          ),
          SectionHeader(l.evWho),
          AppCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              ShareBar(parts: [
                for (final e in p.last!.byMember.entries) (e.value.toDouble(), hexColor(labels.memberColor(e.key))),
              ]),
              const SizedBox(height: 10),
              ChartLegend([
                for (final e in p.last!.byMember.entries)
                  (hexColor(labels.memberColor(e.key)),
                      '${labels.memberAvatar(e.key)} ${labels.member(e.key)} · ${m(e.value)}'),
              ]),
            ]),
          ),
          SectionHeader(l.evLastTx('${LocalDate.yearOf(p.last!.date)}'),
              link: l.addRec,
              onLink: () => TransactionSheet.show(context, presetOccasionKey: occasionKey)),
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Column(children: [
              for (final t in p.last!.transactions)
                TransactionRow(tx: t, d: d, labels: labels, occasions: s),
            ]),
          ),
        ],
        if (p.history.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: OutlinedButton(
              onPressed: () => TransactionSheet.show(context, presetOccasionKey: occasionKey),
              child: Text(l.addRec),
            ),
          ),
      ],
    );
  }
}

/// Exposed for tests.
OccasionPrediction predictionFor(OccasionService s, String key) => s.predict(key);
