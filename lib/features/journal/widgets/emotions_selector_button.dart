import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:movie_journal/features/emotion/emotion.dart';
import 'package:movie_journal/features/journal/widgets/emotions_selector_bottom_sheet.dart';
import 'package:movie_journal/themes.dart';
import 'package:movie_journal/l10n/app_localizations.dart';

class EmotionsSelectorButton extends StatelessWidget {
  final List<Emotion> emotions;
  final Function(List<Emotion>)? onSave;
  final bool readonly;

  const EmotionsSelectorButton({
    super.key,
    required this.emotions,
    this.onSave,
    this.readonly = false,
  });

  /// Determines the gradient colors based on the energy mix of selected emotions
  LinearGradient _getEnergyGradientColors(List<Emotion> selectedEmotions) {
    if (selectedEmotions.isEmpty) {
      // Default colors when no emotions are selected
      return const LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [Color(0xFF545454), Color(0xFF545454)],
      );
    }

    if (selectedEmotions.every((e) => e.group == 'Perspectives')) {
      return const LinearGradient(
        colors: [Color(0xFFDDDDDD), Color(0xFFDDDDDD)],
      );
    }

    final hasHighEnergy = selectedEmotions.any((e) => e.energyLevel == 'high');
    final hasLowEnergy = selectedEmotions.any((e) => e.energyLevel == 'low');

    if (hasHighEnergy && !hasLowEnergy) {
      // All High Energy: Pink/salmon gradient
      return const LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [Color(0xFFFADD9E), Color(0xFFFF8784)],
        stops: [0.1, 0.9],
      );
    } else if (!hasHighEnergy && hasLowEnergy) {
      // All Low Energy: Teal/cyan gradient
      return const LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [Color(0xFF87C997), Color(0xFF9ADCFF)],
        stops: [0.1, 0.9],
      );
    } else {
      // Mixed Energy: Yellow/green gradient
      return const LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [
          Color(0xFFFF8784),
          Color(0xFFFADD9E),
          Color(0xFFE1E9B1),
          Color(0xFFA4E5B4),
          Color(0xFF9ADCFF),
        ],
        stops: [0.15, 0.35, 0.5, 0.7, 0.9],
      );
    }
  }

  static const _sentenceStyle = TextStyle(
    color: Color(0xFFDDDDDD),
    fontSize: 14,
    fontWeight: FontWeight.w500,
    fontFamily: 'AvenirNext',
  );

  static const _emotionNameStyle = TextStyle(
    fontWeight: FontWeight.w600,
    fontFamily: 'AvenirNext',
  );

  TextSpan _emotionName(String name) =>
      TextSpan(text: name, style: _emotionNameStyle);

  Widget _getButtonText(List<Emotion> selectedEmotions, AppLocalizations l10n) {
    if (selectedEmotions.isEmpty) {
      return Text(
        l10n.emotionsSelect,
        style: const TextStyle(
          color: Color(0xFF8F8E8E),
          fontSize: 14,
          fontWeight: FontWeight.w500,
          fontFamily: 'AvenirNext',
        ),
      );
    }

    final names = selectedEmotions.map((e) => e.name.toLowerCase()).toList();

    return Text.rich(
      TextSpan(
        style: _sentenceStyle,
        children: [
          TextSpan(text: l10n.emotionsSummaryPrefix),
          _emotionName(names.first),
          for (var i = 1; i < names.length; i++) ...[
            TextSpan(
              text:
                  i == names.length - 1
                      ? l10n.emotionsListFinalSeparator
                      : l10n.emotionsListSeparator,
            ),
            _emotionName(names[i]),
          ],
          TextSpan(text: l10n.emotionsSummarySuffix),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasSelection = emotions.isNotEmpty;
    final l10n = AppLocalizations.of(context);

    final color = Theme.of(context).colorScheme.primary;
    final buttonText = _getButtonText(emotions, l10n);
    final gradientColors = _getEnergyGradientColors(emotions);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!readonly) ...[
          Text(
            l10n.emotionsPrompt,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
              fontFamily: 'AvenirNext',
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
        ],
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap:
                readonly
                    ? null
                    : () {
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: Colors.transparent,
                        isScrollControlled: true,
                        builder:
                            (context) => EmotionsSelectorBottomSheet(
                              initialEmotions: emotions,
                              onSave: onSave,
                            ),
                      );
                    },
            borderRadius: BorderRadius.circular(10),
            child: Container(
              constraints: const BoxConstraints(minHeight: 64),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: hasSelection ? DarkSurfaces.card : Colors.transparent,
                border:
                    hasSelection
                        ? null
                        : Border.all(color: Colors.white.withAlpha(26)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: gradientColors,
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        'assets/images/emotion_face.svg',
                        width: 40,
                        height: 40,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: buttonText),
                  if (!readonly) ...[
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 36,
                      height: 36,
                      child: Icon(
                        hasSelection ? Icons.edit : Icons.add,
                        color: hasSelection ? color : Colors.white,
                        size: 24,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
