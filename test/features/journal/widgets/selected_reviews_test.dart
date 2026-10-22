import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_journal/features/journal/widgets/selected_reviews.dart';
import 'package:movie_journal/features/quesgen/review.dart';
import 'package:movie_journal/themes.dart';
import '../../../helpers/localized_test_app.dart';
import '../../../helpers/widget_test_setup.dart';

void main() {
  setUpAll(setUpWidgetTests);
  tearDownAll(tearDownWidgetTests);

  testWidgets('removing one review preserves the other and its full text', (
    tester,
  ) async {
    final first = Review(text: 'First review', source: 'reddit');
    final second = Review(text: 'A longer review. ' * 30, source: 'letterboxd');
    var reviews = [first, second];
    await tester.pumpWidget(
      localizedTestApp(
        theme: Themes.dark,
        home: Scaffold(
          body: StatefulBuilder(
            builder:
                (context, setState) => SingleChildScrollView(
                  child: SelectedReviews(
                    references: reviews,
                    onRemove: (review) {
                      setState(
                        () =>
                            reviews =
                                reviews
                                    .where((item) => item != review)
                                    .toList(),
                      );
                    },
                  ),
                ),
          ),
        ),
      ),
    );
    await tester.tap(find.byTooltip('Remove').first);
    await tester.pump();
    expect(reviews, [second]);
    expect(find.text(first.text), findsNothing);
    expect(find.text(second.text), findsOneWidget);
    expect(tester.widget<Text>(find.text(second.text)).maxLines, isNull);
    expect(find.byTooltip('Remove'), findsOneWidget);
    await tester.tap(find.byTooltip('Remove'));
    await tester.pump();
    expect(find.text('You resonated with'), findsNothing);
  });

  testWidgets(
    'Traditional Chinese uses 評論 and read-only cards cannot collapse',
    (tester) async {
      final review = Review(text: '令人回味的電影', source: 'reddit');
      await tester.pumpWidget(
        localizedTestApp(
          locale: const Locale.fromSubtags(
            languageCode: 'zh',
            scriptCode: 'Hant',
            countryCode: 'TW',
          ),
          theme: Themes.dark,
          home: Scaffold(body: SelectedReviews(references: [review])),
        ),
      );
      expect(find.text('讓你產生共鳴的評論'), findsOneWidget);
      expect(find.byIcon(Icons.close), findsNothing);
      await tester.tap(find.text('讓你產生共鳴的評論'));
      await tester.pumpAndSettle();
      expect(find.text(review.text), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
