import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_journal/features/home/widgets/empty_placeholder.dart';

import '../../../helpers/localized_test_app.dart';
import '../../../helpers/widget_test_setup.dart';

void main() {
  setUpAll(setUpWidgetTests);
  tearDownAll(tearDownWidgetTests);

  testWidgets('renders Taiwan Traditional Chinese empty-state copy', (
    tester,
  ) async {
    await tester.pumpWidget(
      localizedTestApp(
        locale: const Locale.fromSubtags(
          languageCode: 'zh',
          scriptCode: 'Hant',
          countryCode: 'TW',
        ),
        home: const Scaffold(
          body: SizedBox(height: 700, child: EmptyPlaceholder()),
        ),
      ),
    );

    expect(find.text('你的電影日記從這裡開始'), findsOneWidget);
    expect(find.text('新增第一部電影，留下你的觀影回憶'), findsOneWidget);
    expect(find.text('新增日記'), findsOneWidget);
  });
}
