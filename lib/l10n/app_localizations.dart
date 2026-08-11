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

  /// No description provided for @homeLeaveSubtitleUnlimited.
  ///
  /// In en, this message translates to:
  /// **'Used: {used} days (no limit)'**
  String homeLeaveSubtitleUnlimited(int used);

  /// No description provided for @homeLeaveAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get homeLeaveAvailable;

  /// No description provided for @homeLeaveUnlimited.
  ///
  /// In en, this message translates to:
  /// **'Unlimited'**
  String get homeLeaveUnlimited;

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
