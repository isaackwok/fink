import 'package:jiffy/jiffy.dart';
import 'package:movie_journal/features/emotion/emotion.dart';
import 'package:movie_journal/features/journal/controllers/journal.dart';
import 'package:movie_journal/features/quesgen/review.dart';

/// Creates a JournalState with sensible defaults for testing.
/// Override any field to customize for a specific test case.
JournalState makeJournal({
  String? id,
  int tmdbId = 550,
  String movieTitle = 'Fight Club',
  String moviePoster = '/poster.jpg',
  int rating = 0,
  List<Emotion> emotions = const [],
  List<SceneItem> selectedScenes = const [],
  List<Review>? selectedRefs,
  String thoughts = '',
  Jiffy? createdAt,
  Jiffy? updatedAt,
}) {
  return JournalState(
    id: id,
    tmdbId: tmdbId,
    movieTitle: movieTitle,
    moviePoster: moviePoster,
    rating: rating,
    emotions: emotions,
    selectedScenes: selectedScenes,
    selectedRefs: selectedRefs,
    thoughts: thoughts,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}
