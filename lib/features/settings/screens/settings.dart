import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:movie_journal/analytics_manager.dart';
import 'package:movie_journal/features/toast/custom_toast.dart';
import 'package:movie_journal/features/account_link/controllers/account_link.dart';
import 'package:movie_journal/features/account_link/widgets/secure_account_sheet.dart';
import 'package:movie_journal/features/auth/auth_providers.dart';
import 'package:movie_journal/features/home/screens/home.dart';
import 'package:movie_journal/supabase_auth_manager.dart';
import 'package:movie_journal/features/journal/controllers/journals.dart';
import 'package:movie_journal/features/settings/controllers/language_settings.dart';
import 'package:movie_journal/l10n/app_localizations.dart';
import 'package:movie_journal/shared_widgets/circled_icon_button.dart';
import 'package:movie_journal/shared_widgets/confirmation_dialog.dart';
import 'package:movie_journal/themes.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usernameAsync = ref.watch(currentUsernameProvider);
    final l10n = AppLocalizations.of(context);

    return ScreenViewTracker(
      screenName: 'Settings',
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          leading: CircledIconButton(
            icon: Icons.arrow_back_ios_new,
            onPressed: () => Navigator.of(context).pop(),
            outerPadding: const EdgeInsets.only(left: 16),
          ),
          title: Text(l10n.settingsTitle),
          titleSpacing: 10,
          titleTextStyle: const TextStyle(
            fontFamily: 'AvenirNext',
            fontWeight: FontWeight.w700,
            fontSize: 22,
          ),
          leadingWidth: 40 + 16,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Username display
              usernameAsync.when(
                data:
                    (username) => Text(
                      username,
                      style: GoogleFonts.nothingYouCouldDo(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                loading:
                    () => Text(
                      l10n.commonLoading,
                      style: GoogleFonts.nothingYouCouldDo(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                error:
                    (error, stack) => Text(
                      l10n.commonUser,
                      style: GoogleFonts.nothingYouCouldDo(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
              ),
              const SizedBox(height: 24),

              // Language section
              const _LanguageSection(),
              const SizedBox(height: 16),

              // Account section
              _AccountSection(),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageSection extends ConsumerWidget {
  const _LanguageSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(languageSettingsProvider);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              l10n.settingsLanguageSection,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.6),
                letterSpacing: 0.5,
                fontFamily: 'AvenirNext',
              ),
            ),
          ),
          _SettingsItem(
            title: l10n.settingsInterfaceLanguage,
            trailing: _languageLabel(l10n, settings.interfaceLanguage),
            onTap:
                () => _showLanguagePicker(
                  context,
                  title: l10n.settingsInterfaceLanguage,
                  selected: settings.interfaceLanguage,
                  onSelected:
                      ref
                          .read(languageSettingsProvider.notifier)
                          .setInterfaceLanguage,
                ),
          ),
          Divider(height: 1, color: Colors.white.withValues(alpha: 0.1)),
          _SettingsItem(
            title: l10n.settingsAiReviewsLanguage,
            trailing: _languageLabel(l10n, settings.aiReviewsLanguage),
            isLast: true,
            onTap:
                () => _showLanguagePicker(
                  context,
                  title: l10n.settingsAiReviewsLanguage,
                  selected: settings.aiReviewsLanguage,
                  onSelected:
                      ref
                          .read(languageSettingsProvider.notifier)
                          .setAiReviewsLanguage,
                ),
          ),
        ],
      ),
    );
  }

  void _showLanguagePicker(
    BuildContext context, {
    required String title,
    required LanguagePreference selected,
    required ValueChanged<LanguagePreference> onSelected,
  }) {
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      backgroundColor: DarkSurfaces.sheetSecondary,
      builder:
          (context) => _LanguagePickerSheet(
            title: title,
            selected: selected,
            onSelected: (language) {
              onSelected(language);
              Navigator.of(context).pop();
            },
          ),
    );
  }
}

class _LanguagePickerSheet extends StatelessWidget {
  const _LanguagePickerSheet({
    required this.title,
    required this.selected,
    required this.onSelected,
  });

  final String title;
  final LanguagePreference selected;
  final ValueChanged<LanguagePreference> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 6),
              child: Text(
                title,
                style: const TextStyle(
                  fontFamily: 'AvenirNext',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            for (final language in LanguagePreference.values)
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                title: Text(
                  _languageLabel(l10n, language),
                  style: const TextStyle(
                    fontFamily: 'AvenirNext',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                trailing:
                    language == selected
                        ? Icon(
                          Icons.check,
                          color: Theme.of(context).colorScheme.primary,
                        )
                        : null,
                onTap: () => onSelected(language),
              ),
          ],
        ),
      ),
    );
  }
}

String _languageLabel(AppLocalizations l10n, LanguagePreference preference) {
  return switch (preference) {
    LanguagePreference.system => l10n.languageSystemDefault,
    LanguagePreference.english => l10n.languageEnglish,
    LanguagePreference.traditionalChineseTaiwan =>
      l10n.languageTraditionalChineseTaiwan,
  };
}

class _AccountSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final needsAccountLink = ref.watch(needsAccountLinkProvider);
    final l10n = AppLocalizations.of(context);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              l10n.settingsAccountSection,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.6),
                letterSpacing: 0.5,
                fontFamily: 'AvenirNext',
              ),
            ),
          ),

          // A bridged user's only route back into this account, and the only
          // place they can find it once the one-time prompt has been dismissed.
          if (needsAccountLink) ...[
            _SettingsItem(
              title: l10n.settingsSecureAccount,
              titleColor: StatusColors.warning,
              onTap: () => SecureAccountSheet.show(context),
            ),
            Divider(height: 1, color: Colors.white.withValues(alpha: 0.1)),
          ],

          // Logout option
          _SettingsItem(
            title: l10n.settingsLogout,
            onTap:
                () => _showLogoutConfirmation(
                  context,
                  ref,
                  isDeviceDependent: needsAccountLink,
                ),
          ),

          Divider(height: 1, color: Colors.white.withValues(alpha: 0.1)),

          // Delete Account option
          _SettingsItem(
            title: l10n.settingsDeleteAccount,
            titleColor: Colors.red,
            isLast: true,
            onTap: () => _showDeleteAccountConfirmation(context, ref),
          ),
        ],
      ),
    );
  }

  /// [isDeviceDependent] marks the case where a bridged user has no credential
  /// to sign back in with, so returning to this account depends entirely on
  /// this device.
  ///
  /// Not phrased as "you will lose everything": logging out is in fact
  /// recoverable. `AnonymousBridge` re-runs on the next cold start and
  /// `claim_anonymous_data` matches the profile by its retained `firebase_uid`,
  /// re-pointing the journals to the new session. What is unrecoverable is
  /// losing the *Firebase* anonymous session — a reinstall or a new phone —
  /// which signing out does not do. Overstating it would be a warning the user
  /// can discover is false, which is worse than none.
  void _showLogoutConfirmation(
    BuildContext context,
    WidgetRef ref, {
    bool isDeviceDependent = false,
  }) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder:
          (context) => ConfirmationDialog(
            title: l10n.settingsLogout,
            description:
                isDeviceDependent
                    ? l10n.settingsLogoutDeviceWarning
                    : l10n.settingsLogoutConfirmation,
            confirmText: l10n.settingsLogout,
            confirmTextStyle: TextStyle(
              fontFamily: 'AvenirNext',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              height: 1.4,
              color: Theme.of(context).colorScheme.primary,
            ),
            onCancel: () => Navigator.of(context).pop(),
            onConfirm: () async {
              await SupabaseAuthManager.signOut();
              ref.invalidate(journalsControllerProvider);
              ref.invalidate(currentUsernameProvider);
              // Otherwise the next sign-in reuses this user's cached
              // profile-existence answer and can skip CreateUserScreen.
              ref.invalidate(hasProfileProvider);
              if (context.mounted) {
                unawaited(
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                    (route) => false,
                  ),
                );
              }
            },
          ),
    );
  }

  void _showDeleteAccountConfirmation(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder:
          (context) => ConfirmationDialog(
            title: l10n.settingsDeleteAccount,
            description: l10n.settingsDeleteAccountDescription,
            confirmText: l10n.commonDelete,
            onCancel: () => Navigator.of(context).pop(),
            onConfirm: () async {
              await _deleteAccount(context, ref);
            },
          ),
    );
  }

  Future<void> _deleteAccount(BuildContext context, WidgetRef ref) async {
    if (SupabaseAuthManager.currentUser == null) return;

    // 1. Confirm presence before anything destructive. Supabase has no
    //    `requires-recent-login`, so unlike the Firebase flow this is no
    //    longer load-bearing for correctness — it is kept because backing out
    //    of the provider prompt must still cancel the deletion.
    try {
      final confirmed = await SupabaseAuthManager.reauthenticate();
      if (!confirmed) return; // user backed out of the prompt
    } catch (e) {
      if (context.mounted) {
        CustomToast.showError(
          context,
          AppLocalizations.of(
            context,
          ).settingsReauthenticationRequired(error: e),
        );
      }
      return;
    }

    // 2. A single server-side call. Deleting the auth user cascades to the
    //    profile and journals and fires the tombstone triggers, so there is no
    //    longer a window where data is gone but the account still exists —
    //    the half-deleted state the old ordering existed to avoid.
    try {
      final deletedJournalIds = await SupabaseAuthManager.deleteAccount();
      for (final id in deletedJournalIds) {
        unawaited(AnalyticsManager.logJournalDeleted(journalId: id));
      }

      ref.invalidate(journalsControllerProvider);
      ref.invalidate(currentUsernameProvider);
      ref.invalidate(hasProfileProvider);

      if (context.mounted) {
        unawaited(
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
            (route) => false,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        CustomToast.showError(
          context,
          AppLocalizations.of(context).settingsDeleteAccountFailed(error: e),
        );
      }
    }
  }
}

class _SettingsItem extends StatelessWidget {
  final String title;
  final String? trailing;
  final Color? titleColor;
  final VoidCallback onTap;
  final bool isLast;

  const _SettingsItem({
    required this.title,
    this.trailing,
    this.titleColor,
    required this.onTap,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    // Determine border radius based on position
    BorderRadius? borderRadius;
    if (isLast) {
      // Last item - only bottom corners
      borderRadius = const BorderRadius.only(
        bottomLeft: Radius.circular(12),
        bottomRight: Radius.circular(12),
      );
    }
    // Middle items get no border radius (null)

    return InkWell(
      onTap: onTap,
      borderRadius: borderRadius,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: titleColor ?? Colors.white,
                fontFamily: 'AvenirNext',
              ),
            ),
            if (trailing != null) ...[
              const Spacer(),
              Text(
                trailing!,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.55),
                  fontFamily: 'AvenirNext',
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.chevron_right,
                size: 18,
                color: Colors.white.withValues(alpha: 0.4),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
