import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/builtin_categories.dart';
import '../../l10n/l10n.dart';
import '../../widgets/common/common.dart';
import '../common/ui.dart';
import '../sheets/category_sheet.dart';

/// Categories (REQUIREMENTS §7.15).
class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({super.key, this.type = 'expense'});
  final String type;

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen> {
  late TxType _type = TxType.parse(widget.type);

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final c = context.mc;
    return PageScaffold(showBack: true, title: l.categories, children: [
      DataBuilder(builder: (context, d) {
        final labels = labelsFor(context, ref, d);
        final usage = <String, int>{};
        for (final t in d.transactions) {
          usage[t.categoryId] = (usage[t.categoryId] ?? 0) + 1;
        }
        final mine = labels.catalog.userOf(_type);
        return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Segments<TxType>(
            value: _type,
            items: [(TxType.expense, l.expenses), (TxType.income, l.income)],
            onChanged: (v) => setState(() => _type = v),
          ),
          SectionHeader(l.myCats,
              link: l.addCat, onLink: () => CategorySheet.show(context, type: _type)),
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: mine.isEmpty
                ? EmptyState(l.noMyCats)
                : Column(children: [
                    for (final cat in mine)
                      ListTile(
                        leading: CatIcon(icon: cat.icon, color: cat.color, size: 36),
                        title: Text(cat.name(context.lang)),
                        subtitle: Text((usage[cat.id] ?? 0) == 0 ? l.notUsed : l.usedN('${usage[cat.id]}')),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => CategorySheet.show(context, categoryId: cat.id),
                      ),
                  ]),
          ),
          SectionHeader(l.builtinCats),
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Column(children: [
              for (final cat in builtinCategoriesOf(_type))
                ListTile(
                  leading: CatIcon(icon: cat.icon, color: cat.color, size: 36),
                  title: Text(cat.name(context.lang)),
                  trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.lock_outline, size: 16, color: c.muted),
                    const SizedBox(width: 4),
                    Text(l.builtin, style: TextStyle(color: c.muted, fontSize: 12)),
                  ]),
                ),
            ]),
          ),
          HintText(l.catsHint),
        ]);
      }),
    ]);
  }
}
