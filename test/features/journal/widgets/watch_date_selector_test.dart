import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_journal/features/journal/widgets/watch_date_selector.dart';
import 'package:movie_journal/themes.dart';

import '../../../helpers/localized_test_app.dart';

void main() {
  testWidgets('opens calendar with selected date and confirms a new day', (
    tester,
  ) async {
    DateTime? selected;
    await tester.pumpWidget(
      localizedTestApp(
        theme: Themes.dark,
        home: Scaffold(
          body: WatchDateSelector(
            date: DateTime(2025, 5, 27),
            onChanged: (value) => selected = value,
          ),
        ),
      ),
    );
    expect(find.text('May 27th 2025'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_drop_down), findsOneWidget);
    await tester.tap(find.byType(WatchDateSelector));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<DatePickerDialog>(find.byType(DatePickerDialog))
          .initialDate,
      DateTime(2025, 5, 27),
    );
    final theme = DatePickerTheme.of(
      tester.element(find.byType(DatePickerDialog)),
    );
    expect(theme.backgroundColor, DarkSurfaces.card);
    expect(theme.headerHeadlineStyle?.fontFamily, 'AvenirNext');
    expect(
      theme.dayBackgroundColor?.resolve({WidgetState.selected}),
      Themes.dark.colorScheme.primary,
    );
    expect(
      theme.dayForegroundColor?.resolve({WidgetState.selected}),
      Colors.black,
    );
    await tester.tap(find.text('15'));
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(selected, DateTime(2025, 5, 15));
  });

  testWidgets('cancel leaves the watch date unchanged', (tester) async {
    DateTime? selected;
    await tester.pumpWidget(
      localizedTestApp(
        theme: Themes.dark,
        home: Scaffold(
          body: WatchDateSelector(
            date: DateTime(2025, 5, 27),
            onChanged: (value) => selected = value,
          ),
        ),
      ),
    );
    await tester.tap(find.byType(WatchDateSelector));
    await tester.pumpAndSettle();
    await tester.tap(find.text('15'));
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(selected, isNull);
  });
}
