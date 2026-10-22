import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_journal/features/journal/controllers/journal.dart';
import 'package:movie_journal/features/journal/widgets/thoughts_editor.dart';
import 'package:movie_journal/themes.dart';
import 'package:movie_journal/features/quesgen/review.dart';
import '../../../helpers/localized_test_app.dart';
import '../../../helpers/widget_test_setup.dart';

void main() {
  setUpAll(setUpWidgetTests);
  tearDownAll(tearDownWidgetTests);

  Widget subject(
    ProviderContainer container, {
    Locale locale = const Locale('en'),
  }) => UncontrolledProviderScope(
    container: container,
    child: localizedTestApp(
      locale: locale,
      theme: Themes.dark,
      home: const Scaffold(
        body: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: ThoughtsEditor(),
        ),
      ),
    ),
  );

  testWidgets('empty inline field defaults to ten lines with tools below', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await tester.pumpWidget(subject(container));
    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.minLines, 10);
    expect(field.decoration!.fillColor, Colors.transparent);
    expect(find.text('Movie Info'), findsOneWidget);
    expect(find.text('Reviews'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('Movie Info')).dy,
      greaterThan(tester.getBottomLeft(find.byType(TextField)).dy),
    );
  });

  testWidgets('typing updates journal immediately without opening a route', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await tester.pumpWidget(subject(container));
    await tester.enterText(find.byType(TextField), 'A memorable ending.');
    await tester.pump();
    expect(
      container.read(journalControllerProvider).thoughts,
      'A memorable ending.',
    );
    expect(find.byType(BottomSheet), findsNothing);
    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.decoration!.fillColor, DarkSurfaces.card);
    final selection = field.controller!.selection;
    container.read(journalControllerProvider.notifier).setRating(5);
    await tester.pump();
    expect(field.controller!.selection, selection);
  });

  testWidgets('existing thoughts load and external replacements synchronize', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container
        .read(journalControllerProvider.notifier)
        .setThoughts('Existing draft');
    await tester.pumpWidget(subject(container));
    expect(find.text('Existing draft'), findsOneWidget);
    container
        .read(journalControllerProvider.notifier)
        .setThoughts('Replacement');
    await tester.pump();
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      'Replacement',
    );
  });

  testWidgets('edit mode retains Movie Info and hides review generation', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container.read(journalModeProvider.notifier).set(JournalMode.edit);
    await tester.pumpWidget(subject(container));
    expect(find.text('Movie Info'), findsOneWidget);
    expect(find.text('Reviews'), findsNothing);
  });

  testWidgets('selected reviews stay visible and can be removed in edit mode', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final review = Review(text: 'An unforgettable film.', source: 'reddit');
    container.read(journalModeProvider.notifier).set(JournalMode.edit);
    container.read(journalControllerProvider.notifier).setSelectedReviews([
      review,
    ]);
    await tester.pumpWidget(subject(container));
    await tester.ensureVisible(find.text('You resonated with'));
    await tester.tap(find.text('You resonated with'));
    await tester.pump();
    expect(find.text(review.text), findsOneWidget);
    await tester.ensureVisible(find.byTooltip('Remove'));
    await tester.tap(find.byTooltip('Remove'));
    await tester.pump();
    expect(container.read(journalControllerProvider).selectedRefs, isEmpty);
    expect(find.text(review.text), findsNothing);
    expect(find.text('You resonated with'), findsNothing);
  });

  testWidgets('localized editor and movie info label', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await tester.pumpWidget(
      subject(
        container,
        locale: const Locale.fromSubtags(
          languageCode: 'zh',
          scriptCode: 'Hant',
          countryCode: 'TW',
        ),
      ),
    );
    expect(find.text('在這裡輸入文字...'), findsOneWidget);
    expect(find.text('電影資訊'), findsOneWidget);
  });

  for (final wrapped in [false, true]) {
    for (final atEnd in [true, false]) {
      testWidgets(
        '${wrapped ? 'wrapped' : 'multiline'} thoughts reveal the tapped ${atEnd ? 'last' : 'first'} line above the keyboard',
        (tester) async {
          tester.view.physicalSize = const Size(390, 844);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          addTearDown(tester.view.resetViewInsets);
          final container = ProviderContainer();
          addTearDown(container.dispose);
          final text =
              wrapped
                  ? List.filled(100, 'A memorable scene.').join(' ')
                  : List.generate(35, (i) => 'Thought line $i').join('\n');
          container.read(journalControllerProvider.notifier).setThoughts(text);
          await tester.pumpWidget(subject(container));
          final outerScroll =
              tester
                  .state<ScrollableState>(find.byType(Scrollable).first)
                  .position;
          if (atEnd) {
            outerScroll.jumpTo(outerScroll.maxScrollExtent);
            await tester.pump();
          }
          final editable = tester.state<EditableTextState>(
            find.byType(EditableText),
          );
          final offset = atEnd ? text.length : 0;
          final caret = editable.renderEditable.getLocalRectForCaret(
            TextPosition(offset: offset),
          );
          await tester.tapAt(
            editable.renderEditable.localToGlobal(caret.center),
          );
          await tester.pump();
          tester.view.viewInsets = const FakeViewPadding(bottom: 336);
          await tester.pump();
          await tester.pumpAndSettle();
          final selection = editable.widget.controller.selection;
          expect(
            selection.baseOffset,
            atEnd ? greaterThan(text.length - 20) : lessThan(20),
          );
          final visibleCaret = editable.renderEditable.getLocalRectForCaret(
            selection.extent,
          );
          final bottom =
              editable.renderEditable.localToGlobal(visibleCaret.bottomLeft).dy;
          expect(bottom, lessThan(508));
          expect(bottom, greaterThan(0));
          if (atEnd) expect(outerScroll.pixels, greaterThan(0));
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  testWidgets(
    'editor keeps ten lines and grows while typing with the keyboard open',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetViewInsets);
      final container = ProviderContainer();
      addTearDown(container.dispose);
      await tester.pumpWidget(subject(container));
      await tester.tap(find.byType(TextField));
      tester.view.viewInsets = const FakeViewPadding(bottom: 336);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      final fieldFinder = find.byType(TextField);
      final initialHeight = tester.getSize(fieldFinder).height;
      expect(tester.widget<TextField>(fieldFinder).minLines, 10);
      expect(tester.widget<TextField>(fieldFinder).maxLines, isNull);
      await tester.enterText(
        fieldFinder,
        List.filled(15, 'A line of thoughts.').join('\n'),
      );
      await tester.pump();
      expect(tester.getSize(fieldFinder).height, greaterThan(initialHeight));
      await tester.enterText(fieldFinder, 'Short again');
      await tester.pump();
      expect(tester.getSize(fieldFinder).height, initialHeight);
      expect(tester.takeException(), isNull);
    },
  );
}
