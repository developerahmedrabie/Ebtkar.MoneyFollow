import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:money_follow/data/family_data.dart';
import 'package:money_follow/data/remote/date_clients.dart';
import 'package:money_follow/data/remote/occasion_dates_service.dart';
import 'package:money_follow/data/repositories/occasions_repository.dart';
import 'package:money_follow/domain/occasions.dart';
import 'package:test/test.dart';

import '../../fixtures/repos.dart';

/// Fake Aladhan: Hijri year hy → Ramadan starts on `(hy+579)-03-01`, etc.
http.Response aladhan(http.Request req) {
  final m = RegExp(r'hToG/(\d{2})-(\d{2})-(\d{4})').firstMatch(req.url.path)!;
  final hm = int.parse(m[2]!), hy = int.parse(m[3]!);
  final gy = hy + 579;
  final mm = {9: '03', 10: '04', 12: '06'}[hm]!;
  return http.Response(
      jsonEncode({
        'code': 200,
        'data': {
          'gregorian': {'date': '01-$mm-$gy'}
        }
      }),
      200);
}

void main() {
  late TestRepos r;
  late OccasionsRepository occ;
  setUp(() {
    r = TestRepos();
    occ = OccasionsRepository(r.db, r.stamper);
  });
  tearDown(() => r.db.close());

  OccasionDatesService service(MockClient c) {
    final h = DateHttp(c);
    return OccasionDatesService(AladhanClient(h), NagerClient(h), occ, r.settings);
  }

  test('parses Aladhan dates and matches Nager holidays', () async {
    final requests = <Uri>[];
    final c = MockClient((req) async {
      requests.add(req.url);
      expect(req.headers['User-Agent'], startsWith('MoneyFollow/'));
      if (req.url.host == 'api.aladhan.com') return aladhan(req);
      final year = req.url.pathSegments[3];
      return http.Response(
          jsonEncode([
            {'date': '$year-12-25', 'name': 'Christmas Day'},
            {'date': '$year-04-06', 'name': 'Easter Monday'},
          ]),
          200);
    });
    final res = await service(c).refresh('US', '2026-11-13');
    expect(res.status, DatesRefreshStatus.updated);
    expect(requests.where((u) => u.host == 'date.nager.at'), hasLength(5));
    await r.settings.write('country', 'US');
    final s = OccasionService(await r.data(), '2026-11-13');
    expect(s.dates('xmas'), contains('2026-12-25'));
    expect(s.dates('ramadan'), contains('2025-03-01'));
    expect(s.byKey.containsKey('sham'), isFalse); // EG only
    expect(s.byKey.containsKey('mothers'), isFalse);
  });

  test('empty list / 404 means no holiday data (SA)', () async {
    final c = MockClient((req) async => req.url.host == 'api.aladhan.com'
        ? aladhan(req)
        : (req.url.pathSegments[3] == '2025'
            ? http.Response('', 404)
            : http.Response('[]', 200)));
    final res = await service(c).refresh('SA', '2026-11-13');
    expect(res.status, DatesRefreshStatus.noHolidayData);
    expect(res.count, greaterThan(0)); // Islamic dates still update
  });

  test('total failure changes nothing', () async {
    final before = (await r.data()).occasionDates.length;
    final c = MockClient((req) async => throw http.ClientException('offline'));
    final res = await service(c).refresh('EG', '2026-11-13');
    expect(res.status, DatesRefreshStatus.failed);
    final d = await r.data();
    expect(d.occasionDates.length, before);
    expect(d.settings['occasion_dates_updated_at'], isNull);
  });

  test('partial failure keeps old rows; adjust_days is preserved', () async {
    await occ.adjust('ramadan', 2026, 'EG', 1, startDate: '2026-02-18');
    final c = MockClient((req) async {
      if (req.url.host == 'api.aladhan.com') {
        final hm = RegExp(r'hToG/\d{2}-(\d{2})').firstMatch(req.url.path)![1];
        if (hm == '10') throw http.ClientException('down'); // Eid al-Fitr fails
        return aladhan(req);
      }
      return http.Response('[]', 200);
    });
    await service(c).refresh('EG', '2026-11-13');
    final d = await r.data();
    final ramadan2026 =
        d.occasionDates.firstWhere((x) => x.id == 'ramadan|2026|EG');
    expect(ramadan2026.adjustDays, 1);
    expect(ramadan2026.startDate, '2026-03-01');
    expect(d.occasionDates.where((x) => x.occasionKey == 'eid_fitr' && x.source == 'bundled'),
        hasLength(4));
    final s = OccasionService(d, '2026-11-13');
    expect(s.dates('ramadan'), contains('2026-03-02')); // +1 day
  });

  test('custom occasions and ±1 adjustment of fixed dates', () async {
    final key = await occ.createCustom('Anniversary', '🎁', '#db2777', '06-10', 1);
    await occ.adjust('mothers', 2027, 'EG', -1, startDate: '2027-03-21');
    final s = OccasionService(await r.data(), '2026-11-13');
    expect(s.dates(key), contains('2027-06-10'));
    expect(s.nextOccurrence(key), '2027-06-10');
    expect(s.dates('mothers'), contains('2027-03-20'));
    expect(() => occ.adjust('mothers', 2027, 'EG', 2, startDate: '2027-03-21'),
        throwsA(anything));
  });

  test('FamilyData sees no deleted occasion dates', () async {
    expect((await FamilyData.load(r.db)).occasionDates.every((d) => !d.deleted), isTrue);
  });
}
