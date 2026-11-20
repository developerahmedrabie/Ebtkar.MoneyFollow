import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// prototype key: about
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// prototype key: acc_bank
  ///
  /// In en, this message translates to:
  /// **'Bank'**
  String get accBank;

  /// prototype key: acc_card
  ///
  /// In en, this message translates to:
  /// **'Card'**
  String get accCard;

  /// prototype key: acc_cash
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get accCash;

  /// prototype key: acc_usd
  ///
  /// In en, this message translates to:
  /// **'Dollar account'**
  String get accUsd;

  /// prototype key: account
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// prototype key: accounts
  ///
  /// In en, this message translates to:
  /// **'Accounts'**
  String get accounts;

  /// prototype key: add_cat
  ///
  /// In en, this message translates to:
  /// **'+ Add category'**
  String get addCat;

  /// prototype key: add_member
  ///
  /// In en, this message translates to:
  /// **'+ Add member'**
  String get addMember;

  /// prototype key: add_occasion
  ///
  /// In en, this message translates to:
  /// **'+ Add occasion'**
  String get addOccasion;

  /// prototype key: add_rec
  ///
  /// In en, this message translates to:
  /// **'+ Add'**
  String get addRec;

  /// prototype key: adjust_date
  ///
  /// In en, this message translates to:
  /// **'Adjust date'**
  String get adjustDate;

  /// prototype key: adjust_hint
  ///
  /// In en, this message translates to:
  /// **'Moon sighting can shift the date by a day.'**
  String get adjustHint;

  /// prototype key: all
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// prototype key: all_members
  ///
  /// In en, this message translates to:
  /// **'Everyone'**
  String get allMembers;

  /// prototype key: all_rec
  ///
  /// In en, this message translates to:
  /// **'All recurring'**
  String get allRec;

  /// prototype key: amount
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// prototype key: amount_received
  ///
  /// In en, this message translates to:
  /// **'Amount received'**
  String get amountReceived;

  /// prototype key: amount_sent
  ///
  /// In en, this message translates to:
  /// **'Amount sent'**
  String get amountSent;

  /// prototype key: app_lock
  ///
  /// In en, this message translates to:
  /// **'App lock'**
  String get appLock;

  /// prototype key: app_name
  ///
  /// In en, this message translates to:
  /// **'MoneyFollow'**
  String get appName;

  /// prototype key: app_sub
  ///
  /// In en, this message translates to:
  /// **'Home finance'**
  String get appSub;

  /// prototype key: approx
  ///
  /// In en, this message translates to:
  /// **'≈ {v}'**
  String approx(String v);

  /// prototype key: avatar
  ///
  /// In en, this message translates to:
  /// **'Avatar'**
  String get avatar;

  /// prototype key: avg_daily
  ///
  /// In en, this message translates to:
  /// **'Avg. daily spend'**
  String get avgDaily;

  /// prototype key: back
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// prototype key: backup
  ///
  /// In en, this message translates to:
  /// **'Backup'**
  String get backup;

  /// prototype key: backup_created
  ///
  /// In en, this message translates to:
  /// **'Backup created'**
  String get backupCreated;

  /// prototype key: backup_now
  ///
  /// In en, this message translates to:
  /// **'Back up now'**
  String get backupNow;

  /// prototype key: backup_password
  ///
  /// In en, this message translates to:
  /// **'Password (optional)'**
  String get backupPassword;

  /// prototype key: backup_password_confirm
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get backupPasswordConfirm;

  /// prototype key: backup_password_hint
  ///
  /// In en, this message translates to:
  /// **'With a password the file is encrypted. You will need it to restore.'**
  String get backupPasswordHint;

  /// prototype key: backup_reminder
  ///
  /// In en, this message translates to:
  /// **'Backup reminder'**
  String get backupReminder;

  /// prototype key: biometric_reason
  ///
  /// In en, this message translates to:
  /// **'Unlock MoneyFollow'**
  String get biometricReason;

  /// prototype key: budgets
  ///
  /// In en, this message translates to:
  /// **'Budgets'**
  String get budgets;

  /// prototype key: budgets_updated
  ///
  /// In en, this message translates to:
  /// **'Budgets updated'**
  String get budgetsUpdated;

  /// prototype key: builtin
  ///
  /// In en, this message translates to:
  /// **'Built-in'**
  String get builtin;

  /// prototype key: builtin_cats
  ///
  /// In en, this message translates to:
  /// **'Built-in categories'**
  String get builtinCats;

  /// prototype key: by_cat
  ///
  /// In en, this message translates to:
  /// **'Spending by category'**
  String get byCat;

  /// prototype key: by_member
  ///
  /// In en, this message translates to:
  /// **'Spending by member'**
  String get byMember;

  /// prototype key: c_AE
  ///
  /// In en, this message translates to:
  /// **'UAE'**
  String get cAE;

  /// prototype key: c_EG
  ///
  /// In en, this message translates to:
  /// **'Egypt'**
  String get cEG;

  /// prototype key: c_GB
  ///
  /// In en, this message translates to:
  /// **'United Kingdom'**
  String get cGB;

  /// prototype key: c_KW
  ///
  /// In en, this message translates to:
  /// **'Kuwait'**
  String get cKW;

  /// prototype key: c_SA
  ///
  /// In en, this message translates to:
  /// **'Saudi Arabia'**
  String get cSA;

  /// prototype key: c_US
  ///
  /// In en, this message translates to:
  /// **'United States'**
  String get cUS;

  /// prototype key: cancel
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// prototype key: cat_ph
  ///
  /// In en, this message translates to:
  /// **'e.g. Pets'**
  String get catPh;

  /// prototype key: cat_type
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get catType;

  /// prototype key: categories
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// prototype key: category
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// prototype key: cats_hint
  ///
  /// In en, this message translates to:
  /// **'Built-in categories come with the app and can’t be changed or deleted. Categories you add can be edited or deleted at any time.'**
  String get catsHint;

  /// prototype key: change_pin
  ///
  /// In en, this message translates to:
  /// **'Change PIN'**
  String get changePin;

  /// prototype key: clear
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// prototype key: clear_sample
  ///
  /// In en, this message translates to:
  /// **'Clear sample data and start'**
  String get clearSample;

  /// prototype key: clear_sample_body
  ///
  /// In en, this message translates to:
  /// **'All sample data and anything you added while exploring will be removed. Your setup choices are kept.'**
  String get clearSampleBody;

  /// prototype key: clear_sample_title
  ///
  /// In en, this message translates to:
  /// **'Clear sample data?'**
  String get clearSampleTitle;

  /// prototype key: color_l
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get colorL;

  /// prototype key: coming_up
  ///
  /// In en, this message translates to:
  /// **'Coming up'**
  String get comingUp;

  /// prototype key: confirm_pin
  ///
  /// In en, this message translates to:
  /// **'Enter the PIN again'**
  String get confirmPin;

  /// prototype key: currency
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currency;

  /// prototype key: dark
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// prototype key: data
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get data;

  /// prototype key: date
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// prototype key: day_earlier
  ///
  /// In en, this message translates to:
  /// **'1 day earlier'**
  String get dayEarlier;

  /// prototype key: day_later
  ///
  /// In en, this message translates to:
  /// **'1 day later'**
  String get dayLater;

  /// prototype key: days_left
  ///
  /// In en, this message translates to:
  /// **'in {n} days'**
  String daysLeft(String n);

  /// prototype key: del_cat
  ///
  /// In en, this message translates to:
  /// **'Delete category'**
  String get delCat;

  /// prototype key: del_cat_hint
  ///
  /// In en, this message translates to:
  /// **'Deleting keeps its transactions, recurring items and history and moves them to “Other”.'**
  String get delCatHint;

  /// prototype key: del_mem_hint
  ///
  /// In en, this message translates to:
  /// **'Removing a member keeps their transactions and moves them to Whole family.'**
  String get delMemHint;

  /// prototype key: del_member
  ///
  /// In en, this message translates to:
  /// **'Remove member'**
  String get delMember;

  /// prototype key: del_occ_hint
  ///
  /// In en, this message translates to:
  /// **'Tagged transactions keep their history.'**
  String get delOccHint;

  /// prototype key: del_occasion
  ///
  /// In en, this message translates to:
  /// **'Delete occasion'**
  String get delOccasion;

  /// prototype key: del_rec
  ///
  /// In en, this message translates to:
  /// **'Stop repeating'**
  String get delRec;

  /// prototype key: delete
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// prototype key: done
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// prototype key: dont_remind
  ///
  /// In en, this message translates to:
  /// **'Don\'\'t remind me'**
  String get dontRemind;

  /// prototype key: due_30
  ///
  /// In en, this message translates to:
  /// **'Due in the next 30 days'**
  String get due30;

  /// prototype key: due_in_30
  ///
  /// In en, this message translates to:
  /// **'Due in 30 days'**
  String get dueIn30;

  /// prototype key: due_today
  ///
  /// In en, this message translates to:
  /// **'Due today'**
  String get dueToday;

  /// prototype key: edit
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// prototype key: edit_cat
  ///
  /// In en, this message translates to:
  /// **'Edit category'**
  String get editCat;

  /// prototype key: edit_member
  ///
  /// In en, this message translates to:
  /// **'Edit member'**
  String get editMember;

  /// prototype key: edit_occasion
  ///
  /// In en, this message translates to:
  /// **'Edit occasion'**
  String get editOccasion;

  /// prototype key: edit_rec
  ///
  /// In en, this message translates to:
  /// **'Edit recurring item'**
  String get editRec;

  /// prototype key: edit_transfer
  ///
  /// In en, this message translates to:
  /// **'Edit transfer'**
  String get editTransfer;

  /// prototype key: edit_tx
  ///
  /// In en, this message translates to:
  /// **'Edit transaction'**
  String get editTx;

  /// prototype key: enter_password
  ///
  /// In en, this message translates to:
  /// **'Enter the backup password'**
  String get enterPassword;

  /// prototype key: enter_pin
  ///
  /// In en, this message translates to:
  /// **'Enter your PIN'**
  String get enterPin;

  /// prototype key: err_amount
  ///
  /// In en, this message translates to:
  /// **'Enter an amount greater than 0'**
  String get errAmount;

  /// prototype key: err_backup_damaged
  ///
  /// In en, this message translates to:
  /// **'This file is damaged or is not a MoneyFollow backup.'**
  String get errBackupDamaged;

  /// prototype key: err_backup_newer
  ///
  /// In en, this message translates to:
  /// **'This backup was made by a newer version of MoneyFollow. Update the app first.'**
  String get errBackupNewer;

  /// prototype key: err_backup_password
  ///
  /// In en, this message translates to:
  /// **'Wrong password'**
  String get errBackupPassword;

  /// prototype key: err_cat
  ///
  /// In en, this message translates to:
  /// **'Choose a category'**
  String get errCat;

  /// prototype key: err_cat_dup
  ///
  /// In en, this message translates to:
  /// **'A category with this name already exists'**
  String get errCatDup;

  /// prototype key: err_name
  ///
  /// In en, this message translates to:
  /// **'Enter a name'**
  String get errName;

  /// prototype key: err_password_match
  ///
  /// In en, this message translates to:
  /// **'The passwords don\'\'t match'**
  String get errPasswordMatch;

  /// prototype key: err_pin
  ///
  /// In en, this message translates to:
  /// **'Wrong PIN'**
  String get errPin;

  /// prototype key: err_pin_match
  ///
  /// In en, this message translates to:
  /// **'The PINs don\'\'t match'**
  String get errPinMatch;

  /// prototype key: err_rate
  ///
  /// In en, this message translates to:
  /// **'Enter a rate greater than 0'**
  String get errRate;

  /// prototype key: err_same_account
  ///
  /// In en, this message translates to:
  /// **'Choose two different accounts'**
  String get errSameAccount;

  /// prototype key: error_generic
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get errorGeneric;

  /// prototype key: ev_builtin
  ///
  /// In en, this message translates to:
  /// **'Built-in dates'**
  String get evBuiltin;

  /// prototype key: ev_by_cat
  ///
  /// In en, this message translates to:
  /// **'Expected by category'**
  String get evByCat;

  /// prototype key: ev_country
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get evCountry;

  /// prototype key: ev_eid_adha
  ///
  /// In en, this message translates to:
  /// **'Eid al-Adha'**
  String get evEidAdha;

  /// prototype key: ev_eid_fitr
  ///
  /// In en, this message translates to:
  /// **'Eid al-Fitr'**
  String get evEidFitr;

  /// prototype key: ev_expected
  ///
  /// In en, this message translates to:
  /// **'Expected spending'**
  String get evExpected;

  /// prototype key: ev_hint
  ///
  /// In en, this message translates to:
  /// **'Each occasion is predicted from what you spent on it in previous years, adjusted by your average change from year to year.'**
  String get evHint;

  /// prototype key: ev_hint_d
  ///
  /// In en, this message translates to:
  /// **'Expected = last time ({l}) × your average change between years ({g}).'**
  String evHintD(String l, String g);

  /// prototype key: ev_hint_one
  ///
  /// In en, this message translates to:
  /// **'Only one year recorded, so the expected amount equals last time.'**
  String get evHintOne;

  /// prototype key: ev_last
  ///
  /// In en, this message translates to:
  /// **'Last time {v}'**
  String evLast(String v);

  /// prototype key: ev_last_tx
  ///
  /// In en, this message translates to:
  /// **'Last time · {y}'**
  String evLastTx(String y);

  /// prototype key: ev_mothers
  ///
  /// In en, this message translates to:
  /// **'Mother’s Day'**
  String get evMothers;

  /// prototype key: ev_new_year
  ///
  /// In en, this message translates to:
  /// **'New Year’s Eve'**
  String get evNewYear;

  /// prototype key: ev_next
  ///
  /// In en, this message translates to:
  /// **'Next occasion'**
  String get evNext;

  /// prototype key: ev_no_holiday
  ///
  /// In en, this message translates to:
  /// **'Nager.Date has no public holidays for this country. Islamic dates still update.'**
  String get evNoHoliday;

  /// prototype key: ev_none
  ///
  /// In en, this message translates to:
  /// **'No history yet. Tag expenses with this occasion and the app learns what it costs you.'**
  String get evNone;

  /// prototype key: ev_now
  ///
  /// In en, this message translates to:
  /// **'Happening now'**
  String get evNow;

  /// prototype key: ev_pred
  ///
  /// In en, this message translates to:
  /// **'Expected'**
  String get evPred;

  /// prototype key: ev_prev
  ///
  /// In en, this message translates to:
  /// **'Previous years vs expected'**
  String get evPrev;

  /// prototype key: ev_ramadan
  ///
  /// In en, this message translates to:
  /// **'Ramadan'**
  String get evRamadan;

  /// prototype key: ev_save
  ///
  /// In en, this message translates to:
  /// **'Put aside {v} a month to be ready'**
  String evSave(String v);

  /// prototype key: ev_school
  ///
  /// In en, this message translates to:
  /// **'Back to school'**
  String get evSchool;

  /// prototype key: ev_sham
  ///
  /// In en, this message translates to:
  /// **'Sham El-Nessim'**
  String get evSham;

  /// prototype key: ev_sources
  ///
  /// In en, this message translates to:
  /// **'Islamic dates: Aladhan Hijri calendar API. Public holidays: Nager.Date API.'**
  String get evSources;

  /// prototype key: ev_src_custom
  ///
  /// In en, this message translates to:
  /// **'Your occasion'**
  String get evSrcCustom;

  /// prototype key: ev_src_fixed
  ///
  /// In en, this message translates to:
  /// **'Fixed date'**
  String get evSrcFixed;

  /// prototype key: ev_src_hijri
  ///
  /// In en, this message translates to:
  /// **'Hijri calendar'**
  String get evSrcHijri;

  /// prototype key: ev_src_holiday
  ///
  /// In en, this message translates to:
  /// **'Public holiday'**
  String get evSrcHoliday;

  /// prototype key: ev_src_title
  ///
  /// In en, this message translates to:
  /// **'Dates'**
  String get evSrcTitle;

  /// prototype key: ev_sync
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get evSync;

  /// prototype key: ev_sync_fail
  ///
  /// In en, this message translates to:
  /// **'Could not reach the date services. Saved dates are still used.'**
  String get evSyncFail;

  /// prototype key: ev_synced
  ///
  /// In en, this message translates to:
  /// **'Occasion dates updated ({n} dates)'**
  String evSynced(String n);

  /// prototype key: ev_syncing
  ///
  /// In en, this message translates to:
  /// **'Updating…'**
  String get evSyncing;

  /// prototype key: ev_total12
  ///
  /// In en, this message translates to:
  /// **'Occasions · next 12 months'**
  String get evTotal12;

  /// prototype key: ev_tracked
  ///
  /// In en, this message translates to:
  /// **'Tracked occasions'**
  String get evTracked;

  /// prototype key: ev_upcoming
  ///
  /// In en, this message translates to:
  /// **'Next 12 months'**
  String get evUpcoming;

  /// prototype key: ev_updated
  ///
  /// In en, this message translates to:
  /// **'Updated {d}'**
  String evUpdated(String d);

  /// prototype key: ev_who
  ///
  /// In en, this message translates to:
  /// **'Who spent last time'**
  String get evWho;

  /// prototype key: ev_xmas
  ///
  /// In en, this message translates to:
  /// **'Christmas'**
  String get evXmas;

  /// prototype key: exp_income
  ///
  /// In en, this message translates to:
  /// **'Expected income'**
  String get expIncome;

  /// prototype key: exp_savings
  ///
  /// In en, this message translates to:
  /// **'Expected savings'**
  String get expSavings;

  /// prototype key: expense
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get expense;

  /// prototype key: expenses
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get expenses;

  /// prototype key: explore
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get explore;

  /// prototype key: explore_sample
  ///
  /// In en, this message translates to:
  /// **'Explore with sample data'**
  String get exploreSample;

  /// prototype key: explore_sample_hint
  ///
  /// In en, this message translates to:
  /// **'See the app filled with a sample family. Clear it whenever you are ready.'**
  String get exploreSampleHint;

  /// prototype key: export
  ///
  /// In en, this message translates to:
  /// **'Export CSV'**
  String get kExport;

  /// prototype key: export_done
  ///
  /// In en, this message translates to:
  /// **'CSV exported'**
  String get exportDone;

  /// prototype key: fam_fc
  ///
  /// In en, this message translates to:
  /// **'Expected spending · next 3 months'**
  String get famFc;

  /// prototype key: fam_fc_hint
  ///
  /// In en, this message translates to:
  /// **'Each member’s forecast = their recurring items + the average of their other expenses over the last 3 months. Amounts in orange include a quarterly or yearly bill or an occasion.'**
  String get famFcHint;

  /// prototype key: fam_members
  ///
  /// In en, this message translates to:
  /// **'Family members'**
  String get famMembers;

  /// prototype key: fam_share
  ///
  /// In en, this message translates to:
  /// **'Who spent this month'**
  String get famShare;

  /// prototype key: family
  ///
  /// In en, this message translates to:
  /// **'Family'**
  String get family;

  /// prototype key: fc_avg
  ///
  /// In en, this message translates to:
  /// **'Average expected spending / month'**
  String get fcAvg;

  /// prototype key: fc_hint
  ///
  /// In en, this message translates to:
  /// **'How the forecast works: fixed bills come from your recurring items. Occasions use what you spent on them in previous years. Day-to-day spending is the average of your other expenses over the last 3 months ({v} / month). Expected income counts recurring income only.'**
  String fcHint(String v);

  /// prototype key: fc_items
  ///
  /// In en, this message translates to:
  /// **'{f} fixed + {v} day-to-day'**
  String fcItems(String f, String v);

  /// prototype key: fc_occ
  ///
  /// In en, this message translates to:
  /// **'Occasions (estimated)'**
  String get fcOcc;

  /// prototype key: fc_title
  ///
  /// In en, this message translates to:
  /// **'Expected spending'**
  String get fcTitle;

  /// prototype key: finish
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finish;

  /// prototype key: fixed
  ///
  /// In en, this message translates to:
  /// **'Fixed bills'**
  String get fixed;

  /// prototype key: fixed_month
  ///
  /// In en, this message translates to:
  /// **'Fixed bills / month'**
  String get fixedMonth;

  /// prototype key: for_whom
  ///
  /// In en, this message translates to:
  /// **'For'**
  String get forWhom;

  /// prototype key: fq_monthly
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get fqMonthly;

  /// prototype key: fq_never
  ///
  /// In en, this message translates to:
  /// **'Doesn\'\'t repeat'**
  String get fqNever;

  /// prototype key: fq_quarterly
  ///
  /// In en, this message translates to:
  /// **'Every 3 months'**
  String get fqQuarterly;

  /// prototype key: fq_weekly
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get fqWeekly;

  /// prototype key: fq_yearly
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get fqYearly;

  /// prototype key: frequency
  ///
  /// In en, this message translates to:
  /// **'Repeats'**
  String get frequency;

  /// prototype key: from_account
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get fromAccount;

  /// prototype key: higher
  ///
  /// In en, this message translates to:
  /// **'Higher than usual'**
  String get higher;

  /// prototype key: icon_l
  ///
  /// In en, this message translates to:
  /// **'Icon'**
  String get iconL;

  /// prototype key: in_days
  ///
  /// In en, this message translates to:
  /// **'In {n} days'**
  String inDays(String n);

  /// prototype key: includes
  ///
  /// In en, this message translates to:
  /// **'Includes {x}'**
  String includes(String x);

  /// prototype key: income
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get income;

  /// prototype key: income1
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get income1;

  /// prototype key: language
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// prototype key: last_backup
  ///
  /// In en, this message translates to:
  /// **'Last backup {d}'**
  String lastBackup(String d);

  /// prototype key: last6
  ///
  /// In en, this message translates to:
  /// **'Last 6 months'**
  String get last6;

  /// prototype key: left
  ///
  /// In en, this message translates to:
  /// **'{v} left'**
  String left(String v);

  /// prototype key: left_of
  ///
  /// In en, this message translates to:
  /// **'{v} left of {t}'**
  String leftOf(String v, String t);

  /// prototype key: light
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// prototype key: lock_biometric
  ///
  /// In en, this message translates to:
  /// **'PIN + fingerprint / face'**
  String get lockBiometric;

  /// prototype key: lock_off
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get lockOff;

  /// prototype key: lock_pin
  ///
  /// In en, this message translates to:
  /// **'PIN'**
  String get lockPin;

  /// prototype key: m3
  ///
  /// In en, this message translates to:
  /// **'Next 3 months'**
  String get m3;

  /// prototype key: m6
  ///
  /// In en, this message translates to:
  /// **'Next 6 months'**
  String get m6;

  /// prototype key: main_currency
  ///
  /// In en, this message translates to:
  /// **'Main currency'**
  String get mainCurrency;

  /// prototype key: manage
  ///
  /// In en, this message translates to:
  /// **'Manage'**
  String get manage;

  /// prototype key: mark_paid
  ///
  /// In en, this message translates to:
  /// **'Mark paid'**
  String get markPaid;

  /// prototype key: mark_recv
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get markRecv;

  /// prototype key: mem_dad
  ///
  /// In en, this message translates to:
  /// **'Dad'**
  String get memDad;

  /// prototype key: mem_family
  ///
  /// In en, this message translates to:
  /// **'Whole family'**
  String get memFamily;

  /// prototype key: mem_mariam
  ///
  /// In en, this message translates to:
  /// **'Mariam'**
  String get memMariam;

  /// prototype key: mem_mom
  ///
  /// In en, this message translates to:
  /// **'Mom'**
  String get memMom;

  /// prototype key: mem_omar
  ///
  /// In en, this message translates to:
  /// **'Omar'**
  String get memOmar;

  /// prototype key: mem_ph
  ///
  /// In en, this message translates to:
  /// **'e.g. Omar'**
  String get memPh;

  /// prototype key: mem_tx
  ///
  /// In en, this message translates to:
  /// **'Activity · {m}'**
  String memTx(String m);

  /// prototype key: members
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get members;

  /// prototype key: monthly_limits
  ///
  /// In en, this message translates to:
  /// **'Monthly limits'**
  String get monthlyLimits;

  /// prototype key: my_cats
  ///
  /// In en, this message translates to:
  /// **'Your categories'**
  String get myCats;

  /// prototype key: n_bakery
  ///
  /// In en, this message translates to:
  /// **'Bakery'**
  String get nBakery;

  /// prototype key: n_ballet
  ///
  /// In en, this message translates to:
  /// **'Ballet class'**
  String get nBallet;

  /// prototype key: n_books
  ///
  /// In en, this message translates to:
  /// **'School books & uniform'**
  String get nBooks;

  /// prototype key: n_cats
  ///
  /// In en, this message translates to:
  /// **'{b} built-in · {c} yours'**
  String nCats(String b, String c);

  /// prototype key: n_clothes
  ///
  /// In en, this message translates to:
  /// **'Clothes'**
  String get nClothes;

  /// prototype key: n_coffee
  ///
  /// In en, this message translates to:
  /// **'Coffee'**
  String get nCoffee;

  /// prototype key: n_course
  ///
  /// In en, this message translates to:
  /// **'Online course'**
  String get nCourse;

  /// prototype key: n_dinner
  ///
  /// In en, this message translates to:
  /// **'Family dinner'**
  String get nDinner;

  /// prototype key: n_eid_clothes
  ///
  /// In en, this message translates to:
  /// **'Eid clothes'**
  String get nEidClothes;

  /// prototype key: n_eidiya
  ///
  /// In en, this message translates to:
  /// **'Eidiya for the kids'**
  String get nEidiya;

  /// prototype key: n_fanous
  ///
  /// In en, this message translates to:
  /// **'Ramadan lantern'**
  String get nFanous;

  /// prototype key: n_fesikh
  ///
  /// In en, this message translates to:
  /// **'Sham El-Nessim food'**
  String get nFesikh;

  /// prototype key: n_filter
  ///
  /// In en, this message translates to:
  /// **'Water filter service'**
  String get nFilter;

  /// prototype key: n_football
  ///
  /// In en, this message translates to:
  /// **'Football academy'**
  String get nFootball;

  /// prototype key: n_freelance
  ///
  /// In en, this message translates to:
  /// **'Freelance project'**
  String get nFreelance;

  /// prototype key: n_fuel
  ///
  /// In en, this message translates to:
  /// **'Fuel'**
  String get nFuel;

  /// prototype key: n_gift
  ///
  /// In en, this message translates to:
  /// **'Gift from family'**
  String get nGift;

  /// prototype key: n_gym
  ///
  /// In en, this message translates to:
  /// **'Gym membership'**
  String get nGym;

  /// prototype key: n_help
  ///
  /// In en, this message translates to:
  /// **'Domestic help'**
  String get nHelp;

  /// prototype key: n_home
  ///
  /// In en, this message translates to:
  /// **'Home items'**
  String get nHome;

  /// prototype key: n_iftar
  ///
  /// In en, this message translates to:
  /// **'Iftar gathering'**
  String get nIftar;

  /// prototype key: n_insurance
  ///
  /// In en, this message translates to:
  /// **'Car insurance'**
  String get nInsurance;

  /// prototype key: n_kahk
  ///
  /// In en, this message translates to:
  /// **'Eid cookies (kahk)'**
  String get nKahk;

  /// prototype key: n_members
  ///
  /// In en, this message translates to:
  /// **'{n} members'**
  String nMembers(String n);

  /// prototype key: n_metro
  ///
  /// In en, this message translates to:
  /// **'Metro card'**
  String get nMetro;

  /// prototype key: n_mobile
  ///
  /// In en, this message translates to:
  /// **'Mobile & internet'**
  String get nMobile;

  /// prototype key: n_mom_gift
  ///
  /// In en, this message translates to:
  /// **'Mother’s Day gift'**
  String get nMomGift;

  /// prototype key: n_ny_dinner
  ///
  /// In en, this message translates to:
  /// **'New Year’s Eve dinner'**
  String get nNyDinner;

  /// prototype key: n_outing
  ///
  /// In en, this message translates to:
  /// **'Cinema & outing'**
  String get nOuting;

  /// prototype key: n_pharmacy
  ///
  /// In en, this message translates to:
  /// **'Pharmacy'**
  String get nPharmacy;

  /// prototype key: n_pocket
  ///
  /// In en, this message translates to:
  /// **'Pocket money'**
  String get nPocket;

  /// prototype key: n_power
  ///
  /// In en, this message translates to:
  /// **'Electricity & water'**
  String get nPower;

  /// prototype key: n_ramadan_food
  ///
  /// In en, this message translates to:
  /// **'Ramadan groceries'**
  String get nRamadanFood;

  /// prototype key: n_rent
  ///
  /// In en, this message translates to:
  /// **'House rent'**
  String get nRent;

  /// prototype key: n_rental_in
  ///
  /// In en, this message translates to:
  /// **'Flat rent received'**
  String get nRentalIn;

  /// prototype key: n_salary
  ///
  /// In en, this message translates to:
  /// **'Monthly salary'**
  String get nSalary;

  /// prototype key: n_school
  ///
  /// In en, this message translates to:
  /// **'School fees'**
  String get nSchool;

  /// prototype key: n_stream
  ///
  /// In en, this message translates to:
  /// **'Streaming subscription'**
  String get nStream;

  /// prototype key: n_super
  ///
  /// In en, this message translates to:
  /// **'Supermarket'**
  String get nSuper;

  /// prototype key: n_supplies
  ///
  /// In en, this message translates to:
  /// **'School supplies'**
  String get nSupplies;

  /// prototype key: n_takeaway
  ///
  /// In en, this message translates to:
  /// **'Takeaway'**
  String get nTakeaway;

  /// prototype key: n_taxi
  ///
  /// In en, this message translates to:
  /// **'Taxi'**
  String get nTaxi;

  /// prototype key: n_udhiya
  ///
  /// In en, this message translates to:
  /// **'Udhiya (sacrifice share)'**
  String get nUdhiya;

  /// prototype key: n_uniform
  ///
  /// In en, this message translates to:
  /// **'School uniform'**
  String get nUniform;

  /// prototype key: n_veg
  ///
  /// In en, this message translates to:
  /// **'Vegetables & fruit'**
  String get nVeg;

  /// prototype key: n_weekly
  ///
  /// In en, this message translates to:
  /// **'Weekly groceries'**
  String get nWeekly;

  /// prototype key: n_xmas_gifts
  ///
  /// In en, this message translates to:
  /// **'Christmas gifts'**
  String get nXmasGifts;

  /// prototype key: n_zakat
  ///
  /// In en, this message translates to:
  /// **'Zakat al-Fitr'**
  String get nZakat;

  /// prototype key: name
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// prototype key: name_ph
  ///
  /// In en, this message translates to:
  /// **'e.g. House rent'**
  String get namePh;

  /// prototype key: nav_home
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// prototype key: nav_tx
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get navTx;

  /// prototype key: net_balance
  ///
  /// In en, this message translates to:
  /// **'Net balance'**
  String get netBalance;

  /// prototype key: never_backed_up
  ///
  /// In en, this message translates to:
  /// **'Never backed up'**
  String get neverBackedUp;

  /// prototype key: new_cat
  ///
  /// In en, this message translates to:
  /// **'New category'**
  String get newCat;

  /// prototype key: new_member
  ///
  /// In en, this message translates to:
  /// **'New family member'**
  String get newMember;

  /// prototype key: new_occasion
  ///
  /// In en, this message translates to:
  /// **'New occasion'**
  String get newOccasion;

  /// prototype key: new_rec
  ///
  /// In en, this message translates to:
  /// **'New recurring item'**
  String get newRec;

  /// prototype key: new_transfer
  ///
  /// In en, this message translates to:
  /// **'New transfer'**
  String get newTransfer;

  /// prototype key: new_tx
  ///
  /// In en, this message translates to:
  /// **'New transaction'**
  String get newTx;

  /// prototype key: next
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// prototype key: next_due
  ///
  /// In en, this message translates to:
  /// **'Next due date'**
  String get nextDue;

  /// prototype key: next_month
  ///
  /// In en, this message translates to:
  /// **'Expected next month'**
  String get nextMonth;

  /// prototype key: next_month_s
  ///
  /// In en, this message translates to:
  /// **'Next month ≈ {v}'**
  String nextMonthS(String v);

  /// prototype key: next_on
  ///
  /// In en, this message translates to:
  /// **'Next {d}'**
  String nextOn(String d);

  /// prototype key: next3
  ///
  /// In en, this message translates to:
  /// **'Expected next 3 months'**
  String get next3;

  /// prototype key: no
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// prototype key: no_budgets
  ///
  /// In en, this message translates to:
  /// **'No budgets set'**
  String get noBudgets;

  /// prototype key: no_budgets_edit
  ///
  /// In en, this message translates to:
  /// **'No budgets set. Tap Edit to add limits.'**
  String get noBudgetsEdit;

  /// prototype key: no_exp
  ///
  /// In en, this message translates to:
  /// **'No expenses this month'**
  String get noExp;

  /// prototype key: no_income
  ///
  /// In en, this message translates to:
  /// **'No income recorded yet'**
  String get noIncome;

  /// prototype key: no_limit
  ///
  /// In en, this message translates to:
  /// **'No limit'**
  String get noLimit;

  /// prototype key: no_mem_tx
  ///
  /// In en, this message translates to:
  /// **'No transactions this month'**
  String get noMemTx;

  /// prototype key: no_my_cats
  ///
  /// In en, this message translates to:
  /// **'No categories of your own yet. Tap “+ Add category”.'**
  String get noMyCats;

  /// prototype key: no_rec
  ///
  /// In en, this message translates to:
  /// **'No recurring items yet'**
  String get noRec;

  /// prototype key: no_tx_month
  ///
  /// In en, this message translates to:
  /// **'No transactions this month'**
  String get noTxMonth;

  /// prototype key: not_used
  ///
  /// In en, this message translates to:
  /// **'Not used yet'**
  String get notUsed;

  /// prototype key: note
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get note;

  /// prototype key: note_ph
  ///
  /// In en, this message translates to:
  /// **'e.g. Weekly groceries'**
  String get notePh;

  /// prototype key: nothing
  ///
  /// In en, this message translates to:
  /// **'Nothing found'**
  String get nothing;

  /// prototype key: nothing_due
  ///
  /// In en, this message translates to:
  /// **'Nothing due in the next 30 days'**
  String get nothingDue;

  /// prototype key: notif_bill_title
  ///
  /// In en, this message translates to:
  /// **'{n} is due {when}'**
  String notifBillTitle(String n, String when);

  /// prototype key: notif_bills
  ///
  /// In en, this message translates to:
  /// **'Bills due'**
  String get notifBills;

  /// prototype key: notif_bills_hint
  ///
  /// In en, this message translates to:
  /// **'The day before and on the due date'**
  String get notifBillsHint;

  /// prototype key: notif_budget_title
  ///
  /// In en, this message translates to:
  /// **'{c} budget at {p}%'**
  String notifBudgetTitle(String c, String p);

  /// prototype key: notif_budgets
  ///
  /// In en, this message translates to:
  /// **'Budget alerts'**
  String get notifBudgets;

  /// prototype key: notif_budgets_hint
  ///
  /// In en, this message translates to:
  /// **'When a category reaches 80% and 100%'**
  String get notifBudgetsHint;

  /// prototype key: notif_occasion_body
  ///
  /// In en, this message translates to:
  /// **'Expected ≈ {v}. Put aside {m} a month.'**
  String notifOccasionBody(String v, String m);

  /// prototype key: notif_occasion_title
  ///
  /// In en, this message translates to:
  /// **'{n} in 30 days'**
  String notifOccasionTitle(String n);

  /// prototype key: notif_occasions
  ///
  /// In en, this message translates to:
  /// **'Occasions'**
  String get notifOccasions;

  /// prototype key: notif_occasions_hint
  ///
  /// In en, this message translates to:
  /// **'30 days before, with the amount to put aside'**
  String get notifOccasionsHint;

  /// prototype key: notifications
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// prototype key: occ_date
  ///
  /// In en, this message translates to:
  /// **'Date (month and day)'**
  String get occDate;

  /// prototype key: occ_days
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get occDays;

  /// prototype key: occ_none
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get occNone;

  /// prototype key: occasion
  ///
  /// In en, this message translates to:
  /// **'Occasion'**
  String get occasion;

  /// prototype key: occasions
  ///
  /// In en, this message translates to:
  /// **'Occasions'**
  String get occasions;

  /// prototype key: of
  ///
  /// In en, this message translates to:
  /// **'{a} of {b}'**
  String kOf(String a, String b);

  /// prototype key: ok
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// prototype key: over
  ///
  /// In en, this message translates to:
  /// **'{v} over'**
  String over(String v);

  /// prototype key: over_pct
  ///
  /// In en, this message translates to:
  /// **'You spent {p}% more than you earned this month'**
  String overPct(String p);

  /// prototype key: over_time
  ///
  /// In en, this message translates to:
  /// **'Spending per member · last 6 months'**
  String get overTime;

  /// prototype key: overdue
  ///
  /// In en, this message translates to:
  /// **'Overdue {n}d'**
  String overdue(String n);

  /// prototype key: password
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// prototype key: pin_hint
  ///
  /// In en, this message translates to:
  /// **'4 to 6 digits'**
  String get pinHint;

  /// prototype key: planner
  ///
  /// In en, this message translates to:
  /// **'Planner'**
  String get planner;

  /// prototype key: prefs
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get prefs;

  /// prototype key: proto_note
  ///
  /// In en, this message translates to:
  /// **'Prototype · data is stored only in this browser'**
  String get protoNote;

  /// prototype key: rates
  ///
  /// In en, this message translates to:
  /// **'Exchange rates'**
  String get rates;

  /// prototype key: rates_hint
  ///
  /// In en, this message translates to:
  /// **'Totals, budgets, reports and forecasts are converted to your main currency using these rates.'**
  String get ratesHint;

  /// prototype key: rates_hint_snapshot
  ///
  /// In en, this message translates to:
  /// **'Changing a rate affects new transactions and forecasts. Past transactions keep the rate they were recorded with.'**
  String get ratesHintSnapshot;

  /// prototype key: rates_updated
  ///
  /// In en, this message translates to:
  /// **'Exchange rate updated'**
  String get ratesUpdated;

  /// prototype key: rec_income
  ///
  /// In en, this message translates to:
  /// **'Recurring income / month'**
  String get recIncome;

  /// prototype key: recent
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get recent;

  /// prototype key: remind_3_days
  ///
  /// In en, this message translates to:
  /// **'Remind me in 3 days'**
  String get remind3Days;

  /// prototype key: reminder_body
  ///
  /// In en, this message translates to:
  /// **'It has been more than a week since your last backup.'**
  String get reminderBody;

  /// prototype key: reminder_title
  ///
  /// In en, this message translates to:
  /// **'Back up your data'**
  String get reminderTitle;

  /// prototype key: repeat
  ///
  /// In en, this message translates to:
  /// **'Repeat'**
  String get repeat;

  /// prototype key: reports
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reports;

  /// prototype key: reset
  ///
  /// In en, this message translates to:
  /// **'Reset demo data'**
  String get reset;

  /// prototype key: restore
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restore;

  /// prototype key: restore_backup
  ///
  /// In en, this message translates to:
  /// **'Restore from backup'**
  String get restoreBackup;

  /// prototype key: restore_confirm_body
  ///
  /// In en, this message translates to:
  /// **'This backup from {d} ({device}) has {n} transactions. Restoring replaces all data on this phone.'**
  String restoreConfirmBody(String d, String device, String n);

  /// prototype key: restore_confirm_title
  ///
  /// In en, this message translates to:
  /// **'Replace your data?'**
  String get restoreConfirmTitle;

  /// prototype key: restore_drive
  ///
  /// In en, this message translates to:
  /// **'Restore from Google Drive'**
  String get restoreDrive;

  /// prototype key: restored
  ///
  /// In en, this message translates to:
  /// **'Backup restored'**
  String get restored;

  /// prototype key: role
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get role;

  /// prototype key: role_child
  ///
  /// In en, this message translates to:
  /// **'Child'**
  String get roleChild;

  /// prototype key: role_other
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get roleOther;

  /// prototype key: role_parent
  ///
  /// In en, this message translates to:
  /// **'Parent'**
  String get roleParent;

  /// prototype key: sample_banner
  ///
  /// In en, this message translates to:
  /// **'Sample data'**
  String get sampleBanner;

  /// prototype key: save
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// prototype key: saved_pct
  ///
  /// In en, this message translates to:
  /// **'You saved {p}% of your income this month'**
  String savedPct(String p);

  /// prototype key: search
  ///
  /// In en, this message translates to:
  /// **'Search notes or categories'**
  String get search;

  /// prototype key: security
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get security;

  /// prototype key: see_all
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// prototype key: seed_years
  ///
  /// In en, this message translates to:
  /// **'Seed 3 years (debug)'**
  String get seedYears;

  /// prototype key: set_pin
  ///
  /// In en, this message translates to:
  /// **'Set a PIN'**
  String get setPin;

  /// prototype key: settings
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// prototype key: settings_more
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get settingsMore;

  /// prototype key: setup_currency
  ///
  /// In en, this message translates to:
  /// **'Main currency and country'**
  String get setupCurrency;

  /// prototype key: setup_language
  ///
  /// In en, this message translates to:
  /// **'Choose your language'**
  String get setupLanguage;

  /// prototype key: setup_members
  ///
  /// In en, this message translates to:
  /// **'Your family'**
  String get setupMembers;

  /// prototype key: setup_members_hint
  ///
  /// In en, this message translates to:
  /// **'Add the people you want to follow. You can do this later.'**
  String get setupMembersHint;

  /// prototype key: setup_start
  ///
  /// In en, this message translates to:
  /// **'How do you want to start?'**
  String get setupStart;

  /// prototype key: setup_welcome
  ///
  /// In en, this message translates to:
  /// **'Welcome to MoneyFollow'**
  String get setupWelcome;

  /// prototype key: share_log
  ///
  /// In en, this message translates to:
  /// **'Share diagnostic log'**
  String get shareLog;

  /// prototype key: share_of
  ///
  /// In en, this message translates to:
  /// **'Share of family'**
  String get shareOf;

  /// prototype key: skip
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// prototype key: spent
  ///
  /// In en, this message translates to:
  /// **'Spent'**
  String get spent;

  /// prototype key: spent_v
  ///
  /// In en, this message translates to:
  /// **'{v} spent'**
  String spentV(String v);

  /// prototype key: start_own
  ///
  /// In en, this message translates to:
  /// **'Start with my own data'**
  String get startOwn;

  /// prototype key: start_own_hint
  ///
  /// In en, this message translates to:
  /// **'Begin with an empty app.'**
  String get startOwnHint;

  /// prototype key: sync
  ///
  /// In en, this message translates to:
  /// **'Sync'**
  String get sync;

  /// prototype key: sync_change_passphrase
  ///
  /// In en, this message translates to:
  /// **'Change passphrase'**
  String get syncChangePassphrase;

  /// prototype key: sync_coming
  ///
  /// In en, this message translates to:
  /// **'Sync with Google Drive is coming in version 1.1.'**
  String get syncComing;

  /// prototype key: sync_devices
  ///
  /// In en, this message translates to:
  /// **'Devices'**
  String get syncDevices;

  /// prototype key: sync_disconnect
  ///
  /// In en, this message translates to:
  /// **'Disconnect'**
  String get syncDisconnect;

  /// prototype key: sync_mode_a
  ///
  /// In en, this message translates to:
  /// **'One shared family Google account'**
  String get syncModeA;

  /// prototype key: sync_mode_b
  ///
  /// In en, this message translates to:
  /// **'Each parent\'\'s own Google account'**
  String get syncModeB;

  /// prototype key: sync_now
  ///
  /// In en, this message translates to:
  /// **'Sync now'**
  String get syncNow;

  /// prototype key: sync_passphrase
  ///
  /// In en, this message translates to:
  /// **'Family passphrase'**
  String get syncPassphrase;

  /// prototype key: sync_recovery_key
  ///
  /// In en, this message translates to:
  /// **'Recovery key'**
  String get syncRecoveryKey;

  /// prototype key: sync_saved_it
  ///
  /// In en, this message translates to:
  /// **'I saved it'**
  String get syncSavedIt;

  /// prototype key: sync_status_failed
  ///
  /// In en, this message translates to:
  /// **'Sync failed – tap to retry'**
  String get syncStatusFailed;

  /// prototype key: sync_status_ok
  ///
  /// In en, this message translates to:
  /// **'Synced {t}'**
  String syncStatusOk(String t);

  /// prototype key: sync_status_waiting
  ///
  /// In en, this message translates to:
  /// **'Waiting for internet'**
  String get syncStatusWaiting;

  /// prototype key: sync_title
  ///
  /// In en, this message translates to:
  /// **'Sync with Google Drive'**
  String get syncTitle;

  /// prototype key: sync_wifi_only
  ///
  /// In en, this message translates to:
  /// **'Sync on Wi-Fi only'**
  String get syncWifiOnly;

  /// prototype key: system
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// prototype key: t_added
  ///
  /// In en, this message translates to:
  /// **'Transaction added'**
  String get tAdded;

  /// prototype key: t_added_rep
  ///
  /// In en, this message translates to:
  /// **'Added and scheduled to repeat'**
  String get tAddedRep;

  /// prototype key: t_cat_deleted
  ///
  /// In en, this message translates to:
  /// **'Category deleted'**
  String get tCatDeleted;

  /// prototype key: t_cat_saved
  ///
  /// In en, this message translates to:
  /// **'Category saved'**
  String get tCatSaved;

  /// prototype key: t_deleted
  ///
  /// In en, this message translates to:
  /// **'Transaction deleted'**
  String get tDeleted;

  /// prototype key: t_mem_deleted
  ///
  /// In en, this message translates to:
  /// **'Family member removed'**
  String get tMemDeleted;

  /// prototype key: t_mem_saved
  ///
  /// In en, this message translates to:
  /// **'Family member saved'**
  String get tMemSaved;

  /// prototype key: t_occ_deleted
  ///
  /// In en, this message translates to:
  /// **'Occasion deleted'**
  String get tOccDeleted;

  /// prototype key: t_occ_saved
  ///
  /// In en, this message translates to:
  /// **'Occasion saved'**
  String get tOccSaved;

  /// prototype key: t_paid
  ///
  /// In en, this message translates to:
  /// **'Recorded: {n}'**
  String tPaid(String n);

  /// prototype key: t_rec_deleted
  ///
  /// In en, this message translates to:
  /// **'Recurring item removed'**
  String get tRecDeleted;

  /// prototype key: t_rec_saved
  ///
  /// In en, this message translates to:
  /// **'Recurring item saved'**
  String get tRecSaved;

  /// prototype key: t_reset
  ///
  /// In en, this message translates to:
  /// **'Demo data restored'**
  String get tReset;

  /// prototype key: t_transfer_deleted
  ///
  /// In en, this message translates to:
  /// **'Transfer deleted'**
  String get tTransferDeleted;

  /// prototype key: t_transfer_saved
  ///
  /// In en, this message translates to:
  /// **'Transfer saved'**
  String get tTransferSaved;

  /// prototype key: t_updated
  ///
  /// In en, this message translates to:
  /// **'Transaction updated'**
  String get tUpdated;

  /// prototype key: tab_ev
  ///
  /// In en, this message translates to:
  /// **'Occasions'**
  String get tabEv;

  /// prototype key: tab_fc
  ///
  /// In en, this message translates to:
  /// **'Forecast'**
  String get tabFc;

  /// prototype key: tab_rec
  ///
  /// In en, this message translates to:
  /// **'Recurring'**
  String get tabRec;

  /// prototype key: tap_again
  ///
  /// In en, this message translates to:
  /// **'Tap again to confirm'**
  String get tapAgain;

  /// prototype key: theme
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// prototype key: theme_system
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// prototype key: this_month
  ///
  /// In en, this message translates to:
  /// **'Spent this month'**
  String get thisMonth;

  /// prototype key: to_account
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get toAccount;

  /// prototype key: today
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// prototype key: tomorrow
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get tomorrow;

  /// prototype key: total
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// prototype key: total_budget
  ///
  /// In en, this message translates to:
  /// **'Total budget'**
  String get totalBudget;

  /// prototype key: total_in
  ///
  /// In en, this message translates to:
  /// **'Total in {c}'**
  String totalIn(String c);

  /// prototype key: transactions
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get transactions;

  /// prototype key: transfer
  ///
  /// In en, this message translates to:
  /// **'Transfer'**
  String get transfer;

  /// prototype key: transfer_from_to
  ///
  /// In en, this message translates to:
  /// **'{from} → {to}'**
  String transferFromTo(String from, String to);

  /// prototype key: transfer_hint
  ///
  /// In en, this message translates to:
  /// **'Transfers move money between your accounts. They don\'\'t count as income or spending.'**
  String get transferHint;

  /// prototype key: transfers
  ///
  /// In en, this message translates to:
  /// **'Transfers'**
  String get transfers;

  /// prototype key: type_l
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get typeL;

  /// prototype key: unlock
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get unlock;

  /// prototype key: use_biometric
  ///
  /// In en, this message translates to:
  /// **'Use fingerprint / face'**
  String get useBiometric;

  /// prototype key: used_n
  ///
  /// In en, this message translates to:
  /// **'Used in {n} transactions'**
  String usedN(String n);

  /// prototype key: variable
  ///
  /// In en, this message translates to:
  /// **'Day-to-day (estimated)'**
  String get variable;

  /// prototype key: variable_s
  ///
  /// In en, this message translates to:
  /// **'Day-to-day'**
  String get variableS;

  /// prototype key: version
  ///
  /// In en, this message translates to:
  /// **'Version {v}'**
  String version(String v);

  /// prototype key: view_all
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get viewAll;

  /// prototype key: vs_last
  ///
  /// In en, this message translates to:
  /// **'vs last month'**
  String get vsLast;

  /// prototype key: vs_val
  ///
  /// In en, this message translates to:
  /// **'{d}% spend'**
  String vsVal(String d);

  /// prototype key: yes
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// prototype key: yesterday
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
