import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_journal/features/journal/widgets/rating_selector.dart';
import 'package:movie_journal/themes.dart';

void main() {
  Widget buildSubject({int rating = 0, ValueChanged<int>? onChanged}) {
    return MaterialApp(
      theme: Themes.dark,
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: RatingSelector(rating: rating, onChanged: onChanged),
        ),
      ),
    );
  }

  testWidgets('renders a ten-heart unselected scale', (tester) async {
    await tester.pumpWidget(buildSubject());

    expect(find.text('How much did you enjoy this movie?'), findsOneWidget);
    expect(find.byType(SvgPicture), findsNWidgets(10));
    for (final svg in tester.widgetList<SvgPicture>(find.byType(SvgPicture))) {
      expect(
        (svg.bytesLoader as SvgAssetLoader).assetName,
        'assets/images/rating_heart_unselected.svg',
      );
    }
  });

  testWidgets('uses equal top and bottom padding', (tester) async {
    await tester.pumpWidget(buildSubject());

    final card = tester.widget<Container>(
      find.byKey(const ValueKey('rating-card')),
    );
    expect(
      card.padding,
      const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
    );
  });

  testWidgets('fills every heart through the selected rating', (tester) async {
    await tester.pumpWidget(buildSubject(rating: 3));

    final assetNames =
        tester
            .widgetList<SvgPicture>(find.byType(SvgPicture))
            .map((svg) => (svg.bytesLoader as SvgAssetLoader).assetName)
            .toList();
    expect(
      assetNames.take(3),
      everyElement('assets/images/rating_heart_selected.svg'),
    );
    expect(
      assetNames.skip(3),
      everyElement('assets/images/rating_heart_unselected.svg'),
    );
  });

  testWidgets('reports the tapped one-based rating', (tester) async {
    int? selected;
    await tester.pumpWidget(
      buildSubject(onChanged: (value) => selected = value),
    );

    await tester.tap(find.byKey(const ValueKey('rating-heart-7')));
    expect(selected, 7);
  });

  testWidgets('pressing and dragging scrubs the rating left and right', (
    tester,
  ) async {
    int? selected;
    await tester.pumpWidget(
      buildSubject(onChanged: (value) => selected = value),
    );

    final gesture = await tester.startGesture(
      tester.getCenter(find.byKey(const ValueKey('rating-heart-3'))),
    );
    await tester.pump(kLongPressTimeout + const Duration(milliseconds: 50));

    await gesture.moveTo(
      tester.getCenter(find.byKey(const ValueKey('rating-heart-8'))),
    );
    await tester.pump();
    expect(selected, 8);

    await gesture.moveTo(
      tester.getCenter(find.byKey(const ValueKey('rating-heart-2'))),
    );
    await tester.pump();
    expect(selected, 2);

    await gesture.up();
  });
}
