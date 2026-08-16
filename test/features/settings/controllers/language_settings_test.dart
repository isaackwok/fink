import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_journal/features/settings/controllers/language_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('persists both language choices across app launches', () async {
    SharedPreferences.setMockInitialValues({});

    final firstLaunch = ProviderContainer();
    firstLaunch.read(languageSettingsProvider);
    firstLaunch
        .read(languageSettingsProvider.notifier)
        .setInterfaceLanguage(LanguagePreference.english);
    firstLaunch
        .read(languageSettingsProvider.notifier)
        .setAiReviewsLanguage(LanguagePreference.traditionalChineseTaiwan);
    await pumpEventQueue();
    firstLaunch.dispose();

    final secondLaunch = ProviderContainer();
    addTearDown(secondLaunch.dispose);
    secondLaunch.read(languageSettingsProvider);
    await pumpEventQueue();

    expect(
      secondLaunch.read(languageSettingsProvider),
      const LanguageSettings(
        interfaceLanguage: LanguagePreference.english,
        aiReviewsLanguage: LanguagePreference.traditionalChineseTaiwan,
      ),
    );
  });
}
