import '../data/family_data.dart';
import 'builtin_categories.dart';
import 'category_catalog.dart';

class BudgetRow {
  const BudgetRow(this.category, this.spent, this.limit);
  final CategoryDef category;

  /// Main-currency minor units.
  final int spent;
  final int limit;

  double get ratio => limit <= 0 ? 0 : spent / limit;
  int get left => limit - spent;
}

/// Prototype `budgetRows`: every live budget with its spending in [ym]
/// (transfers are never counted), sorted by % used, highest first.
List<BudgetRow> budgetRows(FamilyData d, String ym, {int? limit}) {
  final cat = CategoryCatalog(d.userCategories);
  final spent = <String, int>{};
  for (final t in d.inMonth(ym)) {
    if (t.type == 'expense') {
      spent[t.categoryId] = (spent[t.categoryId] ?? 0) + d.txMain(t);
    }
  }
  final rows = [
    for (final b in d.budgets)
      if (cat.contains(b.categoryId))
        BudgetRow(cat.byId(b.categoryId), spent[b.categoryId] ?? 0, b.limitMinor),
  ]..sort((a, b) => b.ratio.compareTo(a.ratio));
  return limit == null ? rows : rows.take(limit).toList();
}

class BudgetTotal {
  const BudgetTotal(this.spent, this.limit);
  final int spent;
  final int limit;
  double get ratio => limit <= 0 ? 0 : spent / limit;
}

/// Total budget card: spending in budgeted categories vs the sum of limits.
BudgetTotal budgetTotal(FamilyData d, String ym) {
  final rows = budgetRows(d, ym);
  return BudgetTotal(rows.fold(0, (a, r) => a + r.spent),
      rows.fold(0, (a, r) => a + r.limit));
}

enum BudgetLevel { ok, warn, over }

/// < 80 % ok, 80–100 % warn, > 100 % over.
BudgetLevel budgetLevel(double ratio) =>
    ratio > 1 ? BudgetLevel.over : (ratio >= .8 ? BudgetLevel.warn : BudgetLevel.ok);
