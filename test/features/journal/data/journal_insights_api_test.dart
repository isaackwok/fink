import 'package:flutter_test/flutter_test.dart';
import 'package:movie_journal/features/journal/data/journal_insights_api.dart';

void main() {
  group('Achievement.fromJson', () {
    test('parses a well-formed achievement', () {
      final a = Achievement.fromJson({
        'kind': 'director',
        'key': '7467',
        'name': 'David Fincher',
        'count': 3,
      });
      expect(a, isNotNull);
      expect(a!.kind, AchievementKind.director);
      expect(a.key, '7467');
      expect(a.name, 'David Fincher');
      expect(a.count, 3);
    });

    test('parses every known kind', () {
      for (final kind in AchievementKind.values) {
        final a = Achievement.fromJson({
          'kind': kind.name,
          'key': 'k',
          'name': 'n',
          'count': 2,
        });
        expect(a?.kind, kind);
      }
    });

    test('returns null for an unknown kind (Part 2 forward compat)', () {
      final a = Achievement.fromJson({
        'kind': 'festival',
        'key': 'cannes',
        'name': 'Cannes',
        'count': 2,
      });
      expect(a, isNull);
    });

    test('returns null for missing or mistyped fields', () {
      expect(Achievement.fromJson({'kind': 'genre'}), isNull);
      expect(
        Achievement.fromJson({
          'kind': 'genre',
          'key': 18,
          'name': '18',
          'count': 2,
        }),
        isNull,
      );
      expect(
        Achievement.fromJson({
          'kind': 'genre',
          'key': '18',
          'name': '18',
          'count': 'two',
        }),
        isNull,
      );
    });
  });

  group('Achievement equality', () {
    const base = Achievement(
      kind: AchievementKind.actor,
      key: '287',
      name: 'Brad Pitt',
      count: 3,
    );

    test('equal values are equal with equal hashCodes', () {
      const same = Achievement(
        kind: AchievementKind.actor,
        key: '287',
        name: 'Brad Pitt',
        count: 3,
      );
      expect(base, same);
      expect(base.hashCode, same.hashCode);
    });

    test('each field participates in equality', () {
      expect(
        base,
        isNot(
          const Achievement(
            kind: AchievementKind.director,
            key: '287',
            name: 'Brad Pitt',
            count: 3,
          ),
        ),
      );
      expect(
        base,
        isNot(
          const Achievement(
            kind: AchievementKind.actor,
            key: '288',
            name: 'Brad Pitt',
            count: 3,
          ),
        ),
      );
      expect(
        base,
        isNot(
          const Achievement(
            kind: AchievementKind.actor,
            key: '287',
            name: 'Bradley Pitt',
            count: 3,
          ),
        ),
      );
      expect(
        base,
        isNot(
          const Achievement(
            kind: AchievementKind.actor,
            key: '287',
            name: 'Brad Pitt',
            count: 4,
          ),
        ),
      );
    });
  });
}
