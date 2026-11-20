import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/theme/app_theme.dart';
import '../../l10n/l10n.dart';
import '../sheets/transaction_sheet.dart';
import 'sample_banner.dart';

/// Bottom bar: Home, Activity, (+), Planner, Reports (prototype `.nav`).
class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l;
    final c = context.mc;
    Widget item(int i, IconData icon, IconData iconOn, String label) {
      final on = shell.currentIndex == i;
      return Expanded(
        child: Semantics(
          button: true,
          selected: on,
          label: label,
          child: InkWell(
            onTap: () => shell.goBranch(i, initialLocation: i == shell.currentIndex),
            child: SizedBox(
              height: 64,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(on ? iconOn : icon, color: on ? c.primary : c.muted, size: 24),
                  const SizedBox(height: 3),
                  Text(label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 11,
                          color: on ? c.primary : c.muted,
                          fontWeight: on ? FontWeight.w600 : FontWeight.normal)),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          const SampleBanner(),
          Expanded(child: shell),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: c.surface,
          border: Border(top: BorderSide(color: c.line)),
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              item(0, Icons.home_outlined, Icons.home, l.navHome),
              item(1, Icons.receipt_long_outlined, Icons.receipt_long, l.navTx),
              Expanded(
                child: Center(
                  child: Semantics(
                    button: true,
                    label: l.newTx,
                    child: Material(
                      color: c.primary,
                      borderRadius: BorderRadius.circular(18),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: () => TransactionSheet.show(context),
                        child: SizedBox(
                          width: 56,
                          height: 48,
                          child: Icon(Icons.add, color: c.onPrimary, size: 28),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              item(2, Icons.event_note_outlined, Icons.event_note, l.planner),
              item(3, Icons.pie_chart_outline, Icons.pie_chart, l.reports),
            ],
          ),
        ),
      ),
    );
  }
}
