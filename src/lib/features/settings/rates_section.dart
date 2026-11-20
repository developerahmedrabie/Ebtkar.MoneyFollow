import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/money/currency.dart';
import '../../core/money/money.dart';
import '../../data/db/app_database.dart';
import '../../l10n/l10n.dart';
import '../../providers.dart';
import '../../widgets/common/common.dart';

/// Main currency and exchange rates (FR-012 – FR-014).
class RatesSection extends ConsumerWidget {
  const RatesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l;
    final d = ref.watch(familyDataProvider).value;
    if (d == null) return const SizedBox.shrink();
    final main = d.main;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      SectionHeader(l.currency),
      AppCard(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Column(children: [
          ListTile(
            title: Text(l.mainCurrency),
            trailing: DropdownButton<Currency>(
              value: main,
              underline: const SizedBox.shrink(),
              items: [
                for (final c in Currency.values)
                  DropdownMenuItem(value: c, child: Text('${c.code} · ${c.fullName(context.lang)}')),
              ],
              onChanged: (c) {
                if (c != null) ref.read(settingsRepoProvider).write(SettingKeys.mainCurrency, c.code);
              },
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(l.rates, style: const TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
          for (final c in Currency.values)
            if (c != main)
              _RateRow(
                key: ValueKey('${c.code}-${main.code}-${d.rates.current.id}'),
                currency: c,
                main: main,
                valueMicros: d.rates.current.valueInMainMicros(c.code, main.code),
              ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: HintText('${l.ratesHint} ${l.ratesHintSnapshot}'),
          ),
        ]),
      ),
    ]);
  }
}

class _RateRow extends ConsumerStatefulWidget {
  const _RateRow({super.key, required this.currency, required this.main, required this.valueMicros});
  final Currency currency;
  final Currency main;
  final int valueMicros;

  @override
  ConsumerState<_RateRow> createState() => _RateRowState();
}

class _RateRowState extends ConsumerState<_RateRow> {
  late final _ctl = TextEditingController(text: _fmt(widget.valueMicros));

  static String _fmt(int micros) {
    final s = (micros / 1e6).toStringAsFixed(6);
    return s.replaceFirst(RegExp(r'\.?0+$'), '');
  }

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l = context.l;
    final messenger = ScaffoldMessenger.of(context);
    int? micros;
    try {
      micros = parseMinor(_ctl.text, 6);
    } on FormatException {
      micros = null;
    }
    if (micros == null || micros <= 0) {
      _ctl.text = _fmt(widget.valueMicros); // revert
      return;
    }
    if (micros == widget.valueMicros) return;
    await ref.read(ratesRepoProvider).updateRate(widget.currency.code, micros, main: widget.main.code);
    messenger.showSnackBar(SnackBar(content: Text(l.ratesUpdated)));
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.lang;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(children: [
        Expanded(child: Text('1 ${widget.currency.label(lang)} =')),
        SizedBox(
          width: 110,
          child: TextField(
            controller: _ctl,
            textAlign: TextAlign.end,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(isDense: true),
            onSubmitted: (_) => _submit(),
            onTapOutside: (_) {
              FocusScope.of(context).unfocus();
              _submit();
            },
          ),
        ),
        const SizedBox(width: 8),
        Text(widget.main.label(lang)),
      ]),
    );
  }
}
