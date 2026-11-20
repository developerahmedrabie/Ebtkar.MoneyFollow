import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/money/currency.dart';
import '../../core/money/format.dart';
import '../../data/family_data.dart';
import '../../domain/category_catalog.dart';
import '../../l10n/l10n.dart';
import '../../providers.dart';
import 'labels.dart';

export 'labels.dart';

Labels labelsFor(BuildContext context, WidgetRef ref, FamilyData d) => Labels(
    context.l, context.lang, CategoryCatalog(d.userCategories),
    members: d.membersById);

/// Main-currency total, e.g. `1,250 ج.م`.
String mainMoney(BuildContext context, FamilyData d, int minor,
        {bool sign = false}) =>
    formatAmount(minor, d.main, context.lang, sign: sign);

String moneyIn(BuildContext context, Currency c, int minor) =>
    formatAmount(minor, c, context.lang);

/// Builds [builder] once the family data has loaded.
class DataBuilder extends ConsumerWidget {
  const DataBuilder({super.key, required this.builder});

  final Widget Function(BuildContext context, FamilyData d) builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final d = ref.watch(familyDataProvider);
    return d.when(
      data: (v) => builder(context, v),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(context.l.errorGeneric)),
    );
  }
}

/// Standard screen: title row, optional actions, scrolling body.
class PageScaffold extends StatelessWidget {
  const PageScaffold({
    super.key,
    required this.title,
    required this.children,
    this.actions = const [],
    this.subtitle,
    this.showBack = false,
    this.onRefresh,
  });

  final String title;
  final String? subtitle;
  final List<Widget> actions;
  final List<Widget> children;
  final bool showBack;
  final Future<void> Function()? onRefresh;

  @override
  Widget build(BuildContext context) {
    final list = ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: children,
    );
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: showBack,
        titleSpacing: showBack ? 0 : 16,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (subtitle != null)
              Text(subtitle!,
                  style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor)),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
          ],
        ),
        actions: [...actions, const SizedBox(width: 8)],
      ),
      body: SafeArea(
        top: false,
        child: onRefresh == null
            ? list
            : RefreshIndicator(onRefresh: onRefresh!, child: list),
      ),
    );
  }
}

/// A two-option or three-option segmented control.
class Segments<T> extends StatelessWidget {
  const Segments({super.key, required this.value, required this.items, required this.onChanged});

  final T value;
  final List<(T, String)> items;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        child: SegmentedButton<T>(
          showSelectedIcon: false,
          segments: [
            for (final (v, label) in items)
              ButtonSegment(value: v, label: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis)),
          ],
          selected: {value},
          onSelectionChanged: (s) => onChanged(s.first),
        ),
      );
}

/// Label above a form field.
class FieldLabel extends StatelessWidget {
  const FieldLabel(this.text, {super.key});
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 14, bottom: 6),
        child: Text(text,
            style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).hintColor)),
      );
}
