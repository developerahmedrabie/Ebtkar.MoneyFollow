import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

/// FR-044: every key exists in both languages with the same placeholders.
void main() {
  Map<String, dynamic> load(String lang) =>
      jsonDecode(File('lib/l10n/app_$lang.arb').readAsStringSync())
          as Map<String, dynamic>;

  Set<String> keys(Map<String, dynamic> arb) =>
      arb.keys.where((k) => !k.startsWith('@')).toSet();

  Set<String> placeholders(String text) =>
      RegExp(r'\{(\w+)\}').allMatches(text).map((m) => m.group(1)!).toSet();

  test('app_en.arb and app_ar.arb have the same keys', () {
    final en = load('en'), ar = load('ar');
    expect(keys(ar).difference(keys(en)), isEmpty, reason: 'only in ar');
    expect(keys(en).difference(keys(ar)), isEmpty, reason: 'only in en');
  });

  test('placeholders match per key', () {
    final en = load('en'), ar = load('ar');
    for (final k in keys(en)) {
      expect(placeholders(ar[k] as String), placeholders(en[k] as String),
          reason: k);
    }
  });

  test('no empty strings', () {
    for (final lang in ['en', 'ar']) {
      final arb = load(lang);
      for (final k in keys(arb)) {
        expect((arb[k] as String).trim(), isNotEmpty, reason: '$lang.$k');
      }
    }
  });
}
