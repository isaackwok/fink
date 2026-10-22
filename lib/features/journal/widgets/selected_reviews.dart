import 'package:flutter/material.dart';
import 'package:movie_journal/features/journal/widgets/review_item.dart';
import 'package:movie_journal/features/quesgen/review.dart';
import 'package:movie_journal/l10n/app_localizations.dart';

/// Always-visible selected reviews; removal is available only in the editor.
class SelectedReviews extends StatelessWidget {
  const SelectedReviews({super.key, required this.references, this.onRemove});

  final List<Review> references;
  final ValueChanged<Review>? onRemove;

  @override
  Widget build(BuildContext context) {
    if (references.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            AppLocalizations.of(context).reviewsResonatedWith,
            style: TextStyle(
              fontFamily: 'AvenirNext',
              fontSize: 14,
              height: 1.4,
              fontWeight: FontWeight.w500,
              color: Colors.white.withAlpha(128),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Column(
          spacing: 12,
          children: [
            for (final review in references)
              ReviewItem(
                key: ValueKey(review),
                review: review,
                selectedReference: true,
                showAction: false,
                onRemove: onRemove == null ? null : () => onRemove!(review),
              ),
          ],
        ),
      ],
    );
  }
}
