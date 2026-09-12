import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_journal/features/emotion/emotion.dart';
import 'package:movie_journal/features/home/widgets/journal_card.dart';
import 'package:movie_journal/features/journal/controllers/journal.dart';
import 'package:movie_journal/features/journal/controllers/journals.dart';
import 'package:movie_journal/features/journal/controllers/journal_insights.dart';
import 'package:movie_journal/features/journal/data/journal_insights_api.dart';
import 'package:movie_journal/features/journal/screens/journal_complete.dart';
import 'package:movie_journal/features/journal/widgets/achievement_card.dart';
import 'package:movie_journal/features/journal/widgets/emotion_echo_card.dart';
import 'package:movie_journal/features/share/share_flow.dart';
import 'package:movie_journal/features/share/screens/ticket_poster_picker_screen.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../helpers/fake_journals_controller.dart';
import '../../../helpers/test_journal.dart';
import '../../../helpers/localized_test_app.dart';
import '../../../helpers/widget_test_setup.dart';

/// Returns a fixed achievements list; a null list means never complete
/// (drives the skeleton branch).
class _FixedInsightsApi extends JournalInsightsApi {
  _FixedInsightsApi(this.result);

  final List<Achievement>? result;

  @override
  Future<List<Achievement>> fetchAchievements(int tmdbId) {
    final r = result;
    if (r == null) return Completer<List<Achievement>>().future;
    return Future.value(r);
  }
}

class _ThrowingInsightsApi extends JournalInsightsApi {
  @override
  Future<List<Achievement>> fetchAchievements(int tmdbId) async {
    throw Exception('function unreachable');
  }
}

// Note: journal_complete.dart now logs a screen view in initState via AnalyticsManager.
// The call is safely wrapped and is a no-op without Firebase — no test changes needed.

void main() {
  setUpAll(() => setUpWidgetTests());
  tearDownAll(() => tearDownWidgetTests());

  group('JournalCompleteScreen', () {
    late JournalState journal;

    setUp(() {
      journal = makeJournal(
        id: 'test-journal-123',
        movieTitle: 'Fight Club',
        moviePoster: '/poster.jpg',
      );
    });

    Widget buildSubject({Locale locale = const Locale('en')}) {
      return ProviderScope(
        child: localizedTestApp(
          locale: locale,
          home: JournalCompleteScreen(journal: journal),
        ),
      );
    }

    testWidgets('renders checkmark icon', (tester) async {
      await tester.pumpWidget(buildSubject());
      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('scroll viewport extends through the bottom safe area', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 844);
      tester.view.padding = const FakeViewPadding(top: 54, bottom: 34);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetPadding);

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      final scroll = find.byType(SingleChildScrollView);
      expect(tester.getRect(scroll).bottom, 844);
      expect(tester.getRect(scroll).top, 54);
      expect(
        tester.widget<SingleChildScrollView>(scroll).padding,
        const EdgeInsets.only(bottom: 34),
      );
    });

    testWidgets('renders success message text', (tester) async {
      await tester.pumpWidget(buildSubject());
      expect(find.text("You've saved a journal"), findsOneWidget);
    });

    testWidgets('renders Taiwan Traditional Chinese completion actions', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildSubject(
          locale: const Locale.fromSubtags(
            languageCode: 'zh',
            scriptCode: 'Hant',
            countryCode: 'TW',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('日記已儲存'), findsOneWidget);
      expect(find.text('分享票卡'), findsOneWidget);
      expect(find.text('查看日記'), findsOneWidget);
    });

    testWidgets('renders Share Ticket as ElevatedButton', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();
      expect(
        find.widgetWithText(ElevatedButton, 'Share Ticket'),
        findsOneWidget,
      );
    });

    testWidgets('renders View Journal as TextButton', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();
      expect(find.widgetWithText(TextButton, 'View Journal'), findsOneWidget);
    });

    testWidgets('completion preview and buttons match rounded Figma spacing', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();
      final card = tester.getRect(find.byType(JournalCard));
      final share = tester.getRect(find.byType(ElevatedButton));
      final view = tester.getRect(find.byType(TextButton));
      expect(
        tester
            .widget<JournalCard>(find.byType(JournalCard))
            .isCompletionPreview,
        isTrue,
      );
      expect(card.width, 224);
      expect(card.height, closeTo(355, 1));
      expect(share.top - card.bottom, 32);
      expect(share.height, closeTo(36, 1));
      expect(view.top - share.bottom, 16);
      expect(view.height, closeTo(28, 1));
    });

    testWidgets('wraps JournalCard in IgnorePointer to disable tap', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject());

      final ignorePointer = find.ancestor(
        of: find.byType(JournalCard),
        matching: find.byWidgetPredicate(
          (w) => w is IgnorePointer && w.ignoring,
        ),
      );
      expect(ignorePointer, findsOneWidget);
    });

    testWidgets('displays movie title from journal data', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();
      expect(find.text('Fight Club'), findsOneWidget);
    });

    testWidgets('Share Ticket button is tappable without errors', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // Top-anchored layout: the buttons sit below the 600px test viewport.
      await tester.ensureVisible(find.text('Share Ticket'));
      await tester.tap(find.text('Share Ticket'));
      await tester.pumpAndSettle();
      // No exception = handler ran without crash (currently a TODO stub)
    });

    testWidgets('Share Ticket navigates to TicketPosterPickerScreen', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // Top-anchored layout: the buttons sit below the 600px test viewport.
      await tester.ensureVisible(find.text('Share Ticket'));
      await tester.tap(find.text('Share Ticket'));
      await tester.pumpAndSettle();

      // Verifies the new required `entry` parameter is satisfied and
      // navigation from JournalComplete reaches the poster picker screen.
      expect(find.byType(TicketPosterPickerScreen), findsOneWidget);
    });

    testWidgets('Share Ticket pushes a route tagged with kShareFlowRouteName', (
      tester,
    ) async {
      // Tagging is load-bearing: closeShareFlow popUntil's predicate uses the
      // route name to know where the share flow ends. If the tag is missing,
      // the journalContent close path overshoots back past JournalContent.
      final observer = _RouteSettingsObserver();
      await tester.pumpWidget(
        ProviderScope(
          child: localizedTestApp(
            navigatorObservers: [observer],
            home: JournalCompleteScreen(journal: journal),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Top-anchored layout: the buttons sit below the 600px test viewport.
      await tester.ensureVisible(find.text('Share Ticket'));
      await tester.tap(find.text('Share Ticket'));
      await tester.pumpAndSettle();

      expect(observer.lastPushedName, kShareFlowRouteName);
    });

    testWidgets('checkmark has filled white circle with dark icon', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      final container = tester.widget<Container>(
        find
            .ancestor(
              of: find.byIcon(Icons.check),
              matching: find.byType(Container),
            )
            .first,
      );

      final decoration = container.decoration as BoxDecoration;
      expect(decoration.shape, BoxShape.circle);
      expect(decoration.color, Colors.white);

      final icon = tester.widget<Icon>(find.byIcon(Icons.check));
      expect(icon.color, Colors.black);
    });

    testWidgets('all elements visible after animations complete', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.check), findsOneWidget);
      expect(find.text("You've saved a journal"), findsOneWidget);
      expect(find.byType(JournalCard), findsOneWidget);
      expect(find.text('Share Ticket'), findsOneWidget);
      expect(find.text('View Journal'), findsOneWidget);
    });

    testWidgets('renders close (X) icon button', (tester) async {
      await tester.pumpWidget(buildSubject());
      // Close button is outside the FadeTransition group, so it's there
      // immediately on first frame.
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('tapping close pops back to the first route (home)', (
      tester,
    ) async {
      // JournalCompleteScreen reaches the user via pushAndRemoveUntil
      // sitting on top of Home. Simulate that by pushing it onto a sentinel
      // home route, then verify close pops back to that sentinel.
      await tester.pumpWidget(
        ProviderScope(
          child: localizedTestApp(
            home: Builder(
              builder:
                  (context) => Scaffold(
                    body: Center(
                      child: ElevatedButton(
                        onPressed:
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) =>
                                        JournalCompleteScreen(journal: journal),
                              ),
                            ),
                        child: const Text('open-complete-sentinel'),
                      ),
                    ),
                  ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open-complete-sentinel'));
      await tester.pumpAndSettle();
      expect(find.byType(JournalCompleteScreen), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(find.byType(JournalCompleteScreen), findsNothing);
      expect(find.text('open-complete-sentinel'), findsOneWidget);
    });
  });

  group('JournalCompleteScreen insights sections', () {
    final joyful = emotionList[EmotionType.joyful]!;
    final funny = emotionList[EmotionType.funny]!;

    late JournalState journal;

    setUp(() {
      journal = makeJournal(
        id: 'current',
        tmdbId: 550,
        movieTitle: 'Fight Club',
        moviePoster: '/poster.jpg',
        emotions: [joyful, funny],
      );
    });

    Widget buildSubject({
      required JournalInsightsApi api,
      List<JournalState> journals = const [],
    }) {
      return ProviderScope(
        overrides: [
          journalInsightsApiProvider.overrideWithValue(api),
          journalsControllerProvider.overrideWith(
            () => FakeJournalsController([journal, ...journals]),
          ),
        ],
        child: localizedTestApp(home: JournalCompleteScreen(journal: journal)),
      );
    }

    const fincher = Achievement(
      kind: AchievementKind.director,
      key: '7467',
      name: 'David Fincher',
      count: 3,
    );
    const nineties = Achievement(
      kind: AchievementKind.decade,
      key: '1990',
      name: '1990',
      count: 2,
    );

    testWidgets('both sections hidden when empty — base layout intact', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject(api: _FixedInsightsApi(const [])));
      await tester.pumpAndSettle();

      expect(find.byType(AchievementCard), findsNothing);
      expect(find.byType(EmotionEchoCard), findsNothing);
      expect(find.byIcon(Icons.check), findsOneWidget);
      expect(find.text('Share Ticket'), findsOneWidget);
    });

    testWidgets('achievements section hidden on error', (tester) async {
      await tester.pumpWidget(buildSubject(api: _ThrowingInsightsApi()));
      await tester.pumpAndSettle();

      expect(find.byType(AchievementCard), findsNothing);
      expect(
        find.byWidgetPredicate((w) => w is Skeletonizer, skipOffstage: false),
        findsNothing,
      );
    });

    testWidgets('achievement cards render with a bold-count header', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildSubject(api: _FixedInsightsApi(const [fincher, nineties])),
      );
      await tester.pumpAndSettle();

      expect(
        find.byType(AchievementCard, skipOffstage: false),
        findsNWidgets(2),
      );
      expect(find.text('Your achievements'), findsOneWidget);
      expect(
        find.text('David Fincher', findRichText: true, skipOffstage: false),
        findsOneWidget,
      );
      // Era bucket below 2020 renders as a decade label.
      expect(
        find.text('the 90s', findRichText: true, skipOffstage: false),
        findsOneWidget,
      );
    });

    testWidgets('skeleton grid shows while insights load', (tester) async {
      await tester.pumpWidget(buildSubject(api: _FixedInsightsApi(null)));
      // The shimmer loops forever — fixed pumps only, never pumpAndSettle.
      await tester.pump(const Duration(milliseconds: 1300));

      // Skeletonizer.zone builds a private Skeletonizer subclass, so byType
      // (exact runtimeType) misses it — match on the public supertype.
      expect(
        find.byWidgetPredicate((w) => w is Skeletonizer, skipOffstage: false),
        findsOneWidget,
      );
      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets('echo cards render for the shared emotion group', (
      tester,
    ) async {
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
      );
      await tester.pumpWidget(
        buildSubject(
          api: _FixedInsightsApi(const []),
          journals: [echo1, echo2],
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byType(EmotionEchoCard, skipOffstage: false),
        findsNWidgets(2),
      );
      // Header bolds each shared group name, joined with the same localized
      // separators as EmotionsSelectorButton on JournalContent.
      expect(
        find.textContaining('joyful and funny', findRichText: true),
        findsOneWidget,
      );
      // The thought-less journal shows the italic prompt + Fill in memory.
      expect(
        find.text('No thoughts for this movie yet', skipOffstage: false),
        findsOneWidget,
      );
      expect(find.text('Fill in memory', skipOffstage: false), findsOneWidget);
    });

    testWidgets('a single shared emotion produces no echo section', (
      tester,
    ) async {
      final oneShared = makeJournal(
        id: 'one',
        tmdbId: 680,
        emotions: [joyful],
        selectedScenes: [SceneItem(path: '/scene.jpg')],
      );
      await tester.pumpWidget(
        buildSubject(api: _FixedInsightsApi(const []), journals: [oneShared]),
      );
      await tester.pumpAndSettle();

      expect(find.byType(EmotionEchoCard, skipOffstage: false), findsNothing);
    });
  });
}

class _RouteSettingsObserver extends NavigatorObserver {
  String? lastPushedName;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    lastPushedName = route.settings.name;
  }
}
