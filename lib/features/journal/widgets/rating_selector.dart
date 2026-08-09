import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:movie_journal/themes.dart';

class RatingSelector extends StatelessWidget {
  const RatingSelector({
    super.key,
    required this.rating,
    this.onChanged,
    this.readonly = false,
  });

  static const int maxRating = 10;

  final int rating;
  final ValueChanged<int>? onChanged;
  final bool readonly;

  void _updateRatingFromPosition(double dx) {
    if (readonly || onChanged == null) return;

    // Hearts are 24px wide with an 8px gap. Adding half the gap makes each
    // gap switch at its midpoint, so dragging feels continuous rather than
    // leaving dead zones between hearts.
    final rating = ((dx + 4) / 32).ceil().clamp(1, maxRating);
    onChanged!(rating);
  }

  @override
  Widget build(BuildContext context) {
    final hasRating = rating > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'How much did you enjoy this movie?',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'AvenirNext',
            fontSize: 16,
            fontWeight: FontWeight.w500,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          key: const ValueKey('rating-card'),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          decoration: BoxDecoration(
            color: hasRating ? DarkSurfaces.card : Colors.transparent,
            border:
                hasRating
                    ? null
                    : Border.all(color: Colors.white.withAlpha(26)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown:
                    readonly || onChanged == null
                        ? null
                        : (details) =>
                            _updateRatingFromPosition(details.localPosition.dx),
                onHorizontalDragStart:
                    readonly || onChanged == null
                        ? null
                        : (details) =>
                            _updateRatingFromPosition(details.localPosition.dx),
                onHorizontalDragUpdate:
                    readonly || onChanged == null
                        ? null
                        : (details) =>
                            _updateRatingFromPosition(details.localPosition.dx),
                onLongPressStart:
                    readonly || onChanged == null
                        ? null
                        : (details) =>
                            _updateRatingFromPosition(details.localPosition.dx),
                onLongPressMoveUpdate:
                    readonly || onChanged == null
                        ? null
                        : (details) =>
                            _updateRatingFromPosition(details.localPosition.dx),
                child: SizedBox(
                  width: 312,
                  height: 24,
                  child: Row(
                    children: [
                      for (var value = 1; value <= maxRating; value++) ...[
                        Semantics(
                          key: ValueKey('rating-heart-$value'),
                          button: !readonly,
                          selected: value <= rating,
                          label: '$value out of $maxRating',
                          onTap:
                              readonly || onChanged == null
                                  ? null
                                  : () => onChanged!(value),
                          child: SvgPicture.asset(
                            value <= rating
                                ? 'assets/images/rating_heart_selected.svg'
                                : 'assets/images/rating_heart_unselected.svg',
                            width: 24,
                            height: 24,
                          ),
                        ),
                        if (value < maxRating) const SizedBox(width: 8),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
