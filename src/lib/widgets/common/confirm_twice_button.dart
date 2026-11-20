import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../../core/theme/app_theme.dart';
import '../../l10n/l10n.dart';

/// Destructive button: the first tap changes the label to "Tap again to
/// confirm"; a second tap within 2.5 s runs [onConfirmed] (FR-002).
class ConfirmTwiceButton extends StatefulWidget {
  const ConfirmTwiceButton(
      {super.key, required this.label, required this.onConfirmed});

  final String label;
  final VoidCallback onConfirmed;

  @override
  State<ConfirmTwiceButton> createState() => _ConfirmTwiceButtonState();
}

class _ConfirmTwiceButtonState extends State<ConfirmTwiceButton> {
  bool _armed = false;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _tap() {
    if (_armed) {
      _timer?.cancel();
      setState(() => _armed = false);
      widget.onConfirmed();
      return;
    }
    setState(() => _armed = true);
    _timer?.cancel();
    _timer = Timer(const Duration(milliseconds: 2500), () {
      if (mounted) setState(() => _armed = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.mc;
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: _tap,
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 48),
          foregroundColor: c.expense,
          backgroundColor: _armed ? c.expenseSoft : null,
          side: BorderSide(color: c.expense.withAlpha(90)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: Text(_armed ? context.l.tapAgain : widget.label),
      ),
    );
  }
}
