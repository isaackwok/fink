import 'package:supabase_flutter/supabase_flutter.dart';

/// Achievement dimensions, in display order (matches the server's ordering;
/// the client never re-sorts).
enum AchievementKind { director, actor, decade, country, genre }

/// One "xth film ..." card computed by the `journal-insights` Edge Function.
///
/// [key] is stable and locale-independent (TMDB person id, genre id, ISO
/// 3166-1 code, or era bucket year). The client localizes genre / country /
/// era display from [key]; person cards render [name] from the payload.
class Achievement {
  final AchievementKind kind;
  final String key;
  final String name;
  final int count;

  const Achievement({
    required this.kind,
    required this.key,
    required this.name,
    required this.count,
  });

  /// Returns null for unknown kinds so callers can skip them — a Part 2
  /// server emitting `festival` must not break a Part 1 client.
  static Achievement? fromJson(Map<String, dynamic> json) {
    final kind = AchievementKind.values.asNameMap()[json['kind']];
    if (kind == null) return null;
    final key = json['key'];
    final name = json['name'];
    final count = json['count'];
    if (key is! String || name is! String || count is! int) return null;
    return Achievement(kind: kind, key: key, name: name, count: count);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Achievement &&
          other.kind == kind &&
          other.key == key &&
          other.name == name &&
          other.count == count;

  @override
  int get hashCode => Object.hash(kind, key, name, count);
}

/// Thin seam over the `journal-insights` Edge Function so tests can fake it
/// behind a Provider (quesgen pattern).
class JournalInsightsApi {
  Future<List<Achievement>> fetchAchievements(int tmdbId) async {
    final res = await Supabase.instance.client.functions.invoke(
      'journal-insights',
      body: {'tmdbId': tmdbId},
    );
    final data = res.data;
    final raw = (data is Map && data['achievements'] is List)
        ? data['achievements'] as List
        : const [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map(Achievement.fromJson)
        .whereType<Achievement>()
        .toList();
  }
}
