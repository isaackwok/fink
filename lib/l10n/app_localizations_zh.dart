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
}
