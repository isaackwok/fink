import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_journal/l10n/supported_locales.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum LanguagePreference { system, english, traditionalChineseTaiwan }

extension LanguagePreferenceLocale on LanguagePreference {
  Locale? get explicitLocale => switch (this) {
    LanguagePreference.system => null,
    LanguagePreference.english => const Locale('en'),
    LanguagePreference.traditionalChineseTaiwan => appSupportedLocales.last,
  };
}

Locale resolveLanguagePreference(
  LanguagePreference preference,
  List<Locale> systemLocales,
) {
  return preference.explicitLocale ??
      basicLocaleListResolution(systemLocales, appSupportedLocales);
}

class LanguageSettings {
  const LanguageSettings({
    this.interfaceLanguage = LanguagePreference.system,
    this.aiReviewsLanguage = LanguagePreference.system,
  });

  final LanguagePreference interfaceLanguage;
  final LanguagePreference aiReviewsLanguage;

  LanguageSettings copyWith({
    LanguagePreference? interfaceLanguage,
    LanguagePreference? aiReviewsLanguage,
  }) {
    return LanguageSettings(
      interfaceLanguage: interfaceLanguage ?? this.interfaceLanguage,
      aiReviewsLanguage: aiReviewsLanguage ?? this.aiReviewsLanguage,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LanguageSettings &&
          interfaceLanguage == other.interfaceLanguage &&
          aiReviewsLanguage == other.aiReviewsLanguage;

  @override
  int get hashCode => Object.hash(interfaceLanguage, aiReviewsLanguage);
}

class LanguageSettingsNotifier extends Notifier<LanguageSettings> {
  static const _interfaceLanguageKey = 'interface_language';
  static const _aiReviewsLanguageKey = 'ai_reviews_language';

  int _revision = 0;

  @override
  LanguageSettings build() {
    unawaited(_restore());
    return const LanguageSettings();
  }

  void setInterfaceLanguage(LanguagePreference language) {
    _revision++;
    state = state.copyWith(interfaceLanguage: language);
    unawaited(_persist(_interfaceLanguageKey, language));
  }

  void setAiReviewsLanguage(LanguagePreference language) {
    _revision++;
    state = state.copyWith(aiReviewsLanguage: language);
    unawaited(_persist(_aiReviewsLanguageKey, language));
  }

  Future<void> _restore() async {
    final revision = _revision;
    try {
      final preferences = await SharedPreferences.getInstance();
      final restored = LanguageSettings(
        interfaceLanguage: _decode(
          preferences.getString(_interfaceLanguageKey),
        ),
        aiReviewsLanguage: _decode(
          preferences.getString(_aiReviewsLanguageKey),
        ),
      );
      if (ref.mounted && revision == _revision) {
        state = restored;
      }
    } catch (_) {
      // Keep the safe System Default values when local storage is unavailable.
    }
  }

  Future<void> _persist(String key, LanguagePreference language) async {
    try {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setString(key, language.name);
    } catch (_) {
      // The in-memory selection remains active for this launch.
    }
  }

  LanguagePreference _decode(String? value) {
    return switch (value) {
      'english' => LanguagePreference.english,
      'traditionalChineseTaiwan' => LanguagePreference.traditionalChineseTaiwan,
      _ => LanguagePreference.system,
    };
  }
}

final languageSettingsProvider =
    NotifierProvider<LanguageSettingsNotifier, LanguageSettings>(
      LanguageSettingsNotifier.new,
    );
