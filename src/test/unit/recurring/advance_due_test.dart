import 'package:money_follow/domain/recurring.dart';
import 'package:test/test.dart';

void main() {
  test('weekly adds 7 days', () {
    expect(advanceDue('2026-11-28', 'weekly', 28), '2026-12-05');
  });

  test('monthly from the 31st keeps the anchor day', () {
    var d = '2026-01-31';
    d = advanceDue(d, 'monthly', 31);
    expect(d, '2026-02-28');
    d = advanceDue(d, 'monthly', 31);
    expect(d, '2026-03-31');
    expect(advanceDue('2024-01-31', 'monthly', 31), '2024-02-29');
  });

  test('quarterly', () {
    expect(advanceDue('2026-11-25', 'quarterly', 25), '2027-02-25');
  });

  test('yearly 29 Feb → 28 Feb', () {
    expect(advanceDue('2024-02-29', 'yearly', 29), '2025-02-28');
  });

  test('occurrencesInRange', () {
    expect(occurrencesInRange('2026-11-14', 'weekly', 14, '2026-12-01', '2026-12-31'),
        ['2026-12-05', '2026-12-12', '2026-12-19', '2026-12-26']);
    expect(occurrencesInRange('2026-11-25', 'quarterly', 25, '2026-12-01', '2026-12-31'),
        isEmpty);
  });

  test('monthly equivalents', () {
    expect(monthlyEquivalent(1200, 'weekly'), closeTo(5200, 1e-9));
    expect(monthlyEquivalent(1200, 'yearly'), 100);
    expect(monthlyEquivalent(300, 'quarterly'), 100);
  });

  test('due labels', () {
    expect(dueLabel('2026-11-10', '2026-11-13').kind, DueKind.overdue);
    expect(dueLabel('2026-11-10', '2026-11-13').days, 3);
    expect(dueLabel('2026-11-13', '2026-11-13').kind, DueKind.today);
    expect(dueLabel('2026-11-14', '2026-11-13').kind, DueKind.tomorrow);
    expect(dueLabel('2026-11-20', '2026-11-13').kind, DueKind.soon);
    expect(dueLabel('2026-11-25', '2026-11-13').kind, DueKind.later);
  });
}
