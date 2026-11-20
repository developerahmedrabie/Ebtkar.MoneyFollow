// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get about => 'About';

  @override
  String get accBank => 'Bank';

  @override
  String get accCard => 'Card';

  @override
  String get accCash => 'Cash';

  @override
  String get accUsd => 'Dollar account';

  @override
  String get account => 'Account';

  @override
  String get accounts => 'Accounts';

  @override
  String get addCat => '+ Add category';

  @override
  String get addMember => '+ Add member';

  @override
  String get addOccasion => '+ Add occasion';

  @override
  String get addRec => '+ Add';

  @override
  String get adjustDate => 'Adjust date';

  @override
  String get adjustHint => 'Moon sighting can shift the date by a day.';

  @override
  String get all => 'All';

  @override
  String get allMembers => 'Everyone';

  @override
  String get allRec => 'All recurring';

  @override
  String get amount => 'Amount';

  @override
  String get amountReceived => 'Amount received';

  @override
  String get amountSent => 'Amount sent';

  @override
  String get appLock => 'App lock';

  @override
  String get appName => 'MoneyFollow';

  @override
  String get appSub => 'Home finance';

  @override
  String approx(String v) {
    return '≈ $v';
  }

  @override
  String get avatar => 'Avatar';

  @override
  String get avgDaily => 'Avg. daily spend';

  @override
  String get back => 'Back';

  @override
  String get backup => 'Backup';

  @override
  String get backupCreated => 'Backup created';

  @override
  String get backupNow => 'Back up now';

  @override
  String get backupPassword => 'Password (optional)';

  @override
  String get backupPasswordConfirm => 'Confirm password';

  @override
  String get backupPasswordHint =>
      'With a password the file is encrypted. You will need it to restore.';

  @override
  String get backupReminder => 'Backup reminder';

  @override
  String get biometricReason => 'Unlock MoneyFollow';

  @override
  String get budgets => 'Budgets';

  @override
  String get budgetsUpdated => 'Budgets updated';

  @override
  String get builtin => 'Built-in';

  @override
  String get builtinCats => 'Built-in categories';

  @override
  String get byCat => 'Spending by category';

  @override
  String get byMember => 'Spending by member';

  @override
  String get cAE => 'UAE';

  @override
  String get cEG => 'Egypt';

  @override
  String get cGB => 'United Kingdom';

  @override
  String get cKW => 'Kuwait';

  @override
  String get cSA => 'Saudi Arabia';

  @override
  String get cUS => 'United States';

  @override
  String get cancel => 'Cancel';

  @override
  String get catPh => 'e.g. Pets';

  @override
  String get catType => 'Type';

  @override
  String get categories => 'Categories';

  @override
  String get category => 'Category';

  @override
  String get catsHint =>
      'Built-in categories come with the app and can’t be changed or deleted. Categories you add can be edited or deleted at any time.';

  @override
  String get changePin => 'Change PIN';

  @override
  String get clear => 'Clear';

  @override
  String get clearSample => 'Clear sample data and start';

  @override
  String get clearSampleBody =>
      'All sample data and anything you added while exploring will be removed. Your setup choices are kept.';

  @override
  String get clearSampleTitle => 'Clear sample data?';

  @override
  String get colorL => 'Color';

  @override
  String get comingUp => 'Coming up';

  @override
  String get confirmPin => 'Enter the PIN again';

  @override
  String get currency => 'Currency';

  @override
  String get dark => 'Dark';

  @override
  String get data => 'Data';

  @override
  String get date => 'Date';

  @override
  String get dayEarlier => '1 day earlier';

  @override
  String get dayLater => '1 day later';

  @override
  String daysLeft(String n) {
    return 'in $n days';
  }

  @override
  String get delCat => 'Delete category';

  @override
  String get delCatHint =>
      'Deleting keeps its transactions, recurring items and history and moves them to “Other”.';

  @override
  String get delMemHint =>
      'Removing a member keeps their transactions and moves them to Whole family.';

  @override
  String get delMember => 'Remove member';

  @override
  String get delOccHint => 'Tagged transactions keep their history.';

  @override
  String get delOccasion => 'Delete occasion';

  @override
  String get delRec => 'Stop repeating';

  @override
  String get delete => 'Delete';

  @override
  String get done => 'Done';

  @override
  String get dontRemind => 'Don\'\'t remind me';

  @override
  String get due30 => 'Due in the next 30 days';

  @override
  String get dueIn30 => 'Due in 30 days';

  @override
  String get dueToday => 'Due today';

  @override
  String get edit => 'Edit';

  @override
  String get editCat => 'Edit category';

  @override
  String get editMember => 'Edit member';

  @override
  String get editOccasion => 'Edit occasion';

  @override
  String get editRec => 'Edit recurring item';

  @override
  String get editTransfer => 'Edit transfer';

  @override
  String get editTx => 'Edit transaction';

  @override
  String get enterPassword => 'Enter the backup password';

  @override
  String get enterPin => 'Enter your PIN';

  @override
  String get errAmount => 'Enter an amount greater than 0';

  @override
  String get errBackupDamaged =>
      'This file is damaged or is not a MoneyFollow backup.';

  @override
  String get errBackupNewer =>
      'This backup was made by a newer version of MoneyFollow. Update the app first.';

  @override
  String get errBackupPassword => 'Wrong password';

  @override
  String get errCat => 'Choose a category';

  @override
  String get errCatDup => 'A category with this name already exists';

  @override
  String get errName => 'Enter a name';

  @override
  String get errPasswordMatch => 'The passwords don\'\'t match';

  @override
  String get errPin => 'Wrong PIN';

  @override
  String get errPinMatch => 'The PINs don\'\'t match';

  @override
  String get errRate => 'Enter a rate greater than 0';

  @override
  String get errSameAccount => 'Choose two different accounts';

  @override
  String get errorGeneric => 'Something went wrong';

  @override
  String get evBuiltin => 'Built-in dates';

  @override
  String get evByCat => 'Expected by category';

  @override
  String get evCountry => 'Country';

  @override
  String get evEidAdha => 'Eid al-Adha';

  @override
  String get evEidFitr => 'Eid al-Fitr';

  @override
  String get evExpected => 'Expected spending';

  @override
  String get evHint =>
      'Each occasion is predicted from what you spent on it in previous years, adjusted by your average change from year to year.';

  @override
  String evHintD(String l, String g) {
    return 'Expected = last time ($l) × your average change between years ($g).';
  }

  @override
  String get evHintOne =>
      'Only one year recorded, so the expected amount equals last time.';

  @override
  String evLast(String v) {
    return 'Last time $v';
  }

  @override
  String evLastTx(String y) {
    return 'Last time · $y';
  }

  @override
  String get evMothers => 'Mother’s Day';

  @override
  String get evNewYear => 'New Year’s Eve';

  @override
  String get evNext => 'Next occasion';

  @override
  String get evNoHoliday =>
      'Nager.Date has no public holidays for this country. Islamic dates still update.';

  @override
  String get evNone =>
      'No history yet. Tag expenses with this occasion and the app learns what it costs you.';

  @override
  String get evNow => 'Happening now';

  @override
  String get evPred => 'Expected';

  @override
  String get evPrev => 'Previous years vs expected';

  @override
  String get evRamadan => 'Ramadan';

  @override
  String evSave(String v) {
    return 'Put aside $v a month to be ready';
  }

  @override
  String get evSchool => 'Back to school';

  @override
  String get evSham => 'Sham El-Nessim';

  @override
  String get evSources =>
      'Islamic dates: Aladhan Hijri calendar API. Public holidays: Nager.Date API.';

  @override
  String get evSrcCustom => 'Your occasion';

  @override
  String get evSrcFixed => 'Fixed date';

  @override
  String get evSrcHijri => 'Hijri calendar';

  @override
  String get evSrcHoliday => 'Public holiday';

  @override
  String get evSrcTitle => 'Dates';

  @override
  String get evSync => 'Update';

  @override
  String get evSyncFail =>
      'Could not reach the date services. Saved dates are still used.';

  @override
  String evSynced(String n) {
    return 'Occasion dates updated ($n dates)';
  }

  @override
  String get evSyncing => 'Updating…';

  @override
  String get evTotal12 => 'Occasions · next 12 months';

  @override
  String get evTracked => 'Tracked occasions';

  @override
  String get evUpcoming => 'Next 12 months';

  @override
  String evUpdated(String d) {
    return 'Updated $d';
  }

  @override
  String get evWho => 'Who spent last time';

  @override
  String get evXmas => 'Christmas';

  @override
  String get expIncome => 'Expected income';

  @override
  String get expSavings => 'Expected savings';

  @override
  String get expense => 'Expense';

  @override
  String get expenses => 'Expenses';

  @override
  String get explore => 'Explore';

  @override
  String get exploreSample => 'Explore with sample data';

  @override
  String get exploreSampleHint =>
      'See the app filled with a sample family. Clear it whenever you are ready.';

  @override
  String get kExport => 'Export CSV';

  @override
  String get exportDone => 'CSV exported';

  @override
  String get famFc => 'Expected spending · next 3 months';

  @override
  String get famFcHint =>
      'Each member’s forecast = their recurring items + the average of their other expenses over the last 3 months. Amounts in orange include a quarterly or yearly bill or an occasion.';

  @override
  String get famMembers => 'Family members';

  @override
  String get famShare => 'Who spent this month';

  @override
  String get family => 'Family';

  @override
  String get fcAvg => 'Average expected spending / month';

  @override
  String fcHint(String v) {
    return 'How the forecast works: fixed bills come from your recurring items. Occasions use what you spent on them in previous years. Day-to-day spending is the average of your other expenses over the last 3 months ($v / month). Expected income counts recurring income only.';
  }

  @override
  String fcItems(String f, String v) {
    return '$f fixed + $v day-to-day';
  }

  @override
  String get fcOcc => 'Occasions (estimated)';

  @override
  String get fcTitle => 'Expected spending';

  @override
  String get finish => 'Finish';

  @override
  String get fixed => 'Fixed bills';

  @override
  String get fixedMonth => 'Fixed bills / month';

  @override
  String get forWhom => 'For';

  @override
  String get fqMonthly => 'Monthly';

  @override
  String get fqNever => 'Doesn\'\'t repeat';

  @override
  String get fqQuarterly => 'Every 3 months';

  @override
  String get fqWeekly => 'Weekly';

  @override
  String get fqYearly => 'Yearly';

  @override
  String get frequency => 'Repeats';

  @override
  String get fromAccount => 'From';

  @override
  String get higher => 'Higher than usual';

  @override
  String get iconL => 'Icon';

  @override
  String inDays(String n) {
    return 'In $n days';
  }

  @override
  String includes(String x) {
    return 'Includes $x';
  }

  @override
  String get income => 'Income';

  @override
  String get income1 => 'Income';

  @override
  String get language => 'Language';

  @override
  String lastBackup(String d) {
    return 'Last backup $d';
  }

  @override
  String get last6 => 'Last 6 months';

  @override
  String left(String v) {
    return '$v left';
  }

  @override
  String leftOf(String v, String t) {
    return '$v left of $t';
  }

  @override
  String get light => 'Light';

  @override
  String get lockBiometric => 'PIN + fingerprint / face';

  @override
  String get lockOff => 'Off';

  @override
  String get lockPin => 'PIN';

  @override
  String get m3 => 'Next 3 months';

  @override
  String get m6 => 'Next 6 months';

  @override
  String get mainCurrency => 'Main currency';

  @override
  String get manage => 'Manage';

  @override
  String get markPaid => 'Mark paid';

  @override
  String get markRecv => 'Received';

  @override
  String get memDad => 'Dad';

  @override
  String get memFamily => 'Whole family';

  @override
  String get memMariam => 'Mariam';

  @override
  String get memMom => 'Mom';

  @override
  String get memOmar => 'Omar';

  @override
  String get memPh => 'e.g. Omar';

  @override
  String memTx(String m) {
    return 'Activity · $m';
  }

  @override
  String get members => 'Members';

  @override
  String get monthlyLimits => 'Monthly limits';

  @override
  String get myCats => 'Your categories';

  @override
  String get nBakery => 'Bakery';

  @override
  String get nBallet => 'Ballet class';

  @override
  String get nBooks => 'School books & uniform';

  @override
  String nCats(String b, String c) {
    return '$b built-in · $c yours';
  }

  @override
  String get nClothes => 'Clothes';

  @override
  String get nCoffee => 'Coffee';

  @override
  String get nCourse => 'Online course';

  @override
  String get nDinner => 'Family dinner';

  @override
  String get nEidClothes => 'Eid clothes';

  @override
  String get nEidiya => 'Eidiya for the kids';

  @override
  String get nFanous => 'Ramadan lantern';

  @override
  String get nFesikh => 'Sham El-Nessim food';

  @override
  String get nFilter => 'Water filter service';

  @override
  String get nFootball => 'Football academy';

  @override
  String get nFreelance => 'Freelance project';

  @override
  String get nFuel => 'Fuel';

  @override
  String get nGift => 'Gift from family';

  @override
  String get nGym => 'Gym membership';

  @override
  String get nHelp => 'Domestic help';

  @override
  String get nHome => 'Home items';

  @override
  String get nIftar => 'Iftar gathering';

  @override
  String get nInsurance => 'Car insurance';

  @override
  String get nKahk => 'Eid cookies (kahk)';

  @override
  String nMembers(String n) {
    return '$n members';
  }

  @override
  String get nMetro => 'Metro card';

  @override
  String get nMobile => 'Mobile & internet';

  @override
  String get nMomGift => 'Mother’s Day gift';

  @override
  String get nNyDinner => 'New Year’s Eve dinner';

  @override
  String get nOuting => 'Cinema & outing';

  @override
  String get nPharmacy => 'Pharmacy';

  @override
  String get nPocket => 'Pocket money';

  @override
  String get nPower => 'Electricity & water';

  @override
  String get nRamadanFood => 'Ramadan groceries';

  @override
  String get nRent => 'House rent';

  @override
  String get nRentalIn => 'Flat rent received';

  @override
  String get nSalary => 'Monthly salary';

  @override
  String get nSchool => 'School fees';

  @override
  String get nStream => 'Streaming subscription';

  @override
  String get nSuper => 'Supermarket';

  @override
  String get nSupplies => 'School supplies';

  @override
  String get nTakeaway => 'Takeaway';

  @override
  String get nTaxi => 'Taxi';

  @override
  String get nUdhiya => 'Udhiya (sacrifice share)';

  @override
  String get nUniform => 'School uniform';

  @override
  String get nVeg => 'Vegetables & fruit';

  @override
  String get nWeekly => 'Weekly groceries';

  @override
  String get nXmasGifts => 'Christmas gifts';

  @override
  String get nZakat => 'Zakat al-Fitr';

  @override
  String get name => 'Name';

  @override
  String get namePh => 'e.g. House rent';

  @override
  String get navHome => 'Home';

  @override
  String get navTx => 'Activity';

  @override
  String get netBalance => 'Net balance';

  @override
  String get neverBackedUp => 'Never backed up';

  @override
  String get newCat => 'New category';

  @override
  String get newMember => 'New family member';

  @override
  String get newOccasion => 'New occasion';

  @override
  String get newRec => 'New recurring item';

  @override
  String get newTransfer => 'New transfer';

  @override
  String get newTx => 'New transaction';

  @override
  String get next => 'Next';

  @override
  String get nextDue => 'Next due date';

  @override
  String get nextMonth => 'Expected next month';

  @override
  String nextMonthS(String v) {
    return 'Next month ≈ $v';
  }

  @override
  String nextOn(String d) {
    return 'Next $d';
  }

  @override
  String get next3 => 'Expected next 3 months';

  @override
  String get no => 'No';

  @override
  String get noBudgets => 'No budgets set';

  @override
  String get noBudgetsEdit => 'No budgets set. Tap Edit to add limits.';

  @override
  String get noExp => 'No expenses this month';

  @override
  String get noIncome => 'No income recorded yet';

  @override
  String get noLimit => 'No limit';

  @override
  String get noMemTx => 'No transactions this month';

  @override
  String get noMyCats => 'No categories of your own yet. Tap “+ Add category”.';

  @override
  String get noRec => 'No recurring items yet';

  @override
  String get noTxMonth => 'No transactions this month';

  @override
  String get notUsed => 'Not used yet';

  @override
  String get note => 'Note';

  @override
  String get notePh => 'e.g. Weekly groceries';

  @override
  String get nothing => 'Nothing found';

  @override
  String get nothingDue => 'Nothing due in the next 30 days';

  @override
  String notifBillTitle(String n, String when) {
    return '$n is due $when';
  }

  @override
  String get notifBills => 'Bills due';

  @override
  String get notifBillsHint => 'The day before and on the due date';

  @override
  String notifBudgetTitle(String c, String p) {
    return '$c budget at $p%';
  }

  @override
  String get notifBudgets => 'Budget alerts';

  @override
  String get notifBudgetsHint => 'When a category reaches 80% and 100%';

  @override
  String notifOccasionBody(String v, String m) {
    return 'Expected ≈ $v. Put aside $m a month.';
  }

  @override
  String notifOccasionTitle(String n) {
    return '$n in 30 days';
  }

  @override
  String get notifOccasions => 'Occasions';

  @override
  String get notifOccasionsHint =>
      '30 days before, with the amount to put aside';

  @override
  String get notifications => 'Notifications';

  @override
  String get occDate => 'Date (month and day)';

  @override
  String get occDays => 'Days';

  @override
  String get occNone => 'None';

  @override
  String get occasion => 'Occasion';

  @override
  String get occasions => 'Occasions';

  @override
  String kOf(String a, String b) {
    return '$a of $b';
  }

  @override
  String get ok => 'OK';

  @override
  String over(String v) {
    return '$v over';
  }

  @override
  String overPct(String p) {
    return 'You spent $p% more than you earned this month';
  }

  @override
  String get overTime => 'Spending per member · last 6 months';

  @override
  String overdue(String n) {
    return 'Overdue ${n}d';
  }

  @override
  String get password => 'Password';

  @override
  String get pinHint => '4 to 6 digits';

  @override
  String get planner => 'Planner';

  @override
  String get prefs => 'Preferences';

  @override
  String get protoNote => 'Prototype · data is stored only in this browser';

  @override
  String get rates => 'Exchange rates';

  @override
  String get ratesHint =>
      'Totals, budgets, reports and forecasts are converted to your main currency using these rates.';

  @override
  String get ratesHintSnapshot =>
      'Changing a rate affects new transactions and forecasts. Past transactions keep the rate they were recorded with.';

  @override
  String get ratesUpdated => 'Exchange rate updated';

  @override
  String get recIncome => 'Recurring income / month';

  @override
  String get recent => 'Recent';

  @override
  String get remind3Days => 'Remind me in 3 days';

  @override
  String get reminderBody =>
      'It has been more than a week since your last backup.';

  @override
  String get reminderTitle => 'Back up your data';

  @override
  String get repeat => 'Repeat';

  @override
  String get reports => 'Reports';

  @override
  String get reset => 'Reset demo data';

  @override
  String get restore => 'Restore';

  @override
  String get restoreBackup => 'Restore from backup';

  @override
  String restoreConfirmBody(String d, String device, String n) {
    return 'This backup from $d ($device) has $n transactions. Restoring replaces all data on this phone.';
  }

  @override
  String get restoreConfirmTitle => 'Replace your data?';

  @override
  String get restoreDrive => 'Restore from Google Drive';

  @override
  String get restored => 'Backup restored';

  @override
  String get role => 'Role';

  @override
  String get roleChild => 'Child';

  @override
  String get roleOther => 'Other';

  @override
  String get roleParent => 'Parent';

  @override
  String get sampleBanner => 'Sample data';

  @override
  String get save => 'Save';

  @override
  String savedPct(String p) {
    return 'You saved $p% of your income this month';
  }

  @override
  String get search => 'Search notes or categories';

  @override
  String get security => 'Security';

  @override
  String get seeAll => 'See all';

  @override
  String get seedYears => 'Seed 3 years (debug)';

  @override
  String get setPin => 'Set a PIN';

  @override
  String get settings => 'Settings';

  @override
  String get settingsMore => 'More';

  @override
  String get setupCurrency => 'Main currency and country';

  @override
  String get setupLanguage => 'Choose your language';

  @override
  String get setupMembers => 'Your family';

  @override
  String get setupMembersHint =>
      'Add the people you want to follow. You can do this later.';

  @override
  String get setupStart => 'How do you want to start?';

  @override
  String get setupWelcome => 'Welcome to MoneyFollow';

  @override
  String get shareLog => 'Share diagnostic log';

  @override
  String get shareOf => 'Share of family';

  @override
  String get skip => 'Skip';

  @override
  String get spent => 'Spent';

  @override
  String spentV(String v) {
    return '$v spent';
  }

  @override
  String get startOwn => 'Start with my own data';

  @override
  String get startOwnHint => 'Begin with an empty app.';

  @override
  String get sync => 'Sync';

  @override
  String get syncChangePassphrase => 'Change passphrase';

  @override
  String get syncComing => 'Sync with Google Drive is coming in version 1.1.';

  @override
  String get syncDevices => 'Devices';

  @override
  String get syncDisconnect => 'Disconnect';

  @override
  String get syncModeA => 'One shared family Google account';

  @override
  String get syncModeB => 'Each parent\'\'s own Google account';

  @override
  String get syncNow => 'Sync now';

  @override
  String get syncPassphrase => 'Family passphrase';

  @override
  String get syncRecoveryKey => 'Recovery key';

  @override
  String get syncSavedIt => 'I saved it';

  @override
  String get syncStatusFailed => 'Sync failed – tap to retry';

  @override
  String syncStatusOk(String t) {
    return 'Synced $t';
  }

  @override
  String get syncStatusWaiting => 'Waiting for internet';

  @override
  String get syncTitle => 'Sync with Google Drive';

  @override
  String get syncWifiOnly => 'Sync on Wi-Fi only';

  @override
  String get system => 'System';

  @override
  String get tAdded => 'Transaction added';

  @override
  String get tAddedRep => 'Added and scheduled to repeat';

  @override
  String get tCatDeleted => 'Category deleted';

  @override
  String get tCatSaved => 'Category saved';

  @override
  String get tDeleted => 'Transaction deleted';

  @override
  String get tMemDeleted => 'Family member removed';

  @override
  String get tMemSaved => 'Family member saved';

  @override
  String get tOccDeleted => 'Occasion deleted';

  @override
  String get tOccSaved => 'Occasion saved';

  @override
  String tPaid(String n) {
    return 'Recorded: $n';
  }

  @override
  String get tRecDeleted => 'Recurring item removed';

  @override
  String get tRecSaved => 'Recurring item saved';

  @override
  String get tReset => 'Demo data restored';

  @override
  String get tTransferDeleted => 'Transfer deleted';

  @override
  String get tTransferSaved => 'Transfer saved';

  @override
  String get tUpdated => 'Transaction updated';

  @override
  String get tabEv => 'Occasions';

  @override
  String get tabFc => 'Forecast';

  @override
  String get tabRec => 'Recurring';

  @override
  String get tapAgain => 'Tap again to confirm';

  @override
  String get theme => 'Theme';

  @override
  String get themeSystem => 'System';

  @override
  String get thisMonth => 'Spent this month';

  @override
  String get toAccount => 'To';

  @override
  String get today => 'Today';

  @override
  String get tomorrow => 'Tomorrow';

  @override
  String get total => 'Total';

  @override
  String get totalBudget => 'Total budget';

  @override
  String totalIn(String c) {
    return 'Total in $c';
  }

  @override
  String get transactions => 'Transactions';

  @override
  String get transfer => 'Transfer';

  @override
  String transferFromTo(String from, String to) {
    return '$from → $to';
  }

  @override
  String get transferHint =>
      'Transfers move money between your accounts. They don\'\'t count as income or spending.';

  @override
  String get transfers => 'Transfers';

  @override
  String get typeL => 'Type';

  @override
  String get unlock => 'Unlock';

  @override
  String get useBiometric => 'Use fingerprint / face';

  @override
  String usedN(String n) {
    return 'Used in $n transactions';
  }

  @override
  String get variable => 'Day-to-day (estimated)';

  @override
  String get variableS => 'Day-to-day';

  @override
  String version(String v) {
    return 'Version $v';
  }

  @override
  String get viewAll => 'View all';

  @override
  String get vsLast => 'vs last month';

  @override
  String vsVal(String d) {
    return '$d% spend';
  }

  @override
  String get yes => 'Yes';

  @override
  String get yesterday => 'Yesterday';
}
