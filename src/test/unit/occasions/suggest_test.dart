import 'package:money_follow/data/family_data.dart';
import 'package:money_follow/data/repositories/occasions_repository.dart';
import 'package:money_follow/domain/occasions.dart';
import 'package:test/test.dart';

import '../../fixtures/reference_data.dart';
import '../../fixtures/repos.dart';

void main() {
  late FamilyData d;
  setUpAll(() async {
    final db = await referenceDatabase();
    d = await FamilyData.load(db);
    await db.close();
  });

  test('matches the prototype suggestEv', () {
    final s = OccasionService(d, referenceToday);
    for (final pair in (protoRef['suggest'] as List).cast<List<dynamic>>()) {
      final want = pair[1] as String;
      expect(s.suggest(pair[0] as String), want.isEmpty ? isNull : want,
          reason: pair[0] as String);
    }
  });

  test('window is −14 days … last day', () {
    final s = OccasionService(d, referenceToday);
    // Eid al-Adha 2026-05-27, 4 days
    expect(s.suggest('2026-05-13'), 'eid_adha');
    expect(s.suggest('2026-05-12'), isNull);
    expect(s.suggest('2026-05-30'), 'eid_adha');
    expect(s.suggest('2026-05-31'), isNull);
  });

  test('switched-off occasions are ignored', () async {
    final r = TestRepos();
    addTearDown(r.db.close);
    final occ = OccasionsRepository(r.db, r.stamper);
    expect(OccasionService(await r.data(), referenceToday).suggest('2026-02-10'),
        'ramadan');
    await occ.setEnabled('ramadan', false);
    expect(OccasionService(await r.data(), referenceToday).suggest('2026-02-10'),
        isNull);
  });
}
