import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../../core/theme/app_theme.dart';

/// Donut with centre text (prototype Reports "Spending by category").
class DonutChart extends StatelessWidget {
  const DonutChart({
    super.key,
    required this.slices,
    required this.centerTop,
    required this.centerValue,
    this.size = 150,
  });

  final List<(double, Color)> slices;
  final String centerTop;
  final String centerValue;
  final double size;

  @override
  Widget build(BuildContext context) {
    final c = context.mc;
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _DonutPainter(slices, c.surface2,
            Directionality.of(context) == TextDirection.rtl),
        child: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(centerTop, style: TextStyle(fontSize: 11, color: c.muted)),
            Text(centerValue,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
          ]),
        ),
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  _DonutPainter(this.slices, this.track, this.rtl);
  final List<(double, Color)> slices;
  final Color track;
  final bool rtl;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width * .14;
    final rect = Offset(stroke / 2, stroke / 2) &
        Size(size.width - stroke, size.height - stroke);
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;
    canvas.drawArc(rect, 0, math.pi * 2, false, p..color = track);
    final total = slices.fold<double>(0, (a, s) => a + s.$1);
    if (total <= 0) return;
    var start = -math.pi / 2;
    final dir = rtl ? -1 : 1;
    for (final (v, color) in slices) {
      final sweep = v / total * math.pi * 2 * dir;
      canvas.drawArc(rect, start, sweep, false, p..color = color);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter old) =>
      old.slices != slices || old.rtl != rtl;
}
