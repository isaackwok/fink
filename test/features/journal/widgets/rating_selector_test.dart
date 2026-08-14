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

  testWidgets('shows the numeric score for empty and rated states', (
    tester,
  ) async {
    await tester.pumpWidget(buildSubject());

    expect(find.text('0/10'), findsOneWidget);

    await tester.pumpWidget(buildSubject(rating: 3));

    expect(find.text('3/10'), findsOneWidget);
  });

  testWidgets('keeps every heart fixed when rating changes from 9 to 10', (
    tester,
  ) async {
    await tester.pumpWidget(buildSubject(rating: 9));

    final positionsAtNine = [
      for (var value = 1; value <= 10; value++)
        tester.getTopLeft(find.byKey(ValueKey('rating-heart-$value'))),
    ];

    await tester.pumpWidget(buildSubject(rating: 10));

    final positionsAtTen = [
      for (var value = 1; value <= 10; value++)
        tester.getTopLeft(find.byKey(ValueKey('rating-heart-$value'))),
    ];
    expect(positionsAtTen, positionsAtNine);
  });

  testWidgets('uses sixteen pixels of padding on every side', (tester) async {
    await tester.pumpWidget(buildSubject());

    final card = tester.widget<Container>(
      find.byKey(const ValueKey('rating-card')),
    );
    expect(card.padding, const EdgeInsets.all(16));
  });

  testWidgets('keeps the same border dimensions when rated', (tester) async {
    await tester.pumpWidget(buildSubject());

    final cardFinder = find.byKey(const ValueKey('rating-card'));
    final unselectedSize = tester.getSize(cardFinder);
    final unselectedDecoration =
        tester.widget<Container>(cardFinder).decoration! as BoxDecoration;
    final unselectedBorder = unselectedDecoration.border! as Border;

    await tester.pumpWidget(buildSubject(rating: 5));

    final ratedSize = tester.getSize(cardFinder);
    final ratedDecoration =
        tester.widget<Container>(cardFinder).decoration! as BoxDecoration;
    final ratedBorder = ratedDecoration.border! as Border;

    expect(ratedSize, unselectedSize);
    expect(ratedBorder.top.width, unselectedBorder.top.width);
    expect(ratedBorder.top.color, DarkSurfaces.card);
    expect(ratedDecoration.color, DarkSurfaces.card);
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

  testWidgets('tapping the selected rating clears all hearts', (tester) async {
    var rating = 5;

    await tester.pumpWidget(
      MaterialApp(
        theme: Themes.dark,
        home: Scaffold(
          body: StatefulBuilder(
            builder:
                (context, setState) => RatingSelector(
                  rating: rating,
                  onChanged: (value) => setState(() => rating = value),
                ),
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('rating-heart-5')));
    await tester.pump();

    expect(rating, 0);
    for (final svg in tester.widgetList<SvgPicture>(find.byType(SvgPicture))) {
      expect(
        (svg.bytesLoader as SvgAssetLoader).assetName,
        'assets/images/rating_heart_unselected.svg',
      );
    }
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
