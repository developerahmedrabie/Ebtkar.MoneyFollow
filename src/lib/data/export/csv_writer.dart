import 'dart:convert';

import '../../core/money/currency.dart';
import '../../core/money/money.dart';
import '../../domain/category_catalog.dart';
import '../family_data.dart';

/// Names the CSV needs in the current language.
class CsvLabels {
  const CsvLabels({
    required this.lang,
    required this.account,
    required this.member,
    required this.occasion,
    required this.note,
  });
  final String lang;
  final String Function(String accountId) account;
  final String Function(String? memberId) member;
  final String Function(String? occasionId) occasion;

  /// Note text, resolving sample `note_key`s.
  final String Function(String note, String? noteKey) note;
}

/// contracts/csv-export.md: UTF-8 with BOM, CRLF, RFC 4180, 12 columns.
List<int> buildCsv(FamilyData d, CsvLabels l) {
  String q(String s) => '"${s.replaceAll('"', '""')}"';
  String amt(int minor, String cur) =>
      minorToDecimalString(minor, Currency.fromCode(cur));
  final cats = CategoryCatalog(d.userCategories);
  final main = d.mainCurrency;
  final rows = <(String date, int created, String line)>[];

  for (final t in d.transactions) {
    if (t.isSample) continue;
    rows.add((t.date, t.createdAt, [
      t.date,
      t.type,
      q(cats.displayName(t.categoryId, l.lang)),
      amt(t.amountMinor, t.currency),
      t.currency,
      amt(d.txMain(t), main),
      q(l.account(t.accountId)),
      q(''),
      q(l.member(t.memberId)),
      q(l.occasion(t.occasionId)),
      q(l.note(t.note, t.noteKey)),
      t.recurringId == null ? 'no' : 'yes',
    ].join(',')));
  }
  final accCur = {for (final a in d.accounts) a.id: a.currency};
  for (final t in d.transfers) {
    if (t.isSample) continue;
    final cur = accCur[t.fromAccountId] ?? main;
    rows.add((t.date, t.createdAt, [
      t.date,
      'transfer',
      q(''),
      amt(t.amountOutMinor, cur),
      cur,
      amt(d.rates.rowToMain(t.amountOutMinor, cur, t.rateSnapshotId, main), main),
      q(l.account(t.fromAccountId)),
      q(l.account(t.toAccountId)),
      q(''),
      q(''),
      q(t.note),
      'no',
    ].join(',')));
  }
  rows.sort((a, b) {
    final c = a.$1.compareTo(b.$1);
    return c != 0 ? c : a.$2.compareTo(b.$2);
  });
  const header = 'date,type,category,amount,currency,amount_{M},account,'
      'to_account,member,occasion,note,recurring';
  final text = '${[header.replaceFirst('{M}', main), ...rows.map((r) => r.$3)]
          .join('\r\n')}\r\n';
  return [0xEF, 0xBB, 0xBF, ...utf8.encode(text)];
}

String csvFileName(String today) => 'moneyfollow-transactions-$today.csv';
