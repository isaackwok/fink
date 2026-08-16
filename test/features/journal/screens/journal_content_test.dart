import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jiffy/jiffy.dart';
import 'package:movie_journal/features/journal/controllers/journal.dart';
import 'package:movie_journal/features/journal/controllers/journals.dart';
import 'package:movie_journal/features/journal/screens/journal_content.dart';
import 'package:movie_journal/themes.dart';

import '../../../helpers/test_journal.dart';
import '../../../helpers/localized_test_app.dart';
import '../../../helpers/widget_test_setup.dart';

class _FakeJournalsController extends JournalsController {
  _FakeJournalsController(this.journal);

  final JournalState journal;

  @override
  Future<JournalsState> build() async => JournalsState(journals: [journal]);
}

void main() {
  setUpAll(setUpWidgetTests);
  tearDownAll(tearDownWidgetTests);

  Widget buildSubject(JournalState journal) {
    return ProviderScope(
      overrides: [
        journalsControllerProvider.overrideWith(
          () => _FakeJournalsController(journal),
        ),
      ],
      child: localizedTestApp(
        theme: Themes.dark,
        home: JournalContent(journalId: journal.id),
      ),
    );
  }

  testWidgets('shows the rating badge beside the date', (tester) async {
    final journal = makeJournal(
      id: 'rated-journal',
      movieTitle: 'Lost in Translation',
      rating: 2,
      updatedAt: Jiffy.parse('2025-05-27 10:00:00'),
    );

    await tester.pumpWidget(buildSubject(journal));
    await tester.pump();

    expect(find.text('May 27th 2025'), findsOneWidget);
    expect(find.byKey(const ValueKey('journal-rating-badge')), findsOneWidget);
    expect(find.text('2'), findsOneWidget);

    final icon = tester.widget<SvgPicture>(find.byType(SvgPicture));
    expect(
      (icon.bytesLoader as SvgAssetLoader).assetName,
      'assets/images/rating_heart_badge.svg',
    );
  });

  testWidgets('hides the rating badge when the journal is unrated', (
    tester,
  ) async {
    final journal = makeJournal(id: 'unrated-journal');

    await tester.pumpWidget(buildSubject(journal));
    await tester.pump();

    expect(find.byKey(const ValueKey('journal-rating-badge')), findsNothing);
  });

  group('movie title in header', () {
    // Mirrors JournalingScreen: the app-bar title is transparent at the top
    // and fades in once the body title has scrolled up past 100px.
    Finder headerTitle() => find.descendant(
      of: find.byType(SliverAppBar),
      matching: find.byType(AnimatedOpacity),
    );

    JournalState makeScrollableJournal() => makeJournal(
      id: 'scrolling-journal',
      movieTitle: 'Perfect Days',
      // Enough thoughts text to make the scroll view taller than the
      // viewport — otherwise there is nothing to scroll.
      thoughts: 'A long reflection on the film. ' * 200,
    );

    testWidgets('is transparent while at the top', (tester) async {
      await tester.pumpWidget(buildSubject(makeScrollableJournal()));
      await tester.pump();

      expect(tester.widget<AnimatedOpacity>(headerTitle()).opacity, 0.0);
      expect(
        find.descendant(of: headerTitle(), matching: find.text('Perfect Days')),
        findsOneWidget,
      );
    });

    testWidgets('fades in after scrolling down past 100px', (tester) async {
      await tester.pumpWidget(buildSubject(makeScrollableJournal()));
      await tester.pump();

      await tester.drag(find.byType(CustomScrollView), const Offset(0, -300));
      await tester.pumpAndSettle();

      expect(tester.widget<AnimatedOpacity>(headerTitle()).opacity, 1.0);
    });

    testWidgets('goes transparent again when scrolled back to the top', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject(makeScrollableJournal()));
      await tester.pump();

      await tester.drag(find.byType(CustomScrollView), const Offset(0, -300));
      await tester.pumpAndSettle();
      await tester.drag(find.byType(CustomScrollView), const Offset(0, 300));
      await tester.pumpAndSettle();

      expect(tester.widget<AnimatedOpacity>(headerTitle()).opacity, 0.0);
    });
  });
}
