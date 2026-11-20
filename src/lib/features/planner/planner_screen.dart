import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../l10n/l10n.dart';
import 'budgets_tab.dart';
import 'forecast_tab.dart';
import 'occasions_tab.dart';
import 'recurring_tab.dart';

const plannerTabs = ['recurring', 'forecast', 'occasions', 'budgets'];

/// Planner with tabs bound to `/planner/:tab`.
class PlannerScreen extends StatelessWidget {
  const PlannerScreen({super.key, required this.tab});
  final String tab;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final index = plannerTabs.indexOf(tab).clamp(0, 3);
    return DefaultTabController(
      key: ValueKey(index),
      length: 4,
      initialIndex: index,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l.planner, style: const TextStyle(fontWeight: FontWeight.w800)),
          bottom: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            onTap: (i) => context.go('/planner/${plannerTabs[i]}'),
            tabs: [
              Tab(text: l.tabRec),
              Tab(text: l.tabFc),
              Tab(text: l.tabEv),
              Tab(text: l.budgets),
            ],
          ),
        ),
        body: const TabBarView(
          physics: NeverScrollableScrollPhysics(),
          children: [RecurringTab(), ForecastTab(), OccasionsTab(), BudgetsTab()],
        ),
      ),
    );
  }
}
