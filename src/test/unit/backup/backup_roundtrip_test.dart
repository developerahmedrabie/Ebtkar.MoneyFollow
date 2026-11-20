import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:money_follow/data/backup/backup_service.dart';
import 'package:money_follow/data/db/app_database.dart';
import 'package:money_follow/data/repositories/members_repository.dart';
import 'package:money_follow/data/repositories/transactions_repository.dart';
import 'package:money_follow/data/sample/sample_data.dart';
import 'package:money_follow/domain/builtin_categories.dart';
import 'package:test/test.dart';

import '../../fixtures/repos.dart';

Future<List<Map<String, Object?>>> dump(AppDatabase db, String t) async =>
    [for (final r in await db.customSelect('SELECT * FROM $t ORDER BY id').get()) r.data];

void main() {
  late TestRepos src;
  late BackupService backup;

  setUp(() async {
    src = TestRepos();
    backup = BackupService(src.db, appVersion: '1.0.0+1', deviceName: 'Test phone');
    final m = await MembersRepository(src.db, src.stamper).create('Omar', 'child', '👦');
    for (var i = 1; i <= 5; i++) {
      await src.transactions.create(TxInput(
          type: TxType.expense,
          amountMinor: 1000 * i,
          currency: i.isEven ? 'USD' : 'EGP',
          categoryId: 'groceries',
          accountId: 'acc-cash',
          date: '2026-11-0$i',
          memberId: m,
          note: 'عشاء "$i"'));
    }
    final del = await src.transactions.create(const TxInput(
        type: TxType.income, amountMinor: 1, currency: 'EGP', categoryId: 'gift',
        accountId: 'acc-cash', date: '2026-11-01'));
    await src.transactions.delete(del);
    await src.rates.updateRate('USD', 52000000);
    await SampleData.generate('2026-11-13', createdAt: 1).insertInto(src.db);
  });
  tearDown(() => src.db.close());

  Future<void> roundTrip(String? password) async {
    final bytes = await backup.createBackup(password: password);
    final h = backup.readHeader(bytes);
    expect(h.encrypted, password != null);
    expect(h.deviceName, 'Test phone');
    expect(h.counts['transactions'], 5);
    expect(h.counts['members'], 1);

    final dst = AppDatabase(NativeDatabase.memory());
    addTearDown(dst.close);
    await BackupService(dst, appVersion: '1', deviceName: 'x')
        .restore(bytes, password: password);
    for (final t in ['transactions', 'members', 'rate_snapshots', 'settings', 'accounts']) {
      final want = (await dump(src.db, t)).where((r) => r['is_sample'] == 0).toList();
      expect(await dump(dst, t), want, reason: t);
    }
    // tombstone included, sample rows never
    final txs = await dump(dst, 'transactions');
    expect(txs.where((r) => r['deleted'] == 1), hasLength(1));
    expect(txs.where((r) => r['is_sample'] == 1), isEmpty);
  }

  test('round trip without a password', () => roundTrip(null));

  test('round trip with a password; wrong password refused, data unchanged',
      () async {
    await roundTrip('s3cret');
    final bytes = await backup.createBackup(password: 's3cret');
    final before = await dump(src.db, 'transactions');
    await expectLater(backup.restore(bytes, password: 'nope'),
        throwsA(isA<BackupWrongPassword>()));
    await expectLater(backup.restore(bytes), throwsA(isA<BackupPasswordRequired>()));
    expect(await dump(src.db, 'transactions'), before);
  }, timeout: const Timeout(Duration(minutes: 2)));

  test('newer schema, bad magic, truncation and SHA mismatch are refused',
      () async {
    final good = await backup.createBackup();
    final newer = await BackupCodec.encode(
        payload: {'schemaVersion': 2, 'tables': <String, dynamic>{}},
        header: {'schemaVersion': 2});
    await expectLater(backup.restore(newer), throwsA(isA<BackupNewerVersion>()));

    final badMagic = Uint8List.fromList(good)..[0] = 0x58;
    await expectLater(backup.restore(badMagic), throwsA(isA<BackupDamaged>()));

    final truncated = Uint8List.sublistView(good, 0, good.length - 20);
    await expectLater(backup.restore(truncated), throwsA(isA<BackupDamaged>()));

    final flipped = Uint8List.fromList(good)..[good.length - 5] ^= 0xFF;
    await expectLater(backup.restore(flipped), throwsA(isA<BackupDamaged>()));

    expect(await dump(src.db, 'transactions'), isNotEmpty);
  });

  test('backup trims the outbox', () async {
    expect(await src.db.select(src.db.syncOutbox).get(), isNotEmpty);
    await backup.createBackup();
    expect(await src.db.select(src.db.syncOutbox).get(), isEmpty);
  });
}
