// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get about => 'حول التطبيق';

  @override
  String get accBank => 'البنك';

  @override
  String get accCard => 'البطاقة';

  @override
  String get accCash => 'نقدي';

  @override
  String get accUsd => 'حساب الدولار';

  @override
  String get account => 'الحساب';

  @override
  String get accounts => 'الحسابات';

  @override
  String get addCat => '+ إضافة فئة';

  @override
  String get addMember => '+ إضافة فرد';

  @override
  String get addOccasion => '+ إضافة مناسبة';

  @override
  String get addRec => '+ إضافة';

  @override
  String get adjustDate => 'تعديل التاريخ';

  @override
  String get adjustHint => 'رؤية الهلال قد تغير التاريخ يوماً.';

  @override
  String get all => 'الكل';

  @override
  String get allMembers => 'الكل';

  @override
  String get allRec => 'كل المعاملات المتكررة';

  @override
  String get amount => 'المبلغ';

  @override
  String get amountReceived => 'المبلغ المُستلم';

  @override
  String get amountSent => 'المبلغ المُرسل';

  @override
  String get appLock => 'قفل التطبيق';

  @override
  String get appName => 'MoneyFollow';

  @override
  String get appSub => 'مالية البيت';

  @override
  String approx(String v) {
    return '≈ $v';
  }

  @override
  String get avatar => 'الصورة';

  @override
  String get avgDaily => 'متوسط الصرف اليومي';

  @override
  String get back => 'رجوع';

  @override
  String get backup => 'النسخ الاحتياطي';

  @override
  String get backupCreated => 'تم إنشاء النسخة الاحتياطية';

  @override
  String get backupNow => 'انسخ الآن';

  @override
  String get backupPassword => 'كلمة مرور (اختياري)';

  @override
  String get backupPasswordConfirm => 'تأكيد كلمة المرور';

  @override
  String get backupPasswordHint =>
      'مع كلمة المرور يتم تشفير الملف، وستحتاجها للاستعادة.';

  @override
  String get backupReminder => 'تذكير بالنسخ الاحتياطي';

  @override
  String get biometricReason => 'افتح MoneyFollow';

  @override
  String get budgets => 'الميزانيات';

  @override
  String get budgetsUpdated => 'تم تحديث الميزانيات';

  @override
  String get builtin => 'أساسية';

  @override
  String get builtinCats => 'الفئات الأساسية';

  @override
  String get byCat => 'الصرف حسب الفئة';

  @override
  String get byMember => 'الصرف حسب الفرد';

  @override
  String get cAE => 'الإمارات';

  @override
  String get cEG => 'مصر';

  @override
  String get cGB => 'المملكة المتحدة';

  @override
  String get cKW => 'الكويت';

  @override
  String get cSA => 'السعودية';

  @override
  String get cUS => 'الولايات المتحدة';

  @override
  String get cancel => 'إلغاء';

  @override
  String get catPh => 'مثال: الحيوانات الأليفة';

  @override
  String get catType => 'النوع';

  @override
  String get categories => 'الفئات';

  @override
  String get category => 'الفئة';

  @override
  String get catsHint =>
      'الفئات الأساسية جزء من التطبيق ولا يمكن تعديلها أو حذفها. الفئات التي تضيفها يمكنك تعديلها أو حذفها في أي وقت.';

  @override
  String get changePin => 'تغيير رمز PIN';

  @override
  String get clear => 'مسح';

  @override
  String get clearSample => 'امسح البيانات التجريبية وابدأ';

  @override
  String get clearSampleBody =>
      'سيتم حذف كل البيانات التجريبية وأي شيء أضفته أثناء الاستكشاف. اختيارات الإعداد تبقى كما هي.';

  @override
  String get clearSampleTitle => 'مسح البيانات التجريبية؟';

  @override
  String get colorL => 'اللون';

  @override
  String get comingUp => 'القادم';

  @override
  String get confirmPin => 'أدخل الرمز مرة أخرى';

  @override
  String get currency => 'العملة';

  @override
  String get dark => 'داكن';

  @override
  String get data => 'البيانات';

  @override
  String get date => 'التاريخ';

  @override
  String get dayEarlier => 'قبلها بيوم';

  @override
  String get dayLater => 'بعدها بيوم';

  @override
  String daysLeft(String n) {
    return 'بعد $n يوم';
  }

  @override
  String get delCat => 'حذف الفئة';

  @override
  String get delCatHint =>
      'عند الحذف تبقى المعاملات والمتكررة والسجل وتُنقل إلى «أخرى».';

  @override
  String get delMemHint =>
      'عند حذف الفرد تبقى معاملاته وتُنقل إلى العائلة كلها.';

  @override
  String get delMember => 'حذف الفرد';

  @override
  String get delOccHint => 'المعاملات المرتبطة تحتفظ بسجلها.';

  @override
  String get delOccasion => 'حذف المناسبة';

  @override
  String get delRec => 'إيقاف التكرار';

  @override
  String get delete => 'حذف';

  @override
  String get done => 'تم';

  @override
  String get dontRemind => 'لا تذكّرني';

  @override
  String get due30 => 'مستحق خلال 30 يوم القادمة';

  @override
  String get dueIn30 => 'مستحق خلال 30 يوم';

  @override
  String get dueToday => 'مستحق اليوم';

  @override
  String get edit => 'تعديل';

  @override
  String get editCat => 'تعديل الفئة';

  @override
  String get editMember => 'تعديل الفرد';

  @override
  String get editOccasion => 'تعديل المناسبة';

  @override
  String get editRec => 'تعديل المعاملة المتكررة';

  @override
  String get editTransfer => 'تعديل التحويل';

  @override
  String get editTx => 'تعديل المعاملة';

  @override
  String get enterPassword => 'أدخل كلمة مرور النسخة الاحتياطية';

  @override
  String get enterPin => 'أدخل رمز PIN';

  @override
  String get errAmount => 'أدخل مبلغاً أكبر من صفر';

  @override
  String get errBackupDamaged =>
      'هذا الملف تالف أو ليس نسخة احتياطية من MoneyFollow.';

  @override
  String get errBackupNewer =>
      'هذه النسخة من إصدار أحدث من MoneyFollow. حدّث التطبيق أولاً.';

  @override
  String get errBackupPassword => 'كلمة المرور غير صحيحة';

  @override
  String get errCat => 'اختر فئة';

  @override
  String get errCatDup => 'توجد فئة بنفس الاسم';

  @override
  String get errName => 'أدخل الاسم';

  @override
  String get errPasswordMatch => 'كلمتا المرور غير متطابقتين';

  @override
  String get errPin => 'رمز PIN غير صحيح';

  @override
  String get errPinMatch => 'الرمزان غير متطابقين';

  @override
  String get errRate => 'أدخل سعراً أكبر من صفر';

  @override
  String get errSameAccount => 'اختر حسابين مختلفين';

  @override
  String get errorGeneric => 'حدث خطأ ما';

  @override
  String get evBuiltin => 'تواريخ مدمجة';

  @override
  String get evByCat => 'المتوقع حسب الفئة';

  @override
  String get evCountry => 'الدولة';

  @override
  String get evEidAdha => 'عيد الأضحى';

  @override
  String get evEidFitr => 'عيد الفطر';

  @override
  String get evExpected => 'الصرف المتوقع';

  @override
  String get evHint =>
      'يتم توقع كل مناسبة من مصروفاتك عليها في السنوات السابقة، مع حساب متوسط التغير من سنة لسنة.';

  @override
  String evHintD(String l, String g) {
    return 'المتوقع = آخر مرة ($l) × متوسط التغير بين السنوات ($g).';
  }

  @override
  String get evHintOne =>
      'يوجد سجل لسنة واحدة فقط، لذلك المتوقع يساوي آخر مرة.';

  @override
  String evLast(String v) {
    return 'آخر مرة $v';
  }

  @override
  String evLastTx(String y) {
    return 'آخر مرة · $y';
  }

  @override
  String get evMothers => 'عيد الأم';

  @override
  String get evNewYear => 'رأس السنة';

  @override
  String get evNext => 'المناسبة القادمة';

  @override
  String get evNoHoliday =>
      'لا توجد إجازات رسمية لهذه الدولة في Nager.Date، والتواريخ الهجرية تتحدث عادي.';

  @override
  String get evNone =>
      'لا يوجد سجل بعد. اربط مصروفاتك بهذه المناسبة وسيتعلم التطبيق تكلفتها.';

  @override
  String get evNow => 'الآن';

  @override
  String get evPred => 'المتوقع';

  @override
  String get evPrev => 'السنوات السابقة والمتوقع';

  @override
  String get evRamadan => 'رمضان';

  @override
  String evSave(String v) {
    return 'خصص $v شهرياً لتكون مستعداً';
  }

  @override
  String get evSchool => 'العودة للمدارس';

  @override
  String get evSham => 'شم النسيم';

  @override
  String get evSources =>
      'المناسبات الإسلامية: واجهة التقويم الهجري Aladhan. الإجازات الرسمية: واجهة Nager.Date.';

  @override
  String get evSrcCustom => 'مناسبتك';

  @override
  String get evSrcFixed => 'تاريخ ثابت';

  @override
  String get evSrcHijri => 'تقويم هجري';

  @override
  String get evSrcHoliday => 'إجازة رسمية';

  @override
  String get evSrcTitle => 'المواعيد';

  @override
  String get evSync => 'تحديث';

  @override
  String get evSyncFail =>
      'تعذر الاتصال بخدمات التواريخ. يتم استخدام التواريخ المحفوظة.';

  @override
  String evSynced(String n) {
    return 'تم تحديث مواعيد المناسبات ($n تاريخ)';
  }

  @override
  String get evSyncing => 'جاري التحديث…';

  @override
  String get evTotal12 => 'المناسبات · 12 شهر قادمة';

  @override
  String get evTracked => 'المناسبات المتابَعة';

  @override
  String get evUpcoming => 'خلال 12 شهر القادمة';

  @override
  String evUpdated(String d) {
    return 'آخر تحديث $d';
  }

  @override
  String get evWho => 'مين صرف آخر مرة';

  @override
  String get evXmas => 'عيد الميلاد';

  @override
  String get expIncome => 'الدخل المتوقع';

  @override
  String get expSavings => 'التوفير المتوقع';

  @override
  String get expense => 'مصروف';

  @override
  String get expenses => 'المصروفات';

  @override
  String get explore => 'استكشف';

  @override
  String get exploreSample => 'استكشف ببيانات تجريبية';

  @override
  String get exploreSampleHint =>
      'شاهد التطبيق مع عائلة تجريبية، وامسحها متى كنت جاهزاً.';

  @override
  String get kExport => 'تصدير CSV';

  @override
  String get exportDone => 'تم تصدير CSV';

  @override
  String get famFc => 'الصرف المتوقع · 3 شهور قادمة';

  @override
  String get famFcHint =>
      'توقع كل فرد = معاملاته المتكررة + متوسط مصروفاته الأخرى في آخر 3 شهور. المبالغ باللون البرتقالي تشمل فاتورة ربع سنوية أو سنوية أو مناسبة.';

  @override
  String get famMembers => 'أفراد العائلة';

  @override
  String get famShare => 'مين صرف هذا الشهر';

  @override
  String get family => 'العائلة';

  @override
  String get fcAvg => 'متوسط الصرف المتوقع / شهر';

  @override
  String fcHint(String v) {
    return 'طريقة حساب التوقعات: الفواتير الثابتة من المعاملات المتكررة. المناسبات من مصروفاتك عليها في السنوات السابقة. المصروفات اليومية هي متوسط مصروفاتك الأخرى في آخر 3 شهور ($v / شهر). الدخل المتوقع يشمل الدخل المتكرر فقط.';
  }

  @override
  String fcItems(String f, String v) {
    return '$f ثابت + $v يومي';
  }

  @override
  String get fcOcc => 'مناسبات (تقديري)';

  @override
  String get fcTitle => 'الصرف المتوقع';

  @override
  String get finish => 'إنهاء';

  @override
  String get fixed => 'فواتير ثابتة';

  @override
  String get fixedMonth => 'فواتير ثابتة / شهر';

  @override
  String get forWhom => 'لمن؟';

  @override
  String get fqMonthly => 'شهري';

  @override
  String get fqNever => 'لا يتكرر';

  @override
  String get fqQuarterly => 'كل 3 شهور';

  @override
  String get fqWeekly => 'أسبوعي';

  @override
  String get fqYearly => 'سنوي';

  @override
  String get frequency => 'يتكرر';

  @override
  String get fromAccount => 'من';

  @override
  String get higher => 'أعلى من المعتاد';

  @override
  String get iconL => 'الأيقونة';

  @override
  String inDays(String n) {
    return 'بعد $n يوم';
  }

  @override
  String includes(String x) {
    return 'يشمل $x';
  }

  @override
  String get income => 'الدخل';

  @override
  String get income1 => 'دخل';

  @override
  String get language => 'اللغة';

  @override
  String lastBackup(String d) {
    return 'آخر نسخة $d';
  }

  @override
  String get last6 => 'آخر 6 شهور';

  @override
  String left(String v) {
    return 'متبقي $v';
  }

  @override
  String leftOf(String v, String t) {
    return 'متبقي $v من $t';
  }

  @override
  String get light => 'فاتح';

  @override
  String get lockBiometric => 'رمز PIN + البصمة / الوجه';

  @override
  String get lockOff => 'مغلق';

  @override
  String get lockPin => 'رمز PIN';

  @override
  String get m3 => '3 شهور قادمة';

  @override
  String get m6 => '6 شهور قادمة';

  @override
  String get mainCurrency => 'العملة الأساسية';

  @override
  String get manage => 'إدارة';

  @override
  String get markPaid => 'تم الدفع';

  @override
  String get markRecv => 'تم الاستلام';

  @override
  String get memDad => 'بابا';

  @override
  String get memFamily => 'العائلة كلها';

  @override
  String get memMariam => 'مريم';

  @override
  String get memMom => 'ماما';

  @override
  String get memOmar => 'عمر';

  @override
  String get memPh => 'مثال: عمر';

  @override
  String memTx(String m) {
    return 'معاملات · $m';
  }

  @override
  String get members => 'الأفراد';

  @override
  String get monthlyLimits => 'الحدود الشهرية';

  @override
  String get myCats => 'فئاتك';

  @override
  String get nBakery => 'مخبز';

  @override
  String get nBallet => 'تمرين باليه';

  @override
  String get nBooks => 'كتب وزي المدرسة';

  @override
  String nCats(String b, String c) {
    return '$b أساسية · $c خاصة بك';
  }

  @override
  String get nClothes => 'ملابس';

  @override
  String get nCoffee => 'قهوة';

  @override
  String get nCourse => 'كورس أونلاين';

  @override
  String get nDinner => 'عشاء عائلي';

  @override
  String get nEidClothes => 'لبس العيد';

  @override
  String get nEidiya => 'عيدية الأولاد';

  @override
  String get nFanous => 'فانوس رمضان';

  @override
  String get nFesikh => 'فسيخ ورنجة';

  @override
  String get nFilter => 'صيانة فلتر المياه';

  @override
  String get nFootball => 'أكاديمية كرة القدم';

  @override
  String get nFreelance => 'مشروع عمل حر';

  @override
  String get nFuel => 'بنزين';

  @override
  String get nGift => 'هدية من العائلة';

  @override
  String get nGym => 'اشتراك الجيم';

  @override
  String get nHelp => 'مساعدة منزلية';

  @override
  String get nHome => 'أدوات منزلية';

  @override
  String get nIftar => 'عزومة إفطار';

  @override
  String get nInsurance => 'تأمين السيارة';

  @override
  String get nKahk => 'كحك وبسكويت العيد';

  @override
  String nMembers(String n) {
    return '$n أفراد';
  }

  @override
  String get nMetro => 'كارت المترو';

  @override
  String get nMobile => 'موبايل وإنترنت';

  @override
  String get nMomGift => 'هدية عيد الأم';

  @override
  String get nNyDinner => 'عشاء رأس السنة';

  @override
  String get nOuting => 'سينما وخروجة';

  @override
  String get nPharmacy => 'صيدلية';

  @override
  String get nPocket => 'مصروف الجيب';

  @override
  String get nPower => 'كهرباء ومياه';

  @override
  String get nRamadanFood => 'مشتريات رمضان';

  @override
  String get nRent => 'إيجار البيت';

  @override
  String get nRentalIn => 'إيجار الشقة المستلم';

  @override
  String get nSalary => 'الراتب الشهري';

  @override
  String get nSchool => 'مصاريف المدرسة';

  @override
  String get nStream => 'اشتراك منصة مشاهدة';

  @override
  String get nSuper => 'سوبر ماركت';

  @override
  String get nSupplies => 'أدوات مدرسية';

  @override
  String get nTakeaway => 'أكل جاهز';

  @override
  String get nTaxi => 'تاكسي';

  @override
  String get nUdhiya => 'الأضحية';

  @override
  String get nUniform => 'زي المدرسة';

  @override
  String get nVeg => 'خضار وفاكهة';

  @override
  String get nWeekly => 'مشتريات الأسبوع';

  @override
  String get nXmasGifts => 'هدايا عيد الميلاد';

  @override
  String get nZakat => 'زكاة الفطر';

  @override
  String get name => 'الاسم';

  @override
  String get namePh => 'مثال: إيجار البيت';

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navTx => 'المعاملات';

  @override
  String get netBalance => 'صافي الرصيد';

  @override
  String get neverBackedUp => 'لم يتم النسخ بعد';

  @override
  String get newCat => 'فئة جديدة';

  @override
  String get newMember => 'فرد جديد في العائلة';

  @override
  String get newOccasion => 'مناسبة جديدة';

  @override
  String get newRec => 'معاملة متكررة جديدة';

  @override
  String get newTransfer => 'تحويل جديد';

  @override
  String get newTx => 'معاملة جديدة';

  @override
  String get next => 'التالي';

  @override
  String get nextDue => 'تاريخ الاستحقاق القادم';

  @override
  String get nextMonth => 'المتوقع الشهر القادم';

  @override
  String nextMonthS(String v) {
    return 'الشهر القادم ≈ $v';
  }

  @override
  String nextOn(String d) {
    return 'القادم $d';
  }

  @override
  String get next3 => 'المتوقع في 3 شهور قادمة';

  @override
  String get no => 'لا';

  @override
  String get noBudgets => 'لا توجد ميزانيات';

  @override
  String get noBudgetsEdit => 'لا توجد ميزانيات. اضغط تعديل لإضافة حدود.';

  @override
  String get noExp => 'لا توجد مصروفات هذا الشهر';

  @override
  String get noIncome => 'لا يوجد دخل مسجل بعد';

  @override
  String get noLimit => 'بلا حد';

  @override
  String get noMemTx => 'لا توجد معاملات هذا الشهر';

  @override
  String get noMyCats => 'لا توجد فئات خاصة بك بعد. اضغط «+ إضافة فئة».';

  @override
  String get noRec => 'لا توجد معاملات متكررة بعد';

  @override
  String get noTxMonth => 'لا توجد معاملات هذا الشهر';

  @override
  String get notUsed => 'لم تُستخدم بعد';

  @override
  String get note => 'ملاحظة';

  @override
  String get notePh => 'مثال: مشتريات الأسبوع';

  @override
  String get nothing => 'لا توجد نتائج';

  @override
  String get nothingDue => 'لا يوجد شيء مستحق خلال 30 يوم';

  @override
  String notifBillTitle(String n, String when) {
    return '$n مستحق $when';
  }

  @override
  String get notifBills => 'الفواتير المستحقة';

  @override
  String get notifBillsHint => 'قبل الاستحقاق بيوم وفي يومه';

  @override
  String notifBudgetTitle(String c, String p) {
    return 'ميزانية $c وصلت $p%';
  }

  @override
  String get notifBudgets => 'تنبيهات الميزانية';

  @override
  String get notifBudgetsHint => 'عندما تصل الفئة إلى 80% و100%';

  @override
  String notifOccasionBody(String v, String m) {
    return 'المتوقع ≈ $v. خصص $m شهرياً.';
  }

  @override
  String notifOccasionTitle(String n) {
    return '$n بعد 30 يوماً';
  }

  @override
  String get notifOccasions => 'المناسبات';

  @override
  String get notifOccasionsHint => 'قبلها بـ 30 يوماً مع المبلغ المقترح ادخاره';

  @override
  String get notifications => 'الإشعارات';

  @override
  String get occDate => 'التاريخ (الشهر واليوم)';

  @override
  String get occDays => 'عدد الأيام';

  @override
  String get occNone => 'بدون';

  @override
  String get occasion => 'المناسبة';

  @override
  String get occasions => 'مناسبات';

  @override
  String kOf(String a, String b) {
    return '$a من $b';
  }

  @override
  String get ok => 'حسناً';

  @override
  String over(String v) {
    return 'تجاوز $v';
  }

  @override
  String overPct(String p) {
    return 'صرفت أكثر من دخلك بنسبة $p% هذا الشهر';
  }

  @override
  String get overTime => 'صرف كل فرد · آخر 6 شهور';

  @override
  String overdue(String n) {
    return 'متأخر $n يوم';
  }

  @override
  String get password => 'كلمة المرور';

  @override
  String get pinHint => 'من 4 إلى 6 أرقام';

  @override
  String get planner => 'التخطيط';

  @override
  String get prefs => 'التفضيلات';

  @override
  String get protoNote => 'نموذج أولي · البيانات محفوظة في هذا المتصفح فقط';

  @override
  String get rates => 'أسعار الصرف';

  @override
  String get ratesHint =>
      'يتم تحويل الإجماليات والميزانيات والتقارير والتوقعات إلى العملة الأساسية بهذه الأسعار.';

  @override
  String get ratesHintSnapshot =>
      'تغيير السعر يؤثر على المعاملات الجديدة والتوقعات. المعاملات السابقة تحتفظ بسعرها وقت التسجيل.';

  @override
  String get ratesUpdated => 'تم تحديث سعر الصرف';

  @override
  String get recIncome => 'دخل متكرر / شهر';

  @override
  String get recent => 'الأحدث';

  @override
  String get remind3Days => 'ذكّرني بعد 3 أيام';

  @override
  String get reminderBody => 'مر أكثر من أسبوع على آخر نسخة احتياطية.';

  @override
  String get reminderTitle => 'انسخ بياناتك احتياطياً';

  @override
  String get repeat => 'التكرار';

  @override
  String get reports => 'التقارير';

  @override
  String get reset => 'استعادة البيانات التجريبية';

  @override
  String get restore => 'استعادة';

  @override
  String get restoreBackup => 'استعادة من نسخة احتياطية';

  @override
  String restoreConfirmBody(String d, String device, String n) {
    return 'هذه النسخة من $d ($device) فيها $n معاملة. الاستعادة تستبدل كل البيانات على هذا الهاتف.';
  }

  @override
  String get restoreConfirmTitle => 'استبدال بياناتك؟';

  @override
  String get restoreDrive => 'استعادة من Google Drive';

  @override
  String get restored => 'تمت استعادة النسخة الاحتياطية';

  @override
  String get role => 'الصفة';

  @override
  String get roleChild => 'ابن / ابنة';

  @override
  String get roleOther => 'آخر';

  @override
  String get roleParent => 'أب / أم';

  @override
  String get sampleBanner => 'بيانات تجريبية';

  @override
  String get save => 'حفظ';

  @override
  String savedPct(String p) {
    return 'وفّرت $p% من دخلك هذا الشهر';
  }

  @override
  String get search => 'ابحث في الملاحظات أو الفئات';

  @override
  String get security => 'الأمان';

  @override
  String get seeAll => 'عرض الكل';

  @override
  String get seedYears => 'إضافة 3 سنوات (للتجربة)';

  @override
  String get setPin => 'تعيين رمز PIN';

  @override
  String get settings => 'الإعدادات';

  @override
  String get settingsMore => 'المزيد';

  @override
  String get setupCurrency => 'العملة الأساسية والدولة';

  @override
  String get setupLanguage => 'اختر لغتك';

  @override
  String get setupMembers => 'عائلتك';

  @override
  String get setupMembersHint =>
      'أضف الأشخاص الذين تريد متابعتهم. يمكنك فعل ذلك لاحقاً.';

  @override
  String get setupStart => 'كيف تريد أن تبدأ؟';

  @override
  String get setupWelcome => 'أهلاً بك في MoneyFollow';

  @override
  String get shareLog => 'مشاركة سجل التشخيص';

  @override
  String get shareOf => 'نسبته من العائلة';

  @override
  String get skip => 'تخطي';

  @override
  String get spent => 'المصروف';

  @override
  String spentV(String v) {
    return 'تم صرف $v';
  }

  @override
  String get startOwn => 'ابدأ ببياناتي';

  @override
  String get startOwnHint => 'ابدأ بتطبيق فارغ.';

  @override
  String get sync => 'المزامنة';

  @override
  String get syncChangePassphrase => 'تغيير عبارة المرور';

  @override
  String get syncComing => 'المزامنة مع Google Drive قادمة في الإصدار 1.1.';

  @override
  String get syncDevices => 'الأجهزة';

  @override
  String get syncDisconnect => 'قطع الاتصال';

  @override
  String get syncModeA => 'حساب Google واحد مشترك للعائلة';

  @override
  String get syncModeB => 'حساب Google خاص بكل والد';

  @override
  String get syncNow => 'زامن الآن';

  @override
  String get syncPassphrase => 'عبارة مرور العائلة';

  @override
  String get syncRecoveryKey => 'مفتاح الاسترداد';

  @override
  String get syncSavedIt => 'حفظته';

  @override
  String get syncStatusFailed => 'فشلت المزامنة – اضغط لإعادة المحاولة';

  @override
  String syncStatusOk(String t) {
    return 'تمت المزامنة $t';
  }

  @override
  String get syncStatusWaiting => 'في انتظار الإنترنت';

  @override
  String get syncTitle => 'المزامنة مع Google Drive';

  @override
  String get syncWifiOnly => 'المزامنة على Wi-Fi فقط';

  @override
  String get system => 'حسب النظام';

  @override
  String get tAdded => 'تمت إضافة المعاملة';

  @override
  String get tAddedRep => 'تمت الإضافة وجدولة التكرار';

  @override
  String get tCatDeleted => 'تم حذف الفئة';

  @override
  String get tCatSaved => 'تم حفظ الفئة';

  @override
  String get tDeleted => 'تم حذف المعاملة';

  @override
  String get tMemDeleted => 'تم حذف فرد العائلة';

  @override
  String get tMemSaved => 'تم حفظ فرد العائلة';

  @override
  String get tOccDeleted => 'تم حذف المناسبة';

  @override
  String get tOccSaved => 'تم حفظ المناسبة';

  @override
  String tPaid(String n) {
    return 'تم تسجيل: $n';
  }

  @override
  String get tRecDeleted => 'تم إيقاف المعاملة المتكررة';

  @override
  String get tRecSaved => 'تم حفظ المعاملة المتكررة';

  @override
  String get tReset => 'تمت استعادة البيانات التجريبية';

  @override
  String get tTransferDeleted => 'تم حذف التحويل';

  @override
  String get tTransferSaved => 'تم حفظ التحويل';

  @override
  String get tUpdated => 'تم تحديث المعاملة';

  @override
  String get tabEv => 'المناسبات';

  @override
  String get tabFc => 'التوقعات';

  @override
  String get tabRec => 'المتكررة';

  @override
  String get tapAgain => 'اضغط مرة أخرى للتأكيد';

  @override
  String get theme => 'المظهر';

  @override
  String get themeSystem => 'حسب النظام';

  @override
  String get thisMonth => 'المصروف هذا الشهر';

  @override
  String get toAccount => 'إلى';

  @override
  String get today => 'اليوم';

  @override
  String get tomorrow => 'غداً';

  @override
  String get total => 'الإجمالي';

  @override
  String get totalBudget => 'إجمالي الميزانية';

  @override
  String totalIn(String c) {
    return 'الإجمالي بـ $c';
  }

  @override
  String get transactions => 'المعاملات';

  @override
  String get transfer => 'تحويل';

  @override
  String transferFromTo(String from, String to) {
    return '$from ← $to';
  }

  @override
  String get transferHint =>
      'التحويلات تنقل المال بين حساباتك ولا تُحسب دخلاً أو مصروفاً.';

  @override
  String get transfers => 'التحويلات';

  @override
  String get typeL => 'النوع';

  @override
  String get unlock => 'فتح';

  @override
  String get useBiometric => 'استخدم البصمة / الوجه';

  @override
  String usedN(String n) {
    return 'مستخدمة في $n معاملة';
  }

  @override
  String get variable => 'مصروفات يومية (تقديري)';

  @override
  String get variableS => 'يومية';

  @override
  String version(String v) {
    return 'الإصدار $v';
  }

  @override
  String get viewAll => 'عرض الكل';

  @override
  String get vsLast => 'مقارنة بالشهر السابق';

  @override
  String vsVal(String d) {
    return '$d% في الصرف';
  }

  @override
  String get yes => 'نعم';

  @override
  String get yesterday => 'أمس';
}
