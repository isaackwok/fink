import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:movie_journal/core/utils/tmdb_genres.dart';

void main() {
  const en = Locale('en');
  const zh = Locale.fromSubtags(
    languageCode: 'zh',
    scriptCode: 'Hant',
    countryCode: 'TW',
  );

  test('resolves known TMDB genre ids in both locales', () {
    expect(tmdbGenreName(18, en), 'Drama');
    expect(tmdbGenreName(18, zh), '劇情');
    expect(tmdbGenreName(878, en), 'Science Fiction');
    expect(tmdbGenreName(878, zh), '科幻');
    expect(tmdbGenreName(53, en), 'Thriller');
    expect(tmdbGenreName(53, zh), '驚悚');
  });

  test('covers all 19 TMDB movie genres in both locales', () {
    const ids = [
      28, 12, 16, 35, 80, 99, 18, 10751, 14, 36,
      27, 10402, 9648, 10749, 878, 10770, 53, 10752, 37,
    ];
    for (final id in ids) {
      expect(tmdbGenreName(id, en), isNotNull, reason: 'en missing $id');
      expect(tmdbGenreName(id, zh), isNotNull, reason: 'zh missing $id');
    }
  });

  test('returns null for an unknown id (caller falls back to payload name)', () {
    expect(tmdbGenreName(99999, en), isNull);
    expect(tmdbGenreName(99999, zh), isNull);
  });
}
