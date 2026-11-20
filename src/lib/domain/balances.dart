import '../data/db/app_database.dart';
import '../data/family_data.dart';
import 'conversion.dart';

/// Account balances, derived (data-model "Account"):
/// income − expenses + transfers in − transfers out, in the account's own
/// currency. A row in another currency is converted with its own snapshot.
class AccountBalance {
  const AccountBalance(this.account, this.balanceMinor, this.mainApproxMinor);
  final Account account;

  /// In the account's currency.
  final int balanceMinor;

  /// "≈" in the main currency at the current rates.
  final int mainApproxMinor;
}

List<AccountBalance> accountBalances(FamilyData d) {
  final bal = {for (final a in d.accounts) a.id: 0};
  final cur = {for (final a in d.accounts) a.id: a.currency};
  for (final t in d.transactions) {
    final ac = cur[t.accountId];
    if (ac == null) continue;
    final v = toMain(t.amountMinor, t.currency,
        d.rates.byId(t.rateSnapshotId), ac);
    bal[t.accountId] = bal[t.accountId]! + (t.type == 'income' ? v : -v);
  }
  for (final Transfer tr in d.transfers) {
    if (bal.containsKey(tr.fromAccountId)) {
      bal[tr.fromAccountId] = bal[tr.fromAccountId]! - tr.amountOutMinor;
    }
    if (bal.containsKey(tr.toAccountId)) {
      bal[tr.toAccountId] = bal[tr.toAccountId]! + tr.amountInMinor;
    }
  }
  return [
    for (final a in d.accounts)
      AccountBalance(a, bal[a.id]!, d.currentMain(bal[a.id]!, a.currency)),
  ];
}

/// Total of all accounts in the main currency at the current rates.
int totalInMain(FamilyData d) =>
    accountBalances(d).fold(0, (s, b) => s + b.mainApproxMinor);
