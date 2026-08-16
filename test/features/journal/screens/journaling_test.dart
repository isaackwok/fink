import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_journal/features/journal/controllers/journal.dart';
import 'package:movie_journal/features/journal/screens/journaling.dart';
import 'package:movie_journal/features/quesgen/review.dart';
import 'package:movie_journal/themes.dart';

import '../../../helpers/test_journal.dart';
import '../../../helpers/localized_test_app.dart';
import '../../../helpers/widget_test_setup.dart';

/// A journal controller whose save() always fails, standing in for a dead
/// network / Supabase outage. A rating alone keeps the Save button enabled.
class _FailingSaveController extends JournalController {
  @override
  JournalState build() => makeJournal(rating: 3);

  @override
  Future<JournalController> save() async {
    throw Exception('supabase unreachable');
  }
}

class _InitialJournalController extends JournalController {
  _InitialJournalController(this.initialState);

  final JournalState initialState;

  @override
  JournalState build() => initialState;
}

Widget _buildSwipeSubject(
  ProviderContainer container, {
  String? editJournalId,
}) {
  return UncontrolledProviderScope(
    container: container,
    child: localizedTestApp(
      theme: Themes.dark,
      home: Builder(
        builder:
            (context) => Scaffold(
              body: Center(
                child: TextButton(
                  onPressed:
                      () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder:
                              (_) => JournalingScreen(
                                movieTitle: 'Fight Club',
                                moviePosterUrl: '/poster.jpg',
                                editJournalId: editJournalId,
                              ),
                        ),
                      ),
                  child: const Text('Open editor'),
                ),
              ),
            ),
      ),
    ),
  );
}

Future<void> _openEditor(WidgetTester tester) async {
  await tester.tap(find.text('Open editor'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

Future<void> _swipeRight(
  WidgetTester tester, {
  double startX = 5,
  double distance = 240,
  Duration duration = const Duration(milliseconds: 300),
}) async {
  await tester.timedDragFrom(
    Offset(startX, 300),
    Offset(distance, 0),
    duration,
  );
  await tester.pump();
}

void main() {
  setUpAll(() => setUpWidgetTests());
  tearDownAll(() => tearDownWidgetTests());

  group('JournalingScreen edge swipe', () {
    late ProviderContainer container;

    tearDown(() {
      container.dispose();
    });

    testWidgets('goes back immediately when the journal has no changes', (
      tester,
    ) async {
      container = ProviderContainer(
        overrides: [
          journalControllerProvider.overrideWith(
            () => _InitialJournalController(makeJournal()),
          ),
        ],
      );
      await tester.pumpWidget(_buildSwipeSubject(container));
      await _openEditor(tester);

      await _swipeRight(tester);
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('Open editor'), findsOneWidget);
      expect(find.text('Discard Changes'), findsNothing);
      expect(container.read(journalControllerProvider).tmdbId, 0);
    });

    testWidgets('a short fast flick from the left edge goes back', (
      tester,
    ) async {
      container = ProviderContainer(
        overrides: [
          journalControllerProvider.overrideWith(
            () => _InitialJournalController(makeJournal()),
          ),
        ],
      );
      await tester.pumpWidget(_buildSwipeSubject(container));
      await _openEditor(tester);

      await _swipeRight(
        tester,
        distance: 50,
        duration: const Duration(milliseconds: 50),
      );
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('Open editor'), findsOneWidget);
    });

    testWidgets('confirms and discards changes when editing a journal', (
      tester,
    ) async {
      container = ProviderContainer(
        overrides: [
          journalControllerProvider.overrideWith(
            () => _InitialJournalController(makeJournal(rating: 3)),
          ),
        ],
      );
      await tester.pumpWidget(
        _buildSwipeSubject(container, editJournalId: 'journal-1'),
      );
      await _openEditor(tester);
      container.read(journalControllerProvider.notifier).setRating(4);
      await tester.pump();

      await _swipeRight(tester);
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Discard Changes'), findsOneWidget);
      expect(find.text('Open editor'), findsNothing);

      await tester.tap(find.text('Discard'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('Open editor'), findsOneWidget);
      expect(container.read(journalControllerProvider).rating, 0);
    });

    testWidgets('goes back directly when an existing journal is unchanged', (
      tester,
    ) async {
      container = ProviderContainer(
        overrides: [
          journalControllerProvider.overrideWith(
            () => _InitialJournalController(makeJournal(rating: 3)),
          ),
        ],
      );
      await tester.pumpWidget(
        _buildSwipeSubject(container, editJournalId: 'journal-1'),
      );
      await _openEditor(tester);

      await _swipeRight(tester);
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('Open editor'), findsOneWidget);
      expect(find.text('Discard Changes'), findsNothing);
    });

    testWidgets('confirms when an AI review is the only unsaved change', (
      tester,
    ) async {
      container = ProviderContainer(
        overrides: [
          journalControllerProvider.overrideWith(
            () => _InitialJournalController(makeJournal()),
          ),
        ],
      );
      await tester.pumpWidget(_buildSwipeSubject(container));
      await _openEditor(tester);
      container
          .read(journalControllerProvider.notifier)
          .addSelectedReview(
            Review(text: 'A memorable review', source: 'reddit'),
          );
      await tester.pump();

      await _swipeRight(tester);
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Discard Changes'), findsOneWidget);
    });

    testWidgets('stays on the editor when swipe discard is cancelled', (
      tester,
    ) async {
      container = ProviderContainer(
        overrides: [
          journalControllerProvider.overrideWith(
            () => _InitialJournalController(makeJournal(rating: 3)),
          ),
        ],
      );
      await tester.pumpWidget(_buildSwipeSubject(container));
      await _openEditor(tester);
      container.read(journalControllerProvider.notifier).setRating(4);
      await tester.pump();

      await _swipeRight(tester);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.text('Cancel'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(JournalingScreen), findsOneWidget);
      expect(find.text('Discard Changes'), findsNothing);
      expect(container.read(journalControllerProvider).rating, 4);
    });

    testWidgets('ignores horizontal drags that start away from the left edge', (
      tester,
    ) async {
      container = ProviderContainer(
        overrides: [
          journalControllerProvider.overrideWith(
            () => _InitialJournalController(makeJournal(rating: 3)),
          ),
        ],
      );
      await tester.pumpWidget(_buildSwipeSubject(container));
      await _openEditor(tester);
      container.read(journalControllerProvider.notifier).setRating(4);
      await tester.pump();

      await _swipeRight(tester, startX: 100);
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(JournalingScreen), findsOneWidget);
      expect(find.text('Discard Changes'), findsNothing);
    });
  });

  group('JournalingScreen save failure', () {
    // Regression test for ISA-9 bug 1: the catch block used to call
    // CustomToast.showSuccess with the failure message, so a failed save
    // looked exactly like a successful one.
    testWidgets('shows an error toast, not a success toast', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            journalControllerProvider.overrideWith(_FailingSaveController.new),
          ],
          child: localizedTestApp(
            home: const JournalingScreen(
              movieTitle: 'Fight Club',
              moviePosterUrl: '/poster.jpg',
            ),
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('Save'));
      await tester.pump();
      await tester.pump();

      expect(
        find.text('Failed to save journal. Please try again.'),
        findsOneWidget,
      );

      // The toast must carry the *error* styling: a close glyph in a circle
      // filled with the error status color (success would be a check on the
      // primary color).
      final toastCircle = tester.widget<Container>(
        find
            .ancestor(
              of: find.byIcon(Icons.close),
              matching: find.byType(Container),
            )
            .first,
      );
      final decoration = toastCircle.decoration as BoxDecoration;
      expect(decoration.color, StatusColors.error);

      // The screen stays put (no navigation to JournalComplete) and the Save
      // button recovers from its spinner state for a retry.
      expect(find.text('Save'), findsOneWidget);

      // Drain the fluttertoast timers before the test ends. pumpAndSettle
      // would never return here: the scenes selector's skeleton shimmer loops
      // forever because movieImages stays AsyncLoading by design (see
      // MovieImagesController.build in CLAUDE.md), so use fixed pumps.
      await tester.pump(const Duration(seconds: 3));
      await tester.pump(const Duration(seconds: 1));
    });
  });
}
