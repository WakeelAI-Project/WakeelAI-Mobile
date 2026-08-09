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
  String get leaveRequestTitle => 'تقديم طلب إجازة';

  @override
  String get leaveTypeLabel => 'نوع الإجازة';

  @override
  String get leaveTypeAnnual => 'سنوية';

  @override
  String get leaveTypeSick => 'مرضية';

  @override
  String get leaveTypeUnpaid => 'بدون أجر';

  @override
  String get startDateLabel => 'تاريخ البداية';

  @override
  String get endDateLabel => 'تاريخ النهاية';

  @override
  String get reasonLabel => 'السبب';

  @override
  String get reasonHint => 'سبب اختياري للإجازة';

  @override
  String get attachmentLabel => 'مرفق التقرير الطبي';

  @override
  String get attachmentRequiredHint =>
      'مطلوب للإجازة المرضية (PDF/JPG/PNG، بحد أقصى 10MB)';

  @override
  String get submitButton => 'تقديم الطلب';

  @override
  String get selectDateHint => 'اختر التاريخ';

  @override
  String get pickFileButton => 'اختر ملف';

  @override
  String get errorRequiredField => 'هذا الحقل مطلوب';

  @override
  String get errorEndDateBeforeStartDate =>
      'يجب أن يكون تاريخ النهاية بعد تاريخ البداية';

  @override
  String get errorAttachmentRequired => 'التقرير الطبي مطلوب للإجازة المرضية';

  @override
  String get successLeaveSubmitted => 'تم تقديم طلب الإجازة بنجاح';
}
