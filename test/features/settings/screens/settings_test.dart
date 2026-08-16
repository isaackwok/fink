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
    expect(find.text('登出'), findsOneWidget);
    expect(find.text('刪除帳號'), findsOneWidget);
  });
}
