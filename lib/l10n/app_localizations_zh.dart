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

  @override
  String get ratingPrompt => '你有多喜歡這部電影？';

  @override
  String ratingSemantics({required int value, required int max}) {
    return '$value（滿分 $max）';
  }

  @override
  String get emotionsPrompt => '你對這部電影有什麼感受？';

  @override
  String get emotionsSelect => '選擇情緒';

  @override
  String get emotionsSummaryPrefix => '這部電影讓你感到';

  @override
  String get emotionsSummarySuffix => '。';

  @override
  String get emotionsListSeparator => '、';

  @override
  String get emotionsListFinalSeparator => '、';

  @override
  String selectionUpToStatus({required int limit, required int selected}) {
    return '最多選擇 $limit 個（$selected/$limit）';
  }

  @override
  String emotionsSelectionLimit({required int limit}) {
    return '最多只能選擇 $limit 個情緒';
  }

  @override
  String get scenesTitle => '場景';

  @override
  String get scenesPrompt => '有哪些令人難忘的場景？';

  @override
  String get scenesAdd => '+  新增場景';

  @override
  String get sceneAdd => '新增場景';

  @override
  String get scenesMissingTitle => '找不到場景！';

  @override
  String get scenesMissingBody => '我們找不到這部電影的場景照片。';

  @override
  String get scenesMissingTagline => '把這一幕留在記憶裡。✨';

  @override
  String get sceneErrorLoadingImage => '無法載入圖片';

  @override
  String get sceneErrorLoadingImages => '無法載入圖片';

  @override
  String scenesSelectionLimit({required int limit}) {
    return '最多只能選擇 $limit 個場景';
  }

  @override
  String get sceneCaptionHint => '新增說明...';

  @override
  String get commonMore => '更多';

  @override
  String get thoughtsTitle => '想法';

  @override
  String get thoughtsPrompt => '寫下你的想法與感受。';

  @override
  String get thoughtsHint => '在這裡輸入文字...';

  @override
  String get thoughtsAdd => '新增';

  @override
  String itemPosition({required int current, required int total}) {
    return '$current / $total';
  }

  @override
  String get reviewsTitle => '電影評論';

  @override
  String get reviewsLabel => '評論';

  @override
  String get reviewsDescription =>
      '我們使用 AI 整理了 Letterboxd 和 Reddit 的評論，把這些觀點加入你的筆記吧！';

  @override
  String get reviewsEmpty => '尚未產生評論';

  @override
  String get journalSaved => '日記已儲存';

  @override
  String get shareTicket => '分享票卡';

  @override
  String get viewJournal => '查看日記';

  @override
  String get journalUpdated => '日記已更新。';

  @override
  String get journalSaveFailed => '無法儲存日記，請再試一次。';

  @override
  String get journalDeleteTitle => '刪除日記';

  @override
  String get journalDeleteConfirmation => '確定要刪除這篇日記嗎？';

  @override
  String get journalDeleted => '日記已刪除';

  @override
  String get journalDeleteFailed => '無法刪除日記';

  @override
  String get discardChangesTitle => '捨棄變更';

  @override
  String get discardChangesDescription => '確定要捨棄變更嗎？所有變更都不會被儲存。';

  @override
  String get discardChangesAction => '捨棄';

  @override
  String get posterOriginalLanguage => '原始語言';

  @override
  String get posterPickerTitle => '選擇票卡海報';

  @override
  String get posterPickerEmpty => '沒有可用的海報';

  @override
  String get shareCopySocial => '複製文字並分享到社群';

  @override
  String get shareOptionsTitle => '分享方式';

  @override
  String get shareStory => '限時動態';

  @override
  String get shareCopiedToClipboard => '已複製到剪貼簿';

  @override
  String get shareCopyText => '複製文字';

  @override
  String get sharePhotoAccessDenied => '相簿存取權限遭拒';

  @override
  String get shareImageSaved => '圖片已儲存到相簿';

  @override
  String get shareImageSaveFailed => '無法儲存圖片';

  @override
  String get shareInstagramUnavailable => '無法開啟 Instagram，請確認是否已安裝。';

  @override
  String get shareThreadsUnavailable => '無法開啟 Threads，請確認是否已安裝。';

  @override
  String get shareThreadsFailed => '無法開啟 Threads';

  @override
  String get ticketBrand => 'FINK 電影日記';

  @override
  String ticketNumber({required int number}) {
    return '編號 $number';
  }

  @override
  String get ticketTitle => '片名';

  @override
  String get ticketRelease => '上映';

  @override
  String get ticketDirector => '導演';

  @override
  String get ticketCast => '演員';

  @override
  String get ticketEmotion => '情緒';

  @override
  String get ticketDate => '日期';

  @override
  String get ticketTime => '時間';
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

  @override
  String get ratingPrompt => '你有多喜歡這部電影？';

  @override
  String ratingSemantics({required int value, required int max}) {
    return '$value（滿分 $max）';
  }

  @override
  String get emotionsPrompt => '你對這部電影有什麼感受？';

  @override
  String get emotionsSelect => '選擇情緒';

  @override
  String get emotionsSummaryPrefix => '這部電影讓你感到';

  @override
  String get emotionsSummarySuffix => '。';

  @override
  String get emotionsListSeparator => '、';

  @override
  String get emotionsListFinalSeparator => '、';

  @override
  String selectionUpToStatus({required int limit, required int selected}) {
    return '最多選擇 $limit 個（$selected/$limit）';
  }

  @override
  String emotionsSelectionLimit({required int limit}) {
    return '最多只能選擇 $limit 個情緒';
  }

  @override
  String get scenesTitle => '場景';

  @override
  String get scenesPrompt => '有哪些令人難忘的場景？';

  @override
  String get scenesAdd => '+  新增場景';

  @override
  String get sceneAdd => '新增場景';

  @override
  String get scenesMissingTitle => '找不到場景！';

  @override
  String get scenesMissingBody => '我們找不到這部電影的場景照片。';

  @override
  String get scenesMissingTagline => '把這一幕留在記憶裡。✨';

  @override
  String get sceneErrorLoadingImage => '無法載入圖片';

  @override
  String get sceneErrorLoadingImages => '無法載入圖片';

  @override
  String scenesSelectionLimit({required int limit}) {
    return '最多只能選擇 $limit 個場景';
  }

  @override
  String get sceneCaptionHint => '新增說明...';

  @override
  String get commonMore => '更多';

  @override
  String get thoughtsTitle => '想法';

  @override
  String get thoughtsPrompt => '寫下你的想法與感受。';

  @override
  String get thoughtsHint => '在這裡輸入文字...';

  @override
  String get thoughtsAdd => '新增';

  @override
  String itemPosition({required int current, required int total}) {
    return '$current / $total';
  }

  @override
  String get reviewsTitle => '電影評論';

  @override
  String get reviewsLabel => '評論';

  @override
  String get reviewsDescription =>
      '我們使用 AI 整理了 Letterboxd 和 Reddit 的評論，把這些觀點加入你的筆記吧！';

  @override
  String get reviewsEmpty => '尚未產生評論';

  @override
  String get journalSaved => '日記已儲存';

  @override
  String get shareTicket => '分享票卡';

  @override
  String get viewJournal => '查看日記';

  @override
  String get journalUpdated => '日記已更新。';

  @override
  String get journalSaveFailed => '無法儲存日記，請再試一次。';

  @override
  String get journalDeleteTitle => '刪除日記';

  @override
  String get journalDeleteConfirmation => '確定要刪除這篇日記嗎？';

  @override
  String get journalDeleted => '日記已刪除';

  @override
  String get journalDeleteFailed => '無法刪除日記';

  @override
  String get discardChangesTitle => '捨棄變更';

  @override
  String get discardChangesDescription => '確定要捨棄變更嗎？所有變更都不會被儲存。';

  @override
  String get discardChangesAction => '捨棄';

  @override
  String get posterOriginalLanguage => '原始語言';

  @override
  String get posterPickerTitle => '選擇票卡海報';

  @override
  String get posterPickerEmpty => '沒有可用的海報';

  @override
  String get shareCopySocial => '複製文字並分享到社群';

  @override
  String get shareOptionsTitle => '分享方式';

  @override
  String get shareStory => '限時動態';

  @override
  String get shareCopiedToClipboard => '已複製到剪貼簿';

  @override
  String get shareCopyText => '複製文字';

  @override
  String get sharePhotoAccessDenied => '相簿存取權限遭拒';

  @override
  String get shareImageSaved => '圖片已儲存到相簿';

  @override
  String get shareImageSaveFailed => '無法儲存圖片';

  @override
  String get shareInstagramUnavailable => '無法開啟 Instagram，請確認是否已安裝。';

  @override
  String get shareThreadsUnavailable => '無法開啟 Threads，請確認是否已安裝。';

  @override
  String get shareThreadsFailed => '無法開啟 Threads';

  @override
  String get ticketBrand => 'FINK 電影日記';

  @override
  String ticketNumber({required int number}) {
    return '編號 $number';
  }

  @override
  String get ticketTitle => '片名';

  @override
  String get ticketRelease => '上映';

  @override
  String get ticketDirector => '導演';

  @override
  String get ticketCast => '演員';

  @override
  String get ticketEmotion => '情緒';

  @override
  String get ticketDate => '日期';

  @override
  String get ticketTime => '時間';
}
