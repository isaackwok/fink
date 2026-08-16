import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_journal/features/login/screens/login.dart';
import 'package:movie_journal/shared_widgets/provider_sign_in_button.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show AuthResponse;

import '../../../helpers/localized_test_app.dart';
import '../../../helpers/widget_test_setup.dart';

/// Regression tests for ISA-9 bug 2: both sign-in handlers used to swallow
/// every exception (`catch (e) { // handle error }`), so a real failure looked
/// identical to a cancelled prompt — the screen just sat there.
void main() {
  setUpAll(() => setUpWidgetTests());
  tearDownAll(() => tearDownWidgetTests());

  const errorToast = 'Sign-in failed. Please try again.';

  Widget buildSubject({
    Future<AuthResponse?> Function()? googleSignIn,
    Future<AuthResponse?> Function()? appleSignIn,
    Locale locale = const Locale('en'),
  }) {
    Future<AuthResponse?> unexpected() async =>
        fail('unexpected provider flow invoked');
    return localizedTestApp(
      locale: locale,
      home: LoginScreen(
        googleSignIn: googleSignIn ?? unexpected,
        appleSignIn: appleSignIn ?? unexpected,
      ),
    );
  }

  testWidgets('renders Taiwan Traditional Chinese sign-in copy', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildSubject(
        locale: const Locale.fromSubtags(
          languageCode: 'zh',
          scriptCode: 'Hant',
          countryCode: 'TW',
        ),
      ),
    );

    expect(find.text('開始寫下你的電影日記。'), findsOneWidget);
    expect(find.text('使用 Google 登入'), findsOneWidget);
    expect(find.text('使用 Apple 登入'), findsOneWidget);
  });

  Future<void> drainToastTimers(WidgetTester tester) async {
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
  }

  testWidgets('a failing Google sign-in surfaces an error toast', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildSubject(googleSignIn: () async => throw Exception('network down')),
    );

    await tester.tap(find.text('Sign in with Google'));
    await tester.pump();
    await tester.pump();

    expect(find.text(errorToast), findsOneWidget);
    await drainToastTimers(tester);
  });

  testWidgets('a failing Apple sign-in surfaces an error toast', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildSubject(appleSignIn: () async => throw Exception('network down')),
    );

    await tester.tap(find.text('Sign in with Apple'));
    await tester.pump();
    await tester.pump();

    expect(find.text(errorToast), findsOneWidget);
    await drainToastTimers(tester);
  });

  testWidgets('a cancelled prompt (null) stays silent and re-enables buttons', (
    tester,
  ) async {
    // SupabaseAuthManager.cancellable maps a dismissed native prompt to null;
    // backing out is an ordinary choice and must not toast.
    await tester.pumpWidget(buildSubject(googleSignIn: () async => null));

    await tester.tap(find.text('Sign in with Google'));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text(errorToast), findsNothing);
    for (final button in tester.widgetList<ProviderSignInButton>(
      find.byType(ProviderSignInButton),
    )) {
      expect(button.disabled, isFalse);
    }
  });

  testWidgets('a successful sign-in does not toast', (tester) async {
    await tester.pumpWidget(
      buildSubject(appleSignIn: () async => AuthResponse()),
    );

    await tester.tap(find.text('Sign in with Apple'));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text(errorToast), findsNothing);
  });
}
