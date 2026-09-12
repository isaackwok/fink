import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_journal/features/auth/auth_providers.dart';
import 'package:movie_journal/features/home/screens/home.dart';
import 'package:movie_journal/features/login/screens/create_user.dart';
import 'package:movie_journal/l10n/app_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'helpers/widget_test_setup.dart';

void main() {
  setUpAll(setUpWidgetTests);
  tearDownAll(tearDownWidgetTests);

  testWidgets('anonymous auth event cannot open signup during recovery', (
    tester,
  ) async {
    final bridge = Completer<bool>();
    final auth = StreamController<User?>();
    addTearDown(auth.close);
    var profileChecks = 0;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStateProvider.overrideWith((ref) => auth.stream),
          anonymousBridgeProvider.overrideWith((ref) => bridge.future),
          hasProfileProvider.overrideWith((ref) async {
            profileChecks++;
            return false;
          }),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: HomeScreen(),
        ),
      ),
    );
    auth.add(null);
    await tester.pump();
    auth.add(
      const User(
        id: 'bridge-user',
        appMetadata: {},
        userMetadata: {},
        aud: 'authenticated',
        createdAt: '',
        isAnonymous: true,
      ),
    );
    await tester.pump();
    await tester.pump();
    expect(profileChecks, 0);
    expect(find.byType(CreateUserScreen), findsNothing);
    bridge.complete(true);
    await tester.pump();
    await tester.pump();
    expect(profileChecks, 1);
    expect(find.byType(CreateUserScreen), findsOneWidget);
  });
}
