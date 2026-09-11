import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_journal/features/emotion/emotion.dart';
import 'package:movie_journal/features/emotion/emotion_group_colors.dart';
import 'package:movie_journal/features/journal/widgets/emotion_echo_header_icon.dart';

void main() {
  final joyful = emotionList[EmotionType.joyful]!; // Uplifting
  final touched = emotionList[EmotionType.touched]!; // Soothing
  final angry = emotionList[EmotionType.angry]!; // Intense

  testWidgets('is a 24x24 mark painting one circle per emotion, max two', (
    tester,
  ) async {
    await tester.pumpWidget(
      Center(child: EmotionEchoHeaderIcon(emotions: [joyful, touched, angry])),
    );

    expect(
      tester.getSize(find.byType(EmotionEchoHeaderIcon)),
      const Size(24, 24),
    );
    final icon = tester.widget<EmotionEchoHeaderIcon>(
      find.byType(EmotionEchoHeaderIcon),
    );
    expect(icon.colors, [
      EmotionGroupColors.uplifting,
      EmotionGroupColors.soothing,
    ]);
  });

  test(
    'EmotionGroupColors.of maps every group label, unknown → perspectives',
    () {
      expect(EmotionGroupColors.of('Uplifting'), EmotionGroupColors.uplifting);
      expect(EmotionGroupColors.of('Intense'), EmotionGroupColors.intense);
      expect(EmotionGroupColors.of('Soothing'), EmotionGroupColors.soothing);
      expect(EmotionGroupColors.of('Quiet'), EmotionGroupColors.quiet);
      expect(
        EmotionGroupColors.of('Perspectives'),
        EmotionGroupColors.perspectives,
      );
      expect(EmotionGroupColors.of('???'), EmotionGroupColors.perspectives);
      // Every emotion in the list resolves to a known group.
      for (final e in emotionList.values) {
        expect(EmotionGroupColors.of(e.group), isNot(isNull));
      }
    },
  );
}
