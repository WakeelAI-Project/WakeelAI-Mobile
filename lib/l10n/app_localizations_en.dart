// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Wakeel AI';

  @override
  String get appTagline => 'Your Digital HR & Legal Officer';

  @override
  String get themeShowcaseTitle => 'Design System';

  @override
  String get toggleThemeMode => 'Toggle theme';

  @override
  String get toggleContrast => 'High contrast';

  @override
  String get toggleLanguage => 'العربية';

  @override
  String get aiGeneratedLabel => 'AI-generated';

  @override
  String get citationExample => 'Article 84 · Labor Law 14/2025';

  @override
  String get loginEmailLabel => 'Email';

  @override
  String get loginEmailHint => 'you@company.com';

  @override
  String get loginPasswordLabel => 'Password';

  @override
  String get loginShowPassword => 'Show password';

  @override
  String get loginHidePassword => 'Hide password';

  @override
  String get loginSubmit => 'Log in';

  @override
  String get loginErrorEmailRequired => 'Enter your email';

  @override
  String get loginErrorEmailInvalid => 'Enter a valid email address';

  @override
  String get loginErrorPasswordRequired => 'Enter your password';

  @override
  String get loginErrorPasswordTooShort =>
      'Password must be at least 6 characters';

  @override
  String get loginInvalidCredentials =>
      'Invalid email or password. Please try again.';

  @override
  String get loginAccountInactive =>
      'Your account has been deactivated. Please contact your HR administrator.';

  @override
  String get loginGenericError => 'Something went wrong. Please try again.';

  @override
  String get leaveRequestTitle => 'Submit Leave Request';

  @override
  String get leaveTypeLabel => 'Leave Type';

  @override
  String get leaveTypeAnnual => 'Annual';

  @override
  String get leaveTypeSick => 'Sick';

  @override
  String get leaveTypeUnpaid => 'Unpaid';

  @override
  String get startDateLabel => 'Start Date';

  @override
  String get endDateLabel => 'End Date';

  @override
  String get reasonLabel => 'Reason';

  @override
  String get reasonHint => 'Optional reason for your leave';

  @override
  String get attachmentLabel => 'Medical Report Attachment';

  @override
  String get attachmentRequiredHint =>
      'Required for sick leave (PDF/JPG/PNG, max 10MB)';

  @override
  String get submitButton => 'Submit Request';

  @override
  String get selectDateHint => 'Select date';

  @override
  String get pickFileButton => 'Choose File';

  @override
  String get errorRequiredField => 'This field is required';

  @override
  String get errorEndDateBeforeStartDate => 'End date must be after start date';

  @override
  String get errorAttachmentRequired =>
      'Medical report is required for sick leave';

  @override
  String get successLeaveSubmitted => 'Leave request submitted successfully';
}
