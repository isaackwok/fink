// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '電影日記';

  @override
  String get commonAdd => '新增';

  @override
  String get commonCancel => '取消';

  @override
  String get commonDelete => '刪除';

  @override
  String get commonDone => '完成';

  @override
  String get commonEdit => '編輯';

  @override
  String commonErrorWithDetails({required Object error}) {
    return '錯誤：$error';
  }

  @override
  String get commonGoBack => '返回';

  @override
  String get commonOthers => '其他';

  @override
  String get commonRetry => '重試';

  @override
  String get commonSave => '儲存';

  @override
  String get commonShare => '分享';

  @override
  String get commonConfirm => '確認';

  @override
  String get commonLoading => '載入中...';

  @override
  String get commonUser => '使用者';

  @override
  String get commonUnknown => '未知';

  @override
  String get loginTitle => '開始寫下你的電影日記。';

  @override
  String get loginSubtitle => '使用 Google 或 Apple 帳號登入\n即可開始。';

  @override
  String get loginWithGoogle => '使用 Google 登入';

  @override
  String get loginWithApple => '使用 Apple 登入';

  @override
  String get loginFailed => '登入失敗，請再試一次。';

  @override
  String get createUserTitle => '選個名字。';

  @override
  String get createUserSubtitle => '多告訴我一些關於你的事。';

  @override
  String get usernameLabel => '使用者名稱';

  @override
  String get usernameHint => '名字或暱稱';

  @override
  String get startJournaling => '開始寫日記';

  @override
  String get usernameEmpty => '使用者名稱不能留白';

  @override
  String get usernameInvalidCharacters => '使用者名稱只能包含英文字母、數字、_ 和 .';

  @override
  String get usernameOnlySymbols => '使用者名稱不能只有 _ 和 .';

  @override
  String get usernameTrailingSymbol => '使用者名稱不能以 _ 或 . 結尾';

  @override
  String get usernameTooLong => '使用者名稱不能超過 30 個字元';

  @override
  String get usernameTaken => '這個使用者名稱已被使用，請選擇其他名稱。';

  @override
  String get accountSecured => '帳號已受到保護';

  @override
  String get accountSecureFailed => '無法保護你的帳號，請再試一次。';

  @override
  String get accountBannerTitle => '你的帳號尚未受到保護';

  @override
  String get accountBannerBody => '連結 Apple 或 Google 帳號，重新安裝 App 時才不會遺失日記。';

  @override
  String get accountSheetHeadline => '妥善保護你的日記';

  @override
  String accountSheetHeadlineCount({required int count}) {
    return '妥善保護你的 $count 篇日記';
  }

  @override
  String get accountSheetBody =>
      '這些日記目前只存在這台裝置上。連結 Apple 或 Google 帳號後，即使重新安裝 App 或更換手機，也能再次登入。';

  @override
  String get accountContinueGoogle => '使用 Google 繼續';

  @override
  String get accountContinueApple => '使用 Apple 繼續';

  @override
  String get accountNotNow => '稍後再說';

  @override
  String accountConflict({
    required String provider,
    required String otherProvider,
  }) {
    return '這個 $provider 帳號已連結到另一個 Fink 帳號，因此無法同時連結目前的帳號。請改用 $otherProvider，或聯絡我們協助合併兩個帳號。';
  }

  @override
  String get onboardingTagline => '從電影到筆尖，\n建立你的觀影旅程。';

  @override
  String get settingsTitle => '設定';

  @override
  String get settingsAccountSection => '帳號';

  @override
  String get settingsSecureAccount => '保護帳號';

  @override
  String get settingsLogout => '登出';

  @override
  String get settingsDeleteAccount => '刪除帳號';

  @override
  String get settingsLogoutDeviceWarning =>
      '你的帳號尚未連結 Apple 或 Google 登入方式，目前只能透過這台裝置取回帳號；重新安裝 App 將永久遺失日記。請先保護你的帳號。';

  @override
  String get settingsLogoutConfirmation => '確定要登出嗎？';

  @override
  String get settingsDeleteAccountDescription => '你的所有資料都會被永久刪除。';

  @override
  String settingsReauthenticationRequired({required Object error}) {
    return '需要重新驗證身分：$error';
  }

  @override
  String settingsDeleteAccountFailed({required Object error}) {
    return '無法刪除帳號：$error';
  }

  @override
  String homeJournalCount({required int count}) {
    return '$count 篇電影日記';
  }

  @override
  String get homeEmptyTitle => '你的電影日記從這裡開始';

  @override
  String get homeEmptyBody => '新增第一部電影，留下你的觀影回憶';

  @override
  String get addJournal => '新增日記';

  @override
  String homeErrorCheckingUser({required Object error}) {
    return '檢查使用者時發生錯誤：$error';
  }

  @override
  String homeErrorLoadingJournals({required Object error}) {
    return '載入日記時發生錯誤：$error';
  }

  @override
  String get searchMovieHint => '搜尋電影';

  @override
  String get searchPopularHeader => '大家都在看';

  @override
  String get searchErrorLoadingMovies => '無法載入電影';

  @override
  String get moviePreviewErrorLoading => '無法載入電影';
}

/// The translations for Chinese, as used in Taiwan, using the Han script (`zh_Hant_TW`).
class AppLocalizationsZhHantTw extends AppLocalizationsZh {
  AppLocalizationsZhHantTw() : super('zh_Hant_TW');

  @override
  String get appTitle => '電影日記';

  @override
  String get commonAdd => '新增';

  @override
  String get commonCancel => '取消';

  @override
  String get commonDelete => '刪除';

  @override
  String get commonDone => '完成';

  @override
  String get commonEdit => '編輯';

  @override
  String commonErrorWithDetails({required Object error}) {
    return '錯誤：$error';
  }

  @override
  String get commonGoBack => '返回';

  @override
  String get commonOthers => '其他';

  @override
  String get commonRetry => '重試';

  @override
  String get commonSave => '儲存';

  @override
  String get commonShare => '分享';

  @override
  String get commonConfirm => '確認';

  @override
  String get commonLoading => '載入中...';

  @override
  String get commonUser => '使用者';

  @override
  String get commonUnknown => '未知';

  @override
  String get loginTitle => '開始寫下你的電影日記。';

  @override
  String get loginSubtitle => '使用 Google 或 Apple 帳號登入\n即可開始。';

  @override
  String get loginWithGoogle => '使用 Google 登入';

  @override
  String get loginWithApple => '使用 Apple 登入';

  @override
  String get loginFailed => '登入失敗，請再試一次。';

  @override
  String get createUserTitle => '選個名字。';

  @override
  String get createUserSubtitle => '多告訴我一些關於你的事。';

  @override
  String get usernameLabel => '使用者名稱';

  @override
  String get usernameHint => '名字或暱稱';

  @override
  String get startJournaling => '開始寫日記';

  @override
  String get usernameEmpty => '使用者名稱不能留白';

  @override
  String get usernameInvalidCharacters => '使用者名稱只能包含英文字母、數字、_ 和 .';

  @override
  String get usernameOnlySymbols => '使用者名稱不能只有 _ 和 .';

  @override
  String get usernameTrailingSymbol => '使用者名稱不能以 _ 或 . 結尾';

  @override
  String get usernameTooLong => '使用者名稱不能超過 30 個字元';

  @override
  String get usernameTaken => '這個使用者名稱已被使用，請選擇其他名稱。';

  @override
  String get accountSecured => '帳號已受到保護';

  @override
  String get accountSecureFailed => '無法保護你的帳號，請再試一次。';

  @override
  String get accountBannerTitle => '你的帳號尚未受到保護';

  @override
  String get accountBannerBody => '連結 Apple 或 Google 帳號，重新安裝 App 時才不會遺失日記。';

  @override
  String get accountSheetHeadline => '妥善保護你的日記';

  @override
  String accountSheetHeadlineCount({required int count}) {
    return '妥善保護你的 $count 篇日記';
  }

  @override
  String get accountSheetBody =>
      '這些日記目前只存在這台裝置上。連結 Apple 或 Google 帳號後，即使重新安裝 App 或更換手機，也能再次登入。';

  @override
  String get accountContinueGoogle => '使用 Google 繼續';

  @override
  String get accountContinueApple => '使用 Apple 繼續';

  @override
  String get accountNotNow => '稍後再說';

  @override
  String accountConflict({
    required String provider,
    required String otherProvider,
  }) {
    return '這個 $provider 帳號已連結到另一個 Fink 帳號，因此無法同時連結目前的帳號。請改用 $otherProvider，或聯絡我們協助合併兩個帳號。';
  }

  @override
  String get onboardingTagline => '從電影到筆尖，\n建立你的觀影旅程。';

  @override
  String get settingsTitle => '設定';

  @override
  String get settingsAccountSection => '帳號';

  @override
  String get settingsSecureAccount => '保護帳號';

  @override
  String get settingsLogout => '登出';

  @override
  String get settingsDeleteAccount => '刪除帳號';

  @override
  String get settingsLogoutDeviceWarning =>
      '你的帳號尚未連結 Apple 或 Google 登入方式，目前只能透過這台裝置取回帳號；重新安裝 App 將永久遺失日記。請先保護你的帳號。';

  @override
  String get settingsLogoutConfirmation => '確定要登出嗎？';

  @override
  String get settingsDeleteAccountDescription => '你的所有資料都會被永久刪除。';

  @override
  String settingsReauthenticationRequired({required Object error}) {
    return '需要重新驗證身分：$error';
  }

  @override
  String settingsDeleteAccountFailed({required Object error}) {
    return '無法刪除帳號：$error';
  }

  @override
  String homeJournalCount({required int count}) {
    return '$count 篇電影日記';
  }

  @override
  String get homeEmptyTitle => '你的電影日記從這裡開始';

  @override
  String get homeEmptyBody => '新增第一部電影，留下你的觀影回憶';

  @override
  String get addJournal => '新增日記';

  @override
  String homeErrorCheckingUser({required Object error}) {
    return '檢查使用者時發生錯誤：$error';
  }

  @override
  String homeErrorLoadingJournals({required Object error}) {
    return '載入日記時發生錯誤：$error';
  }

  @override
  String get searchMovieHint => '搜尋電影';

  @override
  String get searchPopularHeader => '大家都在看';

  @override
  String get searchErrorLoadingMovies => '無法載入電影';

  @override
  String get moviePreviewErrorLoading => '無法載入電影';
}
