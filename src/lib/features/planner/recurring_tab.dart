import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/money/currency.dart';
import '../../core/theme/app_theme.dart';
import '../../core/time/dates.dart';
import '../../data/db/app_database.dart';
import '../../data/family_data.dart';
import '../../domain/recurring.dart';
import '../../l10n/l10n.dart';
import '../../providers.dart';
import '../../widgets/common/common.dart';
import '../common/ui.dart';
import '../home/coming_up_card.dart';
import '../sheets/transaction_sheet.dart';

/// Planner › Recurring (REQUIREMENTS §7.8, prototype `renderPlan` rec).
class RecurringTab extends ConsumerWidget {
  const RecurringTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l;
    final c = context.mc;
    final today = ref.watch(todayProvider);
    return DataBuilder(builder: (context, d) {
      final labels = labelsFor(context, ref, d);
      double monthly(String type) => d.recurring
          .where((r) => r.type == type)
          .fold(0.0, (a, r) => a + monthlyEquivalent(d.currentMain(r.amountMinor, r.currency), r.frequency));
      final lim = LocalDate.addDays(today, 30);
      final due = d.recurring.where((r) => r.nextDue.compareTo(lim) <= 0).toList()
        ..sort((a, b) => a.nextDue.compareTo(b.nextDue));
      List<RecurringItem> group(String type) => d.recurring.where((r) => r.type == type).toList()
        ..sort((a, b) => monthlyEquivalent(d.currentMain(b.amountMinor, b.currency), b.frequency)
            .compareTo(monthlyEquivalent(d.currentMain(a.amountMinor, a.currency), a.frequency)));

      Future<void> pay(RecurringItem r) async {
        final messenger = ScaffoldMessenger.of(context);
        await ref.read(recurringRepoProvider).markPaid(r.id, today);
        await ref.read(prefsProvider).setLastDataChangeAt(DateTime.now().millisecondsSinceEpoch);
        messenger.showSnackBar(SnackBar(content: Text(l.tPaid(labels.recurring(r)))));
      }

      Widget row(RecurringItem r, {required bool dueList}) {
        final cat = labels.categoryDef(r.categoryId);
        final chip = dueChip(context, r.nextDue, today);
        return InkWell(
          onTap: () => TransactionSheet.show(context, mode: SheetMode.recurring, id: r.id),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 4),
            child: Row(children: [
              CatIcon(icon: cat.icon, color: cat.color, size: 38),
              const SizedBox(width: 10),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(labels.recurring(r), maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 3),
                  Wrap(spacing: 6, runSpacing: 4, crossAxisAlignment: WrapCrossAlignment.center, children: [
                    if (dueList) ChipLabel(chip.$1, tone: chip.$2)
                    else ...[
                      ChipLabel(labels.frequency(r.frequency)),
                      Text(l.nextOn(chip.$1), style: TextStyle(fontSize: 12, color: c.muted)),
                    ],
                    if (r.memberId != null)
                      Text('${labels.memberAvatar(r.memberId)} ${labels.member(r.memberId)}',
                          style: TextStyle(fontSize: 12, color: c.muted)),
                  ]),
                ]),
              ),
              const SizedBox(width: 6),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                AmountText(
                    income: r.type == 'income',
                    minor: r.amountMinor,
                    currency: Currency.fromCode(r.currency),
                    main: d.main,
                    mainValueMinor: d.currentMain(r.amountMinor, r.currency)),
                if (dueList)
                  TextButton(
                    style: TextButton.styleFrom(minimumSize: const Size(48, 36)),
                    onPressed: () => pay(r),
                    child: Text(r.type == 'income' ? l.markRecv : l.markPaid),
                  ),
              ]),
            ]),
          ),
        );
      }

      return ListView(padding: const EdgeInsets.fromLTRB(16, 12, 16, 32), children: [
        Row(children: [
          Expanded(child: KpiTile(label: l.fixedMonth, value: mainMoney(context, d, monthly('expense').round()), valueColor: c.expense)),
          const SizedBox(width: 10),
          Expanded(child: KpiTile(label: l.recIncome, value: mainMoney(context, d, monthly('income').round()), valueColor: c.income)),
        ]),
        SectionHeader(l.due30),
        AppCard(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: due.isEmpty
              ? EmptyState(l.nothingDue)
              : Column(children: [for (final r in due) row(r, dueList: true)]),
        ),
        SectionHeader(l.allRec,
            link: l.addRec,
            onLink: () => TransactionSheet.show(context, mode: SheetMode.recurring)),
        if (d.recurring.isEmpty) AppCard(child: EmptyState(l.noRec)),
        for (final type in ['expense', 'income'])
          if (group(type).isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 8, 4, 6),
              child: Text(type == 'expense' ? l.expenses : l.income,
                  style: TextStyle(color: c.muted, fontWeight: FontWeight.w600)),
            ),
            AppCard(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Column(children: [for (final r in group(type)) row(r, dueList: false)]),
            ),
          ],
      ]);
    });
  }
}

/// Exposed for tests.
int recurringCount(FamilyData d) => d.recurring.length;
