import 'package:material_ui/material_ui.dart';

import '../../core/theme/app_theme.dart';

/// One horizontal bar split into coloured shares (prototype `.share`).
/// A Row follows the text direction, so it mirrors in RTL.
class ShareBar extends StatelessWidget {
  const ShareBar({super.key, required this.parts, this.height = 14});

  final List<(double, Color)> parts;
  final double height;

  @override
  Widget build(BuildContext context) {
    final total = parts.fold<double>(0, (a, p) => a + p.$1);
    return ClipRRect(
      borderRadius: BorderRadius.circular(height / 2),
      child: SizedBox(
        height: height,
        child: total <= 0
            ? ColoredBox(color: context.mc.surface2)
            : Row(children: [
                for (final (v, color) in parts)
                  if (v > 0)
                    Expanded(
                      flex: (v / total * 1000).round().clamp(1, 1000),
                      child: ColoredBox(color: color),
                    ),
              ]),
      ),
    );
  }
}

/// Simple progress bar (budgets).
class ProgressBar extends StatelessWidget {
  const ProgressBar({super.key, required this.ratio, required this.color, this.height = 8});
  final double ratio;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(height / 2),
        child: LinearProgressIndicator(
          value: ratio.clamp(0, 1).toDouble(),
          minHeight: height,
          color: color,
          backgroundColor: context.mc.surface2,
        ),
      );
}
