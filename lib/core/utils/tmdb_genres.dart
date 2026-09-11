import 'dart:ui';

/// TMDB's fixed movie genre list (19 ids, stable for years — the API's
/// /genre/movie/list). Localized here instead of fetched: the journal
/// insights payload carries only the stable genre id as `key`.
const _genreEn = <int, String>{
  28: 'Action',
  12: 'Adventure',
  16: 'Animation',
  35: 'Comedy',
  80: 'Crime',
  99: 'Documentary',
  18: 'Drama',
  10751: 'Family',
  14: 'Fantasy',
  36: 'History',
  27: 'Horror',
  10402: 'Music',
  9648: 'Mystery',
  10749: 'Romance',
  878: 'Science Fiction',
  10770: 'TV Movie',
  53: 'Thriller',
  10752: 'War',
  37: 'Western',
};

// TMDB's own zh-TW genre names.
const _genreZhHant = <int, String>{
  28: '動作',
  12: '冒險',
  16: '動畫',
  35: '喜劇',
  80: '犯罪',
  99: '紀錄',
  18: '劇情',
  10751: '家庭',
  14: '奇幻',
  36: '歷史',
  27: '恐怖',
  10402: '音樂',
  9648: '懸疑',
  10749: '愛情',
  878: '科幻',
  10770: '電視電影',
  53: '驚悚',
  10752: '戰爭',
  37: '西部',
};

/// Localized genre name for a TMDB genre id; null for an unknown id (caller
/// falls back to the payload's raw name).
String? tmdbGenreName(int genreId, Locale locale) =>
    (locale.languageCode == 'zh' ? _genreZhHant : _genreEn)[genreId];
