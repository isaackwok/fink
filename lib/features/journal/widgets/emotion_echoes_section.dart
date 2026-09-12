import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:movie_journal/features/journal/controllers/journal_insights.dart';
import 'package:movie_journal/features/journal/screens/journal_content.dart';
import 'package:movie_journal/features/journal/widgets/emotion_echo_card.dart';
import 'package:movie_journal/features/journal/widgets/emotion_echo_header_icon.dart';
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
    final emotionNameStyle = GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w700,
      color: Colors.white,
    );
    final names =
        echoes.headerEmotions.map((e) => e.name.toLowerCase()).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Plain 60pt gap, no divider (Figma 7363:24722 — the section's
        // header sits 60 below the achievements grid). Owned by the section
        // so an empty section collapses entirely (mirrors AchievementsSection).
        const SizedBox(height: 60),
        Row(
          children: [
            // Circles tinted by the shared emotions' groups (max two).
            EmotionEchoHeaderIcon(emotions: echoes.headerEmotions),
            const SizedBox(width: 8),
            Expanded(
              child: Text.rich(
                TextSpan(
                  style: greyStyle,
                  children: [
                    TextSpan(text: l10n.emotionEchoHeaderPrefix),
                    // The winning shared-emotion group — built from
                    // headerEmotions, never by splitting a sentence. Each name
                    // is bolded individually with the same localized
                    // separators as EmotionsSelectorButton on JournalContent.
                    TextSpan(text: names.first, style: emotionNameStyle),
                    for (var i = 1; i < names.length; i++) ...[
                      TextSpan(
                        text:
                            i == names.length - 1
                                ? l10n.emotionsListFinalSeparator
                                : l10n.emotionsListSeparator,
                      ),
                      TextSpan(text: names[i], style: emotionNameStyle),
                    ],
                    TextSpan(text: l10n.emotionEchoHeaderSuffix),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        for (final (index, echo) in echoes.echoes.indexed) ...[
          if (index > 0) const SizedBox(height: 12),
          EmotionEchoCard(
            journal: echo.journal,
            // Opened from the complete screen, the journal page hides share
            // and delete: both assume the Home → JournalContent stack.
            onOpen:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => JournalContent(
                          journalId: echo.journal.id,
                          showShareAndDelete: false,
                        ),
                  ),
                ),
            // "Fill in memory" goes straight to the editor (no view page in
            // between); the editor has no share/delete of its own.
            onAddNow: () => editJournal(context, ref, echo.journal),
          ),
        ],
      ],
    );
  }
}
