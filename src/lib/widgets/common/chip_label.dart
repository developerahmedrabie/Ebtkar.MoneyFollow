import 'package:material_ui/material_ui.dart';

import '../../core/theme/app_theme.dart';

enum ChipTone { normal, ok, warn, bad }

/// Small rounded label (prototype `.chip`, `.chip.warn`, `.chip.bad`).
class ChipLabel extends StatelessWidget {
  const ChipLabel(this.text, {super.key, this.tone = ChipTone.normal});

  final String text;
  final ChipTone tone;

  @override
  Widget build(BuildContext context) {
    final c = context.mc;
    final (bg, fg) = switch (tone) {
      ChipTone.normal => (c.surface2, c.muted),
      ChipTone.ok => (c.incomeSoft, c.income),
      ChipTone.warn => (c.warnSoft, c.warn),
      ChipTone.bad => (c.expenseSoft, c.expense),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(text,
          style: TextStyle(fontSize: 11.5, color: fg, fontWeight: FontWeight.w600)),
    );
  }
}
