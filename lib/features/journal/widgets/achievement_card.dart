import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:movie_journal/core/utils/country_names.dart';
import 'package:movie_journal/core/utils/ordinal.dart';
import 'package:movie_journal/core/utils/tmdb_genres.dart';
import 'package:movie_journal/features/journal/data/journal_insights_api.dart';
import 'package:movie_journal/l10n/app_localizations.dart';
import 'package:movie_journal/themes.dart';

/// One "xth film …" card on the journal complete screen (Figma 7170:6136).
///
/// Layout: kind icon, then a two-tone line (bold ordinal + grey connector),
/// then the dimension's display name. People render the payload name; genre /
/// country / era resolve their localized name from the stable [Achievement.key]
/// via the display helpers.
class AchievementCard extends StatelessWidget {
  final Achievement achievement;

  const AchievementCard({super.key, required this.achievement});

  /// Era buckets split at 2020 (see the journal-insights function): a key of
  /// 2020+ is a single year, below it is a decade start.
  static bool _isYearBucket(String key) => (int.tryParse(key) ?? 0) >= 2020;

  String _connector(AppLocalizations l10n) => switch (achievement.kind) {
    AchievementKind.director => l10n.achievementConnectorDirector,
    AchievementKind.actor => l10n.achievementConnectorActor,
    AchievementKind.country => l10n.achievementConnectorCountry,
    AchievementKind.genre => l10n.achievementConnectorGenre,
    AchievementKind.decade =>
      _isYearBucket(achievement.key)
          ? l10n.achievementConnectorYear
          : l10n.achievementConnectorDecade,
  };

  String _displayName(AppLocalizations l10n, Locale locale) {
    switch (achievement.kind) {
      case AchievementKind.director:
      case AchievementKind.actor:
        return achievement.name;
      case AchievementKind.country:
        return countryName(achievement.key, locale);
      case AchievementKind.genre:
        final id = int.tryParse(achievement.key);
        return (id == null ? null : tmdbGenreName(id, locale)) ??
            achievement.name;
      case AchievementKind.decade:
        final value = int.tryParse(achievement.key);
        if (value == null) return achievement.name;
        return _isYearBucket(achievement.key)
            ? l10n.yearLabel(year: value)
            : l10n.decadeLabel(decade: value);
    }
  }

  Widget _icon() => switch (achievement.kind) {
    // Director and country ship as complete 36px assets (tinted rounded
    // background included).
    AchievementKind.director => SvgPicture.asset(
      'assets/images/achievement_director.svg',
      width: 36,
      height: 36,
    ),
    AchievementKind.country => SvgPicture.asset(
      'assets/images/achievement_country.svg',
      width: 36,
      height: 36,
    ),
    // Actor and genre are bare 20px glyphs inside a tinted box in the design.
    AchievementKind.actor => Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0x1434C759),
        borderRadius: BorderRadius.circular(8),
      ),
      child: SvgPicture.asset(
        'assets/images/achievement_actor_glyph.svg',
        width: 20,
        height: 20,
      ),
    ),
    AchievementKind.genre => Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0x14FFECD1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: SvgPicture.asset(
        'assets/images/achievement_genre_glyph.svg',
        width: 20,
        height: 20,
      ),
    ),
    // No era card exists in the Figma node; composed in the same
    // glyph-in-tinted-box style (iOS purple).
    AchievementKind.decade => Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0x14BF5AF2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(
        Icons.calendar_month,
        size: 20,
        color: Color(0xFFBF5AF2),
      ),
    ),
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: DarkSurfaces.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _icon(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    l10n.achievementOrdinal(
                      ordinal: ordinal(achievement.count, locale),
                    ),
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      _connector(l10n),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFFB1B1B1),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                _displayName(l10n, locale),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
