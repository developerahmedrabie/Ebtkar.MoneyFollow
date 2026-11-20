import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:money_follow/data/db/app_database.dart';
import 'package:money_follow/data/sample/sample_data.dart';

/// The prototype's `TODAY`.
const referenceToday = '2026-11-13';

/// An in-memory database seeded with the prototype's sample family.
Future<AppDatabase> referenceDatabase() async {
  final db = AppDatabase(NativeDatabase.memory());
  await SampleData.generate(referenceToday, createdAt: 1).insertInto(db);
  return db;
}

/// Expected numbers, produced by running the prototype's own JavaScript
/// (`node tool/proto_reference.js ../prototype/index.html`). Amounts are in
/// main-currency units (EGP), not minor units.
final Map<String, dynamic> protoRef = jsonDecode(
        File('test/fixtures/prototype_reference.json').readAsStringSync())
    as Map<String, dynamic>;

/// Main-currency units → minor units.
int egp(num v) => (v * 100).round();
