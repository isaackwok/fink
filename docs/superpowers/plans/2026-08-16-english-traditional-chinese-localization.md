# English and Traditional Chinese Localization Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Localize every app-owned user-facing Fink string into English and Taiwan Traditional Chinese, expose both languages through iOS per-app Settings, and preserve English emotion terminology and all current date formatting.

**Architecture:** Flutter `gen_l10n` generates a non-nullable `AppLocalizations` API from paired ARB files. `MaterialApp` follows the locale supplied by iOS without app-owned locale state, while native permission copy is supplied by localized `InfoPlist.strings` resources. Feature widgets read generated values from `BuildContext`; persisted/domain values remain locale-independent.

**Tech Stack:** Flutter 3.41+, Dart 3.7+, `flutter_localizations`, `intl`, ARB/ICU messages, Flutter widget tests, Xcode property-list resources.

**Spec:** `docs/superpowers/specs/2026-08-16-english-traditional-chinese-localization-design.md`

## Global Constraints

- Supported locales are exactly English `en` and Taiwan Traditional Chinese `zh-Hant-TW` (`zh_Hant_TW` in Flutter resource identifiers).
- English is the template locale and fallback.
- Do not add an in-app language selector, Riverpod locale provider, localization facade, or custom locale persistence.
- Translate all app-owned user-facing strings, including semantics and native photo-permission copy.
- Translate “Journal” consistently as `日記`.
- Keep all active and retired emotion names and every emotion group/page heading in English.
- Localize the UI surrounding emotion terms, including prompts, limits, buttons, sentence framing, punctuation, and conjunctions.
- Do not change any Jiffy locale, date/time format pattern, internal `yyyy-MM` grouping key, or rendered date/time output.
- Do not translate TMDB content, generated review content, persisted identifiers, analytics names, routes, paths, URLs, or opaque external error details.
- Preserve existing feature behavior, layout constants, navigation, and error handling except for localized presentation.

---

### Task 1: Bootstrap generated localization and test support

**Files:**
- Create: `l10n.yaml`
- Create: `lib/l10n/app_en.arb`
- Create: `lib/l10n/app_zh_Hant_TW.arb`
- Create: `test/helpers/localized_test_app.dart`
- Create: `test/l10n/app_localizations_test.dart`
- Create: `test/main_test.dart`
- Modify: `pubspec.yaml`
- Modify: `pubspec.lock`
- Modify: `lib/main.dart`

**Interfaces:**
- Produces: generated `AppLocalizations`, `AppLocalizations.localizationsDelegates`, and `AppLocalizations.supportedLocales`.
- Produces: `localizedTestApp({required Widget home, Locale locale = const Locale('en'), ThemeData? theme, List<NavigatorObserver> navigatorObservers = const []}) -> Widget` for feature tests.
- Produces initial keys: `appTitle`, `commonAdd`, `commonCancel`, `commonDelete`, `commonDone`, `commonEdit`, `commonErrorWithDetails`, `commonGoBack`, `commonOthers`, `commonRetry`, `commonSave`, `commonShare`.

- [ ] **Step 1: Add the approved configuration/generated-code bootstrap**

Add SDK dependencies and enable generation:

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  intl: any

flutter:
  generate: true
```

Create `l10n.yaml`:

```yaml
arb-dir: lib/l10n
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
nullable-getter: false
use-named-parameters: true
preferred-supported-locales:
  - en
```

Seed both ARB files with the initial keys above, `@@locale` values `en` and `zh_Hant_TW`, descriptions in the English template, and matching key sets.

- [ ] **Step 2: Generate the localization source**

Run:

```bash
flutter pub get
flutter gen-l10n
```

Expected: generation exits 0 and `AppLocalizations.supportedLocales` contains `Locale('en')` plus `Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant', countryCode: 'TW')`.

- [ ] **Step 3: Write localization contract and root integration tests**

`test/l10n/app_localizations_test.dart` must load the real delegate and assert hand-written expected values:

```dart
final english = await AppLocalizations.delegate.load(const Locale('en'));
final chinese = await AppLocalizations.delegate.load(
  const Locale.fromSubtags(
    languageCode: 'zh',
    scriptCode: 'Hant',
    countryCode: 'TW',
  ),
);

expect(english.commonSave, 'Save');
expect(chinese.commonSave, '儲存');
expect(AppLocalizations.supportedLocales, <Locale>[
  const Locale('en'),
  const Locale.fromSubtags(
    languageCode: 'zh',
    scriptCode: 'Hant',
    countryCode: 'TW',
  ),
]);
```

Parse both ARB files with `jsonDecode` and compare literal user-message key sets after excluding keys beginning with `@`. In `test/main_test.dart`, pump `MyApp` under provider overrides and assert a descendant `Builder` resolves `zh-Hant-TW` when the test platform requests it.

- [ ] **Step 4: Run the root integration test and verify RED**

Run:

```bash
flutter test test/main_test.dart
```

Expected: FAIL because `MyApp` does not yet install the generated localization delegates and supported locales.

- [ ] **Step 5: Wire production and test MaterialApps**

Configure production:

```dart
return MaterialApp(
  onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  themeMode: ThemeMode.dark,
  darkTheme: Themes.dark,
  theme: Themes.light,
  home: const HomeScreen(),
);
```

Implement `localizedTestApp` with the same delegates/supported locales and the explicit test locale.

- [ ] **Step 6: Verify GREEN**

Run:

```bash
flutter test test/l10n/app_localizations_test.dart test/main_test.dart
```

Expected: PASS.

- [ ] **Step 7: Commit the bootstrap**

```bash
git add l10n.yaml pubspec.yaml pubspec.lock lib/l10n lib/main.dart test/helpers/localized_test_app.dart test/l10n/app_localizations_test.dart test/main_test.dart
git commit -m "feat: add Flutter localization foundation"
```

### Task 2: Localize shared, authentication, account, onboarding, and settings UI

**Files:**
- Modify: `lib/shared_widgets/action_text_button.dart`
- Modify: `lib/shared_widgets/confirmation_dialog.dart`
- Modify: `lib/shared_widgets/provider_sign_in_button.dart`
- Modify: `lib/shared_widgets/sheet_app_bar.dart`
- Modify: `lib/features/login/screens/login.dart`
- Modify: `lib/features/login/screens/create_user.dart`
- Modify: `lib/features/account_link/widgets/secure_account_banner.dart`
- Modify: `lib/features/account_link/widgets/secure_account_sheet.dart`
- Modify: `lib/features/onboarding/screens/branding_splash.dart`
- Modify: `lib/features/settings/screens/settings.dart`
- Modify: `lib/l10n/app_en.arb`
- Modify: `lib/l10n/app_zh_Hant_TW.arb`
- Create: `test/features/settings/screens/settings_test.dart`
- Modify affected tests under `test/features/login`, `test/features/account_link`, `test/features/onboarding`, and `test/features/settings`

**Interfaces:**
- Consumes: `AppLocalizations.of(context)` and `localizedTestApp` from Task 1.
- Produces: `common*`, `login*`, `createUser*`, `accountLink*`, `onboarding*`, and `settings*` message groups, with typed `{error}`, `{journalCount}`, and `{username}` placeholders.

- [ ] **Step 1: Add failing Traditional Chinese widget expectations**

Add tests that pump real screens/widgets with `zh-Hant-TW` and assert observable Chinese copy, including:

```dart
expect(find.text('使用 Google 登入'), findsOneWidget);
expect(find.text('設定'), findsOneWidget);
expect(find.text('保護帳號'), findsOneWidget);
```

Keep existing English assertions intact. The mutation each test catches is a widget continuing to use its former English literal under a Chinese locale.

- [ ] **Step 2: Verify RED**

Run the affected test directories. Expected: Chinese expectations fail while the old English text is found.

- [ ] **Step 3: Add ARB messages and replace literals**

Add complete English/Chinese message pairs for sign-in, username creation, account-link prompts/conflicts, splash accessibility copy, Settings items/dialogs, logout/delete warnings, and their toasts. Replace each app-owned literal with `AppLocalizations.of(context)` while leaving provider/brand names unchanged.

For functions that currently receive only strings, pass localized values from the nearest `BuildContext`; do not introduce global localized state. Rebuild generated source with `flutter gen-l10n`.

- [ ] **Step 4: Verify GREEN**

Run:

```bash
flutter test test/features/login test/features/account_link test/features/onboarding test/features/settings
```

Expected: PASS with both existing English and new Chinese expectations.

- [ ] **Step 5: Commit the account/settings slice**

```bash
git add lib/shared_widgets lib/features/login lib/features/account_link lib/features/onboarding lib/features/settings lib/l10n test/features/login test/features/account_link test/features/onboarding test/features/settings
git commit -m "feat: localize account and settings flows"
```

### Task 3: Localize home, search, and movie-selection UI

**Files:**
- Modify: `lib/features/home/screens/home.dart`
- Modify: `lib/features/home/widgets/add_movie_button.dart`
- Modify: `lib/features/home/widgets/empty_placeholder.dart`
- Modify: `lib/features/home/widgets/journal_card.dart`
- Modify: `lib/features/home/widgets/journals_list.dart`
- Modify: `lib/features/search_movie/screens/search_movie.dart`
- Modify: `lib/features/search_movie/widgets/movie_search_bar.dart`
- Modify: `lib/features/search_movie/widgets/movie_result_list.dart`
- Modify: `lib/features/journal/screens/movie_preview.dart`
- Modify: `lib/features/movie/data/models/brief_movie.dart` only if an app-owned fallback string is presented to users
- Modify: `lib/features/movie/data/models/detailed_movie.dart` only if an app-owned fallback string is presented to users
- Modify: both ARB files and affected home/search/movie tests
- Create: `test/features/home/widgets/add_movie_button_test.dart`
- Create: `test/features/home/widgets/empty_placeholder_test.dart`
- Create: `test/features/journal/screens/movie_preview_test.dart`

**Interfaces:**
- Produces: `home*`, `journalCard*`, `search*`, and `moviePreview*` messages with typed `{error}`, `{username}`, and count placeholders.
- Preserves: all current Jiffy calls and patterns in journal cards and month headings.

- [ ] **Step 1: Write failing Chinese home/search tests**

Add explicit-locale tests for the empty home action, journal-card menu, search title/hint/retry behavior, and movie-preview actions. Hand-written expectations include `新增日記`, `搜尋電影`, `重試`, and `開始寫日記`.

- [ ] **Step 2: Verify RED**

Run:

```bash
flutter test test/features/home test/features/search_movie test/features/journal/screens/movie_preview_test.dart
```

Expected: FAIL on the new Chinese expectations.

- [ ] **Step 3: Add paired ARB messages and migrate widgets**

Use generated getters for every app-owned label, prompt, empty/error state, context-menu action, semantic label, and navigation title in this slice. Preserve TMDB-provided titles, overview text, genres, and image content verbatim.

Do not replace or reformat:

```dart
journal.updatedAt.format(pattern: 'MMM. do yyyy')
Jiffy.parse(group.key).format(pattern: 'MMM yyyy')
```

- [ ] **Step 4: Verify GREEN**

Run the same home/search/movie test command and expect PASS.

- [ ] **Step 5: Commit the discovery slice**

```bash
git add lib/features/home lib/features/search_movie lib/features/journal/screens/movie_preview.dart lib/features/movie/data/models lib/l10n test/features/home test/features/search_movie test/features/journal/screens
git commit -m "feat: localize home and movie discovery"
```

### Task 4: Localize journal creation, editing, viewing, and emotion framing

**Files:**
- Modify: `lib/features/journal/screens/caption_editor.dart`
- Modify: `lib/features/journal/screens/journal_complete.dart`
- Modify: `lib/features/journal/screens/journal_content.dart`
- Modify: `lib/features/journal/screens/journaling.dart`
- Modify: `lib/features/journal/screens/thoughts.dart`
- Modify: `lib/features/journal/widgets/ai_references_accordion.dart`
- Modify: `lib/features/journal/widgets/emotions_selector_bottom_sheet.dart`
- Modify: `lib/features/journal/widgets/emotions_selector_button.dart`
- Modify: `lib/features/journal/widgets/journal_actions.dart`
- Modify: `lib/features/journal/widgets/journal_content_more_menu.dart`
- Modify: `lib/features/journal/widgets/rating_selector.dart`
- Modify: `lib/features/journal/widgets/review_item.dart`
- Modify: `lib/features/journal/widgets/reviews_bottom_sheet.dart`
- Modify: `lib/features/journal/widgets/reviews_floating_button.dart`
- Modify: `lib/features/journal/widgets/scene_card.dart`
- Modify: `lib/features/journal/widgets/scenes_select_sheet.dart`
- Modify: `lib/features/journal/widgets/scenes_selector.dart`
- Modify: `lib/features/journal/widgets/thoughts_editor.dart`
- Modify: both ARB files and affected journal tests

**Interfaces:**
- Produces: `journal*`, `thoughts*`, `scenes*`, `reviews*`, `rating*`, and emotion-framing messages.
- Preserves: `emotionList`, `retiredEmotionList`, emotion ids/names/groups/energy values, and the English page/section headings in `emotionPages`.
- Produces localized rich-text fragments `emotionSelectionPrefix`, `emotionSelectionSuffix`, `emotionListSeparator`, and `emotionListFinalSeparator` so names retain their existing `TextSpan` styling.

- [ ] **Step 1: Write failing Chinese journal and emotion tests**

Add tests for Chinese journal actions and editor labels. Extend emotion tests to assert all of the following in one Chinese-locale rendering:

```dart
expect(find.text('你對這部電影有什麼感受？'), findsOneWidget);
expect(find.text('High Energy'), findsOneWidget);
expect(find.text('Uplifting'), findsOneWidget);
expect(find.text('Joyful'), findsOneWidget);
```

Add a selected-emotion rich-text assertion verifying the Chinese sentence framing still contains the English name `joyful`. Existing English typography assertions remain unchanged.

- [ ] **Step 2: Verify RED**

Run:

```bash
flutter test test/features/journal
```

Expected: FAIL because journal and surrounding emotion copy is still English.

- [ ] **Step 3: Migrate journal copy and preserve emotion terms**

Add matching English/Chinese ARB messages for editor/viewer titles, prompts, captions, scene selection, AI-review disclosure/actions, deletion/discard dialogs, completion actions, errors/toasts, and rating semantics.

In `EmotionsSelectorButton`, replace only sentence framing and separators:

```dart
final l10n = AppLocalizations.of(context);
final separators = <String>[
  for (var index = 1; index < names.length; index++)
    index == names.length - 1
        ? l10n.emotionListFinalSeparator
        : l10n.emotionListSeparator,
];
```

Keep each `Emotion.name`, `emotionPages[*]['title']`, and section `label` untouched and English. Re-run `flutter gen-l10n`.

- [ ] **Step 4: Verify GREEN and unchanged dates**

Run all journal tests. Confirm existing assertions for `MMM do yyyy`, `MMM. do yyyy`, `MMM dd`, and `HH:mm` remain unchanged and pass.

- [ ] **Step 5: Commit the journal slice**

```bash
git add lib/features/journal lib/l10n test/features/journal
git commit -m "feat: localize journal flows"
```

### Task 5: Localize share-ticket UI and destination feedback

**Files:**
- Modify: `lib/features/share/screens/share_ticket_screen.dart`
- Modify: `lib/features/share/screens/ticket_poster_picker_screen.dart`
- Modify: `lib/features/share/share_targets.dart`
- Modify: `lib/features/share/widgets/share_options_sheet.dart`
- Modify: `lib/features/share/widgets/ticket_back.dart`
- Modify: `lib/features/share/widgets/ticket_front.dart` if it presents app-owned copy
- Modify: both ARB files and affected share tests
- Create: `test/features/share/widgets/share_options_sheet_test.dart`
- Create: `test/features/share/screens/ticket_poster_picker_screen_test.dart`

**Interfaces:**
- Produces: `share*` and `ticket*` messages for actions, copy-to-clipboard feedback, gallery permissions/errors, poster selection, and destination labels.
- Preserves: Instagram and Threads brand names, external movie content, and all ticket date/time Jiffy patterns.

- [ ] **Step 1: Write failing Chinese share tests**

Add explicit Chinese-locale assertions for the share button/sheet, `限時動態`, `其他`, clipboard success, save-image success/failure, and poster-picker instructions.

- [ ] **Step 2: Verify RED**

Run:

```bash
flutter test test/features/share
```

Expected: FAIL on the new Chinese expectations.

- [ ] **Step 3: Add paired share messages and migrate widgets**

Replace app-owned share labels and feedback with generated getters. When a helper already receives `BuildContext`, resolve localization there; otherwise pass the translated string or `BuildContext` from its UI caller without adding global state.

Leave these formats exactly unchanged:

```dart
createdAt.format(pattern: 'MMM dd')
createdAt.format(pattern: 'HH:mm')
```

- [ ] **Step 4: Verify GREEN**

Run all share tests and expect PASS.

- [ ] **Step 5: Commit the share slice**

```bash
git add lib/features/share lib/l10n test/features/share
git commit -m "feat: localize share ticket flow"
```

### Task 6: Package iOS language and native permission resources

**Files:**
- Create: `ios/Runner/en.lproj/InfoPlist.strings`
- Create: `ios/Runner/zh-Hant-TW.lproj/InfoPlist.strings`
- Modify: `ios/Runner/Info.plist`
- Modify: `ios/Runner.xcodeproj/project.pbxproj`

**Interfaces:**
- Produces: iOS bundle localizations `en` and `zh-Hant-TW`.
- Produces localized values for `CFBundleDisplayName`, `NSPhotoLibraryAddUsageDescription`, and `NSPhotoLibraryUsageDescription`.

- [ ] **Step 1: Add the approved native configuration resources**

Create English values:

```text
"CFBundleDisplayName" = "Fink";
"NSPhotoLibraryAddUsageDescription" = "We need access to save your movie ticket to your photo library.";
"NSPhotoLibraryUsageDescription" = "We need access to your photo library to share your movie ticket.";
```

Create Taiwan Traditional Chinese values:

```text
"CFBundleDisplayName" = "Fink";
"NSPhotoLibraryAddUsageDescription" = "我們需要相簿權限，才能儲存你的電影票根。";
"NSPhotoLibraryUsageDescription" = "我們需要相簿權限，才能分享你的電影票根。";
```

Add `en` and `zh-Hant-TW` to `CFBundleLocalizations`, add `zh-Hant-TW` to Xcode `knownRegions`, register both `InfoPlist.strings` children in one variant group, and include that group in the Runner Resources build phase.

- [ ] **Step 2: Validate property-list syntax and packaged resources**

Run:

```bash
plutil -lint ios/Runner/Info.plist
plutil -lint ios/Runner/en.lproj/InfoPlist.strings
plutil -lint ios/Runner/zh-Hant-TW.lproj/InfoPlist.strings
flutter build ios --simulator
```

Expected: every `plutil` check and the simulator build exit 0; the built `Runner.app` contains both localized `InfoPlist.strings` resources.

- [ ] **Step 3: Commit iOS integration**

```bash
git add ios/Runner ios/Runner.xcodeproj/project.pbxproj
git commit -m "feat: expose app languages in iOS settings"
```

### Task 7: Complete resource audit and full verification

**Files:**
- Modify: any localization call site, ARB resource, or test found incomplete by the audit
- Modify: `docs/superpowers/plans/2026-08-16-english-traditional-chinese-localization.md` only to check completed steps

**Interfaces:**
- Consumes all prior task outputs.
- Produces a complete two-locale app with documented emotion/date/external-content exclusions only.

- [ ] **Step 1: Audit all app-owned user-facing literals**

Search UI construction, dialogs, sheets, input decorations, semantics, and toast calls:

```bash
rg -n --glob '*.dart' "(Text|SelectableText|TextSpan)\\(\\s*['\\\"]|title:\\s*['\\\"]|label:\\s*['\\\"]|hintText:\\s*['\\\"]|helperText:\\s*['\\\"]|tooltip:\\s*['\\\"]|semanticsLabel:\\s*['\\\"]|CustomToast\\." lib
```

For every match, classify it as generated localized copy or one of the exact spec exclusions. Add missing ARB messages and tests before changing any missed production call site.

- [ ] **Step 2: Verify ARB parity and generation**

Run:

```bash
flutter gen-l10n
flutter test test/l10n/app_localizations_test.dart
git diff --check
```

Expected: generation and resource-parity tests pass with no whitespace errors.

- [ ] **Step 3: Run fresh complete verification**

Run:

```bash
flutter analyze
flutter test
plutil -lint ios/Runner/Info.plist
plutil -lint ios/Runner/en.lproj/InfoPlist.strings
plutil -lint ios/Runner/zh-Hant-TW.lproj/InfoPlist.strings
flutter build ios --simulator
```

Expected: every command exits 0 with no analysis errors, test failures, plist errors, or build failure.

- [ ] **Step 4: Review requirements line by line**

Confirm from fresh evidence that both locales are packaged, Chinese UI copy loads, emotion names/headings remain English, existing dates remain unchanged, and only the explicit spec exclusions remain unlocalized.

- [ ] **Step 5: Commit final audit fixes**

```bash
git add lib test ios l10n.yaml pubspec.yaml pubspec.lock docs/superpowers/plans/2026-08-16-english-traditional-chinese-localization.md
git commit -m "test: verify complete app localization"
```
