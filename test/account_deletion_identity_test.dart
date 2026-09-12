import 'dart:convert';
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_journal/features/auth/auth_providers.dart';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:movie_journal/supabase_auth_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const appleChannel = MethodChannel(
    'com.aboutyou.dart_packages.sign_in_with_apple',
  );
  var selectedId = 'account-a';
  var cancel = false;
  var profileReads = 0;
  final deletions = <String>[];
  Map<String, dynamic> session(String id) => {
    'access_token': 'test-token',
    'refresh_token': 'test-refresh',
    'token_type': 'bearer',
    'expires_in': 3600,
    'user': {
      'id': id,
      'aud': 'authenticated',
      'created_at': '2026-01-01T00:00:00Z',
      'app_metadata': {'provider': 'apple'},
      'user_metadata': <String, dynamic>{},
    },
  };

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(appleChannel, (call) async {
          if (cancel) {
            throw PlatformException(
              code: 'authorization-error/canceled',
              message: 'Cancelled',
            );
          }
          return {
            'type': 'appleid',
            'identityToken': 'apple-token',
            'authorizationCode': 'code',
            'userIdentifier': 'apple-user',
          };
        });
    await Supabase.initialize(
      url: 'https://auth-test.invalid',
      publishableKey: 'test-key',
      authOptions: const FlutterAuthClientOptions(
        localStorage: EmptyLocalStorage(),
        detectSessionInUri: false,
        autoRefreshToken: false,
      ),
      httpClient: MockClient((request) async {
        if (request.url.path.endsWith('/token')) {
          return http.Response(
            jsonEncode(session(selectedId)),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        if (request.url.path.endsWith('/delete-account')) {
          deletions.add(jsonDecode(request.body)['expectedUserId'] as String);
          return http.Response(
            '{"deletedJournalIds":["journal-a"]}',
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        if (request.url.path.endsWith('/profiles')) {
          profileReads++;
          return http.Response(
            '[{"id":"account-a","username":"Recovered"}]',
            200,
            request: request,
            headers: {'content-type': 'application/json'},
          );
        }
        if (request.url.path.endsWith('/logout')) return http.Response('', 204);
        throw StateError('Unexpected request: ${request.url}');
      }),
    );
  });
  setUp(() async {
    selectedId = 'account-a';
    cancel = false;
    deletions.clear();
    profileReads = 0;
    await Supabase.instance.client.auth.signInWithIdToken(
      provider: OAuthProvider.apple,
      idToken: 'initial',
    );
  });
  tearDownAll(() async {
    await Supabase.instance.dispose();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(appleChannel, null);
  });

  test(
    'profile and username await bridge completion before reading recovered data',
    () async {
      final bridge = Completer<bool>();
      final container = ProviderContainer(
        overrides: [
          authStateProvider.overrideWith(
            (ref) => Stream.value(SupabaseAuthManager.currentUser),
          ),
          anonymousBridgeProvider.overrideWith((ref) => bridge.future),
        ],
      );
      addTearDown(container.dispose);
      final profile = container.read(hasProfileProvider.future);
      final username = container.read(currentUsernameProvider.future);
      await Future<void>.delayed(Duration.zero);
      expect(profileReads, 0);
      bridge.complete(true);
      expect(await profile, isTrue);
      expect(await username, 'Recovered');
      expect(profileReads, 2);
    },
  );

  test('selecting another provider account aborts deletion', () async {
    selectedId = 'account-b';
    await expectLater(
      SupabaseAuthManager.reauthenticate(expectedUserId: 'account-a'),
      throwsA(isA<AuthException>()),
    );
    await expectLater(
      SupabaseAuthManager.deleteAccount(expectedUserId: 'account-a'),
      throwsA(isA<AuthException>()),
    );
    expect(deletions, isEmpty);
  });

  test('same identity can confirm and delete the intended account', () async {
    expect(
      await SupabaseAuthManager.reauthenticate(expectedUserId: 'account-a'),
      isTrue,
    );
    expect(
      await SupabaseAuthManager.deleteAccount(expectedUserId: 'account-a'),
      ['journal-a'],
    );
    expect(deletions, ['account-a']);
    expect(SupabaseAuthManager.currentUser, isNull);
  });

  test('cancelling confirmation does not delete', () async {
    cancel = true;
    expect(
      await SupabaseAuthManager.reauthenticate(expectedUserId: 'account-a'),
      isFalse,
    );
    expect(deletions, isEmpty);
  });

  test('session change after confirmation is rejected at deletion', () async {
    expect(
      await SupabaseAuthManager.reauthenticate(expectedUserId: 'account-a'),
      isTrue,
    );
    selectedId = 'account-b';
    await Supabase.instance.client.auth.signInWithIdToken(
      provider: OAuthProvider.apple,
      idToken: 'other',
    );
    await expectLater(
      SupabaseAuthManager.deleteAccount(expectedUserId: 'account-a'),
      throwsA(isA<AuthException>()),
    );
    expect(deletions, isEmpty);
  });
}
