import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_journal/features/emotion/emotion.dart';
import 'package:movie_journal/features/emotion/emotion_group_colors.dart';
import 'package:movie_journal/features/journal/controllers/journal.dart';
import 'package:movie_journal/features/journal/controllers/journals.dart';
import 'package:movie_journal/features/journal/screens/journal_content.dart';
import 'package:movie_journal/features/journal/widgets/emotion_echo_card.dart';
import 'package:movie_journal/features/journal/widgets/emotion_echo_header_icon.dart';
import 'package:movie_journal/features/journal/widgets/emotion_echoes_section.dart';

import '../../../helpers/fake_journals_controller.dart';
import '../../../helpers/localized_test_app.dart';
import '../../../helpers/test_journal.dart';
import '../../../helpers/widget_test_setup.dart';

void main() {
  setUpAll(() => setUpWidgetTests());
  tearDownAll(() => tearDownWidgetTests());

  final joyful = emotionList[EmotionType.joyful]!;
  final funny = emotionList[EmotionType.funny]!;

  final current = makeJournal(
    id: 'current',
    tmdbId: 550,
    movieTitle: 'Fight Club',
    emotions: [joyful, funny],
  );
  final echo1 = makeJournal(
    id: 'echo-1',
    tmdbId: 680,
    movieTitle: 'Se7en',
    emotions: [joyful, funny],
    selectedScenes: [SceneItem(path: '/scene1.jpg')],
    thoughts: 'Unforgettable.',
  );
  final echo2 = makeJournal(
    id: 'echo-2',
    tmdbId: 681,
    movieTitle: 'Alien',
    emotions: [joyful, funny],
    selectedScenes: [SceneItem(path: '/scene2.jpg')],
    thoughts: 'Still holds up.',
  );

  Widget subject(List<JournalState> journals) => ProviderScope(
    overrides: [
      journalsControllerProvider.overrideWith(
        () => FakeJournalsController(journals),
      ),
    ],
    child: localizedTestApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: EmotionEchoesSection(journalId: current.id),
          ),
        ),
      ),
    ),
  );

  group('EmotionEchoesSection (Figma 7369:26245)', () {
    testWidgets('opens with a plain 112pt gap — no hairline divider', (
      tester,
    ) async {
      await tester.pumpWidget(subject([current, echo1, echo2]));
      await tester.pumpAndSettle();

      final section = tester.getRect(find.byType(EmotionEchoesSection));
      final header = tester.getRect(find.byType(EmotionEchoHeaderIcon));
      expect(header.top - section.top, 112);
      expect(header.size, const Size(24, 24));

      // The old 0.5pt hairline between achievements and echoes is gone.
      expect(
        find.descendant(
          of: find.byType(EmotionEchoesSection),
          matching: find.byWidgetPredicate(
            (w) => w is Container && w.constraints?.maxHeight == 0.5,
          ),
        ),
        findsNothing,
      );
    });

    testWidgets('header → first card is 32, cards are 24 apart', (
      tester,
    ) async {
      await tester.pumpWidget(subject([current, echo1, echo2]));
      await tester.pumpAndSettle();

      final header = tester.getRect(find.byType(EmotionEchoHeaderIcon));
      final cards = find.byType(EmotionEchoCard, skipOffstage: false);
      expect(cards, findsNWidgets(2));

      final first = tester.getRect(cards.at(0));
      final second = tester.getRect(cards.at(1));
      expect(first.top - header.bottom, 32);
      expect(second.top - first.bottom, 24);
    });

    testWidgets('tapping a card opens the journal with share/delete hidden', (
      tester,
    ) async {
      await tester.pumpWidget(subject([current, echo1, echo2]));
      await tester.pumpAndSettle();

      // The winning group renders in random order, so tap whichever card is
      // first (the second may sit below the 600pt test viewport).
      final firstCard = find.byType(EmotionEchoCard).first;
      final tapped = tester.widget<EmotionEchoCard>(firstCard).journal.id;
      await tester.tap(firstCard);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      final page = tester.widget<JournalContent>(find.byType(JournalContent));
      expect(page.journalId, tapped);
      expect(page.showShareAndDelete, isFalse);
    });

    testWidgets('header circles take the shared emotions\' group colors', (
      tester,
    ) async {
      await tester.pumpWidget(subject([current, echo1, echo2]));
      await tester.pumpAndSettle();

      final icon = tester.widget<EmotionEchoHeaderIcon>(
        find.byType(EmotionEchoHeaderIcon),
      );
      // joyful + funny are both Uplifting.
      expect(icon.colors, [
        EmotionGroupColors.of(joyful.group),
        EmotionGroupColors.of(funny.group),
      ]);
    });

    testWidgets('renders nothing when no previous journal qualifies', (
      tester,
    ) async {
      await tester.pumpWidget(subject([current]));
      await tester.pumpAndSettle();

      expect(find.byType(EmotionEchoHeaderIcon), findsNothing);
      expect(find.byType(EmotionEchoCard), findsNothing);
    });
  });
}
