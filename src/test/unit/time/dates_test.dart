import 'package:test/test.dart';
import 'package:money_follow/core/time/dates.dart';

void main() {
  test('shiftMonth across years', () {
    expect(LocalDate.shiftMonth('2026-11', 2), '2027-01');
    expect(LocalDate.shiftMonth('2026-01', -1), '2025-12');
    expect(LocalDate.shiftMonth('2026-11', -34), '2024-01');
  });

  test('daysInMonth for February in leap and normal years', () {
    expect(LocalDate.daysInMonth(2024, 2), 29);
    expect(LocalDate.daysInMonth(2026, 2), 28);
    expect(LocalDate.daysInMonthOf('2026-12'), 31);
  });

  test('addDays and daysBetween', () {
    expect(LocalDate.addDays('2026-11-13', 30), '2026-12-13');
    expect(LocalDate.addDays('2024-03-01', -1), '2024-02-29');
    expect(LocalDate.daysBetween('2026-11-13', '2026-11-20'), 7);
    expect(LocalDate.daysBetween('2026-11-20', '2026-11-13'), -7);
  });

  test('clampedDate', () {
    expect(LocalDate.clampedDate(2026, 2, 31), '2026-02-28');
    expect(LocalDate.lastOfMonth('2024-02'), '2024-02-29');
  });
}
