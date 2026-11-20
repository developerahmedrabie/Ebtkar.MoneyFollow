import 'dart:convert';

import 'package:money_follow/data/export/csv_writer.dart';
import 'package:money_follow/data/repositories/transactions_repository.dart';
import 'package:money_follow/data/repositories/transfers_repository.dart';
import 'package:money_follow/data/sample/sample_data.dart';
import 'package:money_follow/domain/builtin_categories.dart';
import 'package:test/test.dart';

import '../../fixtures/repos.dart';

void main() {
  test('BOM, CRLF, quoting, 12 columns, transfers, snapshots, no sample/deleted',
      () async {
    final r = TestRepos();
    addTearDown(r.db.close);
    await SampleData.generate('2026-11-13', createdAt: 1).insertInto(r.db);
    final old = await r.transactions.create(const TxInput(
        type: TxType.expense,
        amountMinor: 10000,
        currency: 'USD',
        categoryId: 'groceries',
        accountId: 'acc-usd',
        date: '2026-11-12',
        note: 'He said "hi", ok'));
    await r.rates.updateRate('USD', 52000000);
    r.tick();
    await r.transactions.create(const TxInput(
        type: TxType.expense,
        amountMinor: 10000,
        currency: 'USD',
        categoryId: 'groceries',
        accountId: 'acc-usd',
        date: '2026-11-12'));
    final gone = await r.transactions.create(const TxInput(
        type: TxType.income,
        amountMinor: 500,
        currency: 'EGP',
        categoryId: 'gift',
        accountId: 'acc-cash',
        date: '2026-11-01'));
    await r.transactions.delete(gone);
    await TransfersRepository(r.db, r.stamper, r.settings).create(
        const TransferInput(
            fromAccountId: 'acc-bank',
            toAccountId: 'acc-cash',
            amountOutMinor: 200000,
            amountInMinor: 200000,
            date: '2026-11-13'));

    final bytes = buildCsv(
        await r.data(),
        CsvLabels(
          lang: 'ar',
          account: (id) => {'acc-usd': 'حساب الدولار', 'acc-bank': 'البنك', 'acc-cash': 'نقدي'}[id] ?? id,
          member: (id) => id ?? '',
          occasion: (id) => id ?? '',
          note: (n, k) => n,
        ));
    expect(bytes.sublist(0, 3), [0xEF, 0xBB, 0xBF]);
    final text = utf8.decode(bytes.sublist(3));
    final lines = text.split('\r\n');
    expect(lines.last, ''); // ends with CRLF
    expect(lines.first,
        'date,type,category,amount,currency,amount_EGP,account,to_account,member,occasion,note,recurring');
    final data = lines.sublist(1, lines.length - 1);
    expect(data, hasLength(3)); // no sample, no deleted row
    expect(data[0], startsWith('2026-11-12,expense,"البقالة",100.00,USD,5000.00,"حساب الدولار"'));
    expect(data[0], contains('"He said ""hi"", ok"'));
    expect(data[0], endsWith(',no'));
    expect(data[1], contains(',100.00,USD,5200.00,'));
    expect(data[2], '2026-11-13,transfer,"",2000.00,EGP,2000.00,"البنك","نقدي","","","",no');
    expect(old, isNotEmpty);
  });

  test('file name', () {
    expect(csvFileName('2026-11-13'), 'moneyfollow-transactions-2026-11-13.csv');
  });
}
