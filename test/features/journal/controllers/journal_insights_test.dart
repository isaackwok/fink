import 'dart:async';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:movie_journal/features/emotion/emotion.dart';
import 'package:movie_journal/features/journal/controllers/journal_insights.dart';
import 'package:movie_journal/features/journal/data/journal_insights_api.dart';

import '../../../helpers/test_journal.dart';

const _fincher = Achievement(
  kind: AchievementKind.director,
  key: '7467',
  name: 'David Fincher',
  count: 3,
);
const _nineties = Achievement(
  kind: AchievementKind.decade,
  key: '1990',
  name: '1990',
  count: 2,
);

/// Completer-backed fake: each fetchAchievements call awaits the next queued
/// completer, so tests control exactly when (and how) a fetch resolves.
class _ControlledInsightsApi extends JournalInsightsApi {
  final calls = <int>[];
  final _pending = <Completer<List<Achievement>>>[];

  Completer<List<Achievement>> queue() {
    final c = Completer<List<Achievement>>();
    _pending.add(c);
    return c;
  }

  @override
  Future<List<Achievement>> fetchAchievements(int tmdbId) {
    calls.add(tmdbId);
    return _pending.removeAt(0).future;
  }
}

void main() {
  late _ControlledInsightsApi api;
  late ProviderContainer container;

  setUp(() {
    api = _ControlledInsightsApi();
    container = ProviderContainer(
      overrides: [journalInsightsApiProvider.overrideWithValue(api)],
    );
    // No keep-alive listener needed: the provider is deliberately NOT
    // autoDispose (see journal_insights.dart), so reading `.future` cannot
    // hit the dispose-mid-load hang from Known Test Findings.
  });

  tearDown(() => container.dispose());

  test('build fetches achievements for the family tmdbId', () async {
    api.queue().complete([_fincher, _nineties]);
    final result = await container.read(
      journalInsightsControllerProvider(550).future,
    );
    expect(result, [_fincher, _nineties]);
    expect(api.calls, [550]);
  });

  test('a failed fetch settles as AsyncError (no retry hang)', () async {
    api.queue().completeError(Exception('function unreachable'));
    await expectLater(
      container.read(journalInsightsControllerProvider(550).future),
      throwsException,
    );
    expect(
      container.read(journalInsightsControllerProvider(550)),
      isA<AsyncError<List<Achievement>>>(),
    );
  });

  test('family instances are independent per tmdbId', () async {
    api.queue().complete([_fincher]);
    api.queue().complete(const []);
    final a = await container.read(
      journalInsightsControllerProvider(550).future,
    );
    final b = await container.read(
      journalInsightsControllerProvider(680).future,
    );
    expect(a, [_fincher]);
    expect(b, isEmpty);
    expect(api.calls, [550, 680]);
  });

  group('refresh', () {
    test('keeps the cached value visible while refetching', () async {
      api.queue().complete([_fincher]);
      await container.read(journalInsightsControllerProvider(550).future);

      final second = api.queue();
      final refreshing =
          container
              .read(journalInsightsControllerProvider(550).notifier)
              .refresh();

      final during = container.read(journalInsightsControllerProvider(550));
      expect(during.isLoading, isTrue);
      expect(during.value, [_fincher], reason: 'previous data stays visible');

      second.complete([_fincher, _nineties]);
      await refreshing;
      expect(container.read(journalInsightsControllerProvider(550)).value, [
        _fincher,
        _nineties,
      ]);
      expect(api.calls, [550, 550]);
    });

    test('recovers from an earlier error', () async {
      api.queue().completeError(Exception('offline'));
      await expectLater(
        container.read(journalInsightsControllerProvider(550).future),
        throwsException,
      );

      api.queue().complete([_fincher]);
      await container
          .read(journalInsightsControllerProvider(550).notifier)
          .refresh();
      expect(container.read(journalInsightsControllerProvider(550)).value, [
        _fincher,
      ]);
    });

    test('a refresh failure surfaces as AsyncError', () async {
      api.queue().complete([_fincher]);
      await container.read(journalInsightsControllerProvider(550).future);

      api.queue().completeError(Exception('offline'));
      await container
          .read(journalInsightsControllerProvider(550).notifier)
          .refresh();
      final after = container.read(journalInsightsControllerProvider(550));
      expect(after.hasError, isTrue);
    });
  });

  group('computeEmotionEchoes', () {
    final joyful = emotionList[EmotionType.joyful]!;
    final funny = emotionList[EmotionType.funny]!;
    final inspired = emotionList[EmotionType.inspired]!;
    final hopeful = emotionList[EmotionType.hopeful]!;

    test('requires at least 2 shared emotions', () {
      final current = makeJournal(
        id: 'cur',
        tmdbId: 550,
        emotions: [joyful, funny],
      );
      final oneShared = makeJournal(
        id: 'o1',
        tmdbId: 680,
        emotions: [joyful, hopeful],
      );
      final result = computeEmotionEchoes(
        current: current,
        all: [current, oneShared],
      );
      expect(result.isEmpty, isTrue);
      expect(result.headerEmotions, isEmpty);
    });

    test('excludes the current journal and same-movie journals', () {
      final current = makeJournal(
        id: 'cur',
        tmdbId: 550,
        emotions: [joyful, funny],
      );
      final sameMovie = makeJournal(
        id: 'rewatch',
        tmdbId: 550,
        emotions: [joyful, funny],
      );
      final other = makeJournal(
        id: 'o1',
        tmdbId: 680,
        emotions: [joyful, funny],
      );
      final result = computeEmotionEchoes(
        current: current,
        all: [current, sameMovie, other],
      );
      expect(result.echoes.map((e) => e.journal.id), ['o1']);
    });

    test('the most overlapping group wins (A&B&C beats A&C)', () {
      final current = makeJournal(
        id: 'cur',
        tmdbId: 550,
        emotions: [joyful, funny, inspired],
      );
      final abc = makeJournal(
        id: 'abc',
        tmdbId: 680,
        emotions: [joyful, funny, inspired],
      );
      final ac = makeJournal(
        id: 'ac',
        tmdbId: 681,
        emotions: [joyful, inspired],
      );
      final result = computeEmotionEchoes(
        current: current,
        all: [current, abc, ac],
      );
      expect(result.echoes.map((e) => e.journal.id), ['abc']);
      expect(result.headerEmotions, [joyful, funny, inspired]);
    });

    test('a size tie goes to the group with the highest average rating', () {
      final current = makeJournal(
        id: 'cur',
        tmdbId: 550,
        emotions: [joyful, funny, inspired, hopeful],
      );
      // Group joyful&funny: ratings 4 and 6 -> avg 5.
      final low1 = makeJournal(
        id: 'low1',
        tmdbId: 680,
        emotions: [joyful, funny],
        rating: 4,
      );
      final low2 = makeJournal(
        id: 'low2',
        tmdbId: 681,
        emotions: [joyful, funny],
        rating: 6,
      );
      // Group inspired&hopeful: ratings 8 and 6 -> avg 7, wins.
      final high1 = makeJournal(
        id: 'high1',
        tmdbId: 682,
        emotions: [inspired, hopeful],
        rating: 8,
      );
      final high2 = makeJournal(
        id: 'high2',
        tmdbId: 683,
        emotions: [inspired, hopeful],
        rating: 6,
      );
      final result = computeEmotionEchoes(
        current: current,
        all: [current, low1, low2, high1, high2],
      );
      expect(result.echoes.map((e) => e.journal.id).toSet(), {
        'high1',
        'high2',
      });
      expect(result.headerEmotions, [inspired, hopeful]);
    });

    test('displays only journals of the winning group, capped at maxCards', () {
      final current = makeJournal(
        id: 'cur',
        tmdbId: 550,
        emotions: [joyful, funny],
      );
      final members = [
        for (var i = 0; i < 4; i++)
          makeJournal(id: 'm$i', tmdbId: 600 + i, emotions: [joyful, funny]),
      ];
      final result = computeEmotionEchoes(
        current: current,
        all: [current, ...members],
        random: Random(42),
      );
      expect(result.echoes, hasLength(2));
      expect(
        result.echoes.map((e) => e.journal.id).toSet().difference({
          'm0',
          'm1',
          'm2',
          'm3',
        }),
        isEmpty,
      );
    });

    test('order within the group is randomized (seed-dependent)', () {
      final current = makeJournal(
        id: 'cur',
        tmdbId: 550,
        emotions: [joyful, funny],
      );
      final members = [
        for (var i = 0; i < 6; i++)
          makeJournal(id: 'm$i', tmdbId: 600 + i, emotions: [joyful, funny]),
      ];
      List<String> pick(int seed) =>
          computeEmotionEchoes(
            current: current,
            all: [current, ...members],
            random: Random(seed),
          ).echoes.map((e) => e.journal.id).toList();

      // Same seed -> same pick; across many seeds the pick varies.
      expect(pick(1), pick(1));
      final distinct = {for (var s = 0; s < 20; s++) pick(s).join(',')};
      expect(distinct.length, greaterThan(1));
    });

    test('retired emotions still match by id', () {
      final retired = retiredEmotionList.values.first;
      final current = makeJournal(
        id: 'cur',
        tmdbId: 550,
        emotions: [retired, joyful],
      );
      final other = makeJournal(
        id: 'o1',
        tmdbId: 680,
        emotions: [retired, joyful],
      );
      final result = computeEmotionEchoes(
        current: current,
        all: [current, other],
      );
      expect(result.echoes.map((e) => e.journal.id), ['o1']);
      expect(result.headerEmotions, [retired, joyful]);
    });

    test(
      'sharedEmotions carry the winning group in the echo journal own order',
      () {
        final current = makeJournal(
          id: 'cur',
          tmdbId: 550,
          emotions: [joyful, funny],
        );
        final other = makeJournal(
          id: 'o1',
          tmdbId: 680,
          emotions: [funny, hopeful, joyful],
        );
        final result = computeEmotionEchoes(
          current: current,
          all: [current, other],
        );
        expect(result.echoes.single.sharedEmotions, [funny, joyful]);
      },
    );
  });
}
