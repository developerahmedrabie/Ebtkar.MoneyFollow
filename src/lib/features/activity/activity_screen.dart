import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/money/format.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/builtin_categories.dart';
import '../../domain/monthly_totals.dart';
import '../../l10n/l10n.dart';
import '../../providers.dart';
import '../../widgets/common/common.dart';
import '../../widgets/common/transaction_row.dart';
import '../common/ui.dart';
import '../shell/month_selector.dart';

/// Activity (REQUIREMENTS §7.3, prototype `renderTx`).
class ActivityScreen extends ConsumerStatefulWidget {
  const ActivityScreen({super.key, this.initialType, this.initialMember, this.initialQuery});

  final String? initialType;
  final String? initialMember;
  final String? initialQuery;

  @override
  ConsumerState<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends ConsumerState<ActivityScreen> {
  late String _type = widget.initialType ?? 'all'; // all|expense|income|transfer
  late String _member = widget.initialMember ?? 'all'; // all | '' | id
  late final _q = TextEditingController(text: widget.initialQuery ?? '');

  @override
  void dispose() {
    _q.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final c = context.mc;
    final ym = ref.watch(selectedMonthProvider);
    final today = ref.watch(todayProvider);
    return PageScaffold(
      title: l.transactions,
      onRefresh: () async => ref.invalidate(familyDataProvider),
      children: [
        DataBuilder(builder: (context, d) {
          final labels = labelsFor(context, ref, d);
          final occ = ref.watch(occasionServiceProvider);
          final q = _q.text.trim().toLowerCase();
          bool matches(String s) => s.toLowerCase().contains(q);
          final memberKey = _member == 'all' ? null : _member;

          // (date, created, widget, net)
          final items = <(String, int, Widget, int)>[];
          if (_type != 'transfer') {
            for (final t in d.inMonth(ym)) {
              if (_type != 'all' && t.type != _type) continue;
              if (!matchesMember(t.memberId, memberKey)) continue;
              if (q.isNotEmpty &&
                  !matches(labels.tx(t)) &&
                  !matches(builtinCategoryNames(labels, t.categoryId))) {
                continue;
              }
              final v = d.txMain(t);
              items.add((t.date, t.createdAt,
                  TransactionRow(tx: t, d: d, labels: labels, occasions: occ),
                  t.type == 'income' ? v : -v));
            }
          }
          if ((_type == 'all' || _type == 'transfer') && memberKey == null) {
            for (final t in d.transfers.where((t) => t.date.startsWith(ym))) {
              if (q.isNotEmpty && !matches(t.note) && !matches(l.transfer)) continue;
              items.add((t.date, t.createdAt, TransferRow(t: t, d: d, labels: labels), 0));
            }
          }
          items.sort((a, b) {
            final x = b.$1.compareTo(a.$1);
            return x != 0 ? x : b.$2.compareTo(a.$2);
          });

          final groups = <String, List<(String, int, Widget, int)>>{};
          for (final i in items) {
            (groups[i.$1] ??= []).add(i);
          }

          return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            const Align(alignment: AlignmentDirectional.centerStart, child: MonthSelector()),
            const SizedBox(height: 12),
            Segments<String>(
              value: _type,
              items: [
                ('all', l.all),
                ('expense', l.expenses),
                ('income', l.income),
                ('transfer', l.transfers),
              ],
              onChanged: (v) => setState(() => _type = v),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _q,
              decoration: InputDecoration(prefixIcon: const Icon(Icons.search), hintText: l.search),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: [
                for (final (k, label) in <(String, String)>[
                  ('all', l.allMembers),
                  ('', '$wholeFamilyAvatar ${l.memFamily}'),
                  for (final m in d.members) (m.id, '${m.avatar} ${labels.memberName(m)}'),
                ])
                  Padding(
                    padding: const EdgeInsetsDirectional.only(end: 8),
                    child: ChoiceChip(
                      label: Text(label),
                      selected: _member == k,
                      onSelected: (_) => setState(() => _member = k),
                    ),
                  ),
              ]),
            ),
            const SizedBox(height: 8),
            if (groups.isEmpty) EmptyState(l.nothing),
            for (final e in groups.entries) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 14, 4, 4),
                child: Row(children: [
                  Expanded(
                    child: Text(
                        dayLabel(e.key, today, context.lang,
                            todayText: l.today, yesterdayText: l.yesterday),
                        style: TextStyle(fontWeight: FontWeight.w700, color: c.muted)),
                  ),
                  Text(formatAmount(e.value.fold(0, (a, x) => a + x.$4), d.main, context.lang, sign: true),
                      style: TextStyle(fontSize: 12, color: c.muted)),
                ]),
              ),
              AppCard(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                child: Column(children: [for (final x in e.value) x.$3]),
              ),
            ],
          ]);
        }),
      ],
    );
  }
}

/// Category name in both languages, for search.
String builtinCategoryNames(Labels labels, String id) {
  final c = labels.categoryDef(id);
  return '${c.en} ${c.ar}';
}
