import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_journal/shared_widgets/pull_down_to_dismiss.dart';

void main() {
  // The widget reacts to scroll notifications, so every subject hosts a real
  // scrollable. BouncingScrollPhysics matches what MoviePreviewScreen uses
  // (negative pixels while overscrolled); a separate group covers the
  // clamping/OverscrollNotification path Android's default physics produces.
  Widget buildSubject({
    required VoidCallback onDismiss,
    ScrollPhysics physics = const AlwaysScrollableScrollPhysics(
      parent: BouncingScrollPhysics(),
    ),
    double contentHeight = 2000,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: PullDownToDismiss(
          onDismiss: onDismiss,
          child: SingleChildScrollView(
            physics: physics,
            child: SizedBox(height: contentHeight, width: double.infinity),
          ),
        ),
      ),
    );
  }

  group('bouncing physics (iOS-style overscroll)', () {
    testWidgets('pulling down past the threshold dismisses on release', (
      tester,
    ) async {
      var dismissCount = 0;
      await tester.pumpWidget(buildSubject(onDismiss: () => dismissCount++));

      // Drag down 400px at the top; bouncing physics applies drag resistance,
      // so the actual overscroll is roughly 150px — beyond the 120px
      // threshold with margin (300px would land right at the edge).
      await tester.timedDrag(
        find.byType(SingleChildScrollView),
        const Offset(0, 400),
        const Duration(milliseconds: 300),
      );
      await tester.pumpAndSettle();

      expect(dismissCount, 1);
    });

    testWidgets('a small pull does not dismiss', (tester) async {
      var dismissCount = 0;
      await tester.pumpWidget(buildSubject(onDismiss: () => dismissCount++));

      await tester.timedDrag(
        find.byType(SingleChildScrollView),
        const Offset(0, 40),
        const Duration(milliseconds: 200),
      );
      await tester.pumpAndSettle();

      expect(dismissCount, 0);
    });

    testWidgets('scrolling down through content never dismisses', (
      tester,
    ) async {
      var dismissCount = 0;
      await tester.pumpWidget(buildSubject(onDismiss: () => dismissCount++));

      // Scroll into the content, then back up to the top — normal browsing.
      await tester.timedDrag(
        find.byType(SingleChildScrollView),
        const Offset(0, -400),
        const Duration(milliseconds: 300),
      );
      await tester.pumpAndSettle();
      await tester.timedDrag(
        find.byType(SingleChildScrollView),
        const Offset(0, 400),
        const Duration(milliseconds: 300),
      );
      await tester.pumpAndSettle();

      expect(dismissCount, 0);
    });

    testWidgets('dismisses at most once for a single deep pull', (
      tester,
    ) async {
      var dismissCount = 0;
      await tester.pumpWidget(buildSubject(onDismiss: () => dismissCount++));

      await tester.timedDrag(
        find.byType(SingleChildScrollView),
        const Offset(0, 500),
        const Duration(milliseconds: 400),
      );
      // Let the bounce-back run fully: release + ballistic frames both cross
      // the notification handler, and only one dismiss may fire.
      await tester.pumpAndSettle();

      expect(dismissCount, 1);
    });

    testWidgets('a strong downward fling at the top dismisses', (
      tester,
    ) async {
      var dismissCount = 0;
      await tester.pumpWidget(buildSubject(onDismiss: () => dismissCount++));

      // 100px of travel is below the 120px distance threshold — this only
      // dismisses if the release velocity is recognized as a flick.
      await tester.fling(
        find.byType(SingleChildScrollView),
        const Offset(0, 100),
        2000,
      );
      await tester.pumpAndSettle();

      expect(dismissCount, 1);
    });
  });

  group('clamping physics (Android-style overscroll)', () {
    testWidgets('pulling down past the threshold dismisses on release', (
      tester,
    ) async {
      var dismissCount = 0;
      await tester.pumpWidget(
        buildSubject(
          onDismiss: () => dismissCount++,
          physics: const AlwaysScrollableScrollPhysics(
            parent: ClampingScrollPhysics(),
          ),
        ),
      );

      await tester.timedDrag(
        find.byType(SingleChildScrollView),
        const Offset(0, 200),
        const Duration(milliseconds: 300),
      );
      await tester.pumpAndSettle();

      expect(dismissCount, 1);
    });

    testWidgets('a small pull does not dismiss', (tester) async {
      var dismissCount = 0;
      await tester.pumpWidget(
        buildSubject(
          onDismiss: () => dismissCount++,
          physics: const AlwaysScrollableScrollPhysics(
            parent: ClampingScrollPhysics(),
          ),
        ),
      );

      await tester.timedDrag(
        find.byType(SingleChildScrollView),
        const Offset(0, 40),
        const Duration(milliseconds: 200),
      );
      await tester.pumpAndSettle();

      expect(dismissCount, 0);
    });
  });

  testWidgets('content shorter than the viewport can still dismiss', (
    tester,
  ) async {
    var dismissCount = 0;
    await tester.pumpWidget(
      buildSubject(onDismiss: () => dismissCount++, contentHeight: 100),
    );

    await tester.timedDrag(
      find.byType(SingleChildScrollView),
      const Offset(0, 400),
      const Duration(milliseconds: 300),
    );
    await tester.pumpAndSettle();

    expect(dismissCount, 1);
  });
}
