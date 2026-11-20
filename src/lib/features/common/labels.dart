import '../../data/db/app_database.dart';
import '../../domain/builtin_categories.dart';
import '../../domain/builtin_occasions.dart';
import '../../domain/category_catalog.dart';
import '../../domain/occasions.dart';
import '../../l10n/l10n.dart';

/// Display names shared by every screen (prototype `txName`, `recName`,
/// `memName`, `evName`).
class Labels {
  Labels(this.l, this.lang, this.catalog, {Map<String, Member>? members})
      : members = members ?? const {};

  final AppLocalizations l;
  final String lang;
  final CategoryCatalog catalog;
  final Map<String, Member> members;

  String category(String id) => catalog.displayName(id, lang);

  String tx(TxRow t) => t.note.isNotEmpty
      ? t.note
      : (t.noteKey != null ? l.key(t.noteKey!) : category(t.categoryId));

  String recurring(RecurringItem r) => r.name.isNotEmpty
      ? r.name
      : (r.nameKey != null ? l.key(r.nameKey!) : category(r.categoryId));

  String note(String note, String? key) =>
      note.isNotEmpty ? note : (key != null ? l.key(key) : '');

  /// '' or null = Whole family.
  String member(String? id) {
    if (id == null || id.isEmpty) return l.memFamily;
    final m = members[id];
    if (m == null) return l.memFamily;
    return memberName(m);
  }

  String memberName(Member m) =>
      m.name.isNotEmpty ? m.name : (m.nameKey != null ? l.key(m.nameKey!) : '');

  String memberAvatar(String? id) =>
      (id == null || id.isEmpty) ? wholeFamilyAvatar : (members[id]?.avatar ?? wholeFamilyAvatar);

  String memberColor(String? id) =>
      (id == null || id.isEmpty) ? wholeFamilyColor : (members[id]?.color ?? wholeFamilyColor);

  String role(String r) => switch (r) {
        'parent' => l.roleParent,
        'child' => l.roleChild,
        _ => l.roleOther,
      };

  String account(String accountId) {
    final key = accountId.startsWith('acc-') ? accountId.substring(4) : accountId;
    return l.key('acc_$key');
  }

  String accountIcon(String accountId) => builtinAccounts
      .firstWhere((a) => a.id == accountId, orElse: () => builtinAccounts.first)
      .icon;

  String occasion(String key, [OccasionService? s]) {
    if (isBuiltinOccasion(key)) return l.key('ev_$key');
    return s?.byKey[key]?.customName ?? key;
  }

  String occasionSource(OccasionSource src) => switch (src) {
        OccasionSource.hijri => l.evSrcHijri,
        OccasionSource.holiday => l.evSrcHoliday,
        OccasionSource.fixed => l.evSrcFixed,
        OccasionSource.custom => l.evSrcCustom,
      };

  String frequency(String f) => l.key('fq_$f');

  String country(String c) => l.key('c_$c');

  CategoryDef categoryDef(String id) => catalog.byId(id);
}
