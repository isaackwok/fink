import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_journal/features/auth/auth_providers.dart';
import 'package:movie_journal/features/settings/screens/settings.dart';

import '../../../helpers/localized_test_app.dart';
import '../../../helpers/widget_test_setup.dart';

void main() {
  setUpAll(setUpWidgetTests);
  tearDownAll(tearDownWidgetTests);

  testWidgets('renders Taiwan Traditional Chinese settings actions', (
    tester,
  ) async {
    const locale = Locale.fromSubtags(
      languageCode: 'zh',
      scriptCode: 'Hant',
      countryCode: 'TW',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStateProvider.overrideWith((ref) => Stream.value(null)),
          currentUsernameProvider.overrideWith((ref) async => 'Isaac'),
        ],
        child: localizedTestApp(locale: locale, home: const SettingsScreen()),
      ),
    );
    await tester.pump();

    expect(find.text('設定'), findsOneWidget);
    expect(find.text('語言'), findsOneWidget);
    expect(find.text('介面'), findsOneWidget);
    expect(find.text('AI 評論'), findsOneWidget);
    expect(find.text('依系統設定'), findsNWidgets(2));
    expect(find.text('登出'), findsOneWidget);
    expect(find.text('刪除帳號'), findsOneWidget);
  });

  testWidgets('selects Interface and AI Review languages independently', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStateProvider.overrideWith((ref) => Stream.value(null)),
          currentUsernameProvider.overrideWith((ref) async => 'Isaac'),
        ],
        child: localizedTestApp(home: const SettingsScreen()),
      ),
    );
    await tester.pump();

    expect(find.text('System Default'), findsNWidgets(2));

    await tester.tap(find.text('Interface'));
    await tester.pumpAndSettle();

    expect(find.text('System Default'), findsNWidgets(3));
    expect(find.text('English'), findsOneWidget);
    expect(find.text('繁體中文 (台灣)'), findsOneWidget);

    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();

    expect(find.text('English'), findsOneWidget);
    expect(find.text('System Default'), findsOneWidget);

    await tester.tap(find.text('AI Reviews'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('繁體中文 (台灣)'));
    await tester.pumpAndSettle();

    expect(find.text('English'), findsOneWidget);
    expect(find.text('繁體中文 (台灣)'), findsOneWidget);
    expect(find.text('System Default'), findsNothing);
  });
}
