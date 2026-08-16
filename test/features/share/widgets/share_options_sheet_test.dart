import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_journal/features/share/widgets/share_options_sheet.dart';

import '../../../helpers/localized_test_app.dart';

void main() {
  testWidgets('renders Taiwan Traditional Chinese share options', (
    tester,
  ) async {
    await tester.pumpWidget(
      localizedTestApp(
        locale: const Locale.fromSubtags(
          languageCode: 'zh',
          scriptCode: 'Hant',
          countryCode: 'TW',
        ),
        home: Scaffold(
          body: ShareOptionsSheet(
            thoughts: 'A thoughtful ending.',
            onInstagramStory: () {},
            onThreads: () {},
            onOthers: () {},
          ),
        ),
      ),
    );

    expect(find.text('複製文字並分享到社群'), findsOneWidget);
    expect(find.text('分享方式'), findsOneWidget);
    expect(find.text('限時動態'), findsOneWidget);
    expect(find.text('其他'), findsOneWidget);
    expect(find.text('複製文字'), findsOneWidget);
  });
}
