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
  String get loginPasswordChangedMessage =>
      'Password changed. Please log in with your new password.';

  @override
  String get changePasswordTitle => 'Set your password';

  @override
  String get changePasswordSubtitle =>
      'This is your first time signing in. Choose a new password to finish setting up your account.';

  @override
  String get changePasswordCurrentPasswordLabel => 'Current password';

  @override
  String get changePasswordErrorCurrentPasswordRequired =>
      'Enter your current password';

  @override
  String get changePasswordNewPasswordLabel => 'New password';

  @override
  String get changePasswordConfirmPasswordLabel => 'Confirm new password';

  @override
  String get changePasswordSubmit => 'Set password';

  @override
  String get changePasswordErrorPasswordRequired => 'Enter a new password';

  @override
  String get changePasswordErrorPasswordTooShort =>
      'Password must be at least 8 characters';

  @override
  String get changePasswordErrorPasswordMismatch => 'Passwords do not match';

  @override
  String get changePasswordInvalidCurrentPassword =>
      'Your temporary password is no longer valid. Please log in again.';

  @override
  String get changePasswordUserNotFound =>
      'We couldn\'t find your account. Please log in again.';

  @override
  String get changePasswordGenericError =>
      'Something went wrong. Please try again.';

  @override
  String get loginForgotPasswordLink => 'Forgot password?';

  @override
  String get forgotPasswordTitle => 'Reset your password';

  @override
  String get forgotPasswordSubtitle =>
      'Enter the email associated with your account and we\'ll send you a 6-digit code to reset your password.';

  @override
  String get forgotPasswordSubmit => 'Send code';

  @override
  String get forgotPasswordTooManyRequests =>
      'Too many attempts. Please wait a while before trying again.';

  @override
  String get forgotPasswordGenericError =>
      'Something went wrong. Please try again.';

  @override
  String get verifyOtpTitle => 'Enter verification code';

  @override
  String verifyOtpSubtitle(String email) {
    return 'Enter the 6-digit code sent to $email.';
  }

  @override
  String get verifyOtpSubmit => 'Verify code';

  @override
  String get verifyOtpResendCode => 'Resend code';

  @override
  String verifyOtpResendCodeCountdown(int seconds) {
    return 'Resend code in ${seconds}s';
  }

  @override
  String get verifyOtpResendSuccess => 'A new code has been sent.';

  @override
  String get verifyOtpErrorInvalidOtp => 'Incorrect code. Please try again.';

  @override
  String get verifyOtpErrorOtpExpired =>
      'This code has expired. Request a new one.';

  @override
  String get verifyOtpErrorTooManyAttempts =>
      'Too many incorrect attempts. Please request a new code.';

  @override
  String get verifyOtpErrorGeneric => 'Something went wrong. Please try again.';

  @override
  String get newPasswordTitle => 'Set new password';

  @override
  String get newPasswordSubtitle => 'Choose a new password for your account.';

  @override
  String get newPasswordSubmit => 'Reset password';

  @override
  String get newPasswordErrorInvalidOtp =>
      'Your code is no longer valid. Please request a new one.';

  @override
  String get newPasswordErrorOtpExpired =>
      'Your code has expired. Please request a new one.';

  @override
  String get newPasswordErrorTooManyAttempts =>
      'Too many incorrect attempts. Please request a new code.';

  @override
  String get newPasswordErrorValidation =>
      'Check your new password and try again.';

  @override
  String get newPasswordErrorGeneric =>
      'Something went wrong. Please try again.';

  @override
  String get sessionExpiredTitle => 'Session expired';

  @override
  String get sessionExpiredMessage =>
      'Your session has expired. Please log in again.';

  @override
  String get sessionExpiredOk => 'OK';

  @override
  String get updateAvailableTitle => 'Update available';

  @override
  String get updateAvailableMessage =>
      'A new version of Wakeel AI is available. Download it to get the latest features and fixes.';

  @override
  String get updateAvailableDownload => 'Download';

  @override
  String get updateAvailableLater => 'Later';

  @override
  String get stillWorkingNotice =>
      'Still working… the server may be waking up.';

  @override
  String get navHome => 'Home';

  @override
  String get navChat => 'Chat';

  @override
  String get navLeaves => 'Leaves';

  @override
  String get navDocs => 'Docs';

  @override
  String get homeLeaveBalances => 'LEAVE BALANCES';

  @override
  String get homeQuickActions => 'QUICK ACTIONS';

  @override
  String get homeGreetingMorning => 'Good morning';

  @override
  String get homeGreetingAfternoon => 'Good afternoon';

  @override
  String get homeGreetingEvening => 'Good evening';

  @override
  String get homeLeaveLowBalance => 'Low balance';

  @override
  String get homeLeaveNoneLeft => 'None left';

  @override
  String homeLeaveSubtitle(int remaining, int total) {
    return '$remaining of $total days left';
  }

  @override
  String get homeLeaveSubtitleNotAvailable => 'No entitlement granted';

  @override
  String get homeLeaveAvailable => 'Available';

  @override
  String get homeLeaveNotAvailable => 'Not available';

  @override
  String get homeLeaveUnlimited => 'Unlimited';

  @override
  String homeLeaveSubtitleUnlimited(int used) {
    return '$used days used · no cap';
  }

  @override
  String get homeCurrentLeaveTitle => 'On Leave Now';

  @override
  String homeCurrentLeaveSubtitle(String leaveType, int elapsed, int total) {
    return '$leaveType — Day $elapsed of $total';
  }

  @override
  String get leaveTypeAnnual => 'Annual';

  @override
  String get leaveTypeSick => 'Sick';

  @override
  String get leaveTypeUnpaid => 'Unpaid';

  @override
  String get quickActionChat => 'Ask the assistant';

  @override
  String get quickActionLeaves => 'My Leave Requests';

  @override
  String get quickActionDocs => 'My Documents';

  @override
  String get quickActionProfile => 'Profile';

  @override
  String get welcomeGreeting => 'Hello';

  @override
  String get profileTitle => 'My Profile';

  @override
  String get profileEmailLabel => 'Email';

  @override
  String get profileDepartmentLabel => 'Department';

  @override
  String get profileHireDateLabel => 'Hire Date';

  @override
  String get profileSalaryLabel => 'Salary';

  @override
  String get profileFailedToLoad => 'Failed to load profile';

  @override
  String get profilePhotoSheetTitle => 'Add Profile Photo';

  @override
  String get profilePhotoTakePhoto => 'Take Photo';

  @override
  String get profilePhotoChooseFromGallery => 'Choose from Gallery';

  @override
  String get profilePhotoRemove => 'Remove Profile Photo';

  @override
  String get profilePhotoCropTitle => 'Crop Photo';

  @override
  String get profilePhotoUploadError =>
      'Couldn\'t update your photo. Please try again.';

  @override
  String get profilePhotoRemoveError =>
      'Couldn\'t remove your photo. Please try again.';

  @override
  String get profilePhotoTooLarge =>
      'Photo is too large. Please choose a smaller image.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeHighContrast => 'High contrast';

  @override
  String get logout => 'Log out';

  @override
  String get logoutConfirmationTitle => 'Log Out';

  @override
  String get logoutConfirmationDesc => 'Are you sure you want to log out?';

  @override
  String get cancel => 'Cancel';

  @override
  String get newLeaveRequestTitle => 'Request Leave';

  @override
  String get newLeaveRequestTypeLabel => 'Leave Type';

  @override
  String get newLeaveRequestStartDateLabel => 'Start Date';

  @override
  String get newLeaveRequestEndDateLabel => 'End Date';

  @override
  String get newLeaveRequestSelectDateHint => 'Select date';

  @override
  String newLeaveRequestDaysSummary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days requested',
      one: '1 day requested',
    );
    return '$_temp0';
  }

  @override
  String get newLeaveRequestReasonLabel => 'Reason (optional)';

  @override
  String get newLeaveRequestReasonHint => 'Add any additional details...';

  @override
  String get newLeaveRequestAttachmentLabel => 'Medical Report';

  @override
  String get newLeaveRequestAttachmentButton => 'Choose File';

  @override
  String get newLeaveRequestAttachmentRequiredHint =>
      'A medical report is required for sick leave';

  @override
  String get newLeaveRequestSubmitButton => 'Submit Request';

  @override
  String get newLeaveRequestErrorRequiredDates =>
      'Select both a start and end date';

  @override
  String get newLeaveRequestErrorEndBeforeStart =>
      'End date must be after the start date';

  @override
  String get newLeaveRequestErrorAttachmentRequired =>
      'Please attach a medical report for sick leave';

  @override
  String get newLeaveRequestErrorAttachmentTooLarge =>
      'Attachment exceeds the 10 MB size limit';

  @override
  String get newLeaveRequestSuccessMessage => 'Leave request submitted';

  @override
  String get newLeaveRequestSavedNotSubmittedMessage =>
      'Your request was saved as a draft but could not be submitted. Open it from your requests list and press Submit.';

  @override
  String get newLeaveRequestErrorValidation =>
      'Check the request details and try again.';

  @override
  String get newLeaveRequestErrorInsufficientBalance =>
      'Your remaining leave balance isn\'t enough to cover these dates.';

  @override
  String get newLeaveRequestErrorGeneric =>
      'Something went wrong. Please try again.';

  @override
  String get myLeaveRequestsFabLabel => 'New Request';

  @override
  String get leaveRequestDraftNotSentHint =>
      'This draft hasn\'t been sent to HR yet.';

  @override
  String get leaveRequestSubmitButton => 'Submit';

  @override
  String get leaveRequestWithdrawButton => 'Withdraw request';

  @override
  String get leaveRequestWithdrawConfirmTitle => 'Withdraw request';

  @override
  String get leaveRequestWithdrawConfirmMessage =>
      'This request will be withdrawn before HR reviews it, and any reserved leave balance released. You can submit a new request afterwards.';

  @override
  String get leaveRequestWithdrawConfirmAction => 'Withdraw';

  @override
  String get chatDrawerNewChat => 'New Chat';

  @override
  String get chatDrawerRecentConversations => 'Recent Conversations';

  @override
  String get chatDrawerNoPreviousChats => 'No previous chats.';

  @override
  String get chatDrawerToday => 'Today';

  @override
  String get chatDrawerYesterday => 'Yesterday';

  @override
  String get chatDrawerPrevious7Days => 'Previous 7 Days';

  @override
  String get chatDrawerOlder => 'Older';

  @override
  String get chatComposerPlaceholder => 'Message Wakeel AI...';

  @override
  String get chatEmptyStateTitle => 'How can I help you today?';

  @override
  String get chatSamplePromptLeaveBalance => 'What is my leave balance?';

  @override
  String get chatScreenTitle => 'Ask Wakeel AI';

  @override
  String get chatBubbleFailedToSend => 'Failed to send. Please try again.';
}
