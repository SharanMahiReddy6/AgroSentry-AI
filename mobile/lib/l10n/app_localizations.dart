import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_te.dart';

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
    Locale('en'),
    Locale('hi'),
    Locale('te')
  ];

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @scan.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get scan;

  /// No description provided for @adminPortal.
  ///
  /// In en, this message translates to:
  /// **'Admin Portal'**
  String get adminPortal;

  /// No description provided for @quickTips.
  ///
  /// In en, this message translates to:
  /// **'Quick Tips'**
  String get quickTips;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @recentScans.
  ///
  /// In en, this message translates to:
  /// **'Recent Scans'**
  String get recentScans;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'LANGUAGE'**
  String get language;

  /// No description provided for @sendOtp.
  ///
  /// In en, this message translates to:
  /// **'Send OTP'**
  String get sendOtp;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @verify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verify;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @library.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get library;

  /// No description provided for @backToLogin.
  ///
  /// In en, this message translates to:
  /// **'Back to Login'**
  String get backToLogin;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @agrosentry.
  ///
  /// In en, this message translates to:
  /// **'AgroSentry'**
  String get agrosentry;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @uploadCustomAiDatasetZip.
  ///
  /// In en, this message translates to:
  /// **'Upload Custom AI Dataset (ZIP)'**
  String get uploadCustomAiDatasetZip;

  /// No description provided for @cropTarget.
  ///
  /// In en, this message translates to:
  /// **'Crop Target'**
  String get cropTarget;

  /// No description provided for @others.
  ///
  /// In en, this message translates to:
  /// **'Others...'**
  String get others;

  /// No description provided for @isFullDataset.
  ///
  /// In en, this message translates to:
  /// **'Is Full Dataset?'**
  String get isFullDataset;

  /// No description provided for @toggleOffForNewDiseaseClass.
  ///
  /// In en, this message translates to:
  /// **'Toggle OFF for new disease class'**
  String get toggleOffForNewDiseaseClass;

  /// No description provided for @uploadPrepareDataset.
  ///
  /// In en, this message translates to:
  /// **'Upload & Prepare Dataset'**
  String get uploadPrepareDataset;

  /// No description provided for @initializeLocalDatasetTrainingJob.
  ///
  /// In en, this message translates to:
  /// **'Initialize Local Dataset Training Job'**
  String get initializeLocalDatasetTrainingJob;

  /// No description provided for @selectDatasetCategory.
  ///
  /// In en, this message translates to:
  /// **'Select Dataset Category'**
  String get selectDatasetCategory;

  /// No description provided for @startTrainingPipeline.
  ///
  /// In en, this message translates to:
  /// **'Start Training Pipeline'**
  String get startTrainingPipeline;

  /// No description provided for @completedActiveModelCheckpoints.
  ///
  /// In en, this message translates to:
  /// **'Completed & Active Model Checkpoints'**
  String get completedActiveModelCheckpoints;

  /// No description provided for @deploy.
  ///
  /// In en, this message translates to:
  /// **'Deploy'**
  String get deploy;

  /// No description provided for @noPendingTips.
  ///
  /// In en, this message translates to:
  /// **'No pending tips.'**
  String get noPendingTips;

  /// No description provided for @reject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get reject;

  /// No description provided for @approve.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get approve;

  /// No description provided for @broadcastNotifications.
  ///
  /// In en, this message translates to:
  /// **'Broadcast Notifications'**
  String get broadcastNotifications;

  /// No description provided for @targetRecipients.
  ///
  /// In en, this message translates to:
  /// **'Target Recipients'**
  String get targetRecipients;

  /// No description provided for @allUsers.
  ///
  /// In en, this message translates to:
  /// **'All Users'**
  String get allUsers;

  /// No description provided for @dispatchBroadcastAlert.
  ///
  /// In en, this message translates to:
  /// **'Dispatch Broadcast Alert'**
  String get dispatchBroadcastAlert;

  /// No description provided for @diseaseLibraryManagement.
  ///
  /// In en, this message translates to:
  /// **'Disease Library Management'**
  String get diseaseLibraryManagement;

  /// No description provided for @mockFormNoBackendApiIntegrationRequired.
  ///
  /// In en, this message translates to:
  /// **'Mock form. No backend API integration required.'**
  String get mockFormNoBackendApiIntegrationRequired;

  /// No description provided for @publishToDiseaseLibrary.
  ///
  /// In en, this message translates to:
  /// **'Publish to Disease Library'**
  String get publishToDiseaseLibrary;

  /// No description provided for @superadminWorkspace.
  ///
  /// In en, this message translates to:
  /// **'Super-Admin Workspace'**
  String get superadminWorkspace;

  /// No description provided for @newCropName.
  ///
  /// In en, this message translates to:
  /// **'New Crop Name'**
  String get newCropName;

  /// No description provided for @newDiseaseFolderName.
  ///
  /// In en, this message translates to:
  /// **'New Disease Folder Name'**
  String get newDiseaseFolderName;

  /// No description provided for @epochCountIterations.
  ///
  /// In en, this message translates to:
  /// **'Epoch Count (Iterations)'**
  String get epochCountIterations;

  /// No description provided for @alertHeadline.
  ///
  /// In en, this message translates to:
  /// **'Alert Headline'**
  String get alertHeadline;

  /// No description provided for @detailedMessage.
  ///
  /// In en, this message translates to:
  /// **'Detailed Message'**
  String get detailedMessage;

  /// No description provided for @cropType.
  ///
  /// In en, this message translates to:
  /// **'Crop Type'**
  String get cropType;

  /// No description provided for @diseaseName.
  ///
  /// In en, this message translates to:
  /// **'Disease Name'**
  String get diseaseName;

  /// No description provided for @scientificName.
  ///
  /// In en, this message translates to:
  /// **'Scientific Name'**
  String get scientificName;

  /// No description provided for @overviewSymptoms.
  ///
  /// In en, this message translates to:
  /// **'Overview / Symptoms'**
  String get overviewSymptoms;

  /// No description provided for @aiModels.
  ///
  /// In en, this message translates to:
  /// **'AI Models'**
  String get aiModels;

  /// No description provided for @users.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get users;

  /// No description provided for @tipsQueue.
  ///
  /// In en, this message translates to:
  /// **'Tips Queue'**
  String get tipsQueue;

  /// No description provided for @broadcast.
  ///
  /// In en, this message translates to:
  /// **'Broadcast'**
  String get broadcast;

  /// No description provided for @enterYourEmailAddressAndWeWillSendYouAnO.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address and we will send you an OTP to reset your password.'**
  String get enterYourEmailAddressAndWeWillSendYouAnO;

  /// No description provided for @welcomeToAgrosentry.
  ///
  /// In en, this message translates to:
  /// **'Welcome to AgroSentry'**
  String get welcomeToAgrosentry;

  /// No description provided for @signInToContinue.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue'**
  String get signInToContinue;

  /// No description provided for @registrationSuccessfulPleaseSignIn.
  ///
  /// In en, this message translates to:
  /// **'Registration successful. Please sign in.'**
  String get registrationSuccessfulPleaseSignIn;

  /// No description provided for @joinAgrosentry.
  ///
  /// In en, this message translates to:
  /// **'Join AgroSentry'**
  String get joinAgrosentry;

  /// No description provided for @createYourFreeAccount.
  ///
  /// In en, this message translates to:
  /// **'Create your free account'**
  String get createYourFreeAccount;

  /// No description provided for @passwordMustBeAtLeast8CharactersLongCont.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters long, contain an uppercase letter, and a number.'**
  String get passwordMustBeAtLeast8CharactersLongCont;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @stateRegion.
  ///
  /// In en, this message translates to:
  /// **'State / Region'**
  String get stateRegion;

  /// No description provided for @city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// No description provided for @primaryCropEgAppleRice.
  ///
  /// In en, this message translates to:
  /// **'Primary Crop (e.g. Apple, Rice)'**
  String get primaryCropEgAppleRice;

  /// No description provided for @passwordResetSuccessfulPleaseSignIn.
  ///
  /// In en, this message translates to:
  /// **'Password reset successful. Please sign in.'**
  String get passwordResetSuccessfulPleaseSignIn;

  /// No description provided for @setNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Set New Password'**
  String get setNewPassword;

  /// No description provided for @createNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Create New Password'**
  String get createNewPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @enterVerificationCode.
  ///
  /// In en, this message translates to:
  /// **'Enter Verification Code'**
  String get enterVerificationCode;

  /// No description provided for @verifyOtp.
  ///
  /// In en, this message translates to:
  /// **'Verify OTP'**
  String get verifyOtp;

  /// No description provided for @overview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overview;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @oopsConnectionLost.
  ///
  /// In en, this message translates to:
  /// **'Oops! Connection Lost'**
  String get oopsConnectionLost;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @totalScans.
  ///
  /// In en, this message translates to:
  /// **'Total Scans'**
  String get totalScans;

  /// No description provided for @healthyPlants.
  ///
  /// In en, this message translates to:
  /// **'Healthy Plants'**
  String get healthyPlants;

  /// No description provided for @diseasedPlants.
  ///
  /// In en, this message translates to:
  /// **'Diseased Plants'**
  String get diseasedPlants;

  /// No description provided for @avgAccuracy.
  ///
  /// In en, this message translates to:
  /// **'Avg. Accuracy'**
  String get avgAccuracy;

  /// No description provided for @tips.
  ///
  /// In en, this message translates to:
  /// **'Tips'**
  String get tips;

  /// No description provided for @yourDashboardWillUpdateOnceYouCompleteYo.
  ///
  /// In en, this message translates to:
  /// **'Your dashboard will update once you complete your first crop scan.'**
  String get yourDashboardWillUpdateOnceYouCompleteYo;

  /// No description provided for @startFirstScan.
  ///
  /// In en, this message translates to:
  /// **'Start First Scan'**
  String get startFirstScan;

  /// No description provided for @emptyDashboardStateNoDataAvailable.
  ///
  /// In en, this message translates to:
  /// **'Empty Dashboard State. No data available.'**
  String get emptyDashboardStateNoDataAvailable;

  /// No description provided for @deleteScan.
  ///
  /// In en, this message translates to:
  /// **'Delete scan'**
  String get deleteScan;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @scanDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Scan deleted successfully.'**
  String get scanDeletedSuccessfully;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @noScansYet.
  ///
  /// In en, this message translates to:
  /// **'No Scans Yet'**
  String get noScansYet;

  /// No description provided for @yourPreviousPlantDiseaseScansWillAppearH.
  ///
  /// In en, this message translates to:
  /// **'Your previous plant disease scans will appear here.'**
  String get yourPreviousPlantDiseaseScansWillAppearH;

  /// No description provided for @startScanning.
  ///
  /// In en, this message translates to:
  /// **'Start Scanning'**
  String get startScanning;

  /// No description provided for @scanHistory.
  ///
  /// In en, this message translates to:
  /// **'Scan History'**
  String get scanHistory;

  /// No description provided for @lowSeverity.
  ///
  /// In en, this message translates to:
  /// **'Low Severity'**
  String get lowSeverity;

  /// No description provided for @mediumSeverity.
  ///
  /// In en, this message translates to:
  /// **'Medium Severity'**
  String get mediumSeverity;

  /// No description provided for @highSeverity.
  ///
  /// In en, this message translates to:
  /// **'High Severity'**
  String get highSeverity;

  /// No description provided for @noSpecificTreatmentsAvailableForThisSeve.
  ///
  /// In en, this message translates to:
  /// **'No specific treatments available for this severity level.'**
  String get noSpecificTreatmentsAvailableForThisSeve;

  /// No description provided for @organicTreatment.
  ///
  /// In en, this message translates to:
  /// **'Organic Treatment'**
  String get organicTreatment;

  /// No description provided for @chemicalTreatment.
  ///
  /// In en, this message translates to:
  /// **'Chemical Treatment'**
  String get chemicalTreatment;

  /// No description provided for @preventiveMeasures.
  ///
  /// In en, this message translates to:
  /// **'Preventive Measures'**
  String get preventiveMeasures;

  /// No description provided for @diseaseDetails.
  ///
  /// In en, this message translates to:
  /// **'Disease Details'**
  String get diseaseDetails;

  /// No description provided for @organicTreatments.
  ///
  /// In en, this message translates to:
  /// **'Organic Treatments'**
  String get organicTreatments;

  /// No description provided for @chemicalTreatments.
  ///
  /// In en, this message translates to:
  /// **'Chemical Treatments'**
  String get chemicalTreatments;

  /// No description provided for @healthy.
  ///
  /// In en, this message translates to:
  /// **'Healthy'**
  String get healthy;

  /// No description provided for @diseased.
  ///
  /// In en, this message translates to:
  /// **'Diseased'**
  String get diseased;

  /// No description provided for @failedToLoadLibrary.
  ///
  /// In en, this message translates to:
  /// **'Failed to load library'**
  String get failedToLoadLibrary;

  /// No description provided for @diseaseLibrary.
  ///
  /// In en, this message translates to:
  /// **'Disease Library'**
  String get diseaseLibrary;

  /// No description provided for @searchByDiseaseScientificNameOrCrop.
  ///
  /// In en, this message translates to:
  /// **'Search by disease, scientific name, or crop...'**
  String get searchByDiseaseScientificNameOrCrop;

  /// No description provided for @searchDiseaseLibrary.
  ///
  /// In en, this message translates to:
  /// **'Search disease library'**
  String get searchDiseaseLibrary;

  /// No description provided for @filterByHealthStatus.
  ///
  /// In en, this message translates to:
  /// **'Filter by health status'**
  String get filterByHealthStatus;

  /// No description provided for @filterByDiseasedStatus.
  ///
  /// In en, this message translates to:
  /// **'Filter by diseased status'**
  String get filterByDiseasedStatus;

  /// No description provided for @noDiseasesFound.
  ///
  /// In en, this message translates to:
  /// **'No diseases found'**
  String get noDiseasesFound;

  /// No description provided for @failedToLoadNotifications.
  ///
  /// In en, this message translates to:
  /// **'Failed to load notifications'**
  String get failedToLoadNotifications;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @noNotifications.
  ///
  /// In en, this message translates to:
  /// **'No notifications'**
  String get noNotifications;

  /// No description provided for @urgent.
  ///
  /// In en, this message translates to:
  /// **'URGENT'**
  String get urgent;

  /// No description provided for @viewRelatedScan.
  ///
  /// In en, this message translates to:
  /// **'View Related Scan'**
  String get viewRelatedScan;

  /// No description provided for @notificationDetails.
  ///
  /// In en, this message translates to:
  /// **'Notification Details'**
  String get notificationDetails;

  /// No description provided for @profileSavedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Profile saved successfully.'**
  String get profileSavedSuccessfully;

  /// No description provided for @failedToSaveProfile.
  ///
  /// In en, this message translates to:
  /// **'Failed to save profile.'**
  String get failedToSaveProfile;

  /// No description provided for @preferencesSavedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Preferences saved successfully.'**
  String get preferencesSavedSuccessfully;

  /// No description provided for @failedToSavePreferences.
  ///
  /// In en, this message translates to:
  /// **'Failed to save preferences.'**
  String get failedToSavePreferences;

  /// No description provided for @newPasswordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'New passwords do not match.'**
  String get newPasswordsDoNotMatch;

  /// No description provided for @passwordMustBeAtLeast6Characters.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters.'**
  String get passwordMustBeAtLeast6Characters;

  /// No description provided for @passwordChangedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully.'**
  String get passwordChangedSuccessfully;

  /// No description provided for @failedToChangePassword.
  ///
  /// In en, this message translates to:
  /// **'Failed to change password.'**
  String get failedToChangePassword;

  /// No description provided for @photoUpdated.
  ///
  /// In en, this message translates to:
  /// **'Photo updated.'**
  String get photoUpdated;

  /// No description provided for @failedToUpdatePhoto.
  ///
  /// In en, this message translates to:
  /// **'Failed to update photo.'**
  String get failedToUpdatePhoto;

  /// No description provided for @photoRemoved.
  ///
  /// In en, this message translates to:
  /// **'Photo removed.'**
  String get photoRemoved;

  /// No description provided for @failedToRemovePhoto.
  ///
  /// In en, this message translates to:
  /// **'Failed to remove photo.'**
  String get failedToRemovePhoto;

  /// No description provided for @removePhoto.
  ///
  /// In en, this message translates to:
  /// **'Remove photo'**
  String get removePhoto;

  /// No description provided for @personalInformation.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInformation;

  /// No description provided for @updateYourNameContactDetailsAndFarmingPr.
  ///
  /// In en, this message translates to:
  /// **'Update your name, contact details, and farming profile.'**
  String get updateYourNameContactDetailsAndFarmingPr;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @useAStrongUniquePasswordToProtectYourAcc.
  ///
  /// In en, this message translates to:
  /// **'Use a strong, unique password to protect your account.'**
  String get useAStrongUniquePasswordToProtectYourAcc;

  /// No description provided for @updatePassword.
  ///
  /// In en, this message translates to:
  /// **'Update Password'**
  String get updatePassword;

  /// No description provided for @appPreferences.
  ///
  /// In en, this message translates to:
  /// **'App Preferences'**
  String get appPreferences;

  /// No description provided for @chooseYourDisplayThemeAndLanguageSetting.
  ///
  /// In en, this message translates to:
  /// **'Choose your display theme and language settings.'**
  String get chooseYourDisplayThemeAndLanguageSetting;

  /// No description provided for @interfaceTheme.
  ///
  /// In en, this message translates to:
  /// **'INTERFACE THEME'**
  String get interfaceTheme;

  /// No description provided for @englishDefault.
  ///
  /// In en, this message translates to:
  /// **'English (Default)'**
  String get englishDefault;

  /// No description provided for @telugu.
  ///
  /// In en, this message translates to:
  /// **'తెలుగు (Telugu)'**
  String get telugu;

  /// No description provided for @hindi.
  ///
  /// In en, this message translates to:
  /// **'हिन्दी (Hindi)'**
  String get hindi;

  /// No description provided for @tamil.
  ///
  /// In en, this message translates to:
  /// **'தமிழ் (Tamil)'**
  String get tamil;

  /// No description provided for @malayalam.
  ///
  /// In en, this message translates to:
  /// **'മലയാളം (Malayalam)'**
  String get malayalam;

  /// No description provided for @kannada.
  ///
  /// In en, this message translates to:
  /// **'ಕನ್ನಡ (Kannada)'**
  String get kannada;

  /// No description provided for @savePreferences.
  ///
  /// In en, this message translates to:
  /// **'Save Preferences'**
  String get savePreferences;

  /// No description provided for @accountSettings.
  ///
  /// In en, this message translates to:
  /// **'Account Settings'**
  String get accountSettings;

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get lightMode;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddress;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @farmingRegionState.
  ///
  /// In en, this message translates to:
  /// **'Farming Region (State)'**
  String get farmingRegionState;

  /// No description provided for @locationCity.
  ///
  /// In en, this message translates to:
  /// **'Location / City'**
  String get locationCity;

  /// No description provided for @primaryCrop.
  ///
  /// In en, this message translates to:
  /// **'Primary Crop'**
  String get primaryCrop;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get currentPassword;

  /// No description provided for @confirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm New Password'**
  String get confirmNewPassword;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @personal.
  ///
  /// In en, this message translates to:
  /// **'Personal'**
  String get personal;

  /// No description provided for @security.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get security;

  /// No description provided for @preferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences;

  /// No description provided for @loadingScanDetails.
  ///
  /// In en, this message translates to:
  /// **'Loading scan details...'**
  String get loadingScanDetails;

  /// No description provided for @scanResultNotFoundOrExpired.
  ///
  /// In en, this message translates to:
  /// **'Scan result not found or expired.'**
  String get scanResultNotFoundOrExpired;

  /// No description provided for @backToDashboard.
  ///
  /// In en, this message translates to:
  /// **'Back to Dashboard'**
  String get backToDashboard;

  /// No description provided for @scanAnotherPlant.
  ///
  /// In en, this message translates to:
  /// **'Scan Another Plant'**
  String get scanAnotherPlant;

  /// No description provided for @savedToHistory.
  ///
  /// In en, this message translates to:
  /// **'Saved to history.'**
  String get savedToHistory;

  /// No description provided for @saveResult.
  ///
  /// In en, this message translates to:
  /// **'Save Result'**
  String get saveResult;

  /// No description provided for @scanResult.
  ///
  /// In en, this message translates to:
  /// **'Scan Result'**
  String get scanResult;

  /// No description provided for @visualAnalysisImagesShowingGradcamAndLes.
  ///
  /// In en, this message translates to:
  /// **'Visual analysis images showing Grad-CAM and Lesion Spotlight'**
  String get visualAnalysisImagesShowingGradcamAndLes;

  /// No description provided for @treatmentSectionOrganicTreatment.
  ///
  /// In en, this message translates to:
  /// **'Treatment section: Organic Treatment'**
  String get treatmentSectionOrganicTreatment;

  /// No description provided for @treatmentSectionChemicalTreatment.
  ///
  /// In en, this message translates to:
  /// **'Treatment section: Chemical Treatment'**
  String get treatmentSectionChemicalTreatment;

  /// No description provided for @uploadFailed.
  ///
  /// In en, this message translates to:
  /// **'Upload Failed'**
  String get uploadFailed;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @selectCropType.
  ///
  /// In en, this message translates to:
  /// **'Select Crop Type'**
  String get selectCropType;

  /// No description provided for @analyzingTissuePatterns.
  ///
  /// In en, this message translates to:
  /// **'Analyzing Tissue Patterns...'**
  String get analyzingTissuePatterns;

  /// No description provided for @cancelUpload.
  ///
  /// In en, this message translates to:
  /// **'Cancel Upload'**
  String get cancelUpload;

  /// No description provided for @analyzePlant.
  ///
  /// In en, this message translates to:
  /// **'Analyze Plant'**
  String get analyzePlant;

  /// No description provided for @noImageSelected.
  ///
  /// In en, this message translates to:
  /// **'No image selected'**
  String get noImageSelected;

  /// No description provided for @scanPlant.
  ///
  /// In en, this message translates to:
  /// **'Scan Plant'**
  String get scanPlant;

  /// No description provided for @submitTip.
  ///
  /// In en, this message translates to:
  /// **'Submit Tip'**
  String get submitTip;

  /// No description provided for @featuredTips.
  ///
  /// In en, this message translates to:
  /// **'Featured Tips'**
  String get featuredTips;

  /// No description provided for @recentTips.
  ///
  /// In en, this message translates to:
  /// **'Recent Tips'**
  String get recentTips;

  /// No description provided for @failedToLoadTips.
  ///
  /// In en, this message translates to:
  /// **'Failed to load tips'**
  String get failedToLoadTips;

  /// No description provided for @submitAQuickTip.
  ///
  /// In en, this message translates to:
  /// **'Submit a Quick Tip'**
  String get submitAQuickTip;

  /// No description provided for @failedToSubmitTipPleaseCheckAllFields.
  ///
  /// In en, this message translates to:
  /// **'Failed to submit tip. Please check all fields.'**
  String get failedToSubmitTipPleaseCheckAllFields;

  /// No description provided for @searchByTitleCategory.
  ///
  /// In en, this message translates to:
  /// **'Search by title, category...'**
  String get searchByTitleCategory;

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @briefContent.
  ///
  /// In en, this message translates to:
  /// **'Brief Content'**
  String get briefContent;

  /// No description provided for @detailedExplanation.
  ///
  /// In en, this message translates to:
  /// **'Detailed Explanation'**
  String get detailedExplanation;

  /// No description provided for @searchQuickTips.
  ///
  /// In en, this message translates to:
  /// **'Search quick tips'**
  String get searchQuickTips;

  /// No description provided for @noTipsFound.
  ///
  /// In en, this message translates to:
  /// **'No tips found'**
  String get noTipsFound;

  /// No description provided for @detailedInformation.
  ///
  /// In en, this message translates to:
  /// **'Detailed Information'**
  String get detailedInformation;

  /// No description provided for @tipDetails.
  ///
  /// In en, this message translates to:
  /// **'Tip Details'**
  String get tipDetails;
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
      <String>['en', 'hi', 'te'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
    case 'te':
      return AppLocalizationsTe();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
