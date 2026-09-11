import 'dart:ui';

/// The accent color of each emotion group — the single source for the
/// selector sheet's section labels/chips and the echo header's circles.
///
/// Keyed by the `Emotion.group` label. Unknown labels fall back to the
/// neutral Perspectives grey so a future group can't throw at render time.
abstract final class EmotionGroupColors {
  static const Color uplifting = Color(0xFFFADD9E);
  static const Color intense = Color(0xFFFC8885);
  static const Color soothing = Color(0xFF87C997);
  static const Color quiet = Color(0xFF9ADCFF);
  static const Color perspectives = Color(0xFF8F8E8E);

  static Color of(String group) => switch (group) {
    'Uplifting' => uplifting,
    'Intense' => intense,
    'Soothing' => soothing,
    'Quiet' => quiet,
    _ => perspectives,
  };
}
