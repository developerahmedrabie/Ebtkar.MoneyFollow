import 'package:drift_flutter/drift_flutter.dart';

import 'app_database.dart';

/// Opens the on-device database (kept separate so unit tests can use
/// `NativeDatabase.memory()` without Flutter).
AppDatabase openAppDatabase() =>
    AppDatabase(driftDatabase(name: 'moneyfollow'));
