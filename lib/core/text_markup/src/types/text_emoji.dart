sealed class TextEmoji {
  const TextEmoji();
}

class TextEmojiText extends TextEmoji {
  const TextEmojiText(this.text);

  final String text;
}

class TextEmojiImage extends TextEmoji {
  const TextEmojiImage(
    this.url, {
    this.width,
    this.height,
  });

  final String url;
  final int? width;
  final int? height;
}

final _textEmojiShortcodePattern = RegExp(':([A-Za-z0-9_]{3,32}):');

Set<String> extractTextEmojiShortcodes(String value) {
  final names = <String>{};

  for (final match in _textEmojiShortcodePattern.allMatches(value)) {
    final name = match.group(1)?.toLowerCase();
    if (name == null || !isValidTextEmojiShortcode(name)) continue;

    names.add(name);
  }

  return Set.unmodifiable(names);
}

bool isValidTextEmojiShortcode(String name) {
  if (name == 'http' || name == 'https') return false;
  if (int.tryParse(name) != null) return false;

  return true;
}
