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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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

  /// The application name shown in title bars and app switchers
  ///
  /// In en, this message translates to:
  /// **'Wakeel AI'**
  String get appName;

  /// Short tagline shown under the app name
  ///
  /// In en, this message translates to:
  /// **'Your Digital HR & Legal Officer'**
  String get appTagline;

  /// Title of the internal theme/token showcase screen
  ///
  /// In en, this message translates to:
  /// **'Design System'**
  String get themeShowcaseTitle;

  /// Button label to cycle light/dark/system theme mode
  ///
  /// In en, this message translates to:
  /// **'Toggle theme'**
  String get toggleThemeMode;

  /// Switch label to enable high-contrast mode
  ///
  /// In en, this message translates to:
  /// **'High contrast'**
  String get toggleContrast;

  /// Button label to switch the app language to Arabic
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get toggleLanguage;

  /// Badge label marking content produced by the AI, as opposed to authoritative/human content
  ///
  /// In en, this message translates to:
  /// **'AI-generated'**
  String get aiGeneratedLabel;

  /// Sample law citation shown next to the seal citation marker
  ///
  /// In en, this message translates to:
  /// **'Article 84 · Labor Law 14/2025'**
  String get citationExample;

  /// Label for the email field on the login screen
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get loginEmailLabel;

  /// Placeholder hint for the email field on the login screen
  ///
  /// In en, this message translates to:
  /// **'you@company.com'**
  String get loginEmailHint;

  /// Label for the password field on the login screen
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get loginPasswordLabel;

  /// Accessible name for the button that reveals the password
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get loginShowPassword;

  /// Accessible name for the button that hides the password
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get loginHidePassword;

  /// Submit button label on the login screen
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get loginSubmit;

  /// Validation error when the email field is left empty
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get loginErrorEmailRequired;

  /// Validation error when the email field isn't a valid email
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get loginErrorEmailInvalid;

  /// Validation error when the password field is left empty
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get loginErrorPasswordRequired;

  /// Validation error when the password is shorter than the minimum length
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get loginErrorPasswordTooShort;

  /// Error banner shown on the login screen when the login attempt is rejected
  ///
  /// In en, this message translates to:
  /// **'Invalid email or password. Please try again.'**
  String get loginInvalidCredentials;

  /// Error banner shown when the account has been deactivated by an Owner/HR manager
  ///
  /// In en, this message translates to:
  /// **'Your account has been deactivated. Please contact your HR administrator.'**
  String get loginAccountInactive;

  /// Error banner shown when a Company Owner or HR Manager account tries to sign in on the mobile app
  ///
  /// In en, this message translates to:
  /// **'This app is for employees only. Company Owner and HR Manager accounts should sign in from the web dashboard.'**
  String get loginRoleNotAllowed;

  /// Error banner shown for network/server failures during login
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get loginGenericError;

  /// Success banner shown on the login screen after a forced first-login password change completes
  ///
  /// In en, this message translates to:
  /// **'Password changed. Please log in with your new password.'**
  String get loginPasswordChangedMessage;

  /// Title of the forced first-login change-password screen
  ///
  /// In en, this message translates to:
  /// **'Set your password'**
  String get changePasswordTitle;

  /// Explanatory subtitle on the forced first-login change-password screen
  ///
  /// In en, this message translates to:
  /// **'This is your first time signing in. Choose a new password to finish setting up your account.'**
  String get changePasswordSubtitle;

  /// Label for the current/temp password field on the change-password screen
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get changePasswordCurrentPasswordLabel;

  /// Validation error when the current password field is left empty
  ///
  /// In en, this message translates to:
  /// **'Enter your current password'**
  String get changePasswordErrorCurrentPasswordRequired;

  /// Label for the new password field on the change-password screen
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get changePasswordNewPasswordLabel;

  /// Label for the confirm-new-password field on the change-password screen
  ///
  /// In en, this message translates to:
  /// **'Confirm new password'**
  String get changePasswordConfirmPasswordLabel;

  /// Submit button label on the change-password screen
  ///
  /// In en, this message translates to:
  /// **'Set password'**
  String get changePasswordSubmit;

  /// Validation error when the new password field is left empty
  ///
  /// In en, this message translates to:
  /// **'Enter a new password'**
  String get changePasswordErrorPasswordRequired;

  /// Validation error when the new password is shorter than the minimum length
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get changePasswordErrorPasswordTooShort;

  /// Validation error when the confirm-password field doesn't match the new password field
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get changePasswordErrorPasswordMismatch;

  /// Error banner shown when the backend rejects the temp/current password
  ///
  /// In en, this message translates to:
  /// **'Your temporary password is no longer valid. Please log in again.'**
  String get changePasswordInvalidCurrentPassword;

  /// Error banner shown when the backend can't find the user for this token
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t find your account. Please log in again.'**
  String get changePasswordUserNotFound;

  /// Error banner shown for network/server failures during change-password
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get changePasswordGenericError;

  /// Clickable link on the login screen leading to the forgot-password screen
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get loginForgotPasswordLink;

  /// Title of the forgot-password screen
  ///
  /// In en, this message translates to:
  /// **'Reset your password'**
  String get forgotPasswordTitle;

  /// Explanatory subtitle on the forgot-password screen
  ///
  /// In en, this message translates to:
  /// **'Enter the email associated with your account and we\'ll send you a 6-digit code to reset your password.'**
  String get forgotPasswordSubtitle;

  /// Submit button label on the forgot-password screen
  ///
  /// In en, this message translates to:
  /// **'Send code'**
  String get forgotPasswordSubmit;

  /// Error banner shown when the forgot-password endpoint rate-limits the request
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Please wait a while before trying again.'**
  String get forgotPasswordTooManyRequests;

  /// Error banner shown for network/server failures during forgot-password
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get forgotPasswordGenericError;

  /// Title of the standalone OTP-entry screen
  ///
  /// In en, this message translates to:
  /// **'Enter verification code'**
  String get verifyOtpTitle;

  /// Explanatory subtitle on the OTP-entry screen
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code sent to {email}.'**
  String verifyOtpSubtitle(String email);

  /// Submit button label on the OTP-entry screen
  ///
  /// In en, this message translates to:
  /// **'Verify code'**
  String get verifyOtpSubmit;

  /// Button label to request a new OTP
  ///
  /// In en, this message translates to:
  /// **'Resend code'**
  String get verifyOtpResendCode;

  /// Disabled resend-code label showing the cooldown remaining
  ///
  /// In en, this message translates to:
  /// **'Resend code in {seconds}s'**
  String verifyOtpResendCodeCountdown(int seconds);

  /// Confirmation shown after successfully requesting a new OTP
  ///
  /// In en, this message translates to:
  /// **'A new code has been sent.'**
  String get verifyOtpResendSuccess;

  /// Error banner shown when the submitted OTP doesn't match
  ///
  /// In en, this message translates to:
  /// **'Incorrect code. Please try again.'**
  String get verifyOtpErrorInvalidOtp;

  /// Error banner shown when the OTP is correct but past its validity window
  ///
  /// In en, this message translates to:
  /// **'This code has expired. Request a new one.'**
  String get verifyOtpErrorOtpExpired;

  /// Error banner shown after too many wrong OTP submissions
  ///
  /// In en, this message translates to:
  /// **'Too many incorrect attempts. Please request a new code.'**
  String get verifyOtpErrorTooManyAttempts;

  /// Error banner shown for network/server failures during OTP verification
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get verifyOtpErrorGeneric;

  /// Title of the new-password screen, shown after OTP verification
  ///
  /// In en, this message translates to:
  /// **'Set new password'**
  String get newPasswordTitle;

  /// Explanatory subtitle on the new-password screen
  ///
  /// In en, this message translates to:
  /// **'Choose a new password for your account.'**
  String get newPasswordSubtitle;

  /// Submit button label on the new-password screen
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get newPasswordSubmit;

  /// Error banner shown if the OTP was invalidated between verification and this final submit
  ///
  /// In en, this message translates to:
  /// **'Your code is no longer valid. Please request a new one.'**
  String get newPasswordErrorInvalidOtp;

  /// Error banner shown if the OTP expired between verification and this final submit
  ///
  /// In en, this message translates to:
  /// **'Your code has expired. Please request a new one.'**
  String get newPasswordErrorOtpExpired;

  /// Error banner shown after too many wrong OTP submissions
  ///
  /// In en, this message translates to:
  /// **'Too many incorrect attempts. Please request a new code.'**
  String get newPasswordErrorTooManyAttempts;

  /// Error banner shown when the backend rejects the new password as malformed
  ///
  /// In en, this message translates to:
  /// **'Check your new password and try again.'**
  String get newPasswordErrorValidation;

  /// Error banner shown for network/server failures while setting the new password
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get newPasswordErrorGeneric;

  /// Title of the dialog shown when a forced logout is triggered by a failed token refresh
  ///
  /// In en, this message translates to:
  /// **'Session expired'**
  String get sessionExpiredTitle;

  /// Body text of the session-expired dialog
  ///
  /// In en, this message translates to:
  /// **'Your session has expired. Please log in again.'**
  String get sessionExpiredMessage;

  /// Dismiss button on the session-expired dialog
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get sessionExpiredOk;

  /// Title of the dialog shown when a newer app version is available for download
  ///
  /// In en, this message translates to:
  /// **'Update available'**
  String get updateAvailableTitle;

  /// Body text of the update-available dialog
  ///
  /// In en, this message translates to:
  /// **'A new version of Wakeel AI is available. Download it to get the latest features and fixes.'**
  String get updateAvailableMessage;

  /// Button on the update-available dialog that opens the download link
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get updateAvailableDownload;

  /// Button on the update-available dialog that dismisses it without downloading
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get updateAvailableLater;

  /// No description provided for @stillWorkingNotice.
  ///
  /// In en, this message translates to:
  /// **'Still working… the server may be waking up.'**
  String get stillWorkingNotice;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navChat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get navChat;

  /// No description provided for @navLeaves.
  ///
  /// In en, this message translates to:
  /// **'Leaves'**
  String get navLeaves;

  /// No description provided for @navDocs.
  ///
  /// In en, this message translates to:
  /// **'Docs'**
  String get navDocs;

  /// No description provided for @homeLeaveBalances.
  ///
  /// In en, this message translates to:
  /// **'LEAVE BALANCES'**
  String get homeLeaveBalances;

  /// No description provided for @homeQuickActions.
  ///
  /// In en, this message translates to:
  /// **'QUICK ACTIONS'**
  String get homeQuickActions;

  /// No description provided for @homeGreetingMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get homeGreetingMorning;

  /// No description provided for @homeGreetingAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get homeGreetingAfternoon;

  /// No description provided for @homeGreetingEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get homeGreetingEvening;

  /// No description provided for @homeLeaveLowBalance.
  ///
  /// In en, this message translates to:
  /// **'Low balance'**
  String get homeLeaveLowBalance;

  /// No description provided for @homeLeaveNoneLeft.
  ///
  /// In en, this message translates to:
  /// **'None left'**
  String get homeLeaveNoneLeft;

  /// No description provided for @homeLeaveSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{remaining} of {total} days left'**
  String homeLeaveSubtitle(int remaining, int total);

  /// No description provided for @homeLeaveSubtitleNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'No entitlement granted'**
  String get homeLeaveSubtitleNotAvailable;

  /// No description provided for @homeLeaveAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get homeLeaveAvailable;

  /// No description provided for @homeLeaveNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Not available'**
  String get homeLeaveNotAvailable;

  /// No description provided for @homeLeaveUnlimited.
  ///
  /// In en, this message translates to:
  /// **'Unlimited'**
  String get homeLeaveUnlimited;

  /// No description provided for @homeLeaveSubtitleUnlimited.
  ///
  /// In en, this message translates to:
  /// **'{used} days used · no cap'**
  String homeLeaveSubtitleUnlimited(int used);

  /// No description provided for @homeCurrentLeaveTitle.
  ///
  /// In en, this message translates to:
  /// **'On Leave Now'**
  String get homeCurrentLeaveTitle;

  /// No description provided for @homeCurrentLeaveSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{leaveType} — Day {elapsed} of {total}'**
  String homeCurrentLeaveSubtitle(String leaveType, int elapsed, int total);

  /// No description provided for @leaveTypeAnnual.
  ///
  /// In en, this message translates to:
  /// **'Annual'**
  String get leaveTypeAnnual;

  /// No description provided for @leaveTypeSick.
  ///
  /// In en, this message translates to:
  /// **'Sick'**
  String get leaveTypeSick;

  /// No description provided for @leaveTypeUnpaid.
  ///
  /// In en, this message translates to:
  /// **'Unpaid'**
  String get leaveTypeUnpaid;

  /// No description provided for @quickActionChat.
  ///
  /// In en, this message translates to:
  /// **'Ask the assistant'**
  String get quickActionChat;

  /// No description provided for @quickActionLeaves.
  ///
  /// In en, this message translates to:
  /// **'My Leave Requests'**
  String get quickActionLeaves;

  /// No description provided for @quickActionDocs.
  ///
  /// In en, this message translates to:
  /// **'My Documents'**
  String get quickActionDocs;

  /// No description provided for @quickActionProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get quickActionProfile;

  /// No description provided for @welcomeGreeting.
  ///
  /// In en, this message translates to:
  /// **'Hello'**
  String get welcomeGreeting;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get profileTitle;

  /// No description provided for @profileEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get profileEmailLabel;

  /// No description provided for @profileDepartmentLabel.
  ///
  /// In en, this message translates to:
  /// **'Department'**
  String get profileDepartmentLabel;

  /// No description provided for @profileHireDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Hire Date'**
  String get profileHireDateLabel;

  /// No description provided for @profileSalaryLabel.
  ///
  /// In en, this message translates to:
  /// **'Salary'**
  String get profileSalaryLabel;

  /// No description provided for @profileFailedToLoad.
  ///
  /// In en, this message translates to:
  /// **'Failed to load profile'**
  String get profileFailedToLoad;

  /// No description provided for @profilePhotoSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Profile Photo'**
  String get profilePhotoSheetTitle;

  /// No description provided for @profilePhotoTakePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get profilePhotoTakePhoto;

  /// No description provided for @profilePhotoChooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from Gallery'**
  String get profilePhotoChooseFromGallery;

  /// No description provided for @profilePhotoRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove Profile Photo'**
  String get profilePhotoRemove;

  /// No description provided for @profilePhotoCropTitle.
  ///
  /// In en, this message translates to:
  /// **'Crop Photo'**
  String get profilePhotoCropTitle;

  /// No description provided for @profilePhotoUploadError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t update your photo. Please try again.'**
  String get profilePhotoUploadError;

  /// No description provided for @profilePhotoRemoveError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t remove your photo. Please try again.'**
  String get profilePhotoRemoveError;

  /// No description provided for @profilePhotoTooLarge.
  ///
  /// In en, this message translates to:
  /// **'Photo is too large. Please choose a smaller image.'**
  String get profilePhotoTooLarge;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @themeHighContrast.
  ///
  /// In en, this message translates to:
  /// **'High contrast'**
  String get themeHighContrast;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logout;

  /// No description provided for @logoutConfirmationTitle.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logoutConfirmationTitle;

  /// No description provided for @logoutConfirmationDesc.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get logoutConfirmationDesc;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @newLeaveRequestTitle.
  ///
  /// In en, this message translates to:
  /// **'Request Leave'**
  String get newLeaveRequestTitle;

  /// No description provided for @newLeaveRequestTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Leave Type'**
  String get newLeaveRequestTypeLabel;

  /// No description provided for @newLeaveRequestStartDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get newLeaveRequestStartDateLabel;

  /// No description provided for @newLeaveRequestEndDateLabel.
  ///
  /// In en, this message translates to:
  /// **'End Date'**
  String get newLeaveRequestEndDateLabel;

  /// No description provided for @newLeaveRequestSelectDateHint.
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get newLeaveRequestSelectDateHint;

  /// Computed days-requested summary shown once both dates are picked
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 day requested} other{{count} days requested}}'**
  String newLeaveRequestDaysSummary(int count);

  /// No description provided for @newLeaveRequestReasonLabel.
  ///
  /// In en, this message translates to:
  /// **'Reason (optional)'**
  String get newLeaveRequestReasonLabel;

  /// No description provided for @newLeaveRequestReasonHint.
  ///
  /// In en, this message translates to:
  /// **'Add any additional details...'**
  String get newLeaveRequestReasonHint;

  /// No description provided for @newLeaveRequestAttachmentLabel.
  ///
  /// In en, this message translates to:
  /// **'Medical Report'**
  String get newLeaveRequestAttachmentLabel;

  /// No description provided for @newLeaveRequestAttachmentButton.
  ///
  /// In en, this message translates to:
  /// **'Choose File'**
  String get newLeaveRequestAttachmentButton;

  /// No description provided for @newLeaveRequestAttachmentRequiredHint.
  ///
  /// In en, this message translates to:
  /// **'A medical report is required for sick leave'**
  String get newLeaveRequestAttachmentRequiredHint;

  /// No description provided for @newLeaveRequestSubmitButton.
  ///
  /// In en, this message translates to:
  /// **'Submit Request'**
  String get newLeaveRequestSubmitButton;

  /// No description provided for @newLeaveRequestErrorRequiredDates.
  ///
  /// In en, this message translates to:
  /// **'Select both a start and end date'**
  String get newLeaveRequestErrorRequiredDates;

  /// No description provided for @newLeaveRequestErrorEndBeforeStart.
  ///
  /// In en, this message translates to:
  /// **'End date must be after the start date'**
  String get newLeaveRequestErrorEndBeforeStart;

  /// No description provided for @newLeaveRequestErrorAttachmentRequired.
  ///
  /// In en, this message translates to:
  /// **'Please attach a medical report for sick leave'**
  String get newLeaveRequestErrorAttachmentRequired;

  /// No description provided for @newLeaveRequestErrorAttachmentTooLarge.
  ///
  /// In en, this message translates to:
  /// **'Attachment exceeds the 10 MB size limit'**
  String get newLeaveRequestErrorAttachmentTooLarge;

  /// No description provided for @newLeaveRequestSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Leave request submitted'**
  String get newLeaveRequestSuccessMessage;

  /// No description provided for @newLeaveRequestSavedNotSubmittedMessage.
  ///
  /// In en, this message translates to:
  /// **'Your request was saved as a draft but could not be submitted. Open it from your requests list and press Submit.'**
  String get newLeaveRequestSavedNotSubmittedMessage;

  /// No description provided for @newLeaveRequestErrorValidation.
  ///
  /// In en, this message translates to:
  /// **'Check the request details and try again.'**
  String get newLeaveRequestErrorValidation;

  /// No description provided for @newLeaveRequestErrorInsufficientBalance.
  ///
  /// In en, this message translates to:
  /// **'Your remaining leave balance isn\'t enough to cover these dates.'**
  String get newLeaveRequestErrorInsufficientBalance;

  /// No description provided for @newLeaveRequestErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get newLeaveRequestErrorGeneric;

  /// No description provided for @myLeaveRequestsFabLabel.
  ///
  /// In en, this message translates to:
  /// **'New Request'**
  String get myLeaveRequestsFabLabel;

  /// No description provided for @leaveRequestDraftNotSentHint.
  ///
  /// In en, this message translates to:
  /// **'This draft hasn\'t been sent to HR yet.'**
  String get leaveRequestDraftNotSentHint;

  /// No description provided for @leaveRequestSubmitButton.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get leaveRequestSubmitButton;

  /// No description provided for @leaveRequestWithdrawButton.
  ///
  /// In en, this message translates to:
  /// **'Withdraw request'**
  String get leaveRequestWithdrawButton;

  /// No description provided for @leaveRequestWithdrawConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Withdraw request'**
  String get leaveRequestWithdrawConfirmTitle;

  /// No description provided for @leaveRequestWithdrawConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'This request will be withdrawn before HR reviews it, and any reserved leave balance released. You can submit a new request afterwards.'**
  String get leaveRequestWithdrawConfirmMessage;

  /// No description provided for @leaveRequestWithdrawConfirmAction.
  ///
  /// In en, this message translates to:
  /// **'Withdraw'**
  String get leaveRequestWithdrawConfirmAction;

  /// No description provided for @chatDrawerNewChat.
  ///
  /// In en, this message translates to:
  /// **'New Chat'**
  String get chatDrawerNewChat;

  /// No description provided for @chatDrawerRecentConversations.
  ///
  /// In en, this message translates to:
  /// **'Recent Conversations'**
  String get chatDrawerRecentConversations;

  /// No description provided for @chatDrawerNoPreviousChats.
  ///
  /// In en, this message translates to:
  /// **'No previous chats.'**
  String get chatDrawerNoPreviousChats;

  /// No description provided for @chatDrawerToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get chatDrawerToday;

  /// No description provided for @chatDrawerYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get chatDrawerYesterday;

  /// No description provided for @chatDrawerPrevious7Days.
  ///
  /// In en, this message translates to:
  /// **'Previous 7 Days'**
  String get chatDrawerPrevious7Days;

  /// No description provided for @chatDrawerOlder.
  ///
  /// In en, this message translates to:
  /// **'Older'**
  String get chatDrawerOlder;

  /// No description provided for @chatComposerPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Message Wakeel AI...'**
  String get chatComposerPlaceholder;

  /// No description provided for @chatEmptyStateTitle.
  ///
  /// In en, this message translates to:
  /// **'How can I help you today?'**
  String get chatEmptyStateTitle;

  /// No description provided for @chatSamplePromptLeaveBalance.
  ///
  /// In en, this message translates to:
  /// **'What is my leave balance?'**
  String get chatSamplePromptLeaveBalance;

  /// No description provided for @chatScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Ask Wakeel AI'**
  String get chatScreenTitle;

  /// No description provided for @chatBubbleFailedToSend.
  ///
  /// In en, this message translates to:
  /// **'Failed to send. Please try again.'**
  String get chatBubbleFailedToSend;
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
