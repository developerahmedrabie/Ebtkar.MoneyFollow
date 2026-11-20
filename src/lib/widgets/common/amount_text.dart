import 'package:material_ui/material_ui.dart';

import '../../core/money/currency.dart';
import '../../core/money/format.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/l10n.dart';

/// Signed amount in its own currency, green for income and red for
/// expenses; a foreign amount also shows "≈ main" (FR-015, prototype
/// `amtCell`). [mainValueMinor] is computed by the caller with the right
/// snapshot (the row's own for past rows).
class AmountText extends StatelessWidget {
  const AmountText({
    super.key,
    required this.income,
    required this.minor,
    required this.currency,
    required this.main,
    this.mainValueMinor,
    this.neutral = false,
  });

  final bool income;
  final int minor;
  final Currency currency;
  final Currency main;
  final int? mainValueMinor;

  /// Transfers: no sign, neutral colour.
  final bool neutral;

  @override
  Widget build(BuildContext context) {
    final c = context.mc;
    final lang = context.lang;
    final color = neutral ? c.text : (income ? c.income : c.expense);
    final first = neutral
        ? '$lri${formatExact(minor, currency)}$pdi${currency == main ? '' : ' ${currency.label(lang)}'}'
        : formatSignedCell(income, minor, currency, main, lang);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(first,
            style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
                fontFeatures: const [FontFeature.tabularFigures()])),
        if (currency != main && mainValueMinor != null)
          Text(formatApprox(mainValueMinor!, main, lang),
              style: TextStyle(fontSize: 11, color: c.muted)),
      ],
    );
  }
}
