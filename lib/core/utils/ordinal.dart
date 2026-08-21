import 'dart:ui';

/// Ordinal for the achievement cards: English "1st/2nd/3rd/4th…" (with the
/// 11–13 → "th" exception); Chinese returns the bare digit because the ARB
/// strings wrap it as 「第 N 部」. gen_l10n has no `selectordinal` support,
/// which is why this lives in Dart rather than the ARB files.
String ordinal(int n, Locale locale) {
  if (locale.languageCode == 'zh') return '$n';
  final mod100 = n % 100;
  if (mod100 >= 11 && mod100 <= 13) return '${n}th';
  return switch (n % 10) {
    1 => '${n}st',
    2 => '${n}nd',
    3 => '${n}rd',
    _ => '${n}th',
  };
}
