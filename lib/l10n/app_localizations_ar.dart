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
  String get settingsTitle => 'الإعدادات';

  @override
  String get settingsLanguage => 'اللغة';

  @override
  String get settingsTheme => 'المظهر';

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
}
