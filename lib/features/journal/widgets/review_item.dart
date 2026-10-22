import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:movie_journal/features/quesgen/review.dart';
import 'package:movie_journal/themes.dart';
import 'package:movie_journal/l10n/app_localizations.dart';

class ReviewItem extends StatelessWidget {
  const ReviewItem({
    super.key,
    required this.review,
    this.onPress,
    this.showAction = true,
    this.isSelected = false,
    this.transparent = false,
    this.selectedReference = false,
    this.onRemove,
  });

  final Review review;
  final VoidCallback? onPress;
  final bool showAction;
  final bool isSelected;
  final bool transparent;
  final bool selectedReference;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    if (selectedReference) return _buildSelectedReference(context);
    return InkWell(
      onTap: onPress,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.only(
          left: 16,
          right: 16,
          top: 12,
          bottom: 12,
        ),
        decoration: BoxDecoration(
          color: transparent ? Colors.transparent : DarkSurfaces.raisedCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                transparent ? Colors.white.withAlpha(76) : Colors.transparent,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          spacing: 8,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                maxLines: 6,
                overflow: TextOverflow.ellipsis,
                review.text,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                  height: 1.4,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  spacing: 8,
                  children: [
                    _SourceIcon(source: review.source),
                    Text(
                      review.source.toUpperCase(),
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
                if (showAction) _ActionButton(isSelected: isSelected),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedReference(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 16),
      decoration: BoxDecoration(
        color: DarkSurfaces.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    review.text,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                      height: 1.4,
                    ),
                  ),
                ),
              ),
              if (onRemove != null)
                IconButton(
                  tooltip: AppLocalizations.of(context).commonRemove,
                  onPressed: onRemove,
                  style: IconButton.styleFrom(
                    minimumSize: const Size(24, 24),
                    maximumSize: const Size(24, 24),
                    padding: EdgeInsets.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    backgroundColor: DarkSurfaces.card.withAlpha(204),
                    shape: const CircleBorder(),
                  ),
                  icon: const Icon(Icons.close, size: 16, color: Colors.white),
                ),
            ],
          ),
          Row(
            spacing: 8,
            children: [
              _SourceIcon(source: review.source, size: 20),
              Flexible(
                child: Text(
                  review.source.toUpperCase(),
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SourceIcon extends StatelessWidget {
  const _SourceIcon({required this.source, this.size = 24});

  final double size;

  final String source;

  @override
  Widget build(BuildContext context) {
    final asset = switch (source.toLowerCase()) {
      'letterboxd' => 'assets/images/letterboxd_icon.png',
      'reddit' => 'assets/images/reddit_icon.png',
      _ => null,
    };

    if (asset == null) return SizedBox(width: size, height: size);

    return Image.asset(
      asset,
      width: size,
      height: size,
      filterQuality: FilterQuality.high,
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.isSelected});

  final bool isSelected;

  static const _tealColor = Color(0xFFA8DADD);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? _tealColor : Colors.transparent,
        border: isSelected ? null : Border.all(color: _tealColor, width: 1.333),
      ),
      child: Icon(
        isSelected ? Icons.check_rounded : Icons.add_rounded,
        color: isSelected ? Colors.black : Colors.white,
        size: 20,
      ),
    );
  }
}
