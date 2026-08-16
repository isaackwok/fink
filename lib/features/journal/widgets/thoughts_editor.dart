import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:movie_journal/features/journal/controllers/journal.dart';
import 'package:movie_journal/features/journal/screens/thoughts.dart';
import 'package:movie_journal/features/journal/widgets/ai_references_accordion.dart';
import 'package:movie_journal/themes.dart';
import 'package:movie_journal/l10n/app_localizations.dart';

class ThoughtsEditor extends ConsumerWidget {
  const ThoughtsEditor({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    // Field-level selects: this widget only cares about thoughts and
    // selectedRefs, so scene/emotion edits shouldn't rebuild it.
    final thoughts = ref.watch(
      journalControllerProvider.select((j) => j.thoughts),
    );
    final selectedRefs = ref.watch(
      journalControllerProvider.select((j) => j.selectedRefs),
    );
    final hasThoughts = thoughts.isNotEmpty;

    void openEditor() {
      showModalBottomSheet(
        useSafeArea: true,
        enableDrag: false,
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (context) => const ThoughtsScreen(),
      );
    }

    return Column(
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
        Material(
          color: Colors.transparent,
          child: InkWell(
            splashColor: Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            onTap: openEditor,
            child: Container(
              constraints: const BoxConstraints(minHeight: 299),
              padding: const EdgeInsets.fromLTRB(20, 20, 12, 20),
              decoration: BoxDecoration(
                color: hasThoughts ? DarkSurfaces.card : Colors.transparent,
                border:
                    hasThoughts
                        ? null
                        : Border.all(color: Colors.white.withAlpha(26)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                hasThoughts ? thoughts : l10n.thoughtsHint,
                style:
                    hasThoughts
                        ? GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                          color: Colors.white.withAlpha(204),
                        )
                        : GoogleFonts.nothingYouCouldDo(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          height: 1.25,
                          color: Colors.white.withAlpha(128),
                        ),
              ),
            ),
          ),
        ),
        if (selectedRefs.isNotEmpty) ...[
          const SizedBox(height: 16),
          AiReferencesAccordion(
            defaultExpanded: true,
            references: selectedRefs,
          ),
        ],
      ],
    );
  }
}
