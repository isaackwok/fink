import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_journal/features/journal/data/journal_insights_api.dart';
import 'package:movie_journal/features/journal/widgets/achievement_card.dart';

import '../../../helpers/localized_test_app.dart';
import '../../../helpers/widget_test_setup.dart';

void main() {
  setUpAll(() => setUpWidgetTests());
  tearDownAll(() => tearDownWidgetTests());

  Widget subject(Achievement a, {Locale locale = const Locale('en')}) =>
      localizedTestApp(
        locale: locale,
        home: Scaffold(
          body: Center(
            child: SizedBox(width: 200, child: AchievementCard(achievement: a)),
          ),
        ),
      );

  testWidgets('director card: payload name, ordinal, connector', (
    tester,
  ) async {
    await tester.pumpWidget(
      subject(
        const Achievement(
          kind: AchievementKind.director,
          key: '7467',
          name: 'David Fincher',
          count: 3,
        ),
      ),
    );
    expect(find.text('3rd'), findsOneWidget);
    expect(find.text('film by'), findsOneWidget);
    expect(find.text('David Fincher'), findsOneWidget);
  });

  testWidgets('genre card resolves the localized name from the key', (
    tester,
  ) async {
    await tester.pumpWidget(
      subject(
        const Achievement(
          kind: AchievementKind.genre,
          key: '878',
          name: '878',
          count: 6,
        ),
      ),
    );
    expect(find.text('6th'), findsOneWidget);
    expect(find.text('film in'), findsOneWidget);
    expect(find.text('Science Fiction'), findsOneWidget);
  });

  testWidgets('unknown genre key falls back to the payload name', (
    tester,
  ) async {
    await tester.pumpWidget(
      subject(
        const Achievement(
          kind: AchievementKind.genre,
          key: '99999',
          name: 'Mystery Genre',
          count: 2,
        ),
      ),
    );
    expect(find.text('Mystery Genre'), findsOneWidget);
  });

  testWidgets('country card resolves the ISO code', (tester) async {
    await tester.pumpWidget(
      subject(
        const Achievement(
          kind: AchievementKind.country,
          key: 'JP',
          name: 'JP',
          count: 3,
        ),
      ),
    );
    expect(find.text('film from'), findsOneWidget);
    expect(find.text('Japan'), findsOneWidget);
  });

  testWidgets('pre-2020 era key renders as a decade', (tester) async {
    await tester.pumpWidget(
      subject(
        const Achievement(
          kind: AchievementKind.decade,
          key: '1990',
          name: '1990',
          count: 4,
        ),
      ),
    );
    expect(find.text('film from the'), findsOneWidget);
    expect(find.text('1990s'), findsOneWidget);
  });

  testWidgets('2020+ era key renders as a bare year', (tester) async {
    await tester.pumpWidget(
      subject(
        const Achievement(
          kind: AchievementKind.decade,
          key: '2022',
          name: '2022',
          count: 2,
        ),
      ),
    );
    expect(find.text('film from'), findsOneWidget);
    expect(find.text('2022'), findsOneWidget);
  });

  testWidgets('zh card wraps the ordinal as 第 N 部', (tester) async {
    await tester.pumpWidget(
      subject(
        const Achievement(
          kind: AchievementKind.director,
          key: '7467',
          name: 'David Fincher',
          count: 3,
        ),
        locale: const Locale.fromSubtags(
          languageCode: 'zh',
          scriptCode: 'Hant',
          countryCode: 'TW',
        ),
      ),
    );
    expect(find.text('第 3 部'), findsOneWidget);
    expect(find.text('執導作品'), findsOneWidget);
  });
}
