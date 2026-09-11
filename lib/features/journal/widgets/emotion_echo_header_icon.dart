import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:movie_journal/features/emotion/emotion.dart';
import 'package:movie_journal/features/emotion/emotion_group_colors.dart';

/// The 24×24 two-circle mark beside "You also felt…" (Figma 7363:25088).
///
/// Each circle is tinted with the group color of one shared emotion — the
/// first lower-left, the second upper-right, both at 70% so the overlap
/// reads as a blend. At most two are drawn; extra emotions are ignored.
class EmotionEchoHeaderIcon extends StatelessWidget {
  final List<Emotion> emotions;

  const EmotionEchoHeaderIcon({super.key, required this.emotions});

  /// The group colors actually painted, in draw order (max two).
  List<Color> get colors => [
    for (final e in emotions.take(2)) EmotionGroupColors.of(e.group),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 24,
      child: CustomPaint(painter: _CirclesPainter(colors)),
    );
  }
}

class _CirclesPainter extends CustomPainter {
  _CirclesPainter(this.colors);

  final List<Color> colors;

  // Figma geometry on the 24×24 frame: Ellipse 315 then 316, r = 9.19.
  static const _centers = [Offset(10.19, 13.83), Offset(13.81, 10.19)];
  static const _radius = 9.19;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 24;
    for (var i = 0; i < colors.length && i < _centers.length; i++) {
      canvas.drawCircle(
        _centers[i] * scale,
        _radius * scale,
        Paint()..color = colors[i].withValues(alpha: 0.7),
      );
    }
  }

  @override
  bool shouldRepaint(_CirclesPainter old) => !listEquals(old.colors, colors);
}
