import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_journal/features/emotion/emotion.dart';
import 'package:movie_journal/features/journal/controllers/journal.dart';
import 'package:movie_journal/features/journal/controllers/journals.dart';
import 'package:movie_journal/features/journal/data/journal_insights_api.dart';

final journalInsightsApiProvider = Provider((_) => JournalInsightsApi());

/// One instance per TMDB movie id (`journalInsightsControllerProvider(id)`).
///
/// Mirrors movieDetailControllerProvider's decisions (movie_providers.dart):
/// deliberately NOT autoDispose — JournalingScreen prefetches while the user
/// writes, and the state must survive until JournalCompleteScreen watches it —
/// and retry is disabled so a failed invoke settles as AsyncError immediately
/// (the complete screen hides the section instead of hanging on `.future`).
class JournalInsightsController extends AsyncNotifier<List<Achievement>> {
  JournalInsightsController(this.tmdbId);

  /// The family argument.
  final int tmdbId;

  @override
  Future<List<Achievement>> build() => _fetch();

  Future<List<Achievement>> _fetch() async => onePerKind(
    await ref.read(journalInsightsApiProvider).fetchAchievements(tmdbId),
  );

  /// Refetches while keeping any cached value visible. Guards against
  /// same-session staleness: the family instance survives across journals
  /// (not autoDispose), so a second journal of the same movie would otherwise
  /// show the first save's counts.
  Future<void> refresh() async {
    // Riverpod merges this with the current state (copyWithPrevious under the
    // hood), so a cached list stays visible while the refetch is in flight.
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }
}

/// One card per dimension: the server may emit several achievements of the
/// same kind (co-directors, two top-billed actors); the UI shows only the
/// first of each, in the server's order.
List<Achievement> onePerKind(List<Achievement> achievements) {
  final seen = <AchievementKind>{};
  return [
    for (final a in achievements)
      if (seen.add(a.kind)) a,
  ];
}

Duration? _noRetry(int retryCount, Object error) => null;

final journalInsightsControllerProvider = AsyncNotifierProvider.family<
  JournalInsightsController,
  List<Achievement>,
  int
>(JournalInsightsController.new, retry: _noRetry);

// ---------------------------------------------------------------------------
// Emotion echoes (pure Dart — no fetching; emotions already live on every
// journal in memory).

/// A previous journal resurfaced because it shares emotions with the
/// just-saved one.
class EmotionEcho {
  final JournalState journal;

  /// The winning shared-emotion group, in the echo journal's own emotion
  /// order.
  final List<Emotion> sharedEmotions;

  const EmotionEcho({required this.journal, required this.sharedEmotions});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EmotionEcho &&
          other.journal == journal &&
          listEquals(other.sharedEmotions, sharedEmotions);

  @override
  int get hashCode => Object.hash(journal, Object.hashAll(sharedEmotions));
}

class EmotionEchoes {
  /// The winning shared-emotion group, in the current journal's emotion
  /// order — the section header bolds these.
  final List<Emotion> headerEmotions;
  final List<EmotionEcho> echoes;

  const EmotionEchoes({this.headerEmotions = const [], this.echoes = const []});

  bool get isEmpty => echoes.isEmpty;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EmotionEchoes &&
          listEquals(other.headerEmotions, headerEmotions) &&
          listEquals(other.echoes, echoes);

  @override
  int get hashCode =>
      Object.hash(Object.hashAll(headerEmotions), Object.hashAll(echoes));
}

/// Selects up to [maxCards] previous journals sharing ONE group of emotions
/// with [current], excluding journals of the same movie (and [current]
/// itself).
///
/// Product rules:
/// - A journal qualifies only when it shares at least 2 emotions with
///   [current]; the section shows a single shared-emotion group.
/// - Journals are grouped by their exact shared-emotion set. The largest set
///   wins (a journal sharing a superset forms its own larger group, so
///   "most overlapping wins" falls out of the grouping). A size tie goes to
///   the group whose journals have the highest average rating.
/// - The winning group's journals display in random order ([random] is a
///   test seam; production omits it).
EmotionEchoes computeEmotionEchoes({
  required JournalState current,
  required List<JournalState> all,
  int maxCards = 2,
  Random? random,
}) {
  final currentIds = current.emotions.map((e) => e.id).toSet();
  if (currentIds.length < 2) return const EmotionEchoes();

  // Exact shared-emotion set (as a stable key) -> journals sharing it.
  final groups = <String, List<JournalState>>{};
  for (final journal in all) {
    if (journal.id == current.id) continue;
    if (journal.tmdbId == current.tmdbId) continue;
    final sharedIds =
        journal.emotions.map((e) => e.id).where(currentIds.contains).toSet();
    if (sharedIds.length < 2) continue;
    final key = (sharedIds.toList()..sort()).join('|');
    groups.putIfAbsent(key, () => []).add(journal);
  }
  if (groups.isEmpty) return const EmotionEchoes();

  String? bestKey;
  var bestSize = 0;
  var bestAvgRating = double.negativeInfinity;
  for (final entry in groups.entries) {
    final size = entry.key.split('|').length;
    final avgRating =
        entry.value.fold(0, (sum, j) => sum + j.rating) / entry.value.length;
    if (size > bestSize || (size == bestSize && avgRating > bestAvgRating)) {
      bestKey = entry.key;
      bestSize = size;
      bestAvgRating = avgRating;
    }
  }

  final groupIds = bestKey!.split('|').toSet();
  final members = [...groups[bestKey]!]..shuffle(random ?? Random());
  final echoes =
      members
          .take(maxCards)
          .map(
            (j) => EmotionEcho(
              journal: j,
              sharedEmotions:
                  j.emotions.where((e) => groupIds.contains(e.id)).toList(),
            ),
          )
          .toList();

  final headerEmotions =
      current.emotions.where((e) => groupIds.contains(e.id)).toList();

  return EmotionEchoes(headerEmotions: headerEmotions, echoes: echoes);
}

/// Echoes for the journal with the given id, derived from the in-memory
/// journals list (save() awaits refreshJournals() before navigating, so the
/// just-saved journal is always present). autoDispose: recomputed cheaply,
/// nothing prefetches it.
final emotionEchoesProvider = Provider.autoDispose
    .family<EmotionEchoes, String>((ref, journalId) {
      final journals =
          ref.watch(journalsControllerProvider).value?.journals ?? const [];
      final current = journals.where((j) => j.id == journalId).firstOrNull;
      if (current == null) return const EmotionEchoes();
      return computeEmotionEchoes(current: current, all: journals);
    });
