# Fink

A Flutter movie journal app for capturing how films make you feel. Search for movies, pick the emotions they evoked, select memorable scenes, write your thoughts, and save shareable movie tickets.

## Features

- **Movie Search** — Search TMDB's database. Results update as you type (300ms debounce), so there's no need to press a search button; clearing the field returns to popular picks. Opening a result shows the poster, director, release year, country, and synopsis. Pull down, or tap close, to dismiss it.
- **Rating** — Score a film from 1 to 10 hearts. Tap the same score again to clear it. An empty score is unrated, and Save stays off until the entry has a rating, an emotion, a scene, or some thoughts.
- **Emotion Journaling** — Choose up to 5 of 35 curated emotions across 5 groups (Uplifting, Intense, Soothing, Quiet, Perspectives).
- **Watch Date** — Record the day you watched the film. The calendar does not offer future dates.
- **Scene Selection** — Pick up to 10 memorable scenes from movie stills. The caption editor auto-focuses the input on entry and keeps the keyboard attached as you swipe between scenes, so you can caption multiple scenes in a single pass.
- **Thoughts** — Write reflections on the journaling screen itself, under the rating, emotions, and scenes. Movie Info and Reviews sit below the field.
- **AI-Curated Reviews** — Browse reviews from Letterboxd and Reddit to spark your own thoughts. The Reviews button appears only while you are creating a journal. Reviews you keep stay on the entry, always expanded under "You resonated with", including when you edit it later.
- **Movie Info** — From the journaling screen, open cast and crew: who played whom, and each crew member's job. That sheet is separate from the movie preview.
- **Saved Journal** — A saved entry shows the title, watch date, rating when you set one, emotions, swipeable scene stills with captions, your thoughts, and any reviews you kept. Share it, or use the menu to edit or delete it. The title fades into the header as you scroll. A journal opened from an emotion echo can still be edited, and hides share and delete.
- **Achievements & Emotion Echoes** — After you save, the celebration screen can show achievements for films that share a director, actor, era, country, or genre with this one, and up to two earlier journals that share its emotions.
- **Unsaved Changes** — The back button and a rightward swipe from the left edge both ask before leaving an entry you have changed. If nothing changed, you leave immediately.
- **Shareable Movie Tickets** — Generate flippable movie ticket images with high-res poster front and details back, peek hint animation on entry. Tap the ticket to flip, then use the bottom action row to save to gallery or open the share sheet. The sheet offers Instagram Stories, Threads, and Others (the system share sheet). When the journal has thoughts, it also shows them with a Copy Text action. The close (X) in the top-right is entry-aware: from the just-saved celebration screen it returns to home; when sharing an existing journal it returns to that journal's content page.
- **Poster Picker** — Choose ticket posters in multiple languages (Original, English, 繁體中文, 日本語). Tapping a poster moves you straight to the ticket preview — no Next button — and the close (X) follows the same entry-aware navigation as the ticket screen.
- **Language** — In Settings, choose the interface language and the language of AI reviews. Each can follow the system, English, or Traditional Chinese (Taiwan). The interface language also sets the language of movie information from TMDB; the AI-reviews language only affects generated reviews.
- **Account Management** — The login screen offers Apple and Google only. After signing in, pick a username during onboarding that appears on your home screen. Deleting your account performs a fresh re-authentication and then permanently removes all your journals and account data — no orphaned records left behind.
- **Secure Your Account** — Journals recovered from a pre-migration account arrive on a session with no sign-in attached to it, which a reinstall would lose. The app prompts once to attach an Apple or Google account, then keeps a banner on the home screen until it's done; your journals stay exactly where they are, since the identity attaches to the account you're already using. Settings keeps a **Secure Account** entry for later, and warns before logging out while the account is still unattached. Users who signed in normally never see any of this.
- **Branded Cold Start** — On a cold launch while signed out, a 3-second branded splash plays (logo, wordmark, and tagline fade in/hold/fade out, with a blurred poster marquee scrolling in opposite directions in the bottom-right corner) before handing off to the login screen. The splash is one-shot per session — signing out within an active session goes straight to login, with no replay.

## Getting Started

### Prerequisites

- Flutter 3.41+ (Dart SDK `^3.7.2`)
- A [TMDB API](https://www.themoviedb.org/documentation/api) key
- Supabase project (Postgres + Auth), with Apple and Google providers configured
- Firebase project — for Analytics
- Xcode (for iOS) / Android Studio (for Android)

### Setup

1. **Clone the repository**

   ```bash
   git clone <repo-url>
   cd movie_journal
   ```

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Configure environment variables**

   Create a `.env` file in the project root:

   ```
   TMDB_ACCESS_TOKEN=your_tmdb_v4_access_token
   SUPABASE_URL=https://<project-ref>.supabase.co
   SUPABASE_PUBLISHABLE_KEY=sb_publishable_...
   GOOGLE_IOS_CLIENT_ID=<ios-oauth-client>.apps.googleusercontent.com
   GOOGLE_WEB_CLIENT_ID=<web-oauth-client>.apps.googleusercontent.com
   ```

   The publishable key is meant to ship in the client — row-level security is the boundary that protects data, not the key. Never put the Supabase **secret** key here.

   The AI review service (quesgen) is preconfigured — its URL is hardcoded in `lib/core/network/quesgen_dio_client.dart` and it authenticates via the signed-in user's Supabase access token, so no additional env vars are required.

4. **Set up Supabase**

   ```bash
   supabase link --project-ref <project-ref>
   supabase db push          # applies supabase/migrations/
   supabase functions deploy delete-account
   supabase functions deploy claim-anonymous
   ```

   Both Google OAuth client IDs must also be listed as authorized Client IDs on the Supabase Google provider — Supabase validates the ID token's `aud` against that list.

5. **Set up Firebase** (Analytics)

   Follow the [FlutterFire setup guide](https://firebase.google.com/docs/flutter/setup) to generate `lib/firebase_options.dart` for your project.

6. **Run the app**

   ```bash
   flutter run
   ```

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter |
| State Management | Riverpod 3.x |
| Backend | Supabase — Auth (native Apple/Google) + Postgres with RLS + Edge Functions |
| Analytics | Firebase Analytics |
| Networking | Dio |
| Movie Data | TMDB API |
| Image Caching | `cached_network_image` — posters and backdrops are cached to disk, so they survive a cold start instead of re-downloading |
| AI Reviews | Custom review generation API |

## Development

```bash
flutter analyze    # Static analysis
flutter test       # Run the suite (603 tests)
flutter build apk  # Android build
flutter build ios   # iOS build
```
