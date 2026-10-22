import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_journal/features/journal/widgets/movie_info_sheet.dart';
import 'package:movie_journal/features/movie/data/data_sources/movie_api.dart';
import 'package:movie_journal/features/movie/data/models/detailed_movie.dart';
import 'package:movie_journal/features/movie/data/repositories/movie_repository.dart';
import 'package:movie_journal/features/movie/movie_providers.dart';
import 'package:movie_journal/themes.dart';
import '../../../helpers/localized_test_app.dart';
import '../../../helpers/test_movie.dart';
import '../../../helpers/widget_test_setup.dart';

class _Repo extends MovieRepository {
  _Repo() : super(MovieAPI());
  bool fail = false;
  bool empty = false;
  final ids = <int>[];
  @override
  Future<DetailedMovie> getMovieDetails(int id) async {
    ids.add(id);
    if (fail) throw Exception('offline');
    return DetailedMovie.fromJson(
      makeDetailedMovieJson(
        id: id,
        credits:
            empty
                ? {'cast': [], 'crew': []}
                : {
                  'cast': [
                    makeCastJson(
                      name: 'Actor',
                      character: 'Character',
                      profilePath: null,
                    ),
                  ],
                  'crew': [
                    makeCrewJson(
                      name: 'Director',
                      job: 'Director',
                      profilePath: null,
                    ),
                  ],
                },
      ),
    );
  }
}

void main() {
  setUpAll(setUpWidgetTests);
  tearDownAll(tearDownWidgetTests);
  Widget subject(_Repo repo) => ProviderScope(
    overrides: [movieRepoProvider.overrideWithValue(repo)],
    child: localizedTestApp(
      theme: Themes.dark,
      home: const Scaffold(body: MovieInfoSheet(movieId: 550)),
    ),
  );

  testWidgets(
    'uses requested movie credits, switches cast and crew, omits awards',
    (tester) async {
      final repo = _Repo();
      await tester.pumpWidget(subject(repo));
      await tester.pumpAndSettle();
      expect(repo.ids, [550]);
      expect(find.text('Fight Club'), findsOneWidget);
      expect(find.text('Actor'), findsOneWidget);
      expect(find.text('Character'), findsOneWidget);
      expect(find.text('Awards'), findsNothing);
      await tester.tap(find.text('Crew'));
      await tester.pumpAndSettle();
      expect(find.text('Actor'), findsNothing);
      expect(find.text('Director'), findsNWidgets(2));
      expect(repo.ids, [550]);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('horizontal swipes switch tabs and keep chip selection in sync', (
    tester,
  ) async {
    final repo = _Repo();
    await tester.pumpWidget(subject(repo));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(PageView), const Offset(-600, 0));
    await tester.pumpAndSettle();
    expect(find.text('Director'), findsNWidgets(2));
    expect(
      tester
          .widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Crew'))
          .selected,
      isTrue,
    );
    await tester.drag(find.byType(PageView), const Offset(600, 0));
    await tester.pumpAndSettle();
    expect(find.text('Actor'), findsOneWidget);
    expect(
      tester
          .widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Cast'))
          .selected,
      isTrue,
    );
    await tester.tap(find.text('Crew'));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(PageView), const Offset(600, 0));
    await tester.pumpAndSettle();
    expect(find.text('Actor'), findsOneWidget);
    expect(repo.ids, [550]);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'only credits move horizontally while the header stays in place',
    (tester) async {
      await tester.pumpWidget(subject(_Repo()));
      await tester.pumpAndSettle();
      final titlePosition = tester.getTopLeft(find.text('Fight Club'));
      final tabsPosition = tester.getTopLeft(
        find.widgetWithText(ChoiceChip, 'Cast'),
      );
      final actorPosition = tester.getTopLeft(find.text('Actor'));
      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(PageView)),
      );
      await gesture.moveBy(const Offset(-30, 0));
      await tester.pump();
      await gesture.moveBy(const Offset(-170, 0));
      await tester.pump();
      expect(find.text('Fight Club'), findsOneWidget);
      expect(tester.getTopLeft(find.text('Fight Club')), titlePosition);
      expect(
        tester.getTopLeft(find.widgetWithText(ChoiceChip, 'Cast')),
        tabsPosition,
      );
      expect(
        tester.getTopLeft(find.text('Actor')).dx,
        lessThan(actorPosition.dx),
      );
      await gesture.up();
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('tab background and text fade with page progress', (
    tester,
  ) async {
    await tester.pumpWidget(subject(_Repo()));
    await tester.pumpAndSettle();
    ChoiceChip crew() =>
        tester.widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Crew'));
    final initialBackground = crew().color!.resolve({});
    expect(crew().labelStyle!.color, Colors.white);
    await tester.tap(find.text('Crew'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(crew().color!.resolve({}), isNot(initialBackground));
    expect(crew().color!.resolve({}), isNot(Colors.white.withAlpha(230)));
    expect(crew().labelStyle!.color, isNot(Colors.white));
    expect(crew().labelStyle!.color, isNot(Colors.black));
    await tester.pumpAndSettle();
    expect(crew().color!.resolve({}), Colors.white.withAlpha(230));
    expect(crew().labelStyle!.color, Colors.black);
    await tester.tap(find.text('Cast'));
    await tester.pumpAndSettle();
    expect(crew().color!.resolve({}), initialBackground);
    expect(crew().labelStyle!.color, Colors.white);
  });

  testWidgets('cancelled swipe restores the active tab colors and credits', (
    tester,
  ) async {
    await tester.pumpWidget(subject(_Repo()));
    await tester.pumpAndSettle();
    ChoiceChip crew() =>
        tester.widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Crew'));
    final initialColor = crew().color!.resolve({});
    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(PageView)),
    );
    await gesture.moveBy(const Offset(-30, 0));
    await tester.pump();
    await gesture.moveBy(const Offset(-80, 0));
    await tester.pump();
    expect(crew().color!.resolve({}), isNot(initialColor));
    await gesture.cancel();
    await tester.pumpAndSettle();
    expect(crew().selected, isFalse);
    expect(crew().color!.resolve({}), initialColor);
    expect(crew().labelStyle!.color, Colors.white);
    expect(find.text('Actor'), findsOneWidget);
    expect(find.text('Director'), findsNothing);
  });

  testWidgets('movie info opens as a dismissible sheet', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [movieRepoProvider.overrideWithValue(_Repo())],
        child: localizedTestApp(
          theme: Themes.dark,
          home: Builder(
            builder:
                (context) => Scaffold(
                  body: Center(
                    child: TextButton(
                      onPressed:
                          () => MovieInfoSheet.show(context, movieId: 550),
                      child: const Text('Movie Info'),
                    ),
                  ),
                ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Movie Info'));
    await tester.pumpAndSettle();
    expect(find.byType(BottomSheet), findsOneWidget);
    expect(find.text('Actor'), findsOneWidget);
    await tester.fling(find.byType(MovieInfoSheet), const Offset(0, 700), 1500);
    await tester.pumpAndSettle();
    expect(find.byType(MovieInfoSheet), findsNothing);
  });

  testWidgets('failed details can retry and empty credits render safely', (
    tester,
  ) async {
    final repo = _Repo()..fail = true;
    await tester.pumpWidget(subject(repo));
    await tester.pumpAndSettle();
    expect(find.text('Retry'), findsOneWidget);
    repo
      ..fail = false
      ..empty = true;
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(find.text('No credits available.'), findsOneWidget);
    expect(repo.ids, [550, 550]);
  });
}
