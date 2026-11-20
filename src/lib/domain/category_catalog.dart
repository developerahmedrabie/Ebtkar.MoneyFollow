import '../data/db/app_database.dart';
import 'builtin_categories.dart';

/// Built-in categories merged with the user's own (FR-010, REQUIREMENTS
/// FR-CAT-06). Every screen resolves categories through this catalog.
class CategoryCatalog {
  CategoryCatalog(List<UserCategory> user)
      : _user = [
          for (final c in user)
            CategoryDef(
              id: c.id,
              type: TxType.parse(c.type),
              en: c.name,
              ar: c.name,
              icon: c.icon,
              color: c.color,
              builtIn: false,
            ),
        ];

  final List<CategoryDef> _user;

  late final Map<String, CategoryDef> _byId = {
    ...builtinCategoriesById,
    for (final c in _user) c.id: c,
  };

  /// Built-in first, then the user's (prototype `catsOf`).
  List<CategoryDef> of(TxType type) => [
        ...builtinCategoriesOf(type),
        ..._user.where((c) => c.type == type),
      ];

  List<CategoryDef> userOf(TxType type) =>
      _user.where((c) => c.type == type).toList();

  /// Unknown ids (e.g. a category deleted on another phone) show as Other.
  CategoryDef byId(String id) =>
      _byId[id] ?? builtinCategoriesById['other_e']!;

  bool contains(String id) => _byId.containsKey(id);

  /// A user category's name as typed; built-in names per language.
  String displayName(String id, String lang) => byId(id).name(lang);
}
