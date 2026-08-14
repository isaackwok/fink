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

  int _ratingFromPosition(double dx, double width) {
    return (dx / width * maxRating).ceil().clamp(1, maxRating);
  }

  void _updateRatingFromPosition(double dx, double width) {
    if (readonly || onChanged == null) return;

    onChanged!(_ratingFromPosition(dx, width));
  }

  void _toggleRatingFromPosition(double dx, double width) {
    if (readonly || onChanged == null) return;

    final tappedRating = _ratingFromPosition(dx, width);
    onChanged!(tappedRating == rating ? 0 : tappedRating);
  }

  @override
  Widget build(BuildContext context) {
    final hasRating = rating > 0;
    final ratingValueStyle = TextStyle(
      color: hasRating ? Colors.white : const Color(0xFF8F8E8E),
      fontFamily: 'AvenirNext',
      fontSize: 14,
      fontWeight: FontWeight.w500,
    );
    final currentRatingStyle = TextStyle(
      fontWeight: hasRating ? FontWeight.w700 : FontWeight.w500,
    );
    final maxRatingValuePainter = TextPainter(
      text: TextSpan(
        style: ratingValueStyle,
        children: [
          TextSpan(text: '$maxRating', style: currentRatingStyle),
          const TextSpan(text: '/$maxRating'),
        ],
      ),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
      maxLines: 1,
    )..layout();

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
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: hasRating ? DarkSurfaces.card : Colors.transparent,
            border: Border.all(
              color: hasRating ? DarkSurfaces.card : Colors.white.withAlpha(26),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth;

                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTapUp:
                          readonly || onChanged == null
                              ? null
                              : (details) => _toggleRatingFromPosition(
                                details.localPosition.dx,
                                width,
                              ),
                      onHorizontalDragStart:
                          readonly || onChanged == null
                              ? null
                              : (details) => _updateRatingFromPosition(
                                details.localPosition.dx,
                                width,
                              ),
                      onHorizontalDragUpdate:
                          readonly || onChanged == null
                              ? null
                              : (details) => _updateRatingFromPosition(
                                details.localPosition.dx,
                                width,
                              ),
                      onLongPressStart:
                          readonly || onChanged == null
                              ? null
                              : (details) => _updateRatingFromPosition(
                                details.localPosition.dx,
                                width,
                              ),
                      onLongPressMoveUpdate:
                          readonly || onChanged == null
                              ? null
                              : (details) => _updateRatingFromPosition(
                                details.localPosition.dx,
                                width,
                              ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          for (var value = 1; value <= maxRating; value++)
                            Semantics(
                              key: ValueKey('rating-heart-$value'),
                              button: !readonly,
                              selected: value <= rating,
                              label: '$value out of $maxRating',
                              onTap:
                                  readonly || onChanged == null
                                      ? null
                                      : () => onChanged!(
                                        value == rating ? 0 : value,
                                      ),
                              child: SvgPicture.asset(
                                value <= rating
                                    ? 'assets/images/rating_heart_selected.svg'
                                    : 'assets/images/rating_heart_unselected.svg',
                                width: 24,
                                height: 24,
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              SizedBox(width: hasRating ? 12 : 16),
              SizedBox(
                width: maxRatingValuePainter.width,
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: '$rating', style: currentRatingStyle),
                      const TextSpan(text: '/$maxRating'),
                    ],
                  ),
                  key: const ValueKey('rating-value'),
                  style: ratingValueStyle,
                  softWrap: false,
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
