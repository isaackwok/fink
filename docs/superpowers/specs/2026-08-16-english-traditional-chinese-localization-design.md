# English and Traditional Chinese Localization Design

## Goal

Add Flutter's first-party localization system to Fink, move all app-owned user-facing copy into generated localization resources, and support English plus Taiwan Traditional Chinese through the iOS per-app language setting.

This phase does not add an in-app language control. The operating system remains the sole locale owner until the Settings screen has an approved language-selector design.

## Supported Locales

- English: `en`
- Taiwan Traditional Chinese: `zh-Hant-TW`

Flutter resource identifiers use underscores, so the Traditional Chinese ARB resource is `app_zh_Hant_TW.arb`. The complete language, script, and country identifier is intentional: it distinguishes Taiwan Traditional Chinese from Simplified Chinese and other Traditional Chinese regional variants.

English is the template locale and the fallback for unsupported device languages.

## Localization Architecture

Fink will use Flutter's first-party localization stack:

- `flutter_localizations` from the Flutter SDK
- `intl`, resolved at the version compatible with the Flutter SDK
- Flutter's built-in `gen_l10n` source generator
- ARB resources under `lib/l10n`

The source resources are:

- `lib/l10n/app_en.arb`
- `lib/l10n/app_zh.arb` (generator-required base fallback; identical to the Taiwan Traditional Chinese copy)
- `lib/l10n/app_zh_Hant_TW.arb`

Flutter requires a base-language ARB whenever a script/country-specific ARB exists. The generated delegate therefore understands generic `zh` as a technical fallback, but Fink's production `MaterialApp` and iOS bundle expose only `en` and `zh-Hant-TW` to users.

`l10n.yaml` configures generation into the source tree. Generated getters are non-nullable, dynamic message arguments use named parameters, and English remains the preferred supported locale.

`MaterialApp` declares `AppLocalizations.localizationsDelegates` and a production locale list containing only `en` and `zh-Hant-TW`. It does not set `locale` or add a custom locale-resolution callback. Consequently, Flutter follows the locale supplied by iOS, including a per-app language override, and falls back through Flutter's standard supported-locale resolution.

No localization facade, Riverpod locale provider, or app-owned locale persistence is introduced in this phase. Widgets access the generated `AppLocalizations` API directly from `BuildContext`.

## iOS Integration

The Runner Xcode project declares `en` and `zh-Hant-TW` as supported localizations. The built app bundle includes both localizations so iOS can expose the per-app language choice in Settings.

Native iOS copy that Flutter cannot own is localized through `InfoPlist.strings` resources for both locales. This includes:

- `NSPhotoLibraryAddUsageDescription`
- `NSPhotoLibraryUsageDescription`

The English native copy preserves the current meaning. The Traditional Chinese copy uses natural Taiwan terminology. The app display name remains `Fink` in both locales.

Changing the language in iOS Settings relies on normal iOS lifecycle behavior. Fink does not implement custom relaunch, polling, or locale synchronization logic.

App Store Connect descriptions, keywords, screenshots, and other store metadata are outside this code change.

## Included User-Facing Copy

All app-owned user-facing Dart copy moves to ARB resources, including:

- screen, dialog, sheet, and section titles
- button, menu, and share-destination labels
- instructions, empty states, prompts, and explanatory body copy
- input hints and validation messages
- confirmation dialogs and destructive-action warnings
- success, warning, and error toasts
- retry and loading-error copy
- accessibility labels, tooltips, and semantics values
- dynamic messages containing values such as counts, limits, usernames, and error details

Dynamic values use typed ARB placeholders. Complete sentences live in ARB whenever styling does not require the sentence to be split into spans.

Brand and provider names such as Fink, Apple, Google, Instagram, and Threads remain unchanged inside otherwise localized messages.

## Traditional Chinese Copy Policy

Translations use natural Taiwan Traditional Chinese rather than literal word-for-word substitutions. The core product glossary includes:

- Journal: `日記`
- Add Journal: `新增日記`
- View Journal: `查看日記`
- Start Journaling: `開始寫日記`
- Thoughts: `想法`
- Scenes: `場景`
- Reviews: `評論`
- Share Ticket: `分享票根`
- Settings: `設定`
- Logout: `登出`
- Delete Account: `刪除帳號`
- Secure Account: `保護帳號`

ARB descriptions provide context for ambiguous or high-impact copy. English and Traditional Chinese ARB files contain identical message-key sets, excluding ARB metadata entries.

## Emotion Translation Exclusion

Emotion terminology deliberately remains English in both locales pending a separate team terminology review.

The exclusion covers:

- every active and retired `Emotion.name`
- emotion group and page headings, including `High Energy`, `Low Energy`, `Uplifting`, `Intense`, `Soothing`, `Quiet`, and `Perspectives`

The surrounding emotion experience is localized. In Traditional Chinese this includes the selector prompt, selection instructions and limits, action buttons, and the sentence surrounding selected emotion names. Selected emotion names remain individually styled English text. Chinese punctuation and connective copy surround those English names.

Emotion ids, group identifiers, and energy-level identifiers remain unchanged because they are persisted or used in domain logic.

## Explicit Exclusions

This phase does not localize or alter:

- displayed dates or times
- the existing Jiffy locale or any existing Jiffy format pattern
- internal month-grouping keys such as `yyyy-MM`
- the underlying content of TMDB movie metadata beyond selecting its requested translation
- the underlying AI review sources beyond selecting the generation language
- server, SDK, or operating-system error details embedded in an app-owned localized error wrapper
- analytics event and property names
- route names, database values, domain identifiers, asset paths, and URLs
- app-generated or third-party debug and log output that is not presented to the user

In particular, date output remains byte-for-byte governed by the current patterns in both languages. A Chinese UI can therefore continue showing English month abbreviations and ordinal forms during this phase.

## Backend Locale Behavior

`MaterialApp` exposes its resolved locale through `appLocaleProvider`. Both TMDB title-bearing requests and Quesgen review generation derive their backend language tag from that provider, mapping English to `en-US` and Taiwan Traditional Chinese to `zh-TW`.

TMDB applies the language to popular, search, and movie-detail requests. Poster image filtering keeps its explicit per-tab language behavior.

## Error and Fallback Behavior

- Unsupported locales resolve to English through Flutter's standard resolution and the preferred-locale ordering.
- Generated localization lookup is non-nullable beneath the configured `MaterialApp`.
- App-authored error prefixes and recovery actions are localized.
- Opaque exception or backend details may remain in their source language when the current UI already exposes them; this change does not expand or sanitize those details.
- Missing or mismatched ARB message keys are caught by automated resource-parity tests and generation verification.

## Test Strategy

The configuration and generated-code bootstrap is a narrowly approved TDD exception: ARB resources, `l10n.yaml`, Flutter dependencies, and Xcode localization metadata must exist before their integration tests can compile. Tests are added immediately after that bootstrap. Manually written widget behavior changes otherwise follow red-green-refactor.

Automated coverage includes:

- generated supported locales are exactly `en` and `zh-Hant-TW`, with English preferred
- English and Traditional Chinese ARB resources have matching user-message keys
- representative generated messages load in both locales, including typed placeholders
- the root app installs the generated delegates and resolves an explicit test locale
- representative English and Traditional Chinese widgets display the correct localized copy
- the Traditional Chinese emotion selector displays Chinese surrounding copy while keeping emotion names and all group/page headings in English
- existing date-rendering expectations remain unchanged
- existing feature and navigation behavior remains covered by the complete Flutter test suite

Test app wrappers that host localized widgets receive the same generated delegates and supported locales as production. A reusable test helper accepts an explicit locale so Chinese widget behavior can be tested without changing global platform state.

Static and build verification includes:

- `flutter gen-l10n`
- `flutter analyze`
- `flutter test`
- a final audit for app-owned user-facing literals remaining under `lib`, with documented exclusions for emotion terminology and non-user-facing constants
- `plutil` validation of property-list and strings resources
- an iOS simulator build that confirms the localized bundle resources package successfully

## Completion Criteria

The change is complete when:

1. iOS Settings offers English and Taiwan Traditional Chinese for Fink.
2. Selecting either language launches Fink with the corresponding Flutter and native permission copy.
3. All app-owned user-facing Dart strings are sourced from generated localization resources except the explicit exclusions.
4. Traditional Chinese emotion UI preserves every emotion name and group/page heading in English.
5. Existing date and time presentation is unchanged in both languages.
6. Localization generation, analysis, all tests, property-list validation, and the iOS simulator build pass.
