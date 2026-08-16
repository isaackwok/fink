import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const appSupportedLocales = <Locale>[
  Locale('en'),
  Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant', countryCode: 'TW'),
];

String appLanguageTag(Locale locale) =>
    locale.languageCode == 'zh' ? 'zh-TW' : 'en-US';

final appLocaleProvider = Provider<Locale>((_) => appSupportedLocales.first);
