import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_journal/features/quesgen/api.dart';
import 'package:movie_journal/features/quesgen/controller.dart';
import 'package:movie_journal/features/quesgen/provider.dart';
import 'package:movie_journal/features/quesgen/review.dart';
import 'package:movie_journal/l10n/supported_locales.dart';

class _LanguageEchoQuesgenApi extends QuesgenAPI {
  @override
  Future<List<Review>> generateReviews({
    required int movieId,
    String? locale,
  }) async => [Review(text: 'Review $locale', source: 'reddit')];
}

void main() {
  group('QuesgenState value equality', () {
    test('same fields → equal, same hashCode', () {
      final a = QuesgenState(
        reviews: [Review(text: 'Great', source: 'reddit')],
        isLoading: false,
        isError: false,
      );
      final b = QuesgenState(
        reviews: [Review(text: 'Great', source: 'reddit')],
        isLoading: false,
        isError: false,
      );
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('equal even when review lists are distinct instances', () {
      final a = QuesgenState(
        reviews: [Review(text: 'A', source: 'letterboxd')],
        isLoading: true,
        isError: false,
      );
      final b = QuesgenState(
        reviews: [Review(text: 'A', source: 'letterboxd')],
        isLoading: true,
        isError: false,
      );
      expect(identical(a.reviews, b.reviews), isFalse);
      expect(a, equals(b));
    });

    test('different reviews → not equal', () {
      final a = QuesgenState(reviews: [], isLoading: false, isError: false);
      final b = QuesgenState(
        reviews: [Review(text: 'B', source: 'reddit')],
        isLoading: false,
        isError: false,
      );
      expect(a, isNot(equals(b)));
    });

    test('different isLoading → not equal', () {
      final a = QuesgenState(reviews: [], isLoading: false, isError: false);
      final b = a.copyWith(isLoading: true);
      expect(a, isNot(equals(b)));
    });

    test('different isError → not equal', () {
      final a = QuesgenState(reviews: [], isLoading: false, isError: false);
      final b = a.copyWith(isError: true);
      expect(a, isNot(equals(b)));
    });

    test('copyWith with no args → equal to original', () {
      final a = QuesgenState(
        reviews: [Review(text: 'X', source: 'reddit')],
        isLoading: false,
        isError: true,
      );
      expect(a.copyWith(), equals(a));
    });
  });

  testWidgets(
    'AI reviews use the resolved app locale instead of the OS locale',
    (tester) async {
      tester.binding.platformDispatcher.localesTestValue = const [
        Locale('en', 'US'),
      ];
      addTearDown(tester.binding.platformDispatcher.clearLocalesTestValue);
      final container = ProviderContainer(
        overrides: [
          appLocaleProvider.overrideWithValue(
            const Locale.fromSubtags(
              languageCode: 'zh',
              scriptCode: 'Hant',
              countryCode: 'TW',
            ),
          ),
          quesgenApiProvider.overrideWithValue(_LanguageEchoQuesgenApi()),
        ],
      );
      addTearDown(container.dispose);

      await container
          .read(quesgenControllerProvider.notifier)
          .generateReviews(movieId: 42);

      expect(
        container.read(quesgenControllerProvider).reviews.single.text,
        'Review zh-TW',
      );
    },
  );
}
