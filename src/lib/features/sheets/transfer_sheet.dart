import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/money/currency.dart';
import '../../core/money/format.dart';
import '../../core/money/money.dart';
import '../../core/theme/app_theme.dart';
import '../../core/time/dates.dart';
import '../../data/family_data.dart';
import '../../data/repositories/base_repository.dart';
import '../../data/repositories/transfers_repository.dart';
import '../../domain/conversion.dart';
import '../../l10n/l10n.dart';
import '../../providers.dart';
import '../../widgets/common/common.dart';
import '../common/ui.dart';

/// Move money between accounts (FR-060).
class TransferSheet extends ConsumerStatefulWidget {
  const TransferSheet({super.key, this.id, this.fromAccount});

  final String? id;
  final String? fromAccount;

  static Future<void> show(BuildContext context, {String? id, String? fromAccount}) =>
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (_) => TransferSheet(id: id, fromAccount: fromAccount),
      );

  @override
  ConsumerState<TransferSheet> createState() => _TransferSheetState();
}

class _TransferSheetState extends ConsumerState<TransferSheet> {
  final _out = TextEditingController();
  final _in = TextEditingController();
  final _note = TextEditingController();
  String _from = 'acc-bank';
  String _to = 'acc-cash';
  late String _date;
  bool _inTouched = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _date = ref.read(todayProvider);
    if (widget.fromAccount != null) {
      _from = widget.fromAccount!;
      if (_to == _from) _to = 'acc-bank';
    }
    if (widget.id != null) _load();
  }

  Future<void> _load() async {
    final t = await ref.read(transfersRepoProvider).byId(widget.id!);
    final d = ref.read(familyDataProvider).value;
    if (t == null || d == null || !mounted) return;
    String fmt(int v, String acc) =>
        minorToDecimalString(v, _accCur(d, acc)).replaceFirst(RegExp(r'\.?0+$'), '');
    setState(() {
      _from = t.fromAccountId;
      _to = t.toAccountId;
      _date = t.date;
      _out.text = fmt(t.amountOutMinor, t.fromAccountId);
      _in.text = fmt(t.amountInMinor, t.toAccountId);
      _inTouched = true;
      _note.text = t.note;
    });
  }

  @override
  void dispose() {
    _out.dispose();
    _in.dispose();
    _note.dispose();
    super.dispose();
  }

  Currency _accCur(FamilyData d, String id) =>
      Currency.fromCode(d.accounts.firstWhere((a) => a.id == id).currency);

  void _prefillIn(FamilyData d) {
    if (_inTouched) return;
    final fc = _accCur(d, _from), tc = _accCur(d, _to);
    final m = Money.tryParse(_out.text, fc);
    _in.text = m == null
        ? ''
        : minorToDecimalString(convert(m.minor, fc.code, tc.code, d.rates.current), tc);
  }

  Future<void> _save(FamilyData d) async {
    final l = context.l;
    final fc = _accCur(d, _from), tc = _accCur(d, _to);
    if (_from == _to) {
      setState(() => _error = l.errSameAccount);
      return;
    }
    final out = Money.tryParse(_out.text, fc);
    final inn = fc == tc ? out : Money.tryParse(_in.text, tc);
    if (out == null || inn == null) {
      setState(() => _error = l.errAmount);
      return;
    }
    final nav = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final input = TransferInput(
        fromAccountId: _from,
        toAccountId: _to,
        amountOutMinor: out.minor,
        amountInMinor: inn.minor,
        date: _date,
        note: _note.text);
    try {
      final repo = ref.read(transfersRepoProvider);
      widget.id == null ? await repo.create(input) : await repo.update(widget.id!, input);
    } on ValidationException {
      setState(() => _error = l.errAmount);
      return;
    }
    await ref.read(prefsProvider).setLastDataChangeAt(DateTime.now().millisecondsSinceEpoch);
    nav.pop();
    messenger.showSnackBar(SnackBar(content: Text(l.tTransferSaved)));
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final c = context.mc;
    final d = ref.watch(familyDataProvider).value;
    if (d == null) return const SizedBox(height: 200);
    final labels = labelsFor(context, ref, d);
    final fc = _accCur(d, _from), tc = _accCur(d, _to);
    DropdownButtonFormField<String> acc(String value, ValueChanged<String> on) =>
        DropdownButtonFormField<String>(
          initialValue: value,
          isExpanded: true,
          items: [
            for (final a in d.accounts)
              DropdownMenuItem(value: a.id, child: Text('${labels.accountIcon(a.id)} ${labels.account(a.id)}')),
          ],
          onChanged: (v) => setState(() {
            on(v!);
            _inTouched = false;
            _prefillIn(d);
            _error = null;
          }),
        );
    final fmt = [FilteringTextInputFormatter.allow(RegExp(r'[0-9٠-٩.,٫]'))];
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(children: [
            Expanded(
                child: Text(widget.id == null ? l.newTransfer : l.editTransfer,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800))),
            TextButton(onPressed: () => Navigator.pop(context), child: Text(l.cancel)),
          ]),
          HintText(l.transferHint),
          FieldLabel(l.fromAccount),
          acc(_from, (v) => _from = v),
          FieldLabel(l.toAccount),
          acc(_to, (v) => _to = v),
          FieldLabel('${l.amountSent} (${fc.label(context.lang)})'),
          TextField(
            controller: _out,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: fmt,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
            decoration: const InputDecoration(hintText: '0'),
            onChanged: (_) => setState(() {
              _error = null;
              _prefillIn(d);
            }),
          ),
          if (fc != tc) ...[
            FieldLabel('${l.amountReceived} (${tc.label(context.lang)})'),
            TextField(
              controller: _in,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: fmt,
              decoration: const InputDecoration(hintText: '0'),
              onChanged: (_) => setState(() {
                _inTouched = true;
                _error = null;
              }),
            ),
          ],
          FieldLabel(l.date),
          OutlinedButton.icon(
            icon: const Icon(Icons.event, size: 18),
            label: Text(dateShort(_date, context.lang)),
            onPressed: () async {
              final p = LocalDate.parse(_date);
              final x = await showDatePicker(
                  context: context,
                  initialDate: DateTime(p.year, p.month, p.day),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100));
              if (x != null) {
                setState(() => _date = LocalDate.format(DateTime.utc(x.year, x.month, x.day)));
              }
            },
          ),
          FieldLabel(l.note),
          TextField(controller: _note, maxLength: 60, decoration: const InputDecoration(counterText: '')),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(_error!, style: TextStyle(color: c.expense)),
            ),
          const SizedBox(height: 16),
          FilledButton(onPressed: () => _save(d), child: Text(l.save)),
          if (widget.id != null) ...[
            const SizedBox(height: 10),
            ConfirmTwiceButton(
              label: l.delete,
              onConfirmed: () async {
                final nav = Navigator.of(context);
                final messenger = ScaffoldMessenger.of(context);
                await ref.read(transfersRepoProvider).delete(widget.id!);
                nav.pop();
                messenger.showSnackBar(SnackBar(content: Text(l.tTransferDeleted)));
              },
            ),
          ],
        ]),
      ),
    );
  }
}
