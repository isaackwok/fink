import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:movie_journal/features/journal/controllers/journal.dart';
import 'package:movie_journal/features/journal/screens/journal_content.dart';
import 'package:movie_journal/features/journal/widgets/journal_actions.dart';
import 'package:movie_journal/core/utils/tmdb_image_url.dart';
import 'package:movie_journal/themes.dart';
import 'package:movie_journal/shared_widgets/tmdb_image.dart';
import 'package:movie_journal/l10n/app_localizations.dart';

class JournalCard extends ConsumerStatefulWidget {
  final JournalState journal;
  final bool isCompletionPreview;

  const JournalCard({super.key, required this.journal})
    : isCompletionPreview = false;

  const JournalCard.completionPreview({super.key, required this.journal})
    : isCompletionPreview = true;

  @override
  ConsumerState<JournalCard> createState() => _JournalCardState();
}

class _JournalCardState extends ConsumerState<JournalCard> {
  void _openJournal() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => JournalContent(journalId: widget.journal.id),
      ),
    );
  }

  Future<void> _dismissMenuThen(
    BuildContext menuContext,
    Future<void> Function() action,
  ) async {
    Navigator.of(menuContext, rootNavigator: true).pop();
    // Let the context menu overlay finish dismissing before the next
    // navigation/dialog pushes, so the back stack is clean.
    await Future<void>.delayed(Duration.zero);
    if (!mounted) return;
    await action();
  }

  @override
  Widget build(BuildContext context) {
    final journal = widget.journal;
    final l10n = AppLocalizations.of(context);
    if (widget.isCompletionPreview) {
      return _JournalCardVisual(journal: journal, isCompletionPreview: true);
    }
    return CupertinoContextMenu.builder(
      enableHapticFeedback: true,
      actions: [
        CupertinoContextMenuAction(
          trailingIcon: CupertinoIcons.pencil,
          onPressed:
              () => _dismissMenuThen(context, () async {
                editJournal(this.context, ref, journal);
              }),
          child: Text(l10n.commonEdit),
        ),
        CupertinoContextMenuAction(
          trailingIcon: CupertinoIcons.share,
          onPressed:
              () => _dismissMenuThen(context, () async {
                shareJournal(this.context, journal);
              }),
          child: Text(l10n.commonShare),
        ),
        CupertinoContextMenuAction(
          isDestructiveAction: true,
          trailingIcon: CupertinoIcons.delete,
          onPressed:
              () => _dismissMenuThen(context, () async {
                final shouldDelete = await confirmDeleteJournal(this.context);
                if (!shouldDelete || !mounted) return;
                await deleteJournal(this.context, ref, journal.id);
              }),
          child: Text(l10n.commonDelete),
        ),
      ],
      builder:
          (ctx, animation) => ConstrainedBox(
            // Cap the preview's intrinsic size. Two things to satisfy:
            //   1. CupertinoContextMenu's delegate computes
            //      `menuSheetHeight = overlaySize.height - childSize.height - padding`;
            //      without a cap the child can be larger than the overlay and make
            //      that go negative, tripping a layout assertion.
            //   2. The image uses AspectRatio(150/215), so a wider card forces a
            //      proportionally taller image. maxWidth × 1.433 + text + gap +
            //      padding must stay under maxHeight, otherwise the Column overflows.
            // 200 × (215/150) + 70 ≈ 330, comfortably under 340.
            constraints: const BoxConstraints(maxWidth: 200, maxHeight: 340),
            child: _JournalCardVisual(
              journal: journal,
              // Only accept taps when the menu is at rest — during the zoom
              // transition, taps should be consumed by the context menu route.
              onTap: animation.value == 0 ? _openJournal : null,
            ),
          ),
    );
  }
}

class _JournalCardVisual extends StatelessWidget {
  final JournalState journal;
  final VoidCallback? onTap;
  final bool isCompletionPreview;

  const _JournalCardVisual({
    required this.journal,
    this.onTap,
    this.isCompletionPreview = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(isCompletionPreview ? 16 : 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(isCompletionPreview ? 16 : 12),
        onTap: onTap,
        child: Container(
          padding:
              isCompletionPreview
                  ? const EdgeInsets.fromLTRB(10, 10, 10, 16)
                  : const EdgeInsets.fromLTRB(8, 8, 8, 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(isCompletionPreview ? 16 : 12),
            color: DarkSurfaces.tile,
          ),
          child: Column(
            mainAxisSize:
                isCompletionPreview ? MainAxisSize.min : MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: AspectRatio(
                  aspectRatio: isCompletionPreview ? 204 / 268 : 150 / 215,
                  child: TmdbImage(
                    path: journal.moviePoster,
                    size: TmdbImageSize.w342,
                  ),
                ),
              ),
              SizedBox(height: isCompletionPreview ? 16 : 12),
              Flexible(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isCompletionPreview ? 6 : 4,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        journal.movieTitle,
                        style: GoogleFonts.inter(
                          fontSize: isCompletionPreview ? 21 : 14,
                          fontWeight: FontWeight.w700,
                          height: isCompletionPreview ? 1 : 1.1,
                        ),
                        textAlign: TextAlign.start,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: isCompletionPreview ? 10 : 8),
                      Text(
                        journal.watchedAt.format(pattern: 'MMM. do yyyy'),
                        style: GoogleFonts.nothingYouCouldDo(
                          fontSize: isCompletionPreview ? 13 : 12,
                          fontWeight: FontWeight.w700,
                          height: isCompletionPreview ? 14 / 13 : 1.1,
                        ),
                        textAlign: TextAlign.start,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
