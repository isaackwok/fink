import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:movie_journal/core/utils/tmdb_image_url.dart';
import 'package:movie_journal/features/journal/controllers/journal.dart';
import 'package:movie_journal/l10n/app_localizations.dart';
import 'package:movie_journal/shared_widgets/tmdb_image.dart';
import 'package:movie_journal/themes.dart';

/// Cap on the thoughts excerpt, including its plain trailing ellipsis.
const _kExcerptMaxLines = 5;

/// A previous journal resurfaced on the complete screen because it shares
/// emotions with the just-saved one (Figma 7363:24722, card 7487:9770;
/// thought-less variant 7369:29163).
///
/// Centered title + handwritten date, then — only when the journal has a
/// selected scene — a 207pt still of its first scene (no TMDB backdrop
/// fallback: a scene-less journal simply has no image row), then either the
/// thoughts excerpt centered between a pair of oversized Flavors quote marks
/// or, with no thoughts, the italic "No thoughts…" line with a bold
/// "Fill in memory" action that opens the editor directly.
class EmotionEchoCard extends StatelessWidget {
  final JournalState journal;

  /// Opens the journal when tapping anywhere on the card.
  final VoidCallback onOpen;

  /// Opens the edit flow ("Fill in memory" on a thought-less journal).
  final VoidCallback onAddNow;

  const EmotionEchoCard({
    super.key,
    required this.journal,
    required this.onOpen,
    required this.onAddNow,
  });

  bool get _hasScene => journal.selectedScenes.isNotEmpty;
  bool get _hasThoughts => journal.thoughts.trim().isNotEmpty;

  Widget _image() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        height: 207,
        width: double.infinity,
        child: TmdbImage(
          path: journal.selectedScenes.first.path,
          size: TmdbImageSize.w500,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  /// Thought-less state (Figma 7369:29163): italic prompt over a bold
  /// "Fill in memory" + pencil row. Only the action row is the edit target;
  /// the rest of the card still opens the journal.
  Widget _fillInNudge(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        Text(
          l10n.emotionEchoNoThoughts,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontStyle: FontStyle.italic,
            color: const Color(0xFFD8D8D8),
            letterSpacing: 0.28,
            height: 1.8,
          ),
        ),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: onAddNow,
          behavior: HitTestBehavior.opaque,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                l10n.emotionEchoFillInMemory,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.28,
                  height: 1.8,
                ),
              ),
              const SizedBox(width: 4),
              const SizedBox.square(
                dimension: 24,
                child: Icon(Icons.edit, size: 16, color: Colors.white),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _quotedExcerpt(BuildContext context) {
    final thoughts = journal.thoughts.trim();
    final bodyStyle = GoogleFonts.inter(
      fontSize: 14,
      color: const Color(0xFFB7B7B7),
      letterSpacing: 0.28,
      height: 1.4,
    );
    const ellipsisSpan = TextSpan(text: '...');

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _quoteMark('“'),
        const SizedBox(width: 16),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 8),
            // The cut depends on the rendered width, so measure per layout.
            child: LayoutBuilder(
              builder: (context, constraints) {
                final excerpt = _fitExcerpt(
                  context,
                  thoughts,
                  bodyStyle,
                  ellipsisSpan,
                  constraints.maxWidth,
                );
                return Text.rich(
                  TextSpan(
                    style: bodyStyle,
                    children: [
                      TextSpan(text: excerpt ?? thoughts),
                      if (excerpt != null) ellipsisSpan,
                    ],
                  ),
                  textAlign: TextAlign.center,
                  maxLines: _kExcerptMaxLines,
                  overflow: TextOverflow.ellipsis,
                );
              },
            ),
          ),
        ),
        const SizedBox(width: 16),
        _quoteMark('”'),
      ],
    );
  }

  /// Returns the longest prefix of [thoughts] that, followed by [ellipsisSpan],
  /// fits in [_kExcerptMaxLines] at [maxWidth] — or null when the whole text
  /// already fits and no ellipsis is needed.
  String? _fitExcerpt(
    BuildContext context,
    String thoughts,
    TextStyle bodyStyle,
    TextSpan ellipsisSpan,
    double maxWidth,
  ) {
    final direction = Directionality.of(context);
    final scaler = MediaQuery.textScalerOf(context);
    final painter = TextPainter(
      textDirection: direction,
      textAlign: TextAlign.center,
      textScaler: scaler,
      maxLines: _kExcerptMaxLines,
    );
    bool fits(String body, {bool withEllipsis = true}) {
      painter.text = TextSpan(
        style: bodyStyle,
        children: [TextSpan(text: body), if (withEllipsis) ellipsisSpan],
      );
      painter.layout(maxWidth: maxWidth);
      return !painter.didExceedMaxLines;
    }

    try {
      if (fits(thoughts, withEllipsis: false)) return null;

      // Start from where line 5 ends, leaving room for the ellipsis, then back
      // off word by word until the pair fits.
      painter.text = TextSpan(text: thoughts, style: bodyStyle);
      painter.layout(maxWidth: maxWidth);
      final ellipsisPainter = TextPainter(
        text: TextSpan(style: bodyStyle, children: [ellipsisSpan]),
        textDirection: direction,
        textScaler: scaler,
      )..layout();
      final ellipsisWidth = ellipsisPainter.width;
      ellipsisPainter.dispose();
      var cut =
          painter
              .getPositionForOffset(
                Offset(painter.width - ellipsisWidth, painter.height - 1),
              )
              .offset;
      cut = cut.clamp(0, thoughts.length);
      var excerpt = thoughts.substring(0, cut).trimRight();
      while (excerpt.isNotEmpty && !fits(excerpt)) {
        final space = excerpt.lastIndexOf(' ');
        excerpt =
            (space > 0
                    ? excerpt.substring(0, space)
                    : excerpt.substring(0, excerpt.length - 1))
                .trimRight();
      }
      return excerpt;
    } finally {
      painter.dispose();
    }
  }

  /// The decorative curly quote flanking the excerpt: Flavors 36 in the warm
  /// off-white the design uses only here (Figma 7487:9780 / 7487:9783).
  Widget _quoteMark(String glyph) => Text(
    glyph,
    style: GoogleFonts.flavors(
      fontSize: 36,
      height: 1.4,
      letterSpacing: 0.72,
      color: const Color(0xFFFFF1D7),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onOpen,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: DarkSurfaces.card,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Text(
                journal.movieTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'AvenirNext',
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              journal.watchedAt.format(pattern: 'MMM, yyyy'),
              textAlign: TextAlign.center,
              style: GoogleFonts.nothingYouCouldDo(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            if (_hasScene) ...[const SizedBox(height: 20), _image()],
            // The quoted excerpt sits 12 below the still; the thought-less
            // nudge 16 (Figma 7487:9772 vs 7369:29164).
            SizedBox(height: _hasThoughts ? 12 : 16),
            _hasThoughts ? _quotedExcerpt(context) : _fillInNudge(context),
          ],
        ),
      ),
    );
  }
}
