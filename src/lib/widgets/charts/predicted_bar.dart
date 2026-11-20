import 'package:material_ui/material_ui.dart';

import 'stacked_bars.dart';

/// Past years as solid bars and the expected year as a striped,
/// dashed-outline bar (prototype `.pred`).
class PredictedBars extends StatelessWidget {
  const PredictedBars({
    super.key,
    required this.years,
    required this.color,
    this.height = 130,
  });

  /// (label, value, predicted, topLabel)
  final List<(String, double, bool, String)> years;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) => StackedBars(
        height: height,
        groups: [
          for (final (label, v, pred, top) in years)
            BarGroup(label, [
              BarStack([BarSegment(v, color, striped: pred)], topLabel: top),
            ], highlight: pred),
        ],
      );
}
