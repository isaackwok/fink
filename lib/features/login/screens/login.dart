import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:movie_journal/analytics_manager.dart';
import 'package:movie_journal/features/toast/custom_toast.dart';
import 'package:movie_journal/l10n/app_localizations.dart';
import 'package:movie_journal/shared_widgets/provider_sign_in_button.dart';
import 'package:movie_journal/supabase_auth_manager.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show AuthResponse;

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    this.googleSignIn = _defaultGoogleSignIn,
    this.appleSignIn = _defaultAppleSignIn,
  });

  /// Runs the provider flow, resolving to `null` when the user dismissed the
  /// native prompt (see [SupabaseAuthManager.cancellable]). Injectable purely
  /// so widget tests can fake the three outcomes — the real flows need live
  /// Apple/Google SDKs.
  final Future<AuthResponse?> Function() googleSignIn;
  final Future<AuthResponse?> Function() appleSignIn;

  static Future<AuthResponse?> _defaultGoogleSignIn() =>
      SupabaseAuthManager.cancellable(
        () => SupabaseAuthManager.signInWithGoogle(),
      );

  static Future<AuthResponse?> _defaultAppleSignIn() =>
      SupabaseAuthManager.cancellable(SupabaseAuthManager.signInWithApple);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;

  /// Cancelled prompts stay silent — backing out of the Apple/Google sheet is
  /// an ordinary choice, not a failure. Real faults get an error toast; the
  /// success path needs no navigation because `home.dart` reacts to the auth
  /// state stream.
  Future<void> _signIn(
    Future<AuthResponse?> Function() flow, {
    required String method,
  }) async {
    setState(() => _isLoading = true);
    try {
      final response = await flow();
      if (response == null) return;
      unawaited(AnalyticsManager.logSignIn(method: method));
    } catch (e) {
      debugPrint('Sign-in with $method failed: $e');
      if (mounted) {
        CustomToast.showError(
          context,
          AppLocalizations.of(context).loginFailed,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ScreenViewTracker(
      screenName: 'Login',
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                // Title
                Text(
                  l10n.loginTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    height: 1.5,
                    fontFamily: 'AvenirNext',
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                // Subtitle
                Text(
                  l10n.loginSubtitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    height: 1.5,
                    fontFamily: 'AvenirNext',
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                // Sign in with Google button
                ProviderSignInButton(
                  disabled: _isLoading,
                  onPressed:
                      () => _signIn(widget.googleSignIn, method: 'google'),
                  icon: SvgPicture.asset('assets/images/google_icon.svg'),
                  label: l10n.loginWithGoogle,
                ),
                const SizedBox(height: 16),
                // Sign in with Apple button
                ProviderSignInButton(
                  disabled: _isLoading,
                  onPressed: () => _signIn(widget.appleSignIn, method: 'apple'),
                  icon: const Icon(Icons.apple, color: Colors.white, size: 28),
                  label: l10n.loginWithApple,
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
