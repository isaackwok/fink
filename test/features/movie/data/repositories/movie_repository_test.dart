import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_journal/features/movie/data/data_sources/movie_api.dart';
import 'package:movie_journal/features/movie/data/models/brief_movie.dart';
import 'package:movie_journal/features/movie/data/models/detailed_movie.dart';
import 'package:movie_journal/features/movie/data/repositories/movie_repository.dart';
import 'package:movie_journal/features/movie/movie_providers.dart';
import 'package:movie_journal/l10n/supported_locales.dart';

import '../../../../helpers/test_movie.dart';

final _testLocaleProvider = NotifierProvider<_TestLocale, Locale>(
  _TestLocale.new,
);

class _TestLocale extends Notifier<Locale> {
  @override
  Locale build() => const Locale('en');

  void set(Locale locale) => state = locale;
}

class _LanguageEchoMovieApi extends MovieAPI {
  MovieListResponse _response(String title) => MovieListResponse(
    page: 1,
    results: [BriefMovie.fromJson(makeBriefMovieJson(title: title))],
    totalPages: 1,
    totalResults: 1,
  );

  @override
  Future<MovieListResponse> popularMovies({
    required int page,
    String language = 'en-US',
    String? region,
    CancelToken? cancelToken,
  }) async => _response('Popular $language');

  @override
  Future<MovieListResponse> searchMovies({
    required String query,
    required int page,
    bool includeAdult = false,
    String language = 'en-US',
    String? region,
    int? primaryReleaseYear,
    int? year,
    CancelToken? cancelToken,
  }) async => _response('Search $language');

  @override
  Future<DetailedMovie> getMovieDetails({
    required int id,
    String language = 'en-US',
  }) async => DetailedMovie.fromJson(
    makeDetailedMovieJson(id: id, title: 'Details $language'),
  );
}

typedef _PendingLanguageRequest =
    ({String language, Completer<MovieListResponse> completer});

class _ControlledLanguageMovieApi extends MovieAPI {
  final pending = <_PendingLanguageRequest>[];

  MovieListResponse response(String title) => MovieListResponse(
    page: 1,
    results: [BriefMovie.fromJson(makeBriefMovieJson(title: title))],
    totalPages: 1,
    totalResults: 1,
  );

  Future<MovieListResponse> _park(String language) {
    final completer = Completer<MovieListResponse>();
    pending.add((language: language, completer: completer));
    return completer.future;
  }

  @override
  Future<MovieListResponse> popularMovies({
    required int page,
    String language = 'en-US',
    String? region,
    CancelToken? cancelToken,
  }) => _park(language);

  @override
  Future<MovieListResponse> searchMovies({
    required String query,
    required int page,
    bool includeAdult = false,
    String language = 'en-US',
    String? region,
    int? primaryReleaseYear,
    int? year,
    CancelToken? cancelToken,
  }) => _park(language);
}

void main() {
  test('title-bearing requests use the repository app language', () async {
    final repository = MovieRepository(
      _LanguageEchoMovieApi(),
      language: 'zh-TW',
    );

    final popular = await repository.popular(page: 1);
    final search = await repository.search(query: '霸王別姬', page: 1);
    final details = await repository.getMovieDetails(42);

    expect(popular.results.single.title, 'Popular zh-TW');
    expect(search.results.single.title, 'Search zh-TW');
    expect(details.title, 'Details zh-TW');
  });

  test(
    'movie repository provider derives language from the app locale',
    () async {
      final container = ProviderContainer(
        overrides: [
          appLocaleProvider.overrideWithValue(
            const Locale.fromSubtags(
              languageCode: 'zh',
              scriptCode: 'Hant',
              countryCode: 'TW',
            ),
          ),
          movieApiProvider.overrideWithValue(_LanguageEchoMovieApi()),
        ],
      );
      addTearDown(container.dispose);

      final result = await container.read(movieRepoProvider).popular(page: 1);

      expect(result.results.single.title, 'Popular zh-TW');
    },
  );

  test('loaded movie details refetch when the app locale changes', () async {
    final container = ProviderContainer(
      overrides: [
        appLocaleProvider.overrideWith((ref) => ref.watch(_testLocaleProvider)),
        movieApiProvider.overrideWithValue(_LanguageEchoMovieApi()),
      ],
    );
    addTearDown(container.dispose);
    container.listen(movieDetailControllerProvider(42), (_, _) {});

    final english = await container.read(
      movieDetailControllerProvider(42).future,
    );
    expect(english.title, 'Details en-US');

    container
        .read(_testLocaleProvider.notifier)
        .set(
          const Locale.fromSubtags(
            languageCode: 'zh',
            scriptCode: 'Hant',
            countryCode: 'TW',
          ),
        );
    await container.pump();

    final chinese = await container.read(
      movieDetailControllerProvider(42).future,
    );
    expect(chinese.title, 'Details zh-TW');
  });

  test('loaded movie results refetch when the app locale changes', () async {
    final container = ProviderContainer(
      overrides: [
        appLocaleProvider.overrideWith((ref) => ref.watch(_testLocaleProvider)),
        movieApiProvider.overrideWithValue(_LanguageEchoMovieApi()),
      ],
    );
    addTearDown(container.dispose);
    container.listen(searchMovieControllerProvider, (_, _) {});

    final english = await container.read(searchMovieControllerProvider.future);
    expect(english.movies.single.title, 'Popular en-US');

    container
        .read(_testLocaleProvider.notifier)
        .set(
          const Locale.fromSubtags(
            languageCode: 'zh',
            scriptCode: 'Hant',
            countryCode: 'TW',
          ),
        );
    await container.pump();

    final chinese = await container.read(searchMovieControllerProvider.future);
    expect(chinese.movies.single.title, 'Popular zh-TW');
  });

  test(
    'an old-language search cannot replace results after a locale change',
    () async {
      final api = _ControlledLanguageMovieApi();
      final container = ProviderContainer(
        overrides: [
          appLocaleProvider.overrideWith(
            (ref) => ref.watch(_testLocaleProvider),
          ),
          movieApiProvider.overrideWithValue(api),
        ],
      );
      addTearDown(container.dispose);
      container.listen(searchMovieControllerProvider, (_, _) {});

      final initial = container.read(searchMovieControllerProvider.future);
      api.pending.single.completer.complete(api.response('Popular en-US'));
      await initial;

      final staleSearch = container
          .read(searchMovieControllerProvider.notifier)
          .search('old language');
      expect(api.pending[1].language, 'en-US');

      container
          .read(_testLocaleProvider.notifier)
          .set(
            const Locale.fromSubtags(
              languageCode: 'zh',
              scriptCode: 'Hant',
              countryCode: 'TW',
            ),
          );
      final localized = container.read(searchMovieControllerProvider.future);
      expect(api.pending[2].language, 'zh-TW');
      api.pending[2].completer.complete(api.response('Popular zh-TW'));
      await localized;

      api.pending[1].completer.complete(api.response('Stale en-US search'));
      await staleSearch;

      expect(
        container
            .read(searchMovieControllerProvider)
            .value!
            .movies
            .single
            .title,
        'Popular zh-TW',
      );
    },
  );
}
