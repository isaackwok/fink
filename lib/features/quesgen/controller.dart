import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_journal/features/quesgen/api.dart';
import 'package:movie_journal/features/quesgen/review.dart';
import 'package:movie_journal/l10n/supported_locales.dart';

final quesgenApiProvider = Provider((_) => QuesgenAPI());

class QuesgenState {
  final List<Review> reviews;
  final bool isLoading;
  final bool isError;

  QuesgenState({
    required this.reviews,
    required this.isLoading,
    required this.isError,
  });

  QuesgenState copyWith({
    List<Review>? reviews,
    bool? isLoading,
    bool? isError,
  }) {
    return QuesgenState(
      reviews: reviews ?? this.reviews,
      isLoading: isLoading ?? this.isLoading,
      isError: isError ?? this.isError,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuesgenState &&
          runtimeType == other.runtimeType &&
          listEquals(reviews, other.reviews) &&
          isLoading == other.isLoading &&
          isError == other.isError;

  @override
  int get hashCode => Object.hash(Object.hashAll(reviews), isLoading, isError);
}

class QuesgenController extends Notifier<QuesgenState> {
  @override
  QuesgenState build() {
    return QuesgenState(reviews: [], isLoading: false, isError: false);
  }

  Future<void> generateReviews({required int movieId}) async {
    state = state.copyWith(isLoading: true);
    try {
      final locale = appLanguageTag(ref.read(aiReviewLocaleProvider));
      final newReviews = await ref
          .read(quesgenApiProvider)
          .generateReviews(movieId: movieId, locale: locale);
      state = state.copyWith(reviews: newReviews, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, isError: true);
    }
  }

  void clear() {
    state = state.copyWith(reviews: [], isLoading: false, isError: false);
  }
}
