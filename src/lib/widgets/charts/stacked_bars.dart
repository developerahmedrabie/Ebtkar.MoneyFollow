import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../../core/theme/app_theme.dart';

class BarSegment {
  const BarSegment(this.value, this.color, {this.striped = false});
  final double value;
  final Color color;

  /// Striped fill with a dashed outline (prototype `.pred`).
  final bool striped;
}

class BarStack {
  const BarStack(this.segments, {this.topLabel});
  final List<BarSegment> segments;
  final String? topLabel;
  double get total => segments.fold(0, (a, s) => a + s.value);
}

class BarGroup {
  const BarGroup(this.label, this.stacks, {this.highlight = false});
  final String label;
  final List<BarStack> stacks;
  final bool highlight;
}

/// Groups of stacked bars with labels under each group, painted from the
/// reading start (mirrored in RTL, research R-14).
class StackedBars extends StatelessWidget {
  const StackedBars(
      {super.key, required this.groups, this.height = 150, this.semanticLabel});

  final List<BarGroup> groups;
  final double height;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final c = context.mc;
    final rtl = Directionality.of(context) == TextDirection.rtl;
    return Semantics(
      label: semanticLabel,
      child: SizedBox(
        height: height + 34,
        width: double.infinity,
        child: CustomPaint(
          painter: _BarsPainter(groups, rtl, c,
              DefaultTextStyle.of(context).style.fontFamily),
        ),
      ),
    );
  }
}

class _BarsPainter extends CustomPainter {
  _BarsPainter(this.groups, this.rtl, this.c, this.font);

  final List<BarGroup> groups;
  final bool rtl;
  final MoneyColors c;
  final String? font;

  void _text(Canvas canvas, String s, Offset center, double size, Color color,
      {bool bold = false, double maxWidth = 80}) {
    final tp = TextPainter(
      text: TextSpan(
          text: s,
          style: TextStyle(
              fontSize: size,
              color: color,
              fontFamily: font,
              fontWeight: bold ? FontWeight.w700 : FontWeight.normal)),
      textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
      maxLines: 1,
      ellipsis: '…',
    )..layout(maxWidth: maxWidth);
    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (groups.isEmpty) return;
    const labelH = 20.0, topPad = 14.0;
    final chartH = size.height - labelH - topPad;
    final maxV = math.max(
        1.0,
        groups
            .expand((g) => g.stacks)
            .map((s) => s.total)
            .fold<double>(0, math.max));
    final gw = size.width / groups.length;
    for (var gi = 0; gi < groups.length; gi++) {
      final g = groups[gi];
      final slot = rtl ? groups.length - 1 - gi : gi;
      final gx = slot * gw;
      if (g.highlight) {
        canvas.drawRRect(
            RRect.fromRectAndRadius(
                Rect.fromLTWH(gx + 2, 0, gw - 4, size.height - 2),
                const Radius.circular(10)),
            Paint()..color = c.surface2);
      }
      final n = g.stacks.length;
      final bw = math.min(22.0, (gw - 12) / n - 3);
      final totalW = n * bw + (n - 1) * 4;
      for (var si = 0; si < n; si++) {
        final s = g.stacks[si];
        final idx = rtl ? n - 1 - si : si;
        final x = gx + (gw - totalW) / 2 + idx * (bw + 4);
        var y = topPad + chartH;
        for (final seg in s.segments) {
          if (seg.value <= 0) continue;
          final h = seg.value / maxV * chartH;
          final r = Rect.fromLTWH(x, y - h, bw, h);
          if (seg.striped) {
            _striped(canvas, r, seg.color);
          } else {
            canvas.drawRRect(
                RRect.fromRectAndRadius(r, const Radius.circular(4)),
                Paint()..color = seg.color);
          }
          y -= h;
        }
        if (s.topLabel != null) {
          _text(canvas, s.topLabel!, Offset(x + bw / 2, y - 7), 9.5, c.muted,
              maxWidth: gw);
        }
      }
      _text(canvas, g.label, Offset(gx + gw / 2, size.height - labelH / 2),
          11, g.highlight ? c.text : c.muted,
          bold: g.highlight, maxWidth: gw);
    }
  }

  void _striped(Canvas canvas, Rect r, Color color) {
    canvas.save();
    final rr = RRect.fromRectAndRadius(r, const Radius.circular(4));
    canvas.clipRRect(rr);
    canvas.drawRect(r, Paint()..color = color.withAlpha(40));
    final p = Paint()
      ..color = color.withAlpha(120)
      ..strokeWidth = 3;
    for (var d = -r.height; d < r.width + r.height; d += 8) {
      canvas.drawLine(Offset(r.left + d, r.bottom),
          Offset(r.left + d + r.height, r.top), p);
    }
    canvas.restore();
    // dashed outline
    final o = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    final path = Path()..addRRect(rr);
    for (final m in path.computeMetrics()) {
      for (var d = 0.0; d < m.length; d += 7) {
        canvas.drawPath(m.extractPath(d, math.min(d + 4, m.length)), o);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _BarsPainter old) =>
      old.groups != groups || old.rtl != rtl || old.c != c;
}

/// A colour legend row.
class ChartLegend extends StatelessWidget {
  const ChartLegend(this.items, {super.key});
  final List<(Color, String)> items;

  @override
  Widget build(BuildContext context) => Wrap(
        spacing: 14,
        runSpacing: 6,
        children: [
          for (final (color, label) in items)
            Row(mainAxisSize: MainAxisSize.min, children: [
              Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                      color: color, borderRadius: BorderRadius.circular(3))),
              const SizedBox(width: 5),
              Text(label,
                  style: TextStyle(fontSize: 12, color: context.mc.muted)),
            ]),
        ],
      );
}
