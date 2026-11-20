import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/money/format.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/l10n.dart';
import '../../providers.dart';

/// `‹ Month YYYY ›` bound to the app-wide selected month (FR-006).
class MonthSelector extends ConsumerWidget {
  const MonthSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ym = ref.watch(selectedMonthProvider);
    ref.watch(todayProvider);
    final n = ref.read(selectedMonthProvider.notifier);
    final c = context.mc;
    final rtl = Directionality.of(context) == TextDirection.rtl;
    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: c.line),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: MaterialLocalizations.of(context).previousMonthTooltip,
            icon: Icon(rtl ? Icons.chevron_right : Icons.chevron_left),
            onPressed: () => n.shift(-1),
          ),
          Text(monthLabel(ym, context.lang),
              style: const TextStyle(fontWeight: FontWeight.w600)),
          IconButton(
            tooltip: MaterialLocalizations.of(context).nextMonthTooltip,
            icon: Icon(rtl ? Icons.chevron_left : Icons.chevron_right),
            onPressed: n.canGoNext ? () => n.shift(1) : null,
          ),
        ],
      ),
    );
  }
}
