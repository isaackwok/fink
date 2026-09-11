import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_journal/features/journal/controllers/journal_insights.dart';
import 'package:movie_journal/features/journal/data/journal_insights_api.dart';
import 'package:movie_journal/features/journal/widgets/achievement_card.dart';
import 'package:movie_journal/features/journal/widgets/achievements_section.dart';

import '../../../helpers/localized_test_app.dart';
import '../../../helpers/widget_test_setup.dart';

class _FixedInsightsApi extends JournalInsightsApi {
  _FixedInsightsApi(this.result);

  final List<Achievement> result;

  @override
  Future<List<Achievement>> fetchAchievements(int tmdbId) async => result;
}

Achievement _achievement(int i) => Achievement(
  kind: AchievementKind.values[i % AchievementKind.values.length],
  key: 'k$i',
  name: 'Name $i',
  count: 2 + i,
);

void main() {
  setUpAll(() => setUpWidgetTests());
  tearDownAll(() => tearDownWidgetTests());

  const sectionWidth = 358.0;

  Widget subject(List<Achievement> achievements) => ProviderScope(
    overrides: [
      journalInsightsApiProvider.overrideWithValue(
        _FixedInsightsApi(achievements),
      ),
    ],
    child: localizedTestApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: Center(
            child: SizedBox(
              width: sectionWidth,
              child: const AchievementsSection(tmdbId: 550),
            ),
          ),
        ),
      ),
    ),
  );

  testWidgets('an even count lays cards out two per row', (tester) async {
    await tester.pumpWidget(subject([_achievement(0), _achievement(1)]));
    await tester.pumpAndSettle();

    final cards = find.byType(AchievementCard);
    expect(cards, findsNWidgets(2));
    final left = tester.getRect(cards.at(0));
    final right = tester.getRect(cards.at(1));
    expect(left.top, right.top, reason: 'same row');
    expect(left.width, closeTo((sectionWidth - 12) / 2, 0.01));
    expect(right.width, closeTo((sectionWidth - 12) / 2, 0.01));
    expect(right.left - left.right, closeTo(12, 0.01), reason: '12px gutter');
  });

  testWidgets('an odd trailing card stretches to the full row', (tester) async {
    await tester.pumpWidget(
      subject([_achievement(0), _achievement(1), _achievement(2)]),
    );
    await tester.pumpAndSettle();

    final cards = find.byType(AchievementCard);
    expect(cards, findsNWidgets(3));
    final first = tester.getRect(cards.at(0));
    final last = tester.getRect(cards.at(2));
    expect(last.width, closeTo(sectionWidth, 0.01), reason: 'full row');
    expect(last.top - first.bottom, closeTo(12, 0.01), reason: '12px row gap');
    expect(last.height, first.height, reason: 'same tile height');
  });
}
