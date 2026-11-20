import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import 'app.dart';
import 'core/log/app_log.dart';
import 'data/db/open_database.dart';
import 'data/prefs/device_prefs.dart';
import 'providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await AppLog.init(await getApplicationDocumentsDirectory());
  } catch (_) {}
  FlutterError.onError = (details) {
    AppLog.instance.error(details.exception, details.stack);
    if (kDebugMode) FlutterError.presentError(details);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    AppLog.instance.error(error, stack);
    return true;
  };

  final prefs = await DevicePrefs.load();
  final db = openAppDatabase();
  AppLog.instance.log('app start');

  runApp(ProviderScope(
    overrides: [
      prefsProvider.overrideWithValue(prefs),
      dbProvider.overrideWithValue(db),
    ],
    child: const MoneyFollowApp(),
  ));
}
