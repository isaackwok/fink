import 'package:flutter/material.dart';
import 'package:movie_journal/l10n/app_localizations.dart';
import 'package:movie_journal/l10n/supported_locales.dart';

Widget localizedTestApp({
  required Widget home,
  Locale locale = const Locale('en'),
  ThemeData? theme,
  List<NavigatorObserver> navigatorObservers = const [],
}) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: appSupportedLocales,
    theme: theme,
    navigatorObservers: navigatorObservers,
    home: home,
  );
}
