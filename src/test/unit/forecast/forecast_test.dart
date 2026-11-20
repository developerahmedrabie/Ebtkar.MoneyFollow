import 'package:money_follow/data/family_data.dart';
import 'package:money_follow/domain/forecast.dart';
import 'package:money_follow/domain/occasion_predictor.dart';
import 'package:money_follow/domain/occasions.dart';
import 'package:test/test.dart';

import '../../fixtures/reference_data.dart';

void main() {
  late FamilyData d;
  setUpAll(() async {
    final db = await referenceDatabase();
    d = await FamilyData.load(db);
    await db.close();
  });

  List<Map<String, dynamic>> ref() => (protoRef['fc'] as List).cast<Map<String, dynamic>>();

  test('without occasions: day-to-day, fixed and income match the prototype',
      () {
    final f = Forecast.compute(d, 3, today: referenceToday);
    expect(f.variableAverage, closeTo(egp(protoRef['fc_varAvg'] as num), 1));
    for (var i = 0; i < 3; i++) {
      final m = f.months[i], r = ref()[i];
      expect(m.month, r['m']);
      expect(m.fixed, egp(r['fixed'] as num), reason: m.month);
      expect(m.income, egp(r['inc'] as num), reason: m.month);
      expect(m.occasions, 0);
      expect(m.total, m.fixed + f.variableAverage);
    }
  });

  test('with the real predictor the totals match the prototype (SC-008)', () {
    final f = Forecast.compute(d, 3,
        today: referenceToday,
        occasionPredictor:
            ServiceOccasionPredictor(OccasionService(d, referenceToday)));
    for (var i = 0; i < 3; i++) {
      final m = f.months[i], r = ref()[i];
      expect(m.occasions, closeTo(egp(r['ev'] as num), 1), reason: m.month);
      expect(m.occasionKeys, (r['evs'] as List).cast<String>());
      expect(m.total, closeTo(egp(r['total'] as num), 2), reason: m.month);
      expect(m.high, r['high'], reason: m.month);
    }
  });

  test('member and whole-family-only forecasts add up', () {
    final everyone = Forecast.compute(d, 3, today: referenceToday);
    var fixedSum = 0, varSum = 0;
    for (final k in [...d.members.map((m) => m.id), '']) {
      final f = Forecast.compute(d, 3, today: referenceToday, memberKey: k);
      fixedSum += f.months[0].fixed;
      varSum += f.variableAverage;
    }
    expect(fixedSum, everyone.months[0].fixed);
    expect(varSum, closeTo(everyone.variableAverage, 5));
  });
}
