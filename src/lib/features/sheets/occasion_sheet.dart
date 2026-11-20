import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/money/format.dart';
import '../../core/theme/app_theme.dart';
import '../../core/time/dates.dart';
import '../../data/repositories/base_repository.dart';
import '../../domain/builtin_categories.dart';
import '../../l10n/l10n.dart';
import '../../providers.dart';
import '../../widgets/common/common.dart';
import '../common/ui.dart';

/// Custom occasion add/edit (FR-041), or ±1 day adjustment of a built-in
/// occasion's next date (FR-040).
class OccasionSheet extends ConsumerStatefulWidget {
  const OccasionSheet({super.key, this.occasionKey, this.adjustOnly = false});

  final String? occasionKey;
  final bool adjustOnly;

  static Future<void> show(BuildContext context, {String? occasionKey, bool adjustOnly = false}) =>
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (_) => OccasionSheet(occasionKey: occasionKey, adjustOnly: adjustOnly),
      );

  @override
  ConsumerState<OccasionSheet> createState() => _OccasionSheetState();
}

class _OccasionSheetState extends ConsumerState<OccasionSheet> {
  final _name = TextEditingController();
  String _icon = categoryIcons[1];
  String _color = categoryColors[9];
  int _month = 1, _day = 1, _days = 1;
  String? _error;

  @override
  void initState() {
    super.initState();
    final s = ref.read(occasionServiceProvider);
    final o = s?.byKey[widget.occasionKey];
    if (o != null && o.isCustom) {
      _name.text = o.customName ?? '';
      _icon = o.icon;
      _color = o.color;
      _month = int.parse(o.monthDay!.substring(0, 2));
      _day = int.parse(o.monthDay!.substring(3, 5));
      _days = o.days;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  String get _md => '${_month.toString().padLeft(2, '0')}-${_day.toString().padLeft(2, '0')}';

  Future<void> _save() async {
    final l = context.l;
    final nav = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final repo = ref.read(occasionsRepoProvider);
    try {
      widget.occasionKey == null
          ? await repo.createCustom(_name.text, _icon, _color, _md, _days)
          : await repo.updateCustom(widget.occasionKey!, _name.text, _icon, _color, _md, _days);
    } on ValidationException {
      setState(() => _error = l.errName);
      return;
    }
    nav.pop();
    messenger.showSnackBar(SnackBar(content: Text(l.tOccSaved)));
  }

  Widget _adjust(BuildContext context) {
    final l = context.l;
    final s = ref.watch(occasionServiceProvider);
    final d = ref.watch(familyDataProvider).value;
    final key = widget.occasionKey!;
    final next = s?.nextOccurrence(key);
    if (s == null || d == null || next == null) return const SizedBox(height: 120);
    final year = LocalDate.yearOf(next);
    final row = d.occasionDates
        .where((r) => r.occasionKey == key && r.year == year && r.country == d.country)
        .firstOrNull;
    final adj = row?.adjustDays ?? 0;
    final base = LocalDate.addDays(next, -adj);
    Future<void> set(int v) async {
      await ref.read(occasionsRepoProvider).adjust(key, year, d.country, v, startDate: base);
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Text(l.adjustDate, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
      HintText(l.adjustHint),
      const SizedBox(height: 8),
      Segments<int>(
        value: adj,
        items: [
          (-1, '${l.dayEarlier}\n${dateShort(LocalDate.addDays(base, -1), context.lang)}'),
          (0, dateShort(base, context.lang)),
          (1, '${l.dayLater}\n${dateShort(LocalDate.addDays(base, 1), context.lang)}'),
        ],
        onChanged: set,
      ),
      const SizedBox(height: 16),
      FilledButton(onPressed: () => Navigator.pop(context), child: Text(l.done)),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final c = context.mc;
    if (widget.adjustOnly) {
      return Padding(padding: const EdgeInsets.fromLTRB(18, 0, 18, 24), child: _adjust(context));
    }
    final editing = widget.occasionKey != null;
    final monthNames = [
      for (var m = 1; m <= 12; m++) monthName('2026-${m.toString().padLeft(2, '0')}', context.lang),
    ];
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(children: [
            Expanded(
                child: Text(editing ? l.editOccasion : l.newOccasion,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800))),
            TextButton(onPressed: () => Navigator.pop(context), child: Text(l.cancel)),
          ]),
          FieldLabel(l.name),
          TextField(
            controller: _name,
            maxLength: 30,
            decoration: InputDecoration(errorText: _error, counterText: ''),
          ),
          FieldLabel(l.occDate),
          Row(children: [
            Expanded(
              flex: 3,
              child: DropdownButtonFormField<int>(
                initialValue: _month,
                items: [for (var m = 1; m <= 12; m++) DropdownMenuItem(value: m, child: Text(monthNames[m - 1]))],
                onChanged: (v) => setState(() {
                  _month = v!;
                  _day = _day.clamp(1, LocalDate.daysInMonth(2024, _month));
                }),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: DropdownButtonFormField<int>(
                initialValue: _day,
                items: [
                  for (var x = 1; x <= LocalDate.daysInMonth(2024, _month); x++)
                    DropdownMenuItem(value: x, child: Text('$x')),
                ],
                onChanged: (v) => setState(() => _day = v!),
              ),
            ),
          ]),
          FieldLabel(l.occDays),
          DropdownButtonFormField<int>(
            initialValue: _days,
            items: [for (var x = 1; x <= 30; x++) DropdownMenuItem(value: x, child: Text('$x'))],
            onChanged: (v) => setState(() => _days = v!),
          ),
          FieldLabel(l.iconL),
          Wrap(spacing: 6, runSpacing: 6, children: [
            for (final i in categoryIcons)
              InkWell(
                onTap: () => setState(() => _icon = i),
                child: Container(
                  width: 48,
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: i == _icon ? c.primarySoft : c.surface2,
                  ),
                  child: Text(i, style: const TextStyle(fontSize: 22)),
                ),
              ),
          ]),
          FieldLabel(l.colorL),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final col in categoryColors)
              InkWell(
                customBorder: const CircleBorder(),
                onTap: () => setState(() => _color = col),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: hexColor(col),
                    border: Border.all(color: col == _color ? c.text : Colors.transparent, width: 3),
                  ),
                ),
              ),
          ]),
          const SizedBox(height: 18),
          FilledButton(onPressed: _save, child: Text(l.save)),
          if (editing) ...[
            const SizedBox(height: 10),
            ConfirmTwiceButton(
              label: l.delOccasion,
              onConfirmed: () async {
                final nav = Navigator.of(context);
                final messenger = ScaffoldMessenger.of(context);
                await ref.read(occasionsRepoProvider).deleteCustom(widget.occasionKey!);
                nav.pop();
                messenger.showSnackBar(SnackBar(content: Text(l.tOccDeleted)));
              },
            ),
            HintText(l.delOccHint),
          ],
        ]),
      ),
    );
  }
}
