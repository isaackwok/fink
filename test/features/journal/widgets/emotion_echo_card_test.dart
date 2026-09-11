import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jiffy/jiffy.dart';
import 'package:movie_journal/features/journal/controllers/journal.dart';
import 'package:movie_journal/features/journal/widgets/emotion_echo_card.dart';

import '../../../helpers/localized_test_app.dart';
import '../../../helpers/test_journal.dart';
import '../../../helpers/widget_test_setup.dart';

void main() {
  setUpAll(() => setUpWidgetTests());
  tearDownAll(() => tearDownWidgetTests());

  const cardWidth = 358.0;
  final longThoughts = 'What makes this movie so incredible ' * 8;

  Widget subject(JournalState journal) => ProviderScope(
    child: localizedTestApp(
      home: Scaffold(
        // Scrollable so a long excerpt can't overflow the 600pt test surface.
        body: SingleChildScrollView(
          child: Center(
            child: SizedBox(
              width: cardWidth,
              child: EmotionEchoCard(
                journal: journal,
                onOpen: () {},
                onAddNow: () {},
              ),
            ),
          ),
        ),
      ),
    ),
  );

  JournalState journalWith({String thoughts = 'Unforgettable.'}) => makeJournal(
    id: 'echo',
    movieTitle: 'Sentimental Value',
    selectedScenes: [SceneItem(path: '/scene.jpg')],
    thoughts: thoughts,
    createdAt: Jiffy.parseFromDateTime(DateTime(2025, 10, 20)),
  );

  Text textWidget(WidgetTester tester, String data) =>
      tester.widget<Text>(find.text(data));

  group('EmotionEchoCard (Figma 7363:24722)', () {
    testWidgets('title is AvenirNext Bold 20 and the date reads "Oct, 2025"', (
      tester,
    ) async {
      await tester.pumpWidget(subject(journalWith()));
      await tester.pumpAndSettle();

      final title = textWidget(tester, 'Sentimental Value');
      expect(title.style?.fontFamily, 'AvenirNext');
      expect(title.style?.fontWeight, FontWeight.w700);
      expect(title.style?.fontSize, 20);

      expect(find.text('Oct, 2025'), findsOneWidget);
    });

    testWidgets('wraps the excerpt in Flavors quote marks on both sides', (
      tester,
    ) async {
      await tester.pumpWidget(subject(journalWith()));
      await tester.pumpAndSettle();

      for (final glyph in ['“', '”']) {
        final quote = textWidget(tester, glyph);
        expect(quote.style?.fontFamily, startsWith('Flavors'));
        expect(quote.style?.fontSize, 36);
        expect(quote.style?.letterSpacing, 0.72);
        expect(quote.style?.color, const Color(0xFFFFF1D7));
      }

      // Text.rich lowers to a RichText, which is what findRichText matches.
      final excerpt = tester.widget<RichText>(
        find.textContaining('Unforgettable.', findRichText: true),
      );
      expect(excerpt.textAlign, TextAlign.center);
    });

    testWidgets('layout spec: 12 title→date, 12 image→quote, 16 quote→text', (
      tester,
    ) async {
      await tester.pumpWidget(subject(journalWith()));
      await tester.pumpAndSettle();

      final title = tester.getRect(find.text('Sentimental Value'));
      final date = tester.getRect(find.text('Oct, 2025'));
      expect(date.top - title.bottom, 12);

      final image = tester.getRect(find.byType(ClipRRect));
      expect(image.height, 207);

      final open = tester.getRect(find.text('“'));
      final close = tester.getRect(find.text('”'));
      expect(open.top - image.bottom, 12);
      expect(close.top, open.top);

      final excerpt = tester.getRect(
        find.textContaining('Unforgettable.', findRichText: true),
      );
      expect(excerpt.left - open.right, 16);
      expect(close.left - excerpt.right, 16);
      // The excerpt sits 8pt below the quote marks' top edge.
      expect(excerpt.top - open.top, 8);
    });

    testWidgets('a long excerpt is capped at 5 lines and ends with "…more"', (
      tester,
    ) async {
      await tester.pumpWidget(subject(journalWith(thoughts: longThoughts)));
      await tester.pumpAndSettle();

      final excerpt = find.textContaining('…more', findRichText: true);
      expect(excerpt, findsOneWidget);
      // Re-lay the rendered span out at its rendered width to count lines.
      final rich = tester.widget<RichText>(excerpt);
      final width = tester.getSize(excerpt).width;
      final painter = TextPainter(
        text: rich.text,
        textAlign: rich.textAlign,
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: width);
      expect(painter.computeLineMetrics().length, 5);
      painter.dispose();
      // The link is the visible tail — nothing is ellipsized past it.
      expect(rich.text.toPlainText(), endsWith('…more'));
    });

    testWidgets('a short excerpt shows in full with no link', (tester) async {
      await tester.pumpWidget(subject(journalWith()));
      await tester.pumpAndSettle();

      expect(find.textContaining('…more', findRichText: true), findsNothing);
    });

    group('thought-less journal (Figma 7369:29163)', () {
      testWidgets('shows the italic prompt and bold Fill in memory + pencil', (
        tester,
      ) async {
        await tester.pumpWidget(subject(journalWith(thoughts: '')));
        await tester.pumpAndSettle();

        expect(find.text('“'), findsNothing);
        expect(find.text('”'), findsNothing);

        final prompt = textWidget(tester, 'No thoughts for this movie yet');
        expect(prompt.style?.fontStyle, FontStyle.italic);
        expect(prompt.style?.color, const Color(0xFFD8D8D8));

        final action = textWidget(tester, 'Fill in memory');
        expect(action.style?.fontWeight, FontWeight.w700);
        expect(action.style?.color, Colors.white);
        expect(find.byIcon(Icons.edit), findsOneWidget);

        // The nudge sits 16 below the still (the quoted excerpt sits 12).
        final image = tester.getRect(find.byType(ClipRRect));
        final promptRect = tester.getRect(
          find.text('No thoughts for this movie yet'),
        );
        expect(promptRect.top - image.bottom, 16);
      });

      testWidgets('Fill in memory fires onAddNow; the rest fires onOpen', (
        tester,
      ) async {
        var opened = 0;
        var addNow = 0;
        await tester.pumpWidget(
          ProviderScope(
            child: localizedTestApp(
              home: Scaffold(
                body: SingleChildScrollView(
                  child: SizedBox(
                    width: cardWidth,
                    child: EmotionEchoCard(
                      journal: journalWith(thoughts: ''),
                      onOpen: () => opened++,
                      onAddNow: () => addNow++,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Fill in memory'));
        expect(addNow, 1);
        expect(opened, 0);

        await tester.tap(find.text('Sentimental Value'));
        expect(opened, 1);
        expect(addNow, 1);
      });
    });

    testWidgets('a journal with no selected scene has no image row', (
      tester,
    ) async {
      final journal = makeJournal(
        id: 'no-scene',
        movieTitle: 'Past Lives',
        thoughts: 'Quiet and devastating.',
        createdAt: Jiffy.parseFromDateTime(DateTime(2023, 3, 1)),
      );
      await tester.pumpWidget(subject(journal));
      await tester.pumpAndSettle();

      expect(find.byType(ClipRRect), findsNothing);
      // With no still, the date runs straight into the quote block (12).
      final date = tester.getRect(find.text('Mar, 2023'));
      final open = tester.getRect(find.text('“'));
      expect(open.top - date.bottom, 12);
    });
  });
}
