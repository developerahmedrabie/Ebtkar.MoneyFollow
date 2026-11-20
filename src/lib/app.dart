import 'package:flutter_localizations/flutter_localizations.dart'
    show GlobalCupertinoLocalizations, GlobalWidgetsLocalizations;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import 'core/theme/app_theme.dart';
import 'features/shell/app_lifecycle.dart';
import 'features/shell/router.dart';
import 'l10n/l10n.dart';
import 'providers.dart';

class MoneyFollowApp extends ConsumerWidget {
  const MoneyFollowApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(languageProvider);
    final theme = ref.watch(themeProvider);
    final router = ref.watch(routerProvider);
    // Western digits in Arabic (REQUIREMENTS: Arabic-first, Western digits).
    DateFormat.useNativeDigitsByDefaultFor('ar', false);
    return MaterialApp.router(
      title: 'MoneyFollow',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      locale: Locale(lang),
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: buildTheme(Brightness.light),
      darkTheme: buildTheme(Brightness.dark),
      builder: (context, child) =>
          AppLifecycle(router: router, child: child ?? const SizedBox.shrink()),
      themeMode: switch (theme) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      },
    );
  }
}
