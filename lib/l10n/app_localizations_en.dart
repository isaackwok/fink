// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Movie Journal';

  @override
  String get commonAdd => 'Add';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonDone => 'Done';

  @override
  String get commonEdit => 'Edit';

  @override
  String commonErrorWithDetails({required Object error}) {
    return 'Error: $error';
  }

  @override
  String get commonGoBack => 'Go Back';

  @override
  String get commonOthers => 'Others';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonSave => 'Save';

  @override
  String get commonShare => 'Share';

  @override
  String get commonConfirm => 'Confirm';

  @override
  String get commonLoading => 'Loading...';

  @override
  String get commonUser => 'User';

  @override
  String get commonUnknown => 'Unknown';

  @override
  String get loginTitle => 'Start your movie journals.';

  @override
  String get loginSubtitle =>
      'Get started by signing in with your\nGoogle or Apple accounts.';

  @override
  String get loginWithGoogle => 'Sign in with Google';

  @override
  String get loginWithApple => 'Sign in with Apple';

  @override
  String get loginFailed => 'Sign-in failed. Please try again.';

  @override
  String get createUserTitle => 'Pick a name.';

  @override
  String get createUserSubtitle => 'Tell me more about you.';

  @override
  String get usernameLabel => 'Username';

  @override
  String get usernameHint => 'name or nickname';

  @override
  String get startJournaling => 'Start Journaling';

  @override
  String get usernameEmpty => 'Username cannot be empty';

  @override
  String get usernameInvalidCharacters =>
      'Username can only contain letters, numbers, _ and .';

  @override
  String get usernameOnlySymbols => 'Username cannot contain only _ and .';

  @override
  String get usernameTrailingSymbol => 'Username cannot end with _ or .';

  @override
  String get usernameTooLong => 'Username cannot be longer than 30 characters';

  @override
  String get usernameTaken =>
      'Username already taken. Please choose another one.';

  @override
  String get accountSecured => 'Account secured';

  @override
  String get accountSecureFailed =>
      'Couldn\'t secure your account. Please try again.';

  @override
  String get accountBannerTitle => 'Your account isn\'t secured';

  @override
  String get accountBannerBody =>
      'Attach Apple or Google so reinstalling the app doesn\'t lose your journals.';

  @override
  String get accountSheetHeadline => 'Keep your journals safe';

  @override
  String accountSheetHeadlineCount({required int count}) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Keep your $count journals safe',
      one: 'Keep your 1 journal safe',
    );
    return '$_temp0';
  }

  @override
  String get accountSheetBody =>
      'They currently live on this device only. Attach an Apple or Google account and you can sign back in after a reinstall, or on a new phone.';

  @override
  String get accountContinueGoogle => 'Continue with Google';

  @override
  String get accountContinueApple => 'Continue with Apple';

  @override
  String get accountNotNow => 'Not now';

  @override
  String accountConflict({
    required String provider,
    required String otherProvider,
  }) {
    return 'That $provider account is already attached to another Fink account, so it can\'t also hold this one. Try $otherProvider instead — or get in touch and we can join the two accounts for you.';
  }

  @override
  String get onboardingTagline =>
      'From film to ink,\nBuild your movie journey.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsAccountSection => 'ACCOUNT';

  @override
  String get settingsSecureAccount => 'Secure Account';

  @override
  String get settingsLogout => 'Logout';

  @override
  String get settingsDeleteAccount => 'Delete Account';

  @override
  String get settingsLogoutDeviceWarning =>
      'Your account has no Apple or Google sign-in attached yet, so getting back in depends on this device — and reinstalling the app would lose your journals for good. Secure your account first.';

  @override
  String get settingsLogoutConfirmation => 'Are you sure you want to logout?';

  @override
  String get settingsDeleteAccountDescription =>
      'All your data will be permanently deleted.';

  @override
  String settingsReauthenticationRequired({required Object error}) {
    return 'Re-authentication required: $error';
  }

  @override
  String settingsDeleteAccountFailed({required Object error}) {
    return 'Failed to delete account: $error';
  }

  @override
  String homeJournalCount({required int count}) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count movie journals',
      one: '1 movie journal',
    );
    return '$_temp0';
  }

  @override
  String get homeEmptyTitle => 'Your movie journal starts here';

  @override
  String get homeEmptyBody =>
      'Add your first movie to keep your memories going';

  @override
  String get addJournal => 'Add Journal';

  @override
  String homeErrorCheckingUser({required Object error}) {
    return 'Error checking user: $error';
  }

  @override
  String homeErrorLoadingJournals({required Object error}) {
    return 'Error loading journals: $error';
  }

  @override
  String get searchMovieHint => 'Search movie';

  @override
  String get searchPopularHeader => 'People watched';

  @override
  String get searchErrorLoadingMovies => 'Error loading movies';

  @override
  String get moviePreviewErrorLoading => 'Error loading movie';

  @override
  String get ratingPrompt => 'How much did you enjoy this movie?';

  @override
  String ratingSemantics({required int value, required int max}) {
    return '$value out of $max';
  }

  @override
  String get emotionsPrompt => 'What are your feelings about this movie?';

  @override
  String get emotionsSelect => 'Select Emotions';

  @override
  String get emotionsSummaryPrefix => 'You felt ';

  @override
  String get emotionsSummarySuffix => ' by this movie.';

  @override
  String get emotionsListSeparator => ', ';

  @override
  String get emotionsListFinalSeparator => ' and ';

  @override
  String selectionUpToStatus({required int limit, required int selected}) {
    return 'Select up to $limit ($selected/$limit)';
  }

  @override
  String emotionsSelectionLimit({required int limit}) {
    return 'You can select up to $limit emotions';
  }

  @override
  String get scenesTitle => 'Scenes';

  @override
  String get scenesPrompt => 'What are the memorable scenes?';

  @override
  String get scenesAdd => '+  Add Scenes';

  @override
  String get sceneAdd => 'Add Scene';

  @override
  String get scenesMissingTitle => 'Scene missing!';

  @override
  String get scenesMissingBody =>
      'We couldn\'t find any scene photos for this movie.';

  @override
  String get scenesMissingTagline => 'Keep this one in your memory. ✨';

  @override
  String get sceneErrorLoadingImage => 'Error loading image';

  @override
  String get sceneErrorLoadingImages => 'Error loading images';

  @override
  String scenesSelectionLimit({required int limit}) {
    return 'You can select up to $limit scenes';
  }

  @override
  String get sceneCaptionHint => 'Add a caption...';

  @override
  String get commonMore => 'more';

  @override
  String get thoughtsTitle => 'Thoughts';

  @override
  String get thoughtsPrompt => 'Write down your thoughts & feelings.';

  @override
  String get thoughtsHint => 'Enter your text here...';

  @override
  String get thoughtsAdd => 'Add';

  @override
  String itemPosition({required int current, required int total}) {
    return '$current of $total';
  }

  @override
  String get reviewsTitle => 'Movie Reviews';

  @override
  String get reviewsLabel => 'Reviews';

  @override
  String get reviewsDescription =>
      'We summarized reviews from Letterboxd and Reddit with AI, add these insights to your notes!';

  @override
  String get reviewsEmpty => 'No reviews generated';

  @override
  String get journalSaved => 'You\'ve saved a journal';

  @override
  String get shareTicket => 'Share Ticket';

  @override
  String get viewJournal => 'View Journal';

  @override
  String get journalUpdated => 'Your journal has been updated.';

  @override
  String get journalSaveFailed => 'Failed to save journal. Please try again.';

  @override
  String get journalDeleteTitle => 'Delete Journal';

  @override
  String get journalDeleteConfirmation =>
      'Are you sure you want to delete this journal?';

  @override
  String get journalDeleted => 'Journal deleted successfully';

  @override
  String get journalDeleteFailed => 'Failed to delete journal';

  @override
  String get discardChangesTitle => 'Discard Changes';

  @override
  String get discardChangesDescription =>
      'Are you sure you want to discard the changes? All changes will not be saved.';

  @override
  String get discardChangesAction => 'Discard';
}
