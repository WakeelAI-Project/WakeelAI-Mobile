// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'وكيل';

  @override
  String get appTagline =>
      'مسؤول الموارد البشرية والشؤون القانونية الرقمي الخاص بك';

  @override
  String get themeShowcaseTitle => 'نظام التصميم';

  @override
  String get toggleThemeMode => 'تبديل المظهر';

  @override
  String get toggleContrast => 'تباين عالٍ';

  @override
  String get toggleLanguage => 'English';

  @override
  String get aiGeneratedLabel => 'منشأ بالذكاء الاصطناعي';

  @override
  String get citationExample => 'المادة 84 · قانون العمل 14/2025';

  @override
  String get loginEmailLabel => 'البريد الإلكتروني';

  @override
  String get loginEmailHint => 'you@company.com';

  @override
  String get loginPasswordLabel => 'كلمة المرور';

  @override
  String get loginShowPassword => 'إظهار كلمة المرور';

  @override
  String get loginHidePassword => 'إخفاء كلمة المرور';

  @override
  String get loginSubmit => 'تسجيل الدخول';

  @override
  String get loginErrorEmailRequired => 'أدخل بريدك الإلكتروني';

  @override
  String get loginErrorEmailInvalid => 'أدخل بريدًا إلكترونيًا صحيحًا';

  @override
  String get loginErrorPasswordRequired => 'أدخل كلمة المرور';

  @override
  String get loginErrorPasswordTooShort => 'يجب ألا تقل كلمة المرور عن 6 أحرف';

  @override
  String get loginInvalidCredentials =>
      'البريد الإلكتروني أو كلمة المرور غير صحيحة. حاول مرة أخرى.';

  @override
  String get loginAccountInactive =>
      'تم إيقاف حسابك. يرجى التواصل مع مسؤول الموارد البشرية.';

  @override
  String get loginGenericError => 'حدث خطأ ما. حاول مرة أخرى.';

  @override
  String get loginPasswordChangedMessage =>
      'تم تغيير كلمة المرور. يرجى تسجيل الدخول بكلمة المرور الجديدة.';

  @override
  String get changePasswordTitle => 'تعيين كلمة المرور';

  @override
  String get changePasswordSubtitle =>
      'هذه أول مرة تسجّل فيها الدخول. اختر كلمة مرور جديدة لإكمال إعداد حسابك.';

  @override
  String get changePasswordCurrentPasswordLabel => 'كلمة المرور الحالية';

  @override
  String get changePasswordErrorCurrentPasswordRequired =>
      'أدخل كلمة المرور الحالية';

  @override
  String get changePasswordNewPasswordLabel => 'كلمة المرور الجديدة';

  @override
  String get changePasswordConfirmPasswordLabel => 'تأكيد كلمة المرور الجديدة';

  @override
  String get changePasswordSubmit => 'تعيين كلمة المرور';

  @override
  String get changePasswordErrorPasswordRequired => 'أدخل كلمة مرور جديدة';

  @override
  String get changePasswordErrorPasswordTooShort =>
      'يجب ألا تقل كلمة المرور عن 8 أحرف';

  @override
  String get changePasswordErrorPasswordMismatch =>
      'كلمتا المرور غير متطابقتين';

  @override
  String get changePasswordInvalidCurrentPassword =>
      'كلمة المرور المؤقتة لم تعد صالحة. يرجى تسجيل الدخول مرة أخرى.';

  @override
  String get changePasswordUserNotFound =>
      'تعذر العثور على حسابك. يرجى تسجيل الدخول مرة أخرى.';

  @override
  String get changePasswordGenericError => 'حدث خطأ ما. حاول مرة أخرى.';

  @override
  String get loginForgotPasswordLink => 'هل نسيت كلمة المرور؟';

  @override
  String get forgotPasswordTitle => 'إعادة تعيين كلمة المرور';

  @override
  String get forgotPasswordSubtitle =>
      'أدخل البريد الإلكتروني المرتبط بحسابك وسنرسل لك رمزًا مكونًا من 6 أرقام لإعادة تعيين كلمة المرور.';

  @override
  String get forgotPasswordSubmit => 'إرسال الرمز';

  @override
  String get forgotPasswordTooManyRequests =>
      'محاولات كثيرة جدًا. يرجى الانتظار قليلاً قبل المحاولة مرة أخرى.';

  @override
  String get forgotPasswordGenericError => 'حدث خطأ ما. حاول مرة أخرى.';

  @override
  String get verifyOtpTitle => 'أدخل رمز التحقق';

  @override
  String verifyOtpSubtitle(String email) {
    return 'أدخل الرمز المكون من 6 أرقام المرسل إلى $email.';
  }

  @override
  String get verifyOtpSubmit => 'تحقق من الرمز';

  @override
  String get verifyOtpResendCode => 'إعادة إرسال الرمز';

  @override
  String verifyOtpResendCodeCountdown(int seconds) {
    return 'إعادة إرسال الرمز خلال $seconds ثانية';
  }

  @override
  String get verifyOtpResendSuccess => 'تم إرسال رمز جديد.';

  @override
  String get verifyOtpErrorInvalidOtp => 'رمز غير صحيح. حاول مرة أخرى.';

  @override
  String get verifyOtpErrorOtpExpired =>
      'انتهت صلاحية هذا الرمز. اطلب رمزًا جديدًا.';

  @override
  String get verifyOtpErrorTooManyAttempts =>
      'محاولات غير صحيحة كثيرة جدًا. يرجى طلب رمز جديد.';

  @override
  String get verifyOtpErrorGeneric => 'حدث خطأ ما. حاول مرة أخرى.';

  @override
  String get newPasswordTitle => 'تعيين كلمة مرور جديدة';

  @override
  String get newPasswordSubtitle => 'اختر كلمة مرور جديدة لحسابك.';

  @override
  String get newPasswordSubmit => 'إعادة تعيين كلمة المرور';

  @override
  String get newPasswordErrorInvalidOtp =>
      'لم يعد الرمز صالحًا. يرجى طلب رمز جديد.';

  @override
  String get newPasswordErrorOtpExpired =>
      'انتهت صلاحية الرمز. يرجى طلب رمز جديد.';

  @override
  String get newPasswordErrorTooManyAttempts =>
      'محاولات غير صحيحة كثيرة جدًا. يرجى طلب رمز جديد.';

  @override
  String get newPasswordErrorValidation =>
      'تحقق من كلمة المرور الجديدة وحاول مرة أخرى.';

  @override
  String get newPasswordErrorGeneric => 'حدث خطأ ما. حاول مرة أخرى.';

  @override
  String get sessionExpiredTitle => 'انتهت الجلسة';

  @override
  String get sessionExpiredMessage =>
      'انتهت صلاحية جلستك. يرجى تسجيل الدخول مرة أخرى.';

  @override
  String get sessionExpiredOk => 'حسناً';

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navChat => 'المحادثة';

  @override
  String get navLeaves => 'الإجازات';

  @override
  String get navDocs => 'المستندات';

  @override
  String get homeLeaveBalances => 'أرصدة الإجازات';

  @override
  String get homeQuickActions => 'إجراءات سريعة';

  @override
  String get homeGreetingMorning => 'صباح الخير';

  @override
  String get homeGreetingAfternoon => 'مساء الخير';

  @override
  String get homeGreetingEvening => 'مساء الخير';

  @override
  String get homeLeaveLowBalance => 'رصيد منخفض';

  @override
  String get homeLeaveNoneLeft => 'لا يوجد رصيد';

  @override
  String homeLeaveSubtitle(int remaining, int total) {
    return 'متبقي $remaining من $total أيام';
  }

  @override
  String homeLeaveSubtitleUnlimited(int used) {
    return 'المستخدم: $used أيام (بدون حد)';
  }

  @override
  String get homeLeaveAvailable => 'متاح';

  @override
  String get homeLeaveUnlimited => 'غير محدود';

  @override
  String get leaveTypeAnnual => 'سنوية';

  @override
  String get leaveTypeSick => 'مرضية';

  @override
  String get leaveTypeUnpaid => 'بدون راتب';

  @override
  String get quickActionChat => 'اسأل المساعد';

  @override
  String get quickActionLeaves => 'طلبات إجازاتي';

  @override
  String get quickActionDocs => 'مستنداتي';

  @override
  String get quickActionProfile => 'الملف الشخصي';

  @override
  String get welcomeGreeting => 'مرحباً';

  @override
  String get profileTitle => 'ملفي الشخصي';

  @override
  String get profileEmailLabel => 'البريد الإلكتروني';

  @override
  String get profileDepartmentLabel => 'القسم';

  @override
  String get profileHireDateLabel => 'تاريخ التعيين';

  @override
  String get profileSalaryLabel => 'الراتب';

  @override
  String get profileFailedToLoad => 'تعذر تحميل الملف الشخصي';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get settingsLanguage => 'اللغة';

  @override
  String get settingsTheme => 'المظهر';

  @override
  String get themeSystem => 'تلقائي (حسب النظام)';

  @override
  String get themeLight => 'فاتح';

  @override
  String get themeDark => 'داكن';

  @override
  String get themeHighContrast => 'تباين عالي';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get logoutConfirmationTitle => 'تسجيل الخروج';

  @override
  String get logoutConfirmationDesc => 'هل أنت متأكد أنك تريد تسجيل الخروج؟';

  @override
  String get cancel => 'إلغاء';

  @override
  String get newLeaveRequestTitle => 'طلب إجازة';

  @override
  String get newLeaveRequestTypeLabel => 'نوع الإجازة';

  @override
  String get newLeaveRequestStartDateLabel => 'تاريخ البدء';

  @override
  String get newLeaveRequestEndDateLabel => 'تاريخ الانتهاء';

  @override
  String get newLeaveRequestSelectDateHint => 'اختر التاريخ';

  @override
  String newLeaveRequestDaysSummary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count يوماً',
      few: '$count أيام',
      two: 'يومان',
      one: 'يوم واحد',
    );
    return '$_temp0';
  }

  @override
  String get newLeaveRequestReasonLabel => 'السبب (اختياري)';

  @override
  String get newLeaveRequestReasonHint => 'أضف أي تفاصيل إضافية...';

  @override
  String get newLeaveRequestAttachmentLabel => 'التقرير الطبي';

  @override
  String get newLeaveRequestAttachmentButton => 'اختر ملفًا';

  @override
  String get newLeaveRequestAttachmentRequiredHint =>
      'التقرير الطبي مطلوب للإجازة المرضية';

  @override
  String get newLeaveRequestSubmitButton => 'إرسال الطلب';

  @override
  String get newLeaveRequestErrorRequiredDates =>
      'اختر تاريخ البدء وتاريخ الانتهاء';

  @override
  String get newLeaveRequestErrorEndBeforeStart =>
      'يجب أن يكون تاريخ الانتهاء بعد تاريخ البدء';

  @override
  String get newLeaveRequestErrorAttachmentRequired =>
      'يرجى إرفاق تقرير طبي للإجازة المرضية';

  @override
  String get newLeaveRequestErrorAttachmentTooLarge =>
      'حجم المرفق يتجاوز الحد الأقصى البالغ 10 ميجابايت';

  @override
  String get newLeaveRequestSuccessMessage => 'تم إرسال طلب الإجازة';

  @override
  String get newLeaveRequestErrorValidation =>
      'تحقق من تفاصيل الطلب وحاول مرة أخرى.';

  @override
  String get newLeaveRequestErrorInsufficientBalance =>
      'رصيد إجازتك المتبقي غير كافٍ لتغطية هذه التواريخ.';

  @override
  String get newLeaveRequestErrorGeneric => 'حدث خطأ ما. حاول مرة أخرى.';

  @override
  String get myLeaveRequestsFabLabel => 'طلب جديد';
}
