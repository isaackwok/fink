import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:movie_journal/features/journal/controllers/journal_insights.dart';
import 'package:movie_journal/features/journal/screens/journal_content.dart';
import 'package:movie_journal/features/journal/widgets/emotion_echo_card.dart';
import 'package:movie_journal/features/journal/widgets/journal_actions.dart';
import 'package:movie_journal/l10n/app_localizations.dart';

/// "You also felt … when watching…" on the journal complete screen: previous
/// journals sharing one emotion group with the just-saved journal.
///
/// Pure derivation from the in-memory journals list — renders nothing when no
/// group qualifies.
class EmotionEchoesSection extends ConsumerWidget {
  final String journalId;

  const EmotionEchoesSection({super.key, required this.journalId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final echoes = ref.watch(emotionEchoesProvider(journalId));
    if (echoes.isEmpty) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context);
    final greyStyle = GoogleFonts.inter(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: const Color(0xFFB1B1B1),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 48px gap + hairline + 48px gap, owned by the section so an empty
        // section collapses entirely (mirrors AchievementsSection).
        const SizedBox(height: 48),
        Container(height: 0.5, color: Colors.white12),
        const SizedBox(height: 48),
        Row(
          children: [
            SvgPicture.asset(
              'assets/images/emotion_echo_header.svg',
              width: 36,
              height: 24,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text.rich(
                TextSpan(
                  style: greyStyle,
                  children: [
                    TextSpan(text: l10n.emotionEchoHeaderPrefix),
                    TextSpan(
                      // The winning shared-emotion group, bolded — built from
                      // headerEmotions, never by splitting a sentence.
                      text: echoes.headerEmotions
                          .map((e) => e.name.toLowerCase())
                          .join(' '),
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    TextSpan(text: l10n.emotionEchoHeaderSuffix),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        for (final (index, echo) in echoes.echoes.indexed) ...[
          if (index > 0) const SizedBox(height: 32),
          EmotionEchoCard(
            journal: echo.journal,
            onOpen:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => JournalContent(journalId: echo.journal.id),
                  ),
                ),
            onAddNow: () => editJournal(context, ref, echo.journal),
          ),
        ],
      ],
    );
  }
}
