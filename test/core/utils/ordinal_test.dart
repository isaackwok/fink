import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:movie_journal/core/utils/ordinal.dart';

void main() {
  const en = Locale('en');
  const zh = Locale.fromSubtags(
    languageCode: 'zh',
    scriptCode: 'Hant',
    countryCode: 'TW',
  );

  test('English ordinals use st/nd/rd/th suffixes', () {
    expect(ordinal(1, en), '1st');
    expect(ordinal(2, en), '2nd');
    expect(ordinal(3, en), '3rd');
    expect(ordinal(4, en), '4th');
    expect(ordinal(10, en), '10th');
    expect(ordinal(21, en), '21st');
    expect(ordinal(42, en), '42nd');
    expect(ordinal(63, en), '63rd');
    expect(ordinal(100, en), '100th');
    expect(ordinal(101, en), '101st');
  });

  test('11-13 take th, including above 100', () {
    expect(ordinal(11, en), '11th');
    expect(ordinal(12, en), '12th');
    expect(ordinal(13, en), '13th');
    expect(ordinal(111, en), '111th');
    expect(ordinal(112, en), '112th');
    expect(ordinal(113, en), '113th');
  });

  test('Chinese returns the bare digit for 第 N 部 composition', () {
    expect(ordinal(1, zh), '1');
    expect(ordinal(13, zh), '13');
    expect(ordinal(21, zh), '21');
  });
}
