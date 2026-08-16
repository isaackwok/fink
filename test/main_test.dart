import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_journal/features/auth/auth_providers.dart';
import 'package:movie_journal/features/onboarding/controllers/splash_posters.dart';
import 'package:movie_journal/features/onboarding/screens/branding_splash.dart';
import 'package:movie_journal/l10n/supported_locales.dart';
import 'package:movie_journal/main.dart';

import 'helpers/widget_test_setup.dart';

void main() {
  setUpAll(setUpWidgetTests);
  tearDownAll(tearDownWidgetTests);

  testWidgets('MyApp resolves the iOS Taiwan Traditional Chinese locale', (
    tester,
  ) async {
    const locale = Locale.fromSubtags(
      languageCode: 'zh',
      scriptCode: 'Hant',
      countryCode: 'TW',
    );
    tester.binding.platformDispatcher.localesTestValue = const [locale];
    addTearDown(tester.binding.platformDispatcher.clearLocalesTestValue);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStateProvider.overrideWith((ref) => Stream.value(null)),
          anonymousBridgeProvider.overrideWith((ref) async => false),
          splashPostersProvider.overrideWith((ref) async => const <String>[]),
        ],
        child: const MyApp(),
      ),
    );
    await tester.pump();
    await tester.pump();

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.supportedLocales, appSupportedLocales);

    final splashContext = tester.element(find.byType(BrandingSplashScreen));
    expect(Localizations.localeOf(splashContext), locale);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
