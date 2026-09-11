import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:movie_journal/core/utils/country_names.dart';

void main() {
  const en = Locale('en');
  const zh = Locale.fromSubtags(
    languageCode: 'zh',
    scriptCode: 'Hant',
    countryCode: 'TW',
  );

  test('resolves curated ISO codes in both locales', () {
    expect(countryName('JP', en), 'Japan');
    expect(countryName('JP', zh), '日本');
    expect(countryName('US', en), 'United States');
    expect(countryName('US', zh), '美國');
    expect(countryName('TW', en), 'Taiwan');
    expect(countryName('TW', zh), '台灣');
  });

  test('is case-insensitive on the code', () {
    expect(countryName('jp', en), 'Japan');
  });

  test('falls back to the raw code for unknown countries', () {
    expect(countryName('XX', en), 'XX');
    expect(countryName('xx', zh), 'XX');
  });
}
