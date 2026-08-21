import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_journal/features/journal/controllers/journal_insights.dart';
import 'package:movie_journal/features/journal/data/journal_insights_api.dart';

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
      final refreshing = container
          .read(journalInsightsControllerProvider(550).notifier)
          .refresh();

      final during = container.read(journalInsightsControllerProvider(550));
      expect(during.isLoading, isTrue);
      expect(during.value, [_fincher], reason: 'previous data stays visible');

      second.complete([_fincher, _nineties]);
      await refreshing;
      expect(
        container.read(journalInsightsControllerProvider(550)).value,
        [_fincher, _nineties],
      );
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
      expect(
        container.read(journalInsightsControllerProvider(550)).value,
        [_fincher],
      );
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
}
