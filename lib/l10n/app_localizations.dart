import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

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
    Locale('en'),
    Locale('zh'),
    Locale.fromSubtags(
      languageCode: 'zh',
      countryCode: 'TW',
      scriptCode: 'Hant',
    ),
  ];

  /// The application title used by the operating system
  ///
  /// In en, this message translates to:
  /// **'Movie Journal'**
  String get appTitle;

  /// Generic action to add an item
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get commonAdd;

  /// Generic action to dismiss without saving
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// Generic destructive action
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// Generic action to finish editing
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get commonDone;

  /// Generic action to edit an item
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get commonEdit;

  /// Generic error prefix followed by opaque error details
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String commonErrorWithDetails({required Object error});

  /// Action to return to the previous screen
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get commonGoBack;

  /// Label for other choices not listed explicitly
  ///
  /// In en, this message translates to:
  /// **'Others'**
  String get commonOthers;

  /// Action to repeat a failed operation
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// Generic action to save changes
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// Generic action to share content
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get commonShare;

  /// Generic action to confirm a choice
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get commonConfirm;

  /// Generic loading label
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get commonLoading;

  /// Fallback display label for a user
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get commonUser;

  /// Fallback label for unavailable information
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get commonUnknown;

  /// Headline on the sign-in screen
  ///
  /// In en, this message translates to:
  /// **'Start your movie journals.'**
  String get loginTitle;

  /// Instructions on the sign-in screen
  ///
  /// In en, this message translates to:
  /// **'Get started by signing in with your\nGoogle or Apple accounts.'**
  String get loginSubtitle;

  /// Google sign-in button
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get loginWithGoogle;

  /// Apple sign-in button
  ///
  /// In en, this message translates to:
  /// **'Sign in with Apple'**
  String get loginWithApple;

  /// Toast shown when provider sign-in fails
  ///
  /// In en, this message translates to:
  /// **'Sign-in failed. Please try again.'**
  String get loginFailed;

  /// Headline on the username creation screen
  ///
  /// In en, this message translates to:
  /// **'Pick a name.'**
  String get createUserTitle;

  /// Supporting copy on the username creation screen
  ///
  /// In en, this message translates to:
  /// **'Tell me more about you.'**
  String get createUserSubtitle;

  /// Label for the username field
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get usernameLabel;

  /// Hint inside the username field
  ///
  /// In en, this message translates to:
  /// **'name or nickname'**
  String get usernameHint;

  /// Action that finishes profile creation
  ///
  /// In en, this message translates to:
  /// **'Start Journaling'**
  String get startJournaling;

  /// Validation error for an empty username
  ///
  /// In en, this message translates to:
  /// **'Username cannot be empty'**
  String get usernameEmpty;

  /// Validation error for invalid username characters
  ///
  /// In en, this message translates to:
  /// **'Username can only contain letters, numbers, _ and .'**
  String get usernameInvalidCharacters;

  /// Validation error for a username made only of punctuation
  ///
  /// In en, this message translates to:
  /// **'Username cannot contain only _ and .'**
  String get usernameOnlySymbols;

  /// Validation error for a username ending in punctuation
  ///
  /// In en, this message translates to:
  /// **'Username cannot end with _ or .'**
  String get usernameTrailingSymbol;

  /// Validation error for a username over 30 characters
  ///
  /// In en, this message translates to:
  /// **'Username cannot be longer than 30 characters'**
  String get usernameTooLong;

  /// Validation error for an unavailable username
  ///
  /// In en, this message translates to:
  /// **'Username already taken. Please choose another one.'**
  String get usernameTaken;

  /// Toast after successfully linking an identity
  ///
  /// In en, this message translates to:
  /// **'Account secured'**
  String get accountSecured;

  /// Toast after identity linking fails
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t secure your account. Please try again.'**
  String get accountSecureFailed;

  /// Persistent warning headline for an anonymous account
  ///
  /// In en, this message translates to:
  /// **'Your account isn\'t secured'**
  String get accountBannerTitle;

  /// Persistent warning explanation for an anonymous account
  ///
  /// In en, this message translates to:
  /// **'Attach Apple or Google so reinstalling the app doesn\'t lose your journals.'**
  String get accountBannerBody;

  /// Generic secure-account sheet headline when journal count is unknown
  ///
  /// In en, this message translates to:
  /// **'Keep your journals safe'**
  String get accountSheetHeadline;

  /// Secure-account sheet headline containing the journal count
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Keep your 1 journal safe} other{Keep your {count} journals safe}}'**
  String accountSheetHeadlineCount({required int count});

  /// Explanation of why an anonymous account should be secured
  ///
  /// In en, this message translates to:
  /// **'They currently live on this device only. Attach an Apple or Google account and you can sign back in after a reinstall, or on a new phone.'**
  String get accountSheetBody;

  /// Button to link a Google identity
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get accountContinueGoogle;

  /// Button to link an Apple identity
  ///
  /// In en, this message translates to:
  /// **'Continue with Apple'**
  String get accountContinueApple;

  /// Action to defer securing an account
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get accountNotNow;

  /// Explanation when an identity belongs to another Fink account
  ///
  /// In en, this message translates to:
  /// **'That {provider} account is already attached to another Fink account, so it can\'t also hold this one. Try {otherProvider} instead — or get in touch and we can join the two accounts for you.'**
  String accountConflict({
    required String provider,
    required String otherProvider,
  });

  /// Tagline on the branded splash screen
  ///
  /// In en, this message translates to:
  /// **'From film to ink,\nBuild your movie journey.'**
  String get onboardingTagline;

  /// Settings screen title
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// Heading above account settings
  ///
  /// In en, this message translates to:
  /// **'ACCOUNT'**
  String get settingsAccountSection;

  /// Action to link an identity to an anonymous account
  ///
  /// In en, this message translates to:
  /// **'Secure Account'**
  String get settingsSecureAccount;

  /// Action and dialog title for signing out
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get settingsLogout;

  /// Action and dialog title for deleting the account
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get settingsDeleteAccount;

  /// Logout warning for an anonymous account tied to one device
  ///
  /// In en, this message translates to:
  /// **'Your account has no Apple or Google sign-in attached yet, so getting back in depends on this device — and reinstalling the app would lose your journals for good. Secure your account first.'**
  String get settingsLogoutDeviceWarning;

  /// Logout confirmation question
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get settingsLogoutConfirmation;

  /// Permanent account deletion warning
  ///
  /// In en, this message translates to:
  /// **'All your data will be permanently deleted.'**
  String get settingsDeleteAccountDescription;

  /// Error shown when account deletion reauthentication fails
  ///
  /// In en, this message translates to:
  /// **'Re-authentication required: {error}'**
  String settingsReauthenticationRequired({required Object error});

  /// Error shown when account deletion fails
  ///
  /// In en, this message translates to:
  /// **'Failed to delete account: {error}'**
  String settingsDeleteAccountFailed({required Object error});

  /// Number of movie journals shown below the username
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 movie journal} other{{count} movie journals}}'**
  String homeJournalCount({required int count});

  /// Headline on the empty home screen
  ///
  /// In en, this message translates to:
  /// **'Your movie journal starts here'**
  String get homeEmptyTitle;

  /// Supporting copy on the empty home screen
  ///
  /// In en, this message translates to:
  /// **'Add your first movie to keep your memories going'**
  String get homeEmptyBody;

  /// Action and screen title for adding a movie journal
  ///
  /// In en, this message translates to:
  /// **'Add Journal'**
  String get addJournal;

  /// Error shown while checking whether a user profile exists
  ///
  /// In en, this message translates to:
  /// **'Error checking user: {error}'**
  String homeErrorCheckingUser({required Object error});

  /// Error shown when journals cannot be loaded
  ///
  /// In en, this message translates to:
  /// **'Error loading journals: {error}'**
  String homeErrorLoadingJournals({required Object error});

  /// Hint in the movie search field
  ///
  /// In en, this message translates to:
  /// **'Search movie'**
  String get searchMovieHint;

  /// Heading above the list of popular movies
  ///
  /// In en, this message translates to:
  /// **'People watched'**
  String get searchPopularHeader;

  /// Error shown when a movie list cannot be loaded
  ///
  /// In en, this message translates to:
  /// **'Error loading movies'**
  String get searchErrorLoadingMovies;

  /// Error shown when movie details cannot be loaded
  ///
  /// In en, this message translates to:
  /// **'Error loading movie'**
  String get moviePreviewErrorLoading;

  /// Prompt above the movie rating control
  ///
  /// In en, this message translates to:
  /// **'How much did you enjoy this movie?'**
  String get ratingPrompt;

  /// Accessibility label for one rating value
  ///
  /// In en, this message translates to:
  /// **'{value} out of {max}'**
  String ratingSemantics({required int value, required int max});

  /// Prompt above the emotion selector
  ///
  /// In en, this message translates to:
  /// **'What are your feelings about this movie?'**
  String get emotionsPrompt;

  /// Empty-state action in the emotion selector
  ///
  /// In en, this message translates to:
  /// **'Select Emotions'**
  String get emotionsSelect;

  /// Text before styled English emotion names
  ///
  /// In en, this message translates to:
  /// **'You felt '**
  String get emotionsSummaryPrefix;

  /// Text after styled English emotion names
  ///
  /// In en, this message translates to:
  /// **' by this movie.'**
  String get emotionsSummarySuffix;

  /// Separator between non-final English emotion names
  ///
  /// In en, this message translates to:
  /// **', '**
  String get emotionsListSeparator;

  /// Separator before the final English emotion name
  ///
  /// In en, this message translates to:
  /// **' and '**
  String get emotionsListFinalSeparator;

  /// Current count for a selector with a maximum
  ///
  /// In en, this message translates to:
  /// **'Select up to {limit} ({selected}/{limit})'**
  String selectionUpToStatus({required int limit, required int selected});

  /// Error shown when too many emotions are selected
  ///
  /// In en, this message translates to:
  /// **'You can select up to {limit} emotions'**
  String emotionsSelectionLimit({required int limit});

  /// Title of the scene selector
  ///
  /// In en, this message translates to:
  /// **'Scenes'**
  String get scenesTitle;

  /// Prompt above selected movie scenes
  ///
  /// In en, this message translates to:
  /// **'What are the memorable scenes?'**
  String get scenesPrompt;

  /// Action to select movie scenes
  ///
  /// In en, this message translates to:
  /// **'+  Add Scenes'**
  String get scenesAdd;

  /// Action to add a single movie scene
  ///
  /// In en, this message translates to:
  /// **'Add Scene'**
  String get sceneAdd;

  /// Title when TMDB has no scene images
  ///
  /// In en, this message translates to:
  /// **'Scene missing!'**
  String get scenesMissingTitle;

  /// Explanation when TMDB has no scene images
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t find any scene photos for this movie.'**
  String get scenesMissingBody;

  /// Supporting line when no scene images are available
  ///
  /// In en, this message translates to:
  /// **'Keep this one in your memory. ✨'**
  String get scenesMissingTagline;

  /// Error in a single scene image
  ///
  /// In en, this message translates to:
  /// **'Error loading image'**
  String get sceneErrorLoadingImage;

  /// Error while loading scene images
  ///
  /// In en, this message translates to:
  /// **'Error loading images'**
  String get sceneErrorLoadingImages;

  /// Error shown when too many scenes are selected
  ///
  /// In en, this message translates to:
  /// **'You can select up to {limit} scenes'**
  String scenesSelectionLimit({required int limit});

  /// Hint for a scene caption
  ///
  /// In en, this message translates to:
  /// **'Add a caption...'**
  String get sceneCaptionHint;

  /// Action to expand truncated text
  ///
  /// In en, this message translates to:
  /// **'more'**
  String get commonMore;

  /// Title of the thoughts editor
  ///
  /// In en, this message translates to:
  /// **'Thoughts'**
  String get thoughtsTitle;

  /// Prompt above the thoughts editor
  ///
  /// In en, this message translates to:
  /// **'Write down your thoughts & feelings.'**
  String get thoughtsPrompt;

  /// Hint in the thoughts editor
  ///
  /// In en, this message translates to:
  /// **'Enter your text here...'**
  String get thoughtsHint;

  /// Action to add a generated review to thoughts
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get thoughtsAdd;

  /// Current position in a set of items
  ///
  /// In en, this message translates to:
  /// **'{current} of {total}'**
  String itemPosition({required int current, required int total});

  /// Title of the generated reviews sheet
  ///
  /// In en, this message translates to:
  /// **'Movie Reviews'**
  String get reviewsTitle;

  /// Short label for movie reviews
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get reviewsLabel;

  /// Explanation of AI-generated review summaries
  ///
  /// In en, this message translates to:
  /// **'We summarized reviews from Letterboxd and Reddit with AI, add these insights to your notes!'**
  String get reviewsDescription;

  /// Empty state when no generated reviews are available
  ///
  /// In en, this message translates to:
  /// **'No reviews generated'**
  String get reviewsEmpty;

  /// Success message after saving a journal
  ///
  /// In en, this message translates to:
  /// **'You\'ve saved a journal'**
  String get journalSaved;

  /// Action to share a journal ticket
  ///
  /// In en, this message translates to:
  /// **'Share Ticket'**
  String get shareTicket;

  /// Action to open a saved journal
  ///
  /// In en, this message translates to:
  /// **'View Journal'**
  String get viewJournal;

  /// Success toast after updating a journal
  ///
  /// In en, this message translates to:
  /// **'Your journal has been updated.'**
  String get journalUpdated;

  /// Error toast after a journal cannot be saved
  ///
  /// In en, this message translates to:
  /// **'Failed to save journal. Please try again.'**
  String get journalSaveFailed;

  /// Title of the journal deletion dialog
  ///
  /// In en, this message translates to:
  /// **'Delete Journal'**
  String get journalDeleteTitle;

  /// Journal deletion confirmation question
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this journal?'**
  String get journalDeleteConfirmation;

  /// Success toast after deleting a journal
  ///
  /// In en, this message translates to:
  /// **'Journal deleted successfully'**
  String get journalDeleted;

  /// Error toast after a journal cannot be deleted
  ///
  /// In en, this message translates to:
  /// **'Failed to delete journal'**
  String get journalDeleteFailed;

  /// Title of the discard changes dialog
  ///
  /// In en, this message translates to:
  /// **'Discard Changes'**
  String get discardChangesTitle;

  /// Warning shown before discarding journal edits
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to discard the changes? All changes will not be saved.'**
  String get discardChangesDescription;

  /// Action to discard journal edits
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discardChangesAction;

  /// Poster filter for the movie's original language
  ///
  /// In en, this message translates to:
  /// **'Original Language'**
  String get posterOriginalLanguage;

  /// Title of the ticket poster picker
  ///
  /// In en, this message translates to:
  /// **'Choose a Ticket Poster'**
  String get posterPickerTitle;

  /// Empty state when no ticket posters are available
  ///
  /// In en, this message translates to:
  /// **'No posters available'**
  String get posterPickerEmpty;

  /// Heading above journal thoughts in the share sheet
  ///
  /// In en, this message translates to:
  /// **'Copy text to post on Social'**
  String get shareCopySocial;

  /// Heading above destinations in the share sheet
  ///
  /// In en, this message translates to:
  /// **'Share Option'**
  String get shareOptionsTitle;

  /// Instagram Story destination label
  ///
  /// In en, this message translates to:
  /// **'Story'**
  String get shareStory;

  /// Success toast after copying journal thoughts
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard'**
  String get shareCopiedToClipboard;

  /// Action to copy journal thoughts
  ///
  /// In en, this message translates to:
  /// **'Copy Text'**
  String get shareCopyText;

  /// Error after photo-library permission is denied
  ///
  /// In en, this message translates to:
  /// **'Photo library access denied'**
  String get sharePhotoAccessDenied;

  /// Success toast after saving a ticket image
  ///
  /// In en, this message translates to:
  /// **'Image saved to camera roll'**
  String get shareImageSaved;

  /// Error toast after a ticket image cannot be saved
  ///
  /// In en, this message translates to:
  /// **'Failed to save image'**
  String get shareImageSaveFailed;

  /// Error when Instagram cannot be opened
  ///
  /// In en, this message translates to:
  /// **'Could not open Instagram. Is it installed?'**
  String get shareInstagramUnavailable;

  /// Error when Threads is not installed
  ///
  /// In en, this message translates to:
  /// **'Could not open Threads. Is it installed?'**
  String get shareThreadsUnavailable;

  /// Generic error when Threads cannot be opened
  ///
  /// In en, this message translates to:
  /// **'Could not open Threads'**
  String get shareThreadsFailed;

  /// Brand line on the back of a journal ticket
  ///
  /// In en, this message translates to:
  /// **'FINK MOVIE JOURNAL'**
  String get ticketBrand;

  /// Ticket number on the back of a journal ticket
  ///
  /// In en, this message translates to:
  /// **'NO. {number}'**
  String ticketNumber({required int number});

  /// Movie title field label on a journal ticket
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get ticketTitle;

  /// Release date field label on a journal ticket
  ///
  /// In en, this message translates to:
  /// **'Release'**
  String get ticketRelease;

  /// Director field label on a journal ticket
  ///
  /// In en, this message translates to:
  /// **'Director'**
  String get ticketDirector;

  /// Cast field label on a journal ticket
  ///
  /// In en, this message translates to:
  /// **'Cast'**
  String get ticketCast;

  /// Emotion field label on a journal ticket
  ///
  /// In en, this message translates to:
  /// **'Emotion'**
  String get ticketEmotion;

  /// Journal date field label on a journal ticket
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get ticketDate;

  /// Journal time field label on a journal ticket
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get ticketTime;
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
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+script+country codes are specified.
  switch (locale.toString()) {
    case 'zh_Hant_TW':
      return AppLocalizationsZhHantTw();
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
