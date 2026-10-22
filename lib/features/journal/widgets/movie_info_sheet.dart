import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:movie_journal/core/utils/country_names.dart';
import 'package:movie_journal/core/utils/tmdb_image_url.dart';
import 'package:movie_journal/features/movie/data/models/detailed_movie.dart';
import 'package:movie_journal/features/movie/movie_providers.dart';
import 'package:movie_journal/l10n/app_localizations.dart';
import 'package:movie_journal/shared_widgets/tmdb_image.dart';
import 'package:movie_journal/shared_widgets/pull_down_to_dismiss.dart';
import 'package:movie_journal/themes.dart';

class MovieInfoSheet extends ConsumerStatefulWidget {
  const MovieInfoSheet({super.key, required this.movieId});
  final int movieId;

  static Future<void> show(BuildContext context, {required int movieId}) {
    return showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: DarkSurfaces.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      clipBehavior: Clip.antiAlias,
      builder:
          (_) => FractionallySizedBox(
            heightFactor: 1,
            child: MovieInfoSheet(movieId: movieId),
          ),
    );
  }

  @override
  ConsumerState<MovieInfoSheet> createState() => _MovieInfoSheetState();
}

class _MovieInfoSheetState extends ConsumerState<MovieInfoSheet> {
  bool _showCrew = false;
  final _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final movie = ref.watch(movieDetailControllerProvider(widget.movieId));
    return SafeArea(
      top: false,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Container(
              width: 36,
              height: 3,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          Expanded(
            child: movie.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error:
                  (_, _) => Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(l10n.moviePreviewErrorLoading),
                        TextButton(
                          onPressed:
                              () => ref.invalidate(
                                movieDetailControllerProvider(widget.movieId),
                              ),
                          child: Text(l10n.commonRetry),
                        ),
                      ],
                    ),
                  ),
              data: (movie) => _content(context, movie),
            ),
          ),
        ],
      ),
    );
  }

  Widget _content(BuildContext context, DetailedMovie movie) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final countries = movie.originCountry
        .map((code) => countryName(code, locale))
        .join(', ');
    return PullDownToDismiss(
      onDismiss: () => Navigator.of(context).pop(),
      child: NestedScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        headerSliverBuilder:
            (context, innerBoxIsScrolled) => [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        movie.title,
                        style: const TextStyle(
                          fontFamily: 'AvenirNext',
                          fontSize: 24,
                          height: 1.4,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        [
                          if (movie.year != 'Unknown') movie.year,
                          if (countries.isNotEmpty) countries,
                        ].join(' ｜ '),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                      if (movie.genres.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          movie.genres.map((g) => g.name).join(', '),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children:
                              movie.genres
                                  .map((g) => _GenreChip(genre: g))
                                  .toList(),
                        ),
                      ],
                      const SizedBox(height: 24),
                      Wrap(
                        spacing: 8,
                        children: [
                          _tab(l10n.movieInfoCast, false),
                          _tab(l10n.movieInfoCrew, true),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
        body: PageView(
          controller: _pageController,
          onPageChanged: (index) => setState(() => _showCrew = index == 1),
          children: [
            _credits(context, movie, showCrew: false),
            _credits(context, movie, showCrew: true),
          ],
        ),
      ),
    );
  }

  Widget _credits(
    BuildContext context,
    DetailedMovie movie, {
    required bool showCrew,
  }) {
    final l10n = AppLocalizations.of(context);
    final people =
        showCrew
            ? movie.credits.crew
                .map((p) => (name: p.name, role: p.job, path: p.profilePath))
                .toList()
            : movie.credits.cast
                .map(
                  (p) => (name: p.name, role: p.character, path: p.profilePath),
                )
                .toList();
    return PullDownToDismiss(
      onDismiss: () => Navigator.of(context).pop(),
      child: CustomScrollView(
        key: PageStorageKey(showCrew),
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    showCrew
                        ? l10n.movieInfoCrewCount(count: people.length)
                        : l10n.movieInfoCastCount(count: people.length),
                    style: const TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                  const SizedBox(height: 8),
                  if (people.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Text(l10n.movieInfoNoCredits),
                    ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
            sliver: SliverList.separated(
              itemCount: people.length,
              separatorBuilder:
                  (_, _) => Divider(
                    height: 8,
                    thickness: 0.5,
                    color: Colors.white.withAlpha(51),
                  ),
              itemBuilder: (_, index) {
                final person = people[index];
                final placeholder = Container(
                  color: const Color(0xFFB3B3B3),
                  child: Center(
                    child: SvgPicture.asset(
                      'assets/images/credit_placeholder.svg',
                    ),
                  ),
                );
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: SizedBox(
                          width: 52,
                          height: 52,
                          child:
                              person.path == null || person.path!.isEmpty
                                  ? placeholder
                                  : TmdbImage(
                                    path: person.path!,
                                    size: TmdbImageSize.w154,
                                    width: 52,
                                    height: 52,
                                    errorWidget: placeholder,
                                  ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              person.name,
                              style: const TextStyle(
                                fontFamily: 'AvenirNext',
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              person.role,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _tab(String label, bool crew) => AnimatedBuilder(
    animation: _pageController,
    builder: (context, child) {
      final page =
          _pageController.hasClients
              ? (_pageController.page ?? 0).clamp(0.0, 1.0)
              : 0.0;
      final selectedAmount = crew ? page : 1 - page;
      final background = Color.lerp(
        Colors.white.withAlpha(38),
        Colors.white.withAlpha(230),
        selectedAmount,
      );
      return ChoiceChip(
        label: Text(label),
        selected: _showCrew == crew,
        showCheckmark: false,
        onSelected:
            (_) => _pageController.animateToPage(
              crew ? 1 : 0,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
            ),
        // The page position drives both colors, including cancelled swipes.
        color: WidgetStatePropertyAll(background),
        chipAnimationStyle: ChipAnimationStyle(
          selectAnimation: AnimationStyle.noAnimation,
        ),
        side: BorderSide.none,
        shape: const StadiumBorder(),
        labelStyle: TextStyle(
          color: Color.lerp(Colors.white, Colors.black, selectedAmount),
          fontSize: 14,
          fontFamily: 'AvenirNext',
          fontWeight: FontWeight.w500,
        ),
      );
    },
  );
}

class _GenreChip extends StatelessWidget {
  const _GenreChip({required this.genre});
  final Genre genre;

  @override
  Widget build(BuildContext context) {
    final color = switch (genre.id) {
      18 => const Color(0xFF9ADCFF),
      35 => const Color(0xFF87C997),
      10749 => const Color(0xFFFC8885),
      _ => Theme.of(context).colorScheme.primary,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        genre.name,
        style: TextStyle(
          fontFamily: 'AvenirNext',
          fontSize: 12,
          height: 1.5,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
