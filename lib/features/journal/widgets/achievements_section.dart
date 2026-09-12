import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:movie_journal/features/journal/controllers/journal_insights.dart';
import 'package:movie_journal/features/journal/widgets/achievement_card.dart';
import 'package:movie_journal/l10n/app_localizations.dart';
import 'package:movie_journal/themes.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// "Your achievements" on the journal complete screen.
///
/// Renders nothing on error or a resolved-empty list (the rest of the screen
/// is unaffected by an unreachable insights function); shows a skeleton grid
/// while the (usually prefetched) call is still loading.
class AchievementsSection extends ConsumerWidget {
  final int tmdbId;

  const AchievementsSection({super.key, required this.tmdbId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final insights = ref.watch(journalInsightsControllerProvider(tmdbId));

    // A refresh (AsyncLoading carrying the previous value) renders the value.
    final achievements = insights.value;
    if (achievements == null) {
      if (insights.hasError) return const SizedBox.shrink();
      return const _WithTopGap(child: _SkeletonSection());
    }
    if (achievements.isEmpty) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context);
    return _WithTopGap(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              l10n.achievementsHeader,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xFFB1B1B1),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _AchievementGrid(
            children: [
              for (final a in achievements) AchievementCard(achievement: a),
            ],
          ),
        ],
      ),
    );
  }
}

/// The 112pt gap between the success block's buttons and this section's
/// header (Figma 7363:24722, with no divider).
/// Owned by the section so a hidden section collapses entirely.
class _WithTopGap extends StatelessWidget {
  final Widget child;

  const _WithTopGap({required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [const SizedBox(height: 112), child],
    );
  }
}

/// Two cards per row with 12px gutters; an odd trailing card stretches to
/// the full row. Rows carry a fixed height so every card
/// in the section reads as the same tile regardless of its text length.
class _AchievementGrid extends StatelessWidget {
  final List<Widget> children;

  const _AchievementGrid({required this.children});

  static const _gap = 12.0;
  static const _rowHeight = 132.0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < children.length; i += 2) ...[
          if (i > 0) const SizedBox(height: _gap),
          SizedBox(
            height: _rowHeight,
            child:
                i + 1 < children.length
                    ? Row(
                      children: [
                        Expanded(child: children[i]),
                        const SizedBox(width: _gap),
                        Expanded(child: children[i + 1]),
                      ],
                    )
                    : children[i],
          ),
        ],
      ],
    );
  }
}

class _SkeletonSection extends StatelessWidget {
  const _SkeletonSection();

  @override
  Widget build(BuildContext context) {
    return const Skeletonizer.zone(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Bone.text(words: 4, fontSize: 14),
          ),
          SizedBox(height: 16),
          _AchievementGrid(children: [_SkeletonCard(), _SkeletonCard()]),
        ],
      ),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: DarkSurfaces.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Bone.square(size: 36, uniRadius: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Bone.text(words: 2, fontSize: 12),
              SizedBox(height: 6),
              Bone.text(words: 1, fontSize: 14),
            ],
          ),
        ],
      ),
    );
  }
}
