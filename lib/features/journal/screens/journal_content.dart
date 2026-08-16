import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:movie_journal/analytics_manager.dart';
import 'package:movie_journal/features/journal/controllers/journals.dart';
import 'package:movie_journal/features/journal/widgets/ai_references_accordion.dart';
import 'package:movie_journal/features/journal/widgets/emotions_selector_button.dart';
import 'package:movie_journal/features/journal/widgets/journal_content_more_menu.dart';
import 'package:movie_journal/features/journal/widgets/scene_card.dart';
import 'package:movie_journal/features/share/share_flow.dart';
import 'package:movie_journal/features/share/screens/ticket_poster_picker_screen.dart';
import 'package:movie_journal/shared_widgets/circled_icon_button.dart';
import 'package:movie_journal/themes.dart';

class JournalContent extends ConsumerStatefulWidget {
  final String journalId;
  const JournalContent({super.key, required this.journalId});

  @override
  ConsumerState<JournalContent> createState() => _JournalContentState();
}

class _JournalContentState extends ConsumerState<JournalContent> {
  late PageController _pageController;
  final ScrollController _scrollController = ScrollController();
  bool _showTitle = false;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Show title when scrolled down more than 100 pixels — mirrors
    // JournalingScreen's collapsing-title behavior.
    final showTitle =
        _scrollController.hasClients && _scrollController.offset > 100;
    if (showTitle != _showTitle) {
      setState(() {
        _showTitle = showTitle;
      });
    }
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    final journalsAsync = ref.watch(journalsControllerProvider);

    // Handle loading and error states
    if (journalsAsync.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (journalsAsync.hasError) {
      return Scaffold(
        body: Center(child: Text('Error: ${journalsAsync.error}')),
      );
    }

    final journals = journalsAsync.value?.journals ?? [];

    // Try to find the journal, if not found (deleted), navigate back
    final journalIndex = journals.indexWhere((j) => j.id == widget.journalId);
    if (journalIndex == -1) {
      // Journal was deleted, navigate back after this frame
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && Navigator.canPop(context)) {
          Navigator.of(context).pop();
        }
      });
      // Return empty scaffold while waiting for navigation
      return const Scaffold(body: SizedBox.shrink());
    }

    final journal = journals[journalIndex];

    return ScreenViewTracker(
      screenName: 'JournalContent',
      child: Scaffold(
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
                  journal.movieTitle,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              actions: [
                IconButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        settings: const RouteSettings(
                          name: kShareFlowRouteName,
                        ),
                        builder:
                            (_) => TicketPosterPickerScreen(
                              journal: journal,
                              entry: ShareTicketEntry.journalContent,
                            ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.ios_share, color: Colors.white),
                ),
                JournalContentMoreMenu(journalId: widget.journalId),
              ],
              leading: CircledIconButton(
                icon: Icons.arrow_back_ios_new,
                onPressed: () => Navigator.pop(context),
                outerPadding: const EdgeInsets.only(left: 16),
              ),
              leadingWidth: 40 + 16,
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        journal.movieTitle,
                        style: GoogleFonts.inter(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Text(
                            journal.updatedAt.format(pattern: 'MMM do yyyy'),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              height: 16 / 14,
                              letterSpacing: 0.5,
                              color: Color(0xFFDDDDDD),
                              fontFamily: 'AvenirNext',
                            ),
                          ),
                          if (journal.rating > 0) ...[
                            const SizedBox(width: 8),
                            _JournalRatingBadge(rating: journal.rating),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    if (journal.emotions.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: EmotionsSelectorButton(
                          emotions: journal.emotions,
                          readonly: true,
                        ),
                      ),
                    if (journal.emotions.isNotEmpty) const SizedBox(height: 24),
                    journal.selectedScenes.isEmpty
                        ? const SizedBox.shrink()
                        : Column(
                          children: [
                            SizedBox(
                              height: 235,
                              child: PageView.builder(
                                controller: _pageController,
                                onPageChanged: _onPageChanged,
                                itemCount: journal.selectedScenes.length,
                                itemBuilder: (context, index) {
                                  final scene = journal.selectedScenes[index];
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    child: SceneCard(
                                      imagePath: scene.path,
                                      caption: scene.caption,
                                      isEditable: false,
                                    ),
                                  );
                                },
                              ),
                            ),
                            SizedBox(
                              width: double.infinity,
                              height: 24,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Centered dots
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    spacing: 4,
                                    children: List.generate(
                                      journal.selectedScenes.length,
                                      (index) => Container(
                                        width: 6,
                                        height: 6,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color:
                                              index == _currentPage
                                                  ? Colors.white
                                                  : Colors.white.withAlpha(77),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                    const SizedBox(height: 24),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        journal.thoughts,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child:
                          journal.selectedRefs.isEmpty
                              ? const SizedBox.shrink()
                              : AiReferencesAccordion(
                                references: journal.selectedRefs,
                              ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _JournalRatingBadge extends StatelessWidget {
  const _JournalRatingBadge({required this.rating});

  final int rating;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('journal-rating-badge'),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: DarkSurfaces.card,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            'assets/images/rating_heart_badge.svg',
            width: 20,
            height: 20,
          ),
          const SizedBox(width: 4),
          Text(
            '$rating',
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'AvenirNext',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              height: 1.5,
              letterSpacing: -0.154,
            ),
          ),
        ],
      ),
    );
  }
}
