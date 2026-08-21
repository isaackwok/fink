import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  Future<List<Achievement>> build() =>
      ref.read(journalInsightsApiProvider).fetchAchievements(tmdbId);

  /// Refetches while keeping any cached value visible. Guards against
  /// same-session staleness: the family instance survives across journals
  /// (not autoDispose), so a second journal of the same movie would otherwise
  /// show the first save's counts.
  Future<void> refresh() async {
    // Riverpod merges this with the current state (copyWithPrevious under the
    // hood), so a cached list stays visible while the refetch is in flight.
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(journalInsightsApiProvider).fetchAchievements(tmdbId),
    );
  }
}

Duration? _noRetry(int retryCount, Object error) => null;

final journalInsightsControllerProvider = AsyncNotifierProvider.family<
    JournalInsightsController, List<Achievement>, int>(
  JournalInsightsController.new,
  retry: _noRetry,
);
