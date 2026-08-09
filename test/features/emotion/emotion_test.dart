import 'package:flutter_test/flutter_test.dart';
import 'package:movie_journal/features/emotion/emotion.dart';

void main() {
  group('Emotion data integrity', () {
    test('emotionList contains exactly 35 emotions', () {
      expect(emotionList.length, 35);
    });

    test('all 5 emotion groups are present', () {
      final groups = emotionList.values.map((e) => e.group).toSet();
      expect(groups, {
        'Uplifting',
        'Intense',
        'Soothing',
        'Quiet',
        'Perspectives',
      });
    });

    test('energy groups have 6 emotions and Perspectives has 11', () {
      final groupCounts = <String, int>{};
      for (final emotion in emotionList.values) {
        groupCounts[emotion.group] = (groupCounts[emotion.group] ?? 0) + 1;
      }
      expect(groupCounts, {
        'Uplifting': 6,
        'Intense': 6,
        'Soothing': 6,
        'Quiet': 6,
        'Perspectives': 11,
      });
    });

    test('each energy group follows the requested display order', () {
      List<String> namesFor(String group) =>
          emotionList.values
              .where((emotion) => emotion.group == group)
              .map((emotion) => emotion.name)
              .toList();

      expect(namesFor('Uplifting'), [
        'Joyful',
        'Funny',
        'Inspired',
        'Hopeful',
        'Fulfilling',
        'Exhilarated',
      ]);
      expect(namesFor('Intense'), [
        'Shocked',
        'Angry',
        'Terrified',
        'Anxious',
        'Overwhelmed',
        'Disgusted',
      ]);
      expect(namesFor('Soothing'), [
        'Heartwarming',
        'Touched',
        'Peaceful',
        'Nostalgic',
        'Cozy',
        'Satisfied',
      ]);
      expect(namesFor('Quiet'), [
        'Melancholic',
        'Confused',
        'Bittersweet',
        'Powerless',
        'Bored',
        'Conflicted',
      ]);
    });

    test(
      'Uplifting/Intense are high energy, Soothing/Quiet are low energy',
      () {
        for (final emotion in emotionList.values) {
          if (emotion.group == 'Uplifting' || emotion.group == 'Intense') {
            expect(
              emotion.energyLevel,
              'high',
              reason: '${emotion.name} in ${emotion.group} should be high',
            );
          } else {
            expect(
              emotion.energyLevel,
              'low',
              reason: '${emotion.name} in ${emotion.group} should be low',
            );
          }
        }
      },
    );

    test('each emotion has a unique id', () {
      final ids = emotionList.values.map((e) => e.id).toList();
      expect(ids.toSet().length, ids.length, reason: 'ids should be unique');
    });

    test('emotion lookup by id works (validates fromJson emotion parsing)', () {
      const testId = 'joyful';
      final found = emotionById(testId)!;
      expect(found.id, testId);
      expect(found.name, 'Joyful');
      expect(found.group, 'Uplifting');
    });

    test('retired emotion ids remain readable for existing journals', () {
      expect(emotionById('mindBlown')?.name, 'Mind-blown');
      expect(emotionById('disturbed')?.name, 'Disturbed');
      expect(emotionById('therapeutic')?.name, 'Therapeutic');
      expect(emotionById('profound')?.name, 'Profound');
      expect(emotionById('lonely')?.name, 'Lonely');
    });
  });

  group('Emotion value equality', () {
    // Built with `final` (not const) so instances are not canonicalized and
    // the == override is actually exercised.
    test('same fields → equal, same hashCode', () {
      // ignore: prefer_const_constructors
      final a = Emotion(
        id: 'joyful',
        name: 'Joyful',
        group: 'Uplifting',
        energyLevel: 'high',
      );
      // ignore: prefer_const_constructors
      final b = Emotion(
        id: 'joyful',
        name: 'Joyful',
        group: 'Uplifting',
        energyLevel: 'high',
      );
      expect(identical(a, b), isFalse);
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('different id → not equal', () {
      // ignore: prefer_const_constructors
      final a = Emotion(
        id: 'joyful',
        name: 'Joyful',
        group: 'Uplifting',
        energyLevel: 'high',
      );
      // ignore: prefer_const_constructors
      final b = Emotion(
        id: 'funny',
        name: 'Joyful',
        group: 'Uplifting',
        energyLevel: 'high',
      );
      expect(a, isNot(equals(b)));
    });
  });
}
