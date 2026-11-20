/// Built-in categories (prototype `CATS`). Code constants with stable ids;
/// never stored as rows and never editable (FR-007).
library;

enum TxType {
  expense,
  income;

  static TxType parse(String s) => s == 'income' ? income : expense;
}

class CategoryDef {
  const CategoryDef({
    required this.id,
    required this.type,
    required this.en,
    required this.ar,
    required this.icon,
    required this.color,
    this.builtIn = true,
  });

  final String id;
  final TxType type;
  final String en;
  final String ar;
  final String icon;

  /// `#RRGGBB`.
  final String color;
  final bool builtIn;

  String name(String lang) => lang == 'ar' ? ar : en;
}

const builtinExpenseCategories = <CategoryDef>[
  CategoryDef(id: 'groceries', type: TxType.expense, en: 'Groceries', ar: 'البقالة', icon: '🛒', color: '#f59e0b'),
  CategoryDef(id: 'rent', type: TxType.expense, en: 'Rent', ar: 'الإيجار', icon: '🏠', color: '#6366f1'),
  CategoryDef(id: 'utilities', type: TxType.expense, en: 'Utilities', ar: 'المرافق', icon: '💡', color: '#0ea5e9'),
  CategoryDef(id: 'transport', type: TxType.expense, en: 'Transport', ar: 'المواصلات', icon: '🚗', color: '#14b8a6'),
  CategoryDef(id: 'education', type: TxType.expense, en: 'Education', ar: 'التعليم', icon: '🎓', color: '#8b5cf6'),
  CategoryDef(id: 'health', type: TxType.expense, en: 'Health', ar: 'الصحة', icon: '💊', color: '#ef4444'),
  CategoryDef(id: 'dining', type: TxType.expense, en: 'Dining out', ar: 'مطاعم', icon: '🍽️', color: '#f97316'),
  CategoryDef(id: 'shopping', type: TxType.expense, en: 'Shopping', ar: 'تسوق', icon: '🛍️', color: '#ec4899'),
  CategoryDef(id: 'fun', type: TxType.expense, en: 'Entertainment', ar: 'ترفيه', icon: '🎬', color: '#a855f7'),
  CategoryDef(id: 'bills', type: TxType.expense, en: 'Phone & Net', ar: 'موبايل وإنترنت', icon: '📱', color: '#64748b'),
  CategoryDef(id: 'other_e', type: TxType.expense, en: 'Other', ar: 'أخرى', icon: '📦', color: '#94a3b8'),
];

const builtinIncomeCategories = <CategoryDef>[
  CategoryDef(id: 'salary', type: TxType.income, en: 'Salary', ar: 'الراتب', icon: '💼', color: '#16a34a'),
  CategoryDef(id: 'freelance', type: TxType.income, en: 'Freelance', ar: 'عمل حر', icon: '💻', color: '#0d9488'),
  CategoryDef(id: 'rental', type: TxType.income, en: 'Rental', ar: 'إيجارات', icon: '🏢', color: '#2563eb'),
  CategoryDef(id: 'gift', type: TxType.income, en: 'Gifts', ar: 'هدايا', icon: '🎁', color: '#db2777'),
  CategoryDef(id: 'other_i', type: TxType.income, en: 'Other', ar: 'أخرى', icon: '💰', color: '#65a30d'),
];

final Map<String, CategoryDef> builtinCategoriesById = {
  for (final c in [...builtinExpenseCategories, ...builtinIncomeCategories])
    c.id: c,
};

List<CategoryDef> builtinCategoriesOf(TxType type) =>
    type == TxType.expense ? builtinExpenseCategories : builtinIncomeCategories;

String otherCategoryId(TxType type) =>
    type == TxType.expense ? 'other_e' : 'other_i';

/// Icons and colours for user categories (prototype `CAT_ICONS`, `CAT_COLORS`).
const categoryIcons = <String>[
  '🐾', '🎁', '✈️', '🏖️', '🧸', '💄', '💇', '🧹', '🔧', '⚽', '🎮', '📚', //
  '🎨', '🎵', '🍼', '☕', '🕌', '🤲', '🏥', '💻', '🪴', '🏋️', '🚌', '💸',
];
const categoryColors = <String>[
  '#ef4444', '#f97316', '#f59e0b', '#65a30d', '#16a34a', '#0d9488', //
  '#0ea5e9', '#2563eb', '#7c3aed', '#db2777', '#78716c', '#475569',
];

/// Member avatars and colours (prototype `AVATARS`, `MEM_COLORS`).
const memberAvatars = <String>['👨', '👩', '👦', '👧', '🧒', '👶', '👴', '👵', '🧑'];
const memberColors = <String>[
  '#2563eb', '#db2777', '#f59e0b', '#8b5cf6', //
  '#0d9488', '#ef4444', '#65a30d', '#0ea5e9',
];

/// "Whole family" display (prototype `SHARED`); not a row.
const wholeFamilyAvatar = '🏠';
const wholeFamilyColor = '#94a3b8';

/// Accounts (FR-011) with fixed ids so synced phones agree.
class AccountDef {
  const AccountDef(this.id, this.key, this.icon, this.currencyCode);
  final String id;
  final String key;
  final String icon;
  final String currencyCode;
}

const builtinAccounts = <AccountDef>[
  AccountDef('acc-cash', 'cash', '💵', 'EGP'),
  AccountDef('acc-bank', 'bank', '🏦', 'EGP'),
  AccountDef('acc-card', 'card', '💳', 'EGP'),
  AccountDef('acc-usd', 'usd', '💲', 'USD'),
];

String accountIdForKey(String key) => 'acc-$key';
