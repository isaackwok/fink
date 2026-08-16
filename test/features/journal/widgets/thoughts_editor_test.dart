import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_journal/features/journal/controllers/journal.dart';
import 'package:movie_journal/features/journal/widgets/thoughts_editor.dart';
import 'package:movie_journal/themes.dart';

import '../../../helpers/localized_test_app.dart';

void main() {
  Widget buildSubject(
    ProviderContainer container, {
    Locale locale = const Locale('en'),
  }) {
    return UncontrolledProviderScope(
      container: container,
      child: localizedTestApp(
        locale: locale,
        theme: Themes.dark,
        home: const Scaffold(
          body: Padding(padding: EdgeInsets.all(16), child: ThoughtsEditor()),
        ),
      ),
    );
  }

  testWidgets('unfilled state is bordered and uses the Figma copy', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(buildSubject(container));

    expect(find.text('Write down your thoughts & feelings.'), findsOneWidget);
    expect(find.text('Enter your text here...'), findsOneWidget);

    final card = tester.widget<Container>(
      find
          .ancestor(
            of: find.text('Enter your text here...'),
            matching: find.byType(Container),
          )
          .first,
    );
    final decoration = card.decoration as BoxDecoration;
    expect(decoration.color, Colors.transparent);
    expect(decoration.border, isNotNull);
  });

  testWidgets('renders Taiwan Traditional Chinese thoughts copy', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      buildSubject(
        container,
        locale: const Locale.fromSubtags(
          languageCode: 'zh',
          scriptCode: 'Hant',
          countryCode: 'TW',
        ),
      ),
    );

    expect(find.text('寫下你的想法與感受。'), findsOneWidget);
    expect(find.text('在這裡輸入文字...'), findsOneWidget);
  });

  testWidgets('filled state uses the card surface without a border', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container
        .read(journalControllerProvider.notifier)
        .setThoughts('A memorable ending.');

    await tester.pumpWidget(buildSubject(container));

    final card = tester.widget<Container>(
      find
          .ancestor(
            of: find.text('A memorable ending.'),
            matching: find.byType(Container),
          )
          .first,
    );
    final decoration = card.decoration as BoxDecoration;
    expect(decoration.color, DarkSurfaces.card);
    expect(decoration.border, isNull);
  });
}
