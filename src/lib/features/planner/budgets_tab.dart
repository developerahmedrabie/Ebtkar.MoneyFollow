import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/money/money.dart';
import '../../core/theme/app_theme.dart';
import '../../data/family_data.dart';
import '../../domain/budget_usage.dart';
import '../../domain/builtin_categories.dart';
import '../../l10n/l10n.dart';
import '../../providers.dart';
import '../../widgets/charts/share_bar.dart';
import '../../widgets/common/common.dart';
import '../common/ui.dart';
import '../home/budgets_card.dart';
import '../shell/month_selector.dart';

/// Planner › Budgets (REQUIREMENTS §7.12, prototype `renderBudgets`).
class BudgetsTab extends ConsumerStatefulWidget {
  const BudgetsTab({super.key});

  @override
  ConsumerState<BudgetsTab> createState() => _BudgetsTabState();
}

class _BudgetsTabState extends ConsumerState<BudgetsTab> {
  bool _editing = false;
  final Map<String, TextEditingController> _ctl = {};

  @override
  void dispose() {
    for (final c in _ctl.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _startEdit(FamilyData d) {
    final labels = labelsFor(context, ref, d);
    for (final cat in labels.catalog.of(TxType.expense)) {
      final b = d.budgets.where((x) => x.categoryId == cat.id).firstOrNull;
      (_ctl[cat.id] ??= TextEditingController()).text =
          b == null ? '' : (b.limitMinor ~/ d.main.scale).toString();
    }
    setState(() => _editing = true);
  }

  Future<void> _done(FamilyData d) async {
    final l = context.l;
    final messenger = ScaffoldMessenger.of(context);
    final limits = <String, int?>{
      for (final e in _ctl.entries)
        e.key: e.value.text.trim().isEmpty
            ? null
            : Money.tryParse(e.value.text, d.main, requirePositive: false)?.minor,
    };
    await ref.read(budgetsRepoProvider).setAll(limits);
    setState(() => _editing = false);
    messenger.showSnackBar(SnackBar(content: Text(l.budgetsUpdated)));
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final c = context.mc;
    final ym = ref.watch(selectedMonthProvider);
    return DataBuilder(builder: (context, d) {
      final labels = labelsFor(context, ref, d);
      final rows = budgetRows(d, ym);
      final t = budgetTotal(d, ym);
      return ListView(padding: const EdgeInsets.fromLTRB(16, 12, 16, 32), children: [
        const Align(alignment: AlignmentDirectional.centerStart, child: MonthSelector()),
        const SizedBox(height: 12),
        AppCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Row(children: [
              Expanded(child: Text(l.totalBudget, style: const TextStyle(fontWeight: FontWeight.w700))),
              Text('${(t.ratio * 100).round()}%',
                  style: TextStyle(fontWeight: FontWeight.w800, color: c.budgetColor(t.ratio))),
            ]),
            const SizedBox(height: 8),
            ProgressBar(ratio: t.ratio, color: c.budgetColor(t.ratio), height: 10),
            const SizedBox(height: 6),
            Row(children: [
              Expanded(child: Text(l.spentV(mainMoney(context, d, t.spent)), style: TextStyle(fontSize: 12, color: c.muted))),
              Text(l.leftOf(mainMoney(context, d, t.limit - t.spent), mainMoney(context, d, t.limit)),
                  style: TextStyle(fontSize: 12, color: c.muted)),
            ]),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 18, 4, 8),
          child: Row(children: [
            Expanded(child: Text(l.monthlyLimits, style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700))),
            TextButton(
              onPressed: () => _editing ? _done(d) : _startEdit(d),
              child: Text(_editing ? l.done : l.edit),
            ),
          ]),
        ),
        AppCard(
          child: _editing
              ? Column(children: [
                  for (final cat in labels.catalog.of(TxType.expense))
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(children: [
                        CatIcon(icon: cat.icon, color: cat.color, size: 34),
                        const SizedBox(width: 10),
                        Expanded(child: Text(cat.name(context.lang))),
                        SizedBox(
                          width: 120,
                          child: TextField(
                            controller: _ctl[cat.id],
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9٠-٩]'))],
                            decoration: InputDecoration(hintText: l.noLimit, isDense: true, suffixText: d.main.label(context.lang)),
                          ),
                        ),
                      ]),
                    ),
                ])
              : rows.isEmpty
                  ? EmptyState(l.noBudgetsEdit)
                  : Column(children: [for (final r in rows) BudgetRowView(row: r, d: d)]),
        ),
      ]);
    });
  }
}
