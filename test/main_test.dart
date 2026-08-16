import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_journal/features/auth/auth_providers.dart';
import 'package:movie_journal/features/movie/data/data_sources/movie_api.dart';
import 'package:movie_journal/features/movie/data/models/brief_movie.dart';
import 'package:movie_journal/features/movie/movie_providers.dart';
import 'package:movie_journal/features/onboarding/controllers/splash_posters.dart';
import 'package:movie_journal/features/onboarding/screens/branding_splash.dart';
import 'package:movie_journal/features/quesgen/api.dart';
import 'package:movie_journal/features/quesgen/controller.dart';
import 'package:movie_journal/features/quesgen/provider.dart';
import 'package:movie_journal/features/quesgen/review.dart';
import 'package:movie_journal/l10n/supported_locales.dart';
import 'package:movie_journal/main.dart';

import 'helpers/widget_test_setup.dart';
import 'helpers/test_movie.dart';

class _LanguageEchoMovieApi extends MovieAPI {
  @override
  Future<MovieListResponse> popularMovies({
    required int page,
    String language = 'en-US',
    String? region,
    CancelToken? cancelToken,
  }) async => MovieListResponse(
    page: 1,
    results: [
      BriefMovie.fromJson(makeBriefMovieJson(title: 'Popular $language')),
    ],
    totalPages: 1,
    totalResults: 1,
  );
}

class _LanguageEchoQuesgenApi extends QuesgenAPI {
  @override
  Future<List<Review>> generateReviews({
    required int movieId,
    String? locale,
  }) async => [Review(text: 'Review $locale', source: 'reddit')];
}

void main() {
  setUpAll(setUpWidgetTests);
  tearDownAll(tearDownWidgetTests);

  testWidgets('MyApp resolves the iOS Taiwan Traditional Chinese locale', (
    tester,
  ) async {
    const locale = Locale.fromSubtags(
      languageCode: 'zh',
      scriptCode: 'Hant',
      countryCode: 'TW',
    );
    tester.binding.platformDispatcher.localesTestValue = const [locale];
    addTearDown(tester.binding.platformDispatcher.clearLocalesTestValue);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStateProvider.overrideWith((ref) => Stream.value(null)),
          anonymousBridgeProvider.overrideWith((ref) async => false),
          movieApiProvider.overrideWithValue(_LanguageEchoMovieApi()),
          splashPostersProvider.overrideWith((ref) async => const <String>[]),
        ],
        child: const MyApp(),
      ),
    );
    await tester.pump();
    await tester.pump();

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.supportedLocales, appSupportedLocales);

    final splashContext = tester.element(find.byType(BrandingSplashScreen));
    expect(Localizations.localeOf(splashContext), locale);
    expect(
      ProviderScope.containerOf(splashContext).read(appLocaleProvider),
      locale,
    );
    final movies = await ProviderScope.containerOf(
      splashContext,
    ).read(movieRepoProvider).popular(page: 1);
    expect(movies.results.single.title, 'Popular zh-TW');

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('AI reviews receive the locale resolved by MyApp', (
    tester,
  ) async {
    const locale = Locale.fromSubtags(
      languageCode: 'zh',
      scriptCode: 'Hant',
      countryCode: 'TW',
    );
    tester.binding.platformDispatcher.localesTestValue = const [locale];
    addTearDown(tester.binding.platformDispatcher.clearLocalesTestValue);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStateProvider.overrideWith((ref) => Stream.value(null)),
          anonymousBridgeProvider.overrideWith((ref) async => false),
          quesgenApiProvider.overrideWithValue(_LanguageEchoQuesgenApi()),
          splashPostersProvider.overrideWith((ref) async => const <String>[]),
        ],
        child: const MyApp(),
      ),
    );
    await tester.pump();
    await tester.pump();

    final splashContext = tester.element(find.byType(BrandingSplashScreen));
    final container = ProviderScope.containerOf(splashContext);
    await container
        .read(quesgenControllerProvider.notifier)
        .generateReviews(movieId: 42);

    expect(
      container.read(quesgenControllerProvider).reviews.single.text,
      'Review zh-TW',
    );

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
