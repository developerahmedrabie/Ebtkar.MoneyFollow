import 'package:material_ui/material_ui.dart';

import '../../core/money/currency.dart';
import '../../core/theme/app_theme.dart';
import '../../data/db/app_database.dart';
import '../../data/family_data.dart';
import '../../domain/occasions.dart';
import '../../features/common/labels.dart';
import '../../features/sheets/transaction_sheet.dart';
import '../../features/sheets/transfer_sheet.dart';
import 'amount_text.dart';
import 'cat_icon.dart';

/// One transaction (prototype `txRow`). Tapping opens the edit sheet.
class TransactionRow extends StatelessWidget {
  const TransactionRow({super.key, required this.tx, required this.d, required this.labels, this.occasions});

  final TxRow tx;
  final FamilyData d;
  final Labels labels;
  final OccasionService? occasions;

  @override
  Widget build(BuildContext context) {
    final c = context.mc;
    final cat = labels.categoryDef(tx.categoryId);
    final parts = <String>[
      labels.category(tx.categoryId),
      labels.account(tx.accountId),
      if (tx.recurringId != null) '🔁',
      if (tx.memberId != null) '${labels.memberAvatar(tx.memberId)} ${labels.member(tx.memberId)}',
      if (tx.occasionId != null && occasions?.byKey[tx.occasionId] != null)
        '${occasions!.byKey[tx.occasionId]!.icon} ${labels.occasion(tx.occasionId!, occasions)}',
    ];
    return InkWell(
      onTap: () => TransactionSheet.show(context, id: tx.id),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: Row(children: [
          CatIcon(icon: cat.icon, color: cat.color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(labels.tx(tx),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(parts.join(' · '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, color: c.muted)),
            ]),
          ),
          const SizedBox(width: 8),
          AmountText(
            income: tx.type == 'income',
            minor: tx.amountMinor,
            currency: Currency.fromCode(tx.currency),
            main: d.main,
            mainValueMinor: d.txMain(tx),
          ),
        ]),
      ),
    );
  }
}

/// A transfer row: ⇄, "From → To", neutral amount.
class TransferRow extends StatelessWidget {
  const TransferRow({super.key, required this.t, required this.d, required this.labels});

  final Transfer t;
  final FamilyData d;
  final Labels labels;

  @override
  Widget build(BuildContext context) {
    final c = context.mc;
    final cur = Currency.fromCode(
        d.accounts.firstWhere((a) => a.id == t.fromAccountId).currency);
    return InkWell(
      onTap: () => TransferSheet.show(context, id: t.id),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: Row(children: [
          const CatIcon(icon: '⇄', color: '#64748b'),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(t.note.isNotEmpty ? t.note : labels.l.transfer,
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              Text(labels.l.transferFromTo(labels.account(t.fromAccountId), labels.account(t.toAccountId)),
                  style: TextStyle(fontSize: 12, color: c.muted)),
            ]),
          ),
          AmountText(
            income: false,
            neutral: true,
            minor: t.amountOutMinor,
            currency: cur,
            main: d.main,
            mainValueMinor: d.rates.rowToMain(t.amountOutMinor, cur.code, t.rateSnapshotId, d.mainCurrency),
          ),
        ]),
      ),
    );
  }
}
