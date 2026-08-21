import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:movie_journal/core/utils/tmdb_image_url.dart';
import 'package:movie_journal/features/journal/controllers/journal.dart';
import 'package:movie_journal/features/movie/movie_providers.dart';
import 'package:movie_journal/l10n/app_localizations.dart';
import 'package:movie_journal/shared_widgets/tmdb_image.dart';
import 'package:movie_journal/themes.dart';

/// Cap on the thoughts excerpt; past it the text is cut and the teal
/// "…more" link (which opens the journal) is appended.
const _kExcerptLength = 160;

/// A previous journal resurfaced on the complete screen because it shares
/// emotions with the just-saved one (Figma 6944:8906 / 7168:9534).
///
/// Centered title + handwritten date, a landscape still (first selected
/// scene; falls back to the movie's first TMDB backdrop), then a quoted
/// thoughts excerpt — or, with no thoughts, an italic nudge whose "Add now"
/// opens the edit flow.
class EmotionEchoCard extends ConsumerStatefulWidget {
  final JournalState journal;

  /// Opens the journal (tap anywhere on the card, or "…more").
  final VoidCallback onOpen;

  /// Opens the edit flow ("Add now" on a thought-less journal).
  final VoidCallback onAddNow;

  const EmotionEchoCard({
    super.key,
    required this.journal,
    required this.onOpen,
    required this.onAddNow,
  });

  @override
  ConsumerState<EmotionEchoCard> createState() => _EmotionEchoCardState();
}

class _EmotionEchoCardState extends ConsumerState<EmotionEchoCard> {
  late final TapGestureRecognizer _linkRecognizer;

  bool get _hasScene => widget.journal.selectedScenes.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _linkRecognizer =
        TapGestureRecognizer()
          ..onTap =
              widget.journal.thoughts.trim().isEmpty
                  ? widget.onAddNow
                  : widget.onOpen;

    // No scene to show: fetch this movie's backdrops. Post-frame because
    // mutating a provider during build is illegal; skipped when another flow
    // already populated the family instance.
    if (!_hasScene) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final images = ref.read(
          movieImagesControllerProvider(widget.journal.tmdbId),
        );
        if (images.isLoading) {
          ref
              .read(
                movieImagesControllerProvider(widget.journal.tmdbId).notifier,
              )
              .getMovieImages();
        }
      });
    }
  }

  @override
  void dispose() {
    _linkRecognizer.dispose();
    super.dispose();
  }

  Widget _image() {
    String? path;
    if (_hasScene) {
      path = widget.journal.selectedScenes.first.path;
    } else {
      final images = ref.watch(
        movieImagesControllerProvider(widget.journal.tmdbId),
      );
      final backdrops = images.value?.backdrops;
      if (backdrops != null && backdrops.isNotEmpty) {
        path = backdrops.first.filePath;
      }
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        height: 207,
        width: double.infinity,
        child:
            path == null
                ? const ColoredBox(color: DarkSurfaces.imagePlaceholder)
                : TmdbImage(
                  path: path,
                  size: TmdbImageSize.w500,
                  fit: BoxFit.cover,
                ),
      ),
    );
  }

  Widget _thoughtsBlock(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final primary = Theme.of(context).colorScheme.primary;
    final thoughts = widget.journal.thoughts.trim();

    if (thoughts.isEmpty) {
      return Text.rich(
        TextSpan(
          style: GoogleFonts.inter(
            fontSize: 14,
            fontStyle: FontStyle.italic,
            color: const Color(0xFFD8D8D8),
            letterSpacing: 0.28,
            height: 1.6,
          ),
          children: [
            TextSpan(text: l10n.emotionEchoNoThoughts),
            TextSpan(
              text: l10n.emotionEchoAddNow,
              recognizer: _linkRecognizer,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                fontStyle: FontStyle.normal,
                color: primary,
                height: 1.6,
              ),
            ),
          ],
        ),
        textAlign: TextAlign.center,
      );
    }

    final truncated = thoughts.length > _kExcerptLength;
    final excerpt =
        truncated
            ? thoughts.substring(0, _kExcerptLength).trimRight()
            : thoughts;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '“',
          style: GoogleFonts.inter(
            fontSize: 32,
            height: 1.0,
            color: const Color(0xFFFFFEFE),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text.rich(
            TextSpan(
              style: GoogleFonts.inter(
                fontSize: 14,
                color: const Color(0xFFB7B7B7),
                letterSpacing: 0.28,
                height: 1.4,
              ),
              children: [
                TextSpan(text: excerpt),
                if (truncated)
                  TextSpan(
                    text: l10n.emotionEchoMore,
                    recognizer: _linkRecognizer,
                    style: TextStyle(
                      fontFamily: 'AvenirNext',
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final journal = widget.journal;
    return GestureDetector(
      onTap: widget.onOpen,
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
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              journal.createdAt.format(pattern: 'yyyy MMMM'),
              textAlign: TextAlign.center,
              style: GoogleFonts.nothingYouCouldDo(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            _image(),
            const SizedBox(height: 16),
            _thoughtsBlock(context),
          ],
        ),
      ),
    );
  }
}
