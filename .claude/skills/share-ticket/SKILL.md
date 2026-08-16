---
name: share-ticket
description: This skill should be used when working on the share ticket feature — anything under lib/features/share/, the share flow's close/route-tagging rules, ShareTicketScreen, TicketPosterPickerScreen, FlippableTicket, ticket capture/save, Instagram Story or Threads sharing, or the platform config (Info.plist / AndroidManifest) those destinations require.
---

# Working with Share Ticket

Feature lives under `lib/features/share/`. Flow: callers → `TicketPosterPickerScreen` → `ShareTicketScreen`.

- **`ShareTicketEntry` enum** (`journalContent` / `journalComplete`): identifies which screen opened the flow so the close button can route back correctly. Both `TicketPosterPickerScreen` and `ShareTicketScreen` close via the shared `closeShareFlow(context, entry)` helper. The enum, `kShareFlowRouteName`, and `closeShareFlow` all live in `lib/features/share/share_flow.dart`:
  - `journalComplete` (just-saved journal) → `popUntil(isFirst)` → back to Home (skipping the celebration screen).
  - `journalContent` (sharing existing journal) → `popUntil((r) => r.settings.name != kShareFlowRouteName)` → back to JournalContent.
- **`kShareFlowRouteName` route tagging**: every push into the share flow sets `MaterialPageRoute(settings: const RouteSettings(name: kShareFlowRouteName), …)`. The `journalContent` close path uses this to pop until it leaves the flow — robust if intermediate screens are added/removed. **If you add a new screen inside the share flow, tag its route or close-back will overshoot.** Currently tagged at: `journal_complete.dart`, `journal_content.dart`, `journal_actions.dart`, and the in-flow push in `ticket_poster_picker_screen.dart`.
- **`TicketPosterPickerScreen`** has no Next button and no default-selected poster; tapping a poster pushes `ShareTicketScreen` immediately with that poster path. The AppBar carries only a close (X) action that calls `closeShareFlow`.
- **`JournalCompleteScreen`** has its own close (X) in the top-right (a `Stack` overlay, not an AppBar, so the centered animation layout is not shifted). It does *not* call `closeShareFlow` — this screen isn't part of the share flow — but it pops to the same destination as the `journalComplete` close (`Navigator.popUntil((r) => r.isFirst)` → Home), since this screen only ever appears for a just-saved journal.
- **Ticket number**: `ticketNumberProvider(journalId)` (in `share/controllers/ticket_number.dart`) = journal's chronological 1-based position (sort by `createdAt` asc, index + 1; 0 while loading or if the id is unknown). A `.family` provider so the sort is memoized per journals change instead of re-running on every `ShareTicketScreen` rebuild.
- **Poster picker language tabs**: after the movie detail loads, `_applyLanguageTabFilter()` drops any fixed-language tab whose base code matches the movie's `originalLanguage` to avoid duplicates (e.g. an English movie hides the "English" tab). 繁體中文 uses `zh-TW`.
- **FlippableTicket peek animation**: `hintOnMount: true` triggers a 500ms-delayed peek (0 → 0.30 → 0) on mount. **Must use `animateBack(0.0)` for the return, not `animateTo(0.0)`** — `animateTo` leaves controller status as `completed`, which breaks `_flip()`'s `isCompleted` check. See the `flutter-animation-testing` skill for related pitfalls.
- **Image capture**: `ticket_capture.dart`'s `captureTicketAsBytes(repaintKey, pixelRatio:)` → PNG `Uint8List` from `RepaintBoundary`; `captureTicketToFile(...)` writes it to a temp file. All save/share paths route through these two helpers; read `devicePixelRatio` from context *before* any async gap and pass it in.
- **"Copy Text" tap target**: the copy-thoughts-to-clipboard control is a `GestureDetector` with `behavior: HitTestBehavior.opaque` (so the whole row width is tappable, not just the centered icon+text glyphs — the default `deferToChild` ignores the empty space) wrapping a `Padding(vertical: 8)` to enlarge the vertical hit area to match the visible button.
- **Share destinations**: `share_targets.dart` — Instagram Story via `appinio_social_share` (requires the Facebook App ID const kept there), Threads via `url_launcher` to `threads.net/intent/post`, native share via `SharePlus`.
- **Platform config (don't forget)**:
  - iOS `Info.plist`: `LSApplicationQueriesSchemes` for `instagram-stories` + `threads`, Facebook App ID in `CFBundleURLSchemes`, `NSPhotoLibraryAddUsageDescription` for gallery save, `UIApplicationSceneManifest` for Flutter scene lifecycle.
  - `AppDelegate.swift` uses `FlutterImplicitEngineDelegate` — register plugins in `didInitializeImplicitFlutterEngine`, **not** `application:didFinishLaunchingWithOptions`.
  - Android `AndroidManifest.xml`: `<queries>` for Instagram + Threads intents, `FileProvider` with `filepaths.xml`.

Related always-loaded rule (kept in AGENTS.md): `ShareTicketScreen` rasterises through a `RepaintBoundary` and must never build while a poster is still a placeholder — see "Working with TMDB imagery".
