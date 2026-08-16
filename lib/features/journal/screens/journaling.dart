import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:movie_journal/analytics_manager.dart';
import 'package:jiffy/jiffy.dart';
import 'package:movie_journal/features/journal/controllers/journal.dart';
import 'package:movie_journal/features/journal/screens/journal_complete.dart';
import 'package:movie_journal/features/journal/widgets/emotions_selector_button.dart';
import 'package:movie_journal/features/journal/widgets/rating_selector.dart';
import 'package:movie_journal/features/journal/widgets/scenes_selector.dart';
import 'package:movie_journal/features/journal/widgets/thoughts_editor.dart';
import 'package:movie_journal/features/quesgen/provider.dart';
import 'package:movie_journal/features/toast/custom_toast.dart';
import 'package:movie_journal/shared_widgets/circled_icon_button.dart';
import 'package:movie_journal/shared_widgets/confirmation_dialog.dart';
import 'package:movie_journal/l10n/app_localizations.dart';

class JournalingScreen extends ConsumerStatefulWidget {
  final String movieTitle;
  final String moviePosterUrl;
  final String? editJournalId;
  const JournalingScreen({
    super.key,
    required this.movieTitle,
    required this.moviePosterUrl,
    this.editJournalId,
  });

  @override
  ConsumerState<JournalingScreen> createState() => _JournalingScreenState();
}

class _JournalingScreenState extends ConsumerState<JournalingScreen> {
  final ScrollController _scrollController = ScrollController();
  late final JournalState _initialJournal;
  bool _showTitle = false;
  bool _isSaving = false;

  bool get _isEditMode => widget.editJournalId != null;

  @override
  void initState() {
    super.initState();
    _initialJournal = ref.read(journalControllerProvider);
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(journalModeProvider.notifier)
          .set(_isEditMode ? JournalMode.edit : JournalMode.create);
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Show title when scrolled down more than 100 pixels
    final showTitle =
        _scrollController.hasClients && _scrollController.offset > 100;
    if (showTitle != _showTitle) {
      setState(() {
        _showTitle = showTitle;
      });
    }
  }

  bool _hasUnsavedChanges() {
    return ref.read(journalControllerProvider) != _initialJournal;
  }

  void _cleanupState() {
    ref.read(journalControllerProvider.notifier).clear();
    ref.read(quesgenControllerProvider.notifier).clear();
    ref.read(journalModeProvider.notifier).set(JournalMode.create);
  }

  /// The one exit path: pop immediately when nothing was entered, otherwise
  /// confirm the discard first. Shared by the back button and PopScope.
  Future<void> _confirmDiscardAndPop() async {
    final navigator = Navigator.of(context);

    if (!_hasUnsavedChanges()) {
      navigator.pop();
      _cleanupState();
      return;
    }

    final shouldDiscard = await showDialog<bool>(
      context: context,
      builder: (context) => const _DiscardChangesDialog(),
    );

    if (shouldDiscard == true && mounted) {
      navigator.pop();
      _cleanupState();
    }
  }

  @override
  Widget build(BuildContext context) {
    final journal = ref.watch(journalControllerProvider);
    final l10n = AppLocalizations.of(context);
    // Both create (setMovie before push) and edit (loadJournal) set tmdbId
    // before this screen builds, so the journal is the id's source of truth —
    // no need to wait on the movie-detail fetch.
    final movieId = journal.tmdbId;
    return ScreenViewTracker(
      screenName: 'Journaling',
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) return;
          await _confirmDiscardAndPop();
        },
        child: Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          body: CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverAppBar(
                backgroundColor: Theme.of(context).colorScheme.surface,
                pinned: true,
                floating: true,
                snap: true,
                automaticallyImplyLeading: false,
                centerTitle: true,
                title: AnimatedOpacity(
                  opacity: _showTitle ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                    widget.movieTitle,
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                leading: CircledIconButton(
                  onPressed: _confirmDiscardAndPop,
                  icon: Icons.arrow_back_ios_new,
                  outerPadding: const EdgeInsets.only(left: 16),
                ),
                leadingWidth: 40 + 16,
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: ElevatedButton(
                      onPressed:
                          _isSaving ||
                                  (journal.rating == 0 &&
                                      journal.emotions.isEmpty &&
                                      journal.selectedScenes.isEmpty &&
                                      journal.thoughts.isEmpty)
                              ? null
                              : () async {
                                setState(() {
                                  _isSaving = true;
                                });
                                try {
                                  if (_isEditMode) {
                                    await ref
                                        .read(
                                          journalControllerProvider.notifier,
                                        )
                                        .update();
                                    if (context.mounted) {
                                      CustomToast.showSuccess(
                                        context,
                                        l10n.journalUpdated,
                                      );
                                      Navigator.of(
                                        context,
                                      ).popUntil((route) => route.isFirst);
                                    }
                                  } else {
                                    await ref
                                        .read(
                                          journalControllerProvider.notifier,
                                        )
                                        .save();
                                    final savedJournal = ref.read(
                                      journalControllerProvider,
                                    );
                                    if (context.mounted) {
                                      unawaited(
                                        Navigator.pushAndRemoveUntil(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) =>
                                                    JournalCompleteScreen(
                                                      journal: savedJournal,
                                                    ),
                                          ),
                                          (route) => route.isFirst,
                                        ),
                                      );
                                    }
                                  }
                                  _cleanupState();
                                } catch (e) {
                                  if (context.mounted) {
                                    CustomToast.showError(
                                      context,
                                      l10n.journalSaveFailed,
                                    );
                                  }
                                } finally {
                                  if (mounted) {
                                    setState(() {
                                      _isSaving = false;
                                    });
                                  }
                                }
                              },
                      style: ButtonStyle(
                        shape: WidgetStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        padding: WidgetStateProperty.all(
                          const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        textStyle: WidgetStateProperty.all(
                          const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                        overlayColor: WidgetStateProperty.all(
                          Theme.of(context).colorScheme.primary,
                        ),
                        backgroundColor: WidgetStateProperty.all(
                          Colors.transparent,
                        ),
                        side: WidgetStateProperty.resolveWith((states) {
                          if (states.contains(WidgetState.disabled)) {
                            return BorderSide(
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withAlpha(76),
                              width: 1,
                            );
                          }
                          return BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                            width: 1,
                          );
                        }),
                        foregroundColor: WidgetStateProperty.resolveWith((
                          states,
                        ) {
                          if (states.contains(WidgetState.disabled)) {
                            return Colors.white.withAlpha(76);
                          }
                          return Colors.white;
                        }),
                      ),
                      child:
                          _isSaving
                              ? SizedBox(
                                width: 16,
                                height: 16,
                                child: Center(
                                  child: SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                      backgroundColor: Colors.white.withAlpha(
                                        50,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                              : Text(l10n.commonSave),
                    ),
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 8,
                          children: [
                            Text(
                              widget.movieTitle,
                              style: GoogleFonts.inter(
                                fontSize: 28,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              _isEditMode
                                  ? journal.createdAt.format(
                                    pattern: 'MMM do yyyy',
                                  )
                                  : Jiffy.now().format(pattern: 'MMM do yyyy'),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white.withAlpha(179),
                                fontFamily: 'AvenirNext',
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 36),
                      RatingSelector(
                        rating: journal.rating,
                        onChanged: (rating) {
                          ref
                              .read(journalControllerProvider.notifier)
                              .setRating(rating);
                        },
                      ),
                      const SizedBox(height: 36),
                      EmotionsSelectorButton(
                        emotions: journal.emotions,
                        onSave: (selectedEmotions) {
                          ref
                              .read(journalControllerProvider.notifier)
                              .setEmotions(selectedEmotions);
                        },
                      ),
                      const SizedBox(height: 36),

                      ScenesSelector(movieId: movieId),
                      const SizedBox(height: 36),
                      const ThoughtsEditor(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ).withEdgeSwipeBack(() => unawaited(_confirmDiscardAndPop())),
      ),
    );
  }
}

extension _EdgeSwipeBackWidget on Widget {
  Widget withEdgeSwipeBack(VoidCallback onSwipeBack) {
    return _EdgeSwipeBackDetector(onSwipeBack: onSwipeBack, child: this);
  }
}

/// Observes an iOS-style rightward swipe from the left edge without joining
/// the gesture arena, so the editor's vertical scroll and horizontal controls
/// keep their normal gesture behavior.
class _EdgeSwipeBackDetector extends StatefulWidget {
  const _EdgeSwipeBackDetector({
    required this.child,
    required this.onSwipeBack,
  });

  final Widget child;
  final VoidCallback onSwipeBack;

  @override
  State<_EdgeSwipeBackDetector> createState() => _EdgeSwipeBackDetectorState();
}

class _EdgeSwipeBackDetectorState extends State<_EdgeSwipeBackDetector> {
  static const double _edgeWidth = 24;
  static const double _dismissThreshold = 80;
  static const double _flingVelocity = 700;

  int? _pointer;
  Offset? _startPosition;
  Duration? _startTimestamp;

  void _handlePointerDown(PointerDownEvent event) {
    if (_pointer != null || event.localPosition.dx > _edgeWidth) return;

    _pointer = event.pointer;
    _startPosition = event.localPosition;
    _startTimestamp = event.timeStamp;
  }

  void _handlePointerUp(PointerUpEvent event) {
    if (event.pointer != _pointer || _startPosition == null) return;

    final travel = event.localPosition - _startPosition!;
    final elapsed = event.timeStamp - _startTimestamp!;
    final seconds = elapsed.inMicroseconds / Duration.microsecondsPerSecond;
    final velocity = seconds > 0 ? travel.dx / seconds : 0.0;
    final travelledFar = travel.dx >= _dismissThreshold;
    final flicked =
        travel.dx >= _dismissThreshold / 4 && velocity >= _flingVelocity;
    final isRightwardSwipe =
        travel.dx > travel.dy.abs() && (travelledFar || flicked);
    _reset();

    if (isRightwardSwipe) {
      widget.onSwipeBack();
    }
  }

  void _handlePointerCancel(PointerCancelEvent event) {
    if (event.pointer == _pointer) {
      _reset();
    }
  }

  void _reset() {
    _pointer = null;
    _startPosition = null;
    _startTimestamp = null;
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: _handlePointerDown,
      onPointerUp: _handlePointerUp,
      onPointerCancel: _handlePointerCancel,
      child: widget.child,
    );
  }
}

class _DiscardChangesDialog extends StatelessWidget {
  const _DiscardChangesDialog();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ConfirmationDialog(
      title: l10n.discardChangesTitle,
      description: l10n.discardChangesDescription,
      cancelText: l10n.commonCancel,
      confirmText: l10n.discardChangesAction,
      onCancel: () => Navigator.pop(context, false),
      onConfirm: () => Navigator.pop(context, true),
    );
  }
}
