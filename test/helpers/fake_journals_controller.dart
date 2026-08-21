import 'package:movie_journal/features/journal/controllers/journal.dart';
import 'package:movie_journal/features/journal/controllers/journals.dart';

/// Serves a fixed journals list without touching Supabase.
///
/// The real `JournalsController.build()` reads `SupabaseAuthManager.currentUser`
/// (i.e. `Supabase.instance`), which throws under `flutter_test` — any widget
/// watching `journalsControllerProvider` needs this override:
///
/// ```dart
/// journalsControllerProvider.overrideWith(
///   () => FakeJournalsController([makeJournal()]),
/// )
/// ```
class FakeJournalsController extends JournalsController {
  FakeJournalsController(this.journals);

  final List<JournalState> journals;

  @override
  Future<JournalsState> build() async => JournalsState(journals: journals);
}
