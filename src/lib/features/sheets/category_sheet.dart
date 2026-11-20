import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/theme/app_theme.dart';
import '../../data/repositories/base_repository.dart';
import '../../domain/builtin_categories.dart';
import '../../l10n/l10n.dart';
import '../../providers.dart';
import '../../widgets/common/common.dart';
import '../common/ui.dart';

/// Add / edit a user category (prototype `#csheet`, FR-CAT).
class CategorySheet extends ConsumerStatefulWidget {
  const CategorySheet({super.key, this.categoryId, this.type = TxType.expense});

  final String? categoryId;
  final TxType type;

  static Future<void> show(BuildContext context, {String? categoryId, TxType type = TxType.expense}) =>
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (_) => CategorySheet(categoryId: categoryId, type: type),
      );

  @override
  ConsumerState<CategorySheet> createState() => _CategorySheetState();
}

class _CategorySheetState extends ConsumerState<CategorySheet> {
  final _name = TextEditingController();
  late TxType _type = widget.type;
  String _icon = categoryIcons.first;
  String _color = categoryColors.first;
  String? _error;

  @override
  void initState() {
    super.initState();
    final d = ref.read(familyDataProvider).value;
    final c = d?.userCategories.where((x) => x.id == widget.categoryId).firstOrNull;
    if (c != null) {
      _type = TxType.parse(c.type);
      _name.text = c.name;
      _icon = c.icon;
      _color = c.color;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l = context.l;
    final nav = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final repo = ref.read(categoriesRepoProvider);
      widget.categoryId == null
          ? await repo.create(_type, _name.text, _icon, _color)
          : await repo.update(widget.categoryId!, _name.text, _icon, _color);
    } on ValidationException catch (e) {
      setState(() => _error = e.code == 'err_cat_dup' ? l.errCatDup : l.errName);
      return;
    }
    nav.pop();
    messenger.showSnackBar(SnackBar(content: Text(l.tCatSaved)));
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final c = context.mc;
    final editing = widget.categoryId != null;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(children: [
            Expanded(
                child: Text(editing ? l.editCat : l.newCat,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800))),
            TextButton(onPressed: () => Navigator.pop(context), child: Text(l.cancel)),
          ]),
          Center(
            child: Column(children: [
              CatIcon(icon: _icon, color: _color, size: 64),
              const SizedBox(height: 6),
              Text(_name.text.trim().isEmpty ? l.catPh : _name.text.trim(),
                  style: const TextStyle(fontWeight: FontWeight.w700)),
            ]),
          ),
          if (!editing) ...[
            FieldLabel(l.catType),
            Segments<TxType>(
              value: _type,
              items: [(TxType.expense, l.expense), (TxType.income, l.income1)],
              onChanged: (v) => setState(() => _type = v),
            ),
          ],
          FieldLabel(l.name),
          TextField(
            controller: _name,
            maxLength: 20,
            decoration: InputDecoration(hintText: l.catPh, errorText: _error, counterText: ''),
            onChanged: (_) => setState(() => _error = null),
          ),
          FieldLabel(l.iconL),
          Wrap(spacing: 6, runSpacing: 6, children: [
            for (final i in categoryIcons)
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => setState(() => _icon = i),
                child: Container(
                  width: 48,
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: i == _icon ? c.primarySoft : c.surface2,
                    border: Border.all(color: i == _icon ? c.primary : Colors.transparent, width: 2),
                  ),
                  child: Text(i, style: const TextStyle(fontSize: 22)),
                ),
              ),
          ]),
          FieldLabel(l.colorL),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final col in categoryColors)
              Semantics(
                button: true,
                selected: col == _color,
                label: col,
                child: InkWell(
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
              ),
          ]),
          const SizedBox(height: 18),
          FilledButton(onPressed: _save, child: Text(l.save)),
          if (editing) ...[
            const SizedBox(height: 10),
            ConfirmTwiceButton(
              label: l.delCat,
              onConfirmed: () async {
                final nav = Navigator.of(context);
                final messenger = ScaffoldMessenger.of(context);
                await ref.read(categoriesRepoProvider).delete(widget.categoryId!);
                nav.pop();
                messenger.showSnackBar(SnackBar(content: Text(l.tCatDeleted)));
              },
            ),
            HintText(l.delCatHint),
          ],
        ]),
      ),
    );
  }
}
