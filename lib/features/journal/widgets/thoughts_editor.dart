import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_journal/features/journal/controllers/journal.dart';
import 'package:movie_journal/features/journal/widgets/selected_reviews.dart';
import 'package:movie_journal/features/journal/widgets/movie_info_sheet.dart';
import 'package:movie_journal/features/journal/widgets/reviews_floating_button.dart';
import 'package:movie_journal/themes.dart';
import 'package:movie_journal/l10n/app_localizations.dart';

class ThoughtsEditor extends ConsumerStatefulWidget {
  const ThoughtsEditor({super.key});

  @override
  ConsumerState<ThoughtsEditor> createState() => _ThoughtsEditorState();
}

class _ThoughtsEditorState extends ConsumerState<ThoughtsEditor>
    with WidgetsBindingObserver {
  late final TextEditingController _controller;
  final _focusNode = FocusNode();
  final _sectionKey = GlobalKey();
  final _fieldKey = GlobalKey();
  static const _textStyle = TextStyle(
    fontFamily: 'AvenirNext',
    fontSize: 14,
    height: 1.6,
    fontWeight: FontWeight.w500,
    color: Colors.white,
  );

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: ref.read(journalControllerProvider).thoughts,
    );
    _focusNode.addListener(_onFocusChanged);
    WidgetsBinding.instance.addObserver(this);
  }

  void _onFocusChanged() {
    setState(() {});
    if (_focusNode.hasFocus) _revealEditor();
  }

  @override
  void didChangeMetrics() {
    if (_focusNode.hasFocus) {
      setState(() {});
      _revealEditor();
    }
  }

  void _revealEditor() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final sectionContext = _sectionKey.currentContext;
      if (!mounted || !_focusNode.hasFocus || sectionContext == null) return;
      final fieldContext = _fieldKey.currentContext;
      final box = fieldContext?.findRenderObject() as RenderBox?;
      if (fieldContext == null || box == null || !box.hasSize) return;
      final painter = TextPainter(
        text: TextSpan(text: _controller.text, style: _textStyle),
        textDirection: Directionality.of(fieldContext),
        textScaler: MediaQuery.textScalerOf(fieldContext),
      )..layout(maxWidth: box.size.width - 32);
      final hasGrown = painter.computeLineMetrics().length > 10;
      painter.dispose();
      // EditableText reveals the selected caret on focus and keyboard resize.
      // Aligning the whole section would override that for longer entries.
      if (hasGrown) return;
      Scrollable.ensureVisible(
        sectionContext,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final thoughts = ref.watch(
      journalControllerProvider.select((j) => j.thoughts),
    );
    final selectedRefs = ref.watch(
      journalControllerProvider.select((j) => j.selectedRefs),
    );
    final isEditMode = ref.watch(journalModeProvider) == JournalMode.edit;
    ref.listen(journalControllerProvider.select((j) => j.thoughts), (_, next) {
      // Echoes of typing must not reset selection or an IME composing range.
      if (_controller.text != next) {
        _controller.value = TextEditingValue(
          text: next,
          selection: TextSelection.collapsed(offset: next.length),
        );
      }
    });
    final focused = _focusNode.hasFocus;
    final filled = focused || thoughts.isNotEmpty;

    return Column(
      key: _sectionKey,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.thoughtsPrompt,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
            fontFamily: 'AvenirNext',
            height: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        KeyedSubtree(
          key: _fieldKey,
          child: TextField(
            key: const ValueKey('inline-thoughts'),
            controller: _controller,
            focusNode: _focusNode,
            minLines: 10,
            maxLines: null,
            keyboardType: TextInputType.multiline,
            textCapitalization: TextCapitalization.sentences,
            style: _textStyle,
            scrollPadding: const EdgeInsets.only(bottom: 80),
            onTapOutside: (_) => _focusNode.unfocus(),
            onChanged:
                (value) => ref
                    .read(journalControllerProvider.notifier)
                    .setThoughts(value),
            decoration: InputDecoration(
              hintText: l10n.thoughtsHint,
              hintStyle: _textStyle.copyWith(color: const Color(0xFF8F8E8E)),
              filled: true,
              fillColor: filled ? DarkSurfaces.card : Colors.transparent,
              contentPadding: const EdgeInsets.all(16),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    filled
                        ? BorderSide.none
                        : BorderSide(color: Colors.white.withAlpha(26)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            TextButton.icon(
              onPressed: () {
                _focusNode.unfocus();
                MovieInfoSheet.show(
                  context,
                  movieId: ref.read(journalControllerProvider).tmdbId,
                );
              },
              icon: SvgPicture.asset(
                'assets/images/film.svg',
                width: 16,
                height: 16,
                excludeFromSemantics: true,
              ),
              label: Text(l10n.movieInfoLabel),
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: DarkSurfaces.sheet,
                minimumSize: const Size(0, 44),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                textStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            if (!isEditMode) const ReviewsFloatingButton(inline: true),
          ],
        ),
        if (selectedRefs.isNotEmpty) ...[
          const SizedBox(height: 36),
          SelectedReviews(
            onRemove:
                (review) => ref
                    .read(journalControllerProvider.notifier)
                    .removeSelectedReview(review),
            references: selectedRefs,
          ),
        ],
      ],
    );
  }
}
