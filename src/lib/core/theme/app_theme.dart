import 'package:material_ui/material_ui.dart';

/// Colour tokens from the prototype `:root` CSS.
@immutable
class MoneyColors extends ThemeExtension<MoneyColors> {
  const MoneyColors({
    required this.bg,
    required this.surface,
    required this.surface2,
    required this.text,
    required this.muted,
    required this.line,
    required this.primary,
    required this.primarySoft,
    required this.onPrimary,
    required this.income,
    required this.incomeSoft,
    required this.expense,
    required this.expenseSoft,
    required this.warn,
    required this.warnSoft,
  });

  final Color bg, surface, surface2, text, muted, line;
  final Color primary, primarySoft, onPrimary;
  final Color income, incomeSoft, expense, expenseSoft, warn, warnSoft;

  static const light = MoneyColors(
    bg: Color(0xFFF6F7F9),
    surface: Color(0xFFFFFFFF),
    surface2: Color(0xFFF1F3F6),
    text: Color(0xFF14181F),
    muted: Color(0xFF6B7280),
    line: Color(0xFFE5E7EB),
    primary: Color(0xFF0E7C66),
    primarySoft: Color(0xFFD9F0EA),
    onPrimary: Color(0xFFFFFFFF),
    income: Color(0xFF15803D),
    incomeSoft: Color(0xFFDCFCE7),
    expense: Color(0xFFD9344B),
    expenseSoft: Color(0xFFFDE4E8),
    warn: Color(0xFFB86E00),
    warnSoft: Color(0xFFFDF0D5),
  );

  static const dark = MoneyColors(
    bg: Color(0xFF0F1216),
    surface: Color(0xFF181C22),
    surface2: Color(0xFF222831),
    text: Color(0xFFEEF1F5),
    muted: Color(0xFF98A2B3),
    line: Color(0xFF2A313B),
    primary: Color(0xFF34C3A1),
    primarySoft: Color(0xFF123A32),
    onPrimary: Color(0xFF062019),
    income: Color(0xFF4ADE80),
    incomeSoft: Color(0xFF123522),
    expense: Color(0xFFFB7185),
    expenseSoft: Color(0xFF3D1520),
    warn: Color(0xFFFBBF24),
    warnSoft: Color(0xFF3A2A0A),
  );

  /// Budget bar colour: primary < 80 %, warn 80–100 %, expense > 100 %
  /// (prototype `barColor`).
  Color budgetColor(double ratio) =>
      ratio > 1 ? expense : (ratio >= .8 ? warn : primary);

  @override
  MoneyColors copyWith() => this;

  @override
  MoneyColors lerp(ThemeExtension<MoneyColors>? other, double t) =>
      other is MoneyColors && t >= .5 ? other : this;
}

extension MoneyColorsX on BuildContext {
  MoneyColors get mc =>
      Theme.of(this).extension<MoneyColors>() ?? MoneyColors.light;
}

/// Parses `#RRGGBB`.
Color hexColor(String hex) =>
    Color(int.parse(hex.substring(1), radix: 16) | 0xFF000000);

/// The prototype's "soft" tint (`color + '22'`).
Color softColor(String hex) => hexColor(hex).withAlpha(0x22);

ThemeData buildTheme(Brightness brightness) {
  final c = brightness == Brightness.dark ? MoneyColors.dark : MoneyColors.light;
  final scheme = ColorScheme.fromSeed(
    seedColor: c.primary,
    brightness: brightness,
  ).copyWith(
    primary: c.primary,
    onPrimary: c.onPrimary,
    surface: c.surface,
    onSurface: c.text,
    error: c.expense,
    outline: c.line,
    outlineVariant: c.line,
  );
  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: c.bg,
    extensions: [c],
    dividerColor: c.line,
    cardTheme: CardThemeData(
      color: c.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: c.line),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: c.bg,
      foregroundColor: c.text,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: c.surface2,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(48, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: c.surface2,
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: c.surface,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
    ),
    snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
  );
}
