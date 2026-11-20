import 'package:material_ui/material_ui.dart';

import '../../core/theme/app_theme.dart';
import 'stacked_bars.dart';

/// Income vs expense columns per month. [expenseSegments] lets the
/// forecast stack fixed / occasions / day-to-day on the spending side.
class PairBarData {
  const PairBarData(this.label,
      {required this.income,
      this.expense = 0,
      this.expenseSegments,
      this.highlight = false});
  final String label;
  final double income;
  final double expense;
  final List<BarSegment>? expenseSegments;
  final bool highlight;
}

class PairBars extends StatelessWidget {
  const PairBars({super.key, required this.data, this.height = 140, this.semanticLabel});

  final List<PairBarData> data;
  final double height;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final c = context.mc;
    return StackedBars(
      height: height,
      semanticLabel: semanticLabel,
      groups: [
        for (final d in data)
          BarGroup(
            d.label,
            [
              BarStack([BarSegment(d.income, c.income)]),
              BarStack(d.expenseSegments ?? [BarSegment(d.expense, c.expense)]),
            ],
            highlight: d.highlight,
          ),
      ],
    );
  }
}
