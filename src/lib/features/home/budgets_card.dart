import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/theme/app_theme.dart';
import '../../data/family_data.dart';
import '../../domain/budget_usage.dart';
import '../../l10n/l10n.dart';
import '../../providers.dart';
import '../../widgets/charts/share_bar.dart';
import '../../widgets/common/common.dart';
import '../common/ui.dart';

/// The 3 budgets closest to or over their limit.
class BudgetsCard extends ConsumerWidget {
  const BudgetsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l;
    final d = ref.watch(familyDataProvider).value;
    if (d == null) return const SizedBox.shrink();
    final rows = budgetRows(d, ref.watch(selectedMonthProvider), limit: 3);
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      SectionHeader(l.budgets, link: l.manage, onLink: () => context.go('/planner/budgets')),
      AppCard(
        child: rows.isEmpty
            ? EmptyState(l.noBudgets)
            : Column(children: [for (final r in rows) BudgetRowView(row: r, d: d)]),
      ),
    ]);
  }
}

/// One budget row (prototype `budRow`).
class BudgetRowView extends StatelessWidget {
  const BudgetRowView({super.key, required this.row, required this.d});
  final BudgetRow row;
  final FamilyData d;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final c = context.mc;
    final color = c.budgetColor(row.ratio);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(children: [
        CatIcon(icon: row.category.icon, color: row.category.color, size: 36),
        const SizedBox(width: 10),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(
                child: Text(row.category.name(context.lang),
                    style: const TextStyle(fontWeight: FontWeight.w600)),
              ),
              Text('${(row.ratio * 100).round()}%',
                  style: TextStyle(fontWeight: FontWeight.w700, color: color)),
            ]),
            const SizedBox(height: 6),
            ProgressBar(ratio: row.ratio, color: color),
            const SizedBox(height: 4),
            Row(children: [
              Expanded(
                child: Text(l.kOf(mainMoney(context, d, row.spent), mainMoney(context, d, row.limit)),
                    style: TextStyle(fontSize: 12, color: c.muted)),
              ),
              Text(row.left >= 0 ? l.left(mainMoney(context, d, row.left)) : l.over(mainMoney(context, d, -row.left)),
                  style: TextStyle(fontSize: 12, color: row.left >= 0 ? c.muted : c.expense)),
            ]),
          ]),
        ),
      ]),
    );
  }
}
