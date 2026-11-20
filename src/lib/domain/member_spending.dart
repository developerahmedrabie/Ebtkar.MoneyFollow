import '../core/time/dates.dart';
import '../data/family_data.dart';
import 'monthly_totals.dart';

/// Member key: a member id, or '' for Whole family (member_id NULL).
const wholeFamilyKey = '';

/// Keys of every member plus Whole family (prototype `allMem`).
List<String> allMemberKeys(FamilyData d) =>
    [...d.members.map((m) => m.id), wholeFamilyKey];

class MemberShare {
  const MemberShare(this.memberKey, this.spent, this.share);
  final String memberKey;
  final int spent;

  /// 0–1 of the month's total expenses.
  final double share;
}

/// Who spent this month (prototype `shareHTML`).
List<MemberShare> familyShare(FamilyData d, String ym) {
  final keys = allMemberKeys(d);
  final spent = {for (final k in keys) k: memberSpent(d, k, ym)};
  final total = spent.values.fold(0, (a, b) => a + b);
  return [
    for (final k in keys)
      MemberShare(k, spent[k]!, total == 0 ? 0 : spent[k]! / total),
  ];
}

/// Spending for [n] months ending at [endYm], oldest first.
List<(String, int)> memberSeries(
        FamilyData d, String? memberKey, String endYm, [int n = 6]) =>
    [
      for (var k = n - 1; k >= 0; k--)
        (
          LocalDate.shiftMonth(endYm, -k),
          memberSpent(d, memberKey, LocalDate.shiftMonth(endYm, -k)),
        ),
    ];
