import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/money/currency.dart';
import '../../core/money/format.dart';
import '../../core/money/money.dart';
import '../../core/theme/app_theme.dart';
import '../../core/time/dates.dart';
import '../../data/db/app_database.dart';
import '../../data/family_data.dart';
import '../../data/repositories/base_repository.dart';
import '../../data/repositories/recurring_repository.dart';
import '../../data/repositories/transactions_repository.dart';
import '../../domain/builtin_categories.dart';
import '../../domain/occasions.dart';
import '../../domain/recurring.dart';
import '../../l10n/l10n.dart';
import '../../providers.dart';
import '../../widgets/common/common.dart';
import '../common/ui.dart';
import 'transfer_sheet.dart';

enum SheetMode { tx, recurring }

/// Add / edit a transaction or a recurring item (prototype `#sheet`,
/// REQUIREMENTS §7.4, contracts "Modal sheets").
class TransactionSheet extends ConsumerStatefulWidget {
  const TransactionSheet({
    super.key,
    this.mode = SheetMode.tx,
    this.id,
    this.presetMemberId,
    this.presetOccasionKey,
    this.presetType,
  });

  final SheetMode mode;
  final String? id;

  /// '' = Whole family.
  final String? presetMemberId;
  final String? presetOccasionKey;
  final TxType? presetType;

  static Future<void> show(
    BuildContext context, {
    SheetMode mode = SheetMode.tx,
    String? id,
    String? presetMemberId,
    String? presetOccasionKey,
    TxType? presetType,
  }) =>
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (_) => TransactionSheet(
          mode: mode,
          id: id,
          presetMemberId: presetMemberId,
          presetOccasionKey: presetOccasionKey,
          presetType: presetType,
        ),
      );

  @override
  ConsumerState<TransactionSheet> createState() => _TransactionSheetState();
}

class _TransactionSheetState extends ConsumerState<TransactionSheet> {
  final _amount = TextEditingController();
  final _note = TextEditingController();
  TxType _type = TxType.expense;
  String? _cat;
  String? _member; // null = whole family
  String _account = 'acc-cash';
  late String _date;
  Currency? _currency;
  bool _curTouched = false;
  String _repeat = 'never';
  String? _occasion;
  bool _occTouched = false;
  String? _amountError;
  String? _catError;
  bool _loaded = false;

  bool get _isRec => widget.mode == SheetMode.recurring;
  bool get _editing => widget.id != null;

  @override
  void initState() {
    super.initState();
    _date = ref.read(todayProvider);
    _type = widget.presetType ?? TxType.expense;
    final pm = widget.presetMemberId;
    _member = (pm == null || pm.isEmpty) ? null : pm;
    _occasion = widget.presetOccasionKey;
    _occTouched = widget.presetOccasionKey != null;
    if (_isRec && !_editing) _repeat = 'monthly';
    _load();
  }

  Future<void> _load() async {
    final id = widget.id;
    if (id == null) {
      setState(() => _loaded = true);
      return;
    }
    if (_isRec) {
      final r = await ref.read(recurringRepoProvider).byId(id);
      if (r != null && mounted) {
        final c = Currency.fromCode(r.currency);
        setState(() {
          _type = TxType.parse(r.type);
          _amount.text = minorToDecimalString(r.amountMinor, c).replaceFirst(RegExp(r'\.?0+$'), '');
          _currency = c;
          _curTouched = true;
          _cat = r.categoryId;
          _member = r.memberId;
          _account = r.accountId;
          _date = r.nextDue;
          _repeat = r.frequency;
          _note.text = r.name;
        });
      }
    } else {
      final t = await ref.read(transactionsRepoProvider).byId(id);
      if (t != null && mounted) {
        final c = Currency.fromCode(t.currency);
        setState(() {
          _type = TxType.parse(t.type);
          _amount.text = minorToDecimalString(t.amountMinor, c).replaceFirst(RegExp(r'\.?0+$'), '');
          _currency = c;
          _curTouched = true;
          _cat = t.categoryId;
          _member = t.memberId;
          _account = t.accountId;
          _date = t.date;
          _occasion = t.occasionId;
          _occTouched = true;
          _note.text = t.note;
        });
      }
    }
    if (mounted) setState(() => _loaded = true);
  }

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  Currency _accountCurrency(FamilyData d) {
    final a = d.accounts.where((a) => a.id == _account);
    return a.isEmpty ? d.main : Currency.fromCode(a.first.currency);
  }

  Currency _cur(FamilyData d) => _currency ?? _accountCurrency(d);

  void _maybeSuggest(OccasionService? s) {
    if (_occTouched || _type != TxType.expense || _isRec || s == null) return;
    _occasion = s.suggest(_date);
  }

  Future<void> _save(FamilyData d) async {
    final l = context.l;
    final cur = _cur(d);
    final m = Money.tryParse(_amount.text, cur);
    setState(() {
      _amountError = m == null ? l.errAmount : null;
      _catError = _cat == null ? l.errCat : null;
    });
    if (m == null || _cat == null) return;
    final nav = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    String msg;
    try {
      if (_isRec) {
        final input = RecurringInput(
          type: _type,
          amountMinor: m.minor,
          currency: cur.code,
          categoryId: _cat!,
          accountId: _account,
          frequency: _repeat == 'never' ? 'monthly' : _repeat,
          nextDue: _date,
          memberId: _member,
          name: _note.text,
        );
        final repo = ref.read(recurringRepoProvider);
        _editing ? await repo.update(widget.id!, input) : await repo.create(input);
        msg = l.tRecSaved;
      } else {
        final input = TxInput(
          type: _type,
          amountMinor: m.minor,
          currency: cur.code,
          categoryId: _cat!,
          accountId: _account,
          date: _date,
          memberId: _member,
          occasionId: _type == TxType.expense ? _occasion : null,
          note: _note.text,
        );
        final repo = ref.read(transactionsRepoProvider);
        if (_editing) {
          await repo.update(widget.id!, input);
          msg = l.tUpdated;
        } else {
          String? recId;
          if (_repeat != 'never') {
            // FR-018: also schedule it, due one period after the date.
            recId = await ref.read(recurringRepoProvider).create(RecurringInput(
                  type: _type,
                  amountMinor: m.minor,
                  currency: cur.code,
                  categoryId: _cat!,
                  accountId: _account,
                  frequency: _repeat,
                  nextDue: advanceDue(_date, _repeat, LocalDate.dayOf(_date)),
                  memberId: _member,
                  name: _note.text,
                ));
          }
          await repo.create(TxInput(
              type: input.type,
              amountMinor: input.amountMinor,
              currency: input.currency,
              categoryId: input.categoryId,
              accountId: input.accountId,
              date: input.date,
              memberId: input.memberId,
              occasionId: input.occasionId,
              note: input.note,
              recurringId: recId));
          msg = recId == null ? l.tAdded : l.tAddedRep;
        }
        ref.read(selectedMonthProvider.notifier).set(LocalDate.monthOf(_date));
      }
      await ref.read(prefsProvider).setLastDataChangeAt(DateTime.now().millisecondsSinceEpoch);
    } on ValidationException catch (e) {
      setState(() => e.code == 'err_cat' ? _catError = l.errCat : _amountError = l.errAmount);
      return;
    }
    nav.pop();
    messenger.showSnackBar(SnackBar(content: Text(msg), duration: const Duration(milliseconds: 1800)));
  }

  Future<void> _delete() async {
    final l = context.l;
    final nav = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    if (_isRec) {
      await ref.read(recurringRepoProvider).stop(widget.id!);
    } else {
      await ref.read(transactionsRepoProvider).delete(widget.id!);
    }
    nav.pop();
    messenger.showSnackBar(SnackBar(content: Text(_isRec ? l.tRecDeleted : l.tDeleted)));
  }

  Future<void> _pickDate() async {
    final p = LocalDate.parse(_date);
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(p.year, p.month, p.day),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _date = LocalDate.format(DateTime.utc(picked.year, picked.month, picked.day));
        _maybeSuggest(ref.read(occasionServiceProvider));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final c = context.mc;
    final dAsync = ref.watch(familyDataProvider);
    final d = dAsync.value;
    if (d == null || !_loaded) {
      return const SizedBox(height: 300, child: Center(child: CircularProgressIndicator()));
    }
    final occ = ref.watch(occasionServiceProvider);
    if (!_editing && !_occTouched && _type == TxType.expense && !_isRec) {
      _occasion = occ?.suggest(_date);
    }
    final labels = labelsFor(context, ref, d);
    final cats = labels.catalog.of(_type);
    final cur = _cur(d);
    final parsed = Money.tryParse(_amount.text, cur);
    final title = _isRec
        ? (_editing ? l.editRec : l.newRec)
        : (_editing ? l.editTx : l.newTx);

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(children: [
              Expanded(child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800))),
              TextButton(onPressed: () => Navigator.pop(context), child: Text(l.cancel)),
            ]),
            const SizedBox(height: 8),
            Segments<String>(
              value: _type.name,
              items: [
                ('expense', l.expense),
                ('income', l.income1),
                if (!_isRec && !_editing) ('transfer', l.transfer),
              ],
              onChanged: (v) {
                if (v == 'transfer') {
                  Navigator.pop(context);
                  TransferSheet.show(context);
                  return;
                }
                setState(() {
                  _type = TxType.parse(v);
                  if (_cat != null && labels.categoryDef(_cat!).type != _type) _cat = null;
                  if (_type == TxType.income) _occasion = null;
                });
              },
            ),
            const SizedBox(height: 14),
            // Amount + currency
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(
                child: TextField(
                  controller: _amount,
                  autofocus: !_editing,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9٠-٩.,٫]'))],
                  style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: _type == TxType.income ? c.income : c.expense),
                  decoration: InputDecoration(hintText: '0', errorText: _amountError),
                  onChanged: (_) => setState(() => _amountError = null),
                ),
              ),
              const SizedBox(width: 8),
              DropdownButton<Currency>(
                value: cur,
                underline: const SizedBox.shrink(),
                items: [
                  for (final x in Currency.values)
                    DropdownMenuItem(value: x, child: Text(x.label(context.lang))),
                ],
                onChanged: (x) => setState(() {
                  _currency = x;
                  _curTouched = true;
                }),
              ),
            ]),
            if (cur != d.main && parsed != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                    formatApprox(d.currentMain(parsed.minor, cur.code), d.main, context.lang),
                    style: TextStyle(color: c.muted)),
              ),
            FieldLabel(l.category),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final cat in cats)
                  _CatChoice(
                    icon: cat.icon,
                    color: cat.color,
                    label: cat.name(context.lang),
                    selected: _cat == cat.id,
                    onTap: () => setState(() {
                      _cat = cat.id;
                      _catError = null;
                    }),
                  ),
              ],
            ),
            if (_catError != null)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(_catError!, style: TextStyle(color: c.expense, fontSize: 12)),
              ),
            FieldLabel(l.forWhom),
            _MemberChips(
              members: d.members,
              labels: labels,
              selected: _member,
              onChanged: (v) => setState(() => _member = v),
            ),
            Row(children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  FieldLabel(_isRec ? l.nextDue : l.date),
                  OutlinedButton.icon(
                    onPressed: _pickDate,
                    icon: const Icon(Icons.event, size: 18),
                    label: Text(dateShort(_date, context.lang)),
                  ),
                ]),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  FieldLabel(l.account),
                  DropdownButtonFormField<String>(
                    initialValue: _account,
                    isExpanded: true,
                    items: [
                      for (final a in d.accounts)
                        DropdownMenuItem(
                            value: a.id,
                            child: Text('${labels.accountIcon(a.id)} ${labels.account(a.id)}',
                                overflow: TextOverflow.ellipsis)),
                    ],
                    onChanged: (v) => setState(() {
                      _account = v ?? _account;
                      if (!_curTouched) _currency = null;
                    }),
                  ),
                ]),
              ),
            ]),
            if (!_editing || _isRec) ...[
              FieldLabel(_isRec ? l.frequency : l.repeat),
              DropdownButtonFormField<String>(
                initialValue: _repeat,
                isExpanded: true,
                items: [
                  if (!_isRec) DropdownMenuItem(value: 'never', child: Text(l.fqNever)),
                  for (final f in frequencies)
                    DropdownMenuItem(value: f, child: Text(labels.frequency(f))),
                ],
                onChanged: (v) => setState(() => _repeat = v ?? _repeat),
              ),
            ],
            if (!_isRec && _type == TxType.expense && occ != null) ...[
              FieldLabel(l.occasion),
              DropdownButtonFormField<String?>(
                initialValue: _occasion != null && occ.byKey.containsKey(_occasion) ? _occasion : null,
                isExpanded: true,
                items: [
                  DropdownMenuItem<String?>(value: null, child: Text(l.occNone)),
                  for (final k in occ.enabledKeys)
                    DropdownMenuItem<String?>(
                        value: k,
                        child: Text('${occ.byKey[k]!.icon} ${labels.occasion(k, occ)}')),
                ],
                onChanged: (v) => setState(() {
                  _occasion = v;
                  _occTouched = true;
                }),
              ),
            ],
            FieldLabel(_isRec ? l.name : l.note),
            TextField(
              controller: _note,
              maxLength: 60,
              decoration: InputDecoration(hintText: _isRec ? l.namePh : l.notePh, counterText: ''),
            ),
            const SizedBox(height: 18),
            FilledButton(onPressed: () => _save(d), child: Text(l.save)),
            if (_editing) ...[
              const SizedBox(height: 10),
              ConfirmTwiceButton(label: _isRec ? l.delRec : l.delete, onConfirmed: _delete),
            ],
          ],
        ),
      ),
    );
  }
}

class _CatChoice extends StatelessWidget {
  const _CatChoice({
    required this.icon,
    required this.color,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String icon, color, label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.mc;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          width: 76,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: selected ? c.primary : c.line, width: selected ? 2 : 1),
            color: selected ? c.primarySoft : null,
          ),
          child: Column(children: [
            CatIcon(icon: icon, color: color, size: 32),
            const SizedBox(height: 4),
            Text(label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 11)),
          ]),
        ),
      ),
    );
  }
}

class _MemberChips extends StatelessWidget {
  const _MemberChips({
    required this.members,
    required this.labels,
    required this.selected,
    required this.onChanged,
  });

  final List<Member> members;
  final Labels labels;
  final String? selected;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final items = <(String?, String, String)>[
      (null, wholeFamilyAvatar, labels.l.memFamily),
      for (final m in members) (m.id, m.avatar, labels.memberName(m)),
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(children: [
        for (final (id, av, name) in items)
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 8),
            child: ChoiceChip(
              label: Text('$av $name'),
              selected: selected == id,
              onSelected: (_) => onChanged(id),
            ),
          ),
      ]),
    );
  }
}
