// Project imports:
import '../generated/settings_category.g.dart';
import 'settings_search_entry.dart';

String normalizeSettingsQuery(String value) =>
    value.toLowerCase().replaceAll(RegExp(r'[_\-\s]+'), ' ').trim();

/// Every query word must match. Titles outrank aliases, descriptions and paths.
List<SettingsSearchEntry> searchSettings(
  Iterable<SettingsSearchEntry> entries,
  String query, {
  SettingsSearchScope? scope,
}) {
  final normalized = normalizeSettingsQuery(query);
  if (normalized.isEmpty) return const [];
  final words = normalized.split(' ');
  final scored = <({SettingsSearchEntry entry, int score, int order})>[];
  var order = 0;
  for (final entry in entries) {
    final ordinal = order++;
    if (scope != null && entry.scope != scope) continue;
    final title = normalizeSettingsQuery(entry.title);
    final aliases = normalizeSettingsQuery(entry.keywords);
    final description = normalizeSettingsQuery(entry.description);
    final path = normalizeSettingsQuery(entry.breadcrumb);
    var score = 0;
    var matches = true;
    for (final word in words) {
      bool prefix(String text) =>
          text.split(' ').any((token) => token.startsWith(word));
      bool partial(String text) => word.length >= 4 && text.contains(word);
      if (title.split(' ').contains(word)) {
        score += 50;
      } else if (aliases.split(' ').contains(word)) {
        score += 40;
      } else if (prefix(title)) {
        score += 30;
      } else if (prefix(aliases)) {
        score += 20;
      } else if (partial(title) || partial(aliases)) {
        score += 15;
      } else if (prefix(description) || partial(description)) {
        score += 10;
      } else if (prefix(path) || partial(path)) {
        score += 5;
      } else {
        matches = false;
        break;
      }
    }
    if (matches) {
      if (title == normalized) score += 100;
      if (title.startsWith(normalized)) score += 50;
      scored.add((entry: entry, score: score, order: ordinal));
    }
  }
  scored.sort((a, b) {
    final rank = b.score.compareTo(a.score);
    return rank == 0 ? a.order.compareTo(b.order) : rank;
  });
  return [for (final match in scored) match.entry];
}
