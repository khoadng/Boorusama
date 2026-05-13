// Package imports:
import 'package:booru_clients/danbooru.dart';

// Project imports:
import '../../../../core/text_markup/types.dart';

class DanbooruTextMarkupRepository implements TextMarkupRepository {
  DanbooruTextMarkupRepository({
    required this.client,
  });

  final DanbooruClient client;
  final _cache = <String, TextEmoji>{};
  final _missing = <String>{};

  @override
  Future<Map<String, TextEmoji>> resolveEmojiShortcodes(
    Set<String> names,
  ) async {
    final normalizedNames = names
        .map((name) => name.toLowerCase())
        .where(isValidTextEmojiShortcode)
        .toSet();

    final unresolved = normalizedNames
        .where((name) => !_cache.containsKey(name) && !_missing.contains(name))
        .toSet();

    if (unresolved.isNotEmpty) {
      final resolved = await _resolveMissingEmojiShortcodes(unresolved);
      _cache.addAll(resolved);
      _missing.addAll(unresolved.where((name) => !resolved.containsKey(name)));
    }

    return Map.unmodifiable({
      for (final name in normalizedNames) name: ?_cache[name],
    });
  }

  Future<Map<String, TextEmoji>> _resolveMissingEmojiShortcodes(
    Set<String> names,
  ) async {
    final values = await client.getDTextEmojiValues(names);

    return Map.unmodifiable({
      for (final entry in values.entries) entry.key: _toTextEmoji(entry.value),
    });
  }
}

TextEmoji _toTextEmoji(DanbooruDTextEmojiValue value) {
  return switch (value) {
    DanbooruDTextEmojiText(:final text) => TextEmojiText(text),
    DanbooruDTextEmojiImage(:final url, :final width, :final height) =>
      TextEmojiImage(url, width: width, height: height),
  };
}
