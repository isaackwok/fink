import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_journal/l10n/app_localizations.dart';
import 'package:movie_journal/l10n/supported_locales.dart';

const _traditionalChinese = Locale.fromSubtags(
  languageCode: 'zh',
  scriptCode: 'Hant',
  countryCode: 'TW',
);

Map<String, Object?> _messages(String path) {
  final json =
      jsonDecode(File(path).readAsStringSync()) as Map<String, Object?>;
  return Map.fromEntries(
    json.entries.where((entry) => !entry.key.startsWith('@')),
  );
}

void main() {
  test('production exposes only English and Taiwan Traditional Chinese', () {
    expect(appSupportedLocales, const <Locale>[
      Locale('en'),
      _traditionalChinese,
    ]);
  });

  test('backend language follows the supported app locale', () {
    expect(appLanguageTag(const Locale('en')), 'en-US');
    expect(appLanguageTag(_traditionalChinese), 'zh-TW');
  });

  test(
    'generated resources load real copy for both production locales',
    () async {
      final english = await AppLocalizations.delegate.load(const Locale('en'));
      final chinese = await AppLocalizations.delegate.load(_traditionalChinese);

      expect(english.commonSave, 'Save');
      expect(chinese.commonSave, '儲存');
      expect(
        english.commonErrorWithDetails(error: 'network'),
        'Error: network',
      );
      expect(chinese.commonErrorWithDetails(error: 'network'), '錯誤：network');
    },
  );

  test('English and both Chinese resources contain the same messages', () {
    final english = _messages('lib/l10n/app_en.arb');
    final chineseFallback = _messages('lib/l10n/app_zh.arb');
    final traditionalChinese = _messages('lib/l10n/app_zh_Hant_TW.arb');

    expect(chineseFallback.keys.toSet(), english.keys.toSet());
    expect(traditionalChinese.keys.toSet(), english.keys.toSet());
    expect(chineseFallback, traditionalChinese);
  });
}
