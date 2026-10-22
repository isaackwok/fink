import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_journal/features/journal/controllers/journal.dart';
import 'package:movie_journal/features/journal/widgets/scenes_selector.dart';
import 'package:movie_journal/features/journal/widgets/scenes_select_sheet.dart';
import 'package:movie_journal/features/movie/controllers/movie_images_controller.dart';
import 'package:movie_journal/features/movie/data/models/movie_image.dart';
import 'package:movie_journal/features/movie/movie_providers.dart';
import 'package:movie_journal/themes.dart';
import '../../../helpers/localized_test_app.dart';
import '../../../helpers/widget_test_setup.dart';

class _Images extends MovieImagesController {
  _Images(super.movieId);
  @override
  Future<MovieImagesState> build() async => MovieImagesState(
    posters: [],
    logos: [],
    backdrops: [
      MovieImage(
        aspectRatio: 1.5,
        height: 400,
        width: 600,
        filePath: '/scene.jpg',
        voteAverage: 0,
        voteCount: 0,
      ),
    ],
  );
}

void main() {
  setUpAll(setUpWidgetTests);
  tearDownAll(tearDownWidgetTests);
  testWidgets('scene padding scrolls with photos in a full-width viewport', (
    tester,
  ) async {
    final container = ProviderContainer(
      overrides: [
        movieImagesControllerProvider(550).overrideWith(() => _Images(550)),
      ],
    );
    addTearDown(container.dispose);
    for (var i = 0; i < 4; i++) {
      container
          .read(journalControllerProvider.notifier)
          .addScene('/scene$i.jpg');
    }
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: localizedTestApp(
          theme: Themes.dark,
          home: const Scaffold(body: ScenesSelector(movieId: 550)),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final list = find.byType(ListView);
    final firstCard = find.byType(SelectedSceneCard).first;
    expect(tester.getTopLeft(list).dx, 0);
    expect(
      tester.getSize(list).width,
      tester.getSize(find.byType(Scaffold)).width,
    );
    expect(tester.getTopLeft(firstCard).dx, 16);
    await tester.drag(list, const Offset(-100, 0));
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(firstCard).dx, lessThan(0));
    expect(tester.takeException(), isNull);
  });

  testWidgets('removing the last scene restores the inset empty picker', (
    tester,
  ) async {
    final container = ProviderContainer(
      overrides: [
        movieImagesControllerProvider(550).overrideWith(() => _Images(550)),
      ],
    );
    addTearDown(container.dispose);
    container.read(journalControllerProvider.notifier).addScene('/scene.jpg');
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: localizedTestApp(
          theme: Themes.dark,
          home: const Scaffold(body: ScenesSelector(movieId: 550)),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();
    expect(container.read(journalControllerProvider).selectedScenes, isEmpty);
    expect(find.byType(SelectedSceneCard), findsNothing);
    expect(find.byKey(const ValueKey('add-scene')), findsNothing);
    final picker = find.byType(InkWell);
    expect(tester.getTopLeft(picker).dx, 16);
    expect(
      tester.getTopRight(picker).dx,
      tester.getSize(find.byType(Scaffold)).width - 16,
    );
    await tester.tap(picker);
    await tester.pumpAndSettle();
    expect(find.byType(ScenesSelectSheet), findsOneWidget);
  });

  testWidgets('add tile follows scenes in the same row and opens picker', (
    tester,
  ) async {
    final container = ProviderContainer(
      overrides: [
        movieImagesControllerProvider(550).overrideWith(() => _Images(550)),
      ],
    );
    addTearDown(container.dispose);
    container.read(journalControllerProvider.notifier).addScene('/scene.jpg');
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: localizedTestApp(
          theme: Themes.dark,
          home: const Scaffold(body: ScenesSelector(movieId: 550)),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final card = find.byType(SelectedSceneCard);
    final add = find.byKey(const ValueKey('add-scene'));
    expect(tester.getTopLeft(add).dy, tester.getTopLeft(card).dy);
    expect(tester.getTopLeft(add).dx, greaterThan(tester.getTopRight(card).dx));
    await tester.tap(add);
    await tester.pumpAndSettle();
    expect(find.byType(ScenesSelectSheet), findsOneWidget);
  });
}
