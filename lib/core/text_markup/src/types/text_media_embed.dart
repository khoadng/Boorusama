// Package imports:
import 'package:meta/meta.dart';

enum TextMediaEmbedType {
  post,
  asset
  ;

  static TextMediaEmbedType? parse(String value) {
    return switch (value.toLowerCase()) {
      'post' => TextMediaEmbedType.post,
      'asset' => TextMediaEmbedType.asset,
      _ => null,
    };
  }
}

@immutable
class TextMediaEmbedRef {
  const TextMediaEmbedRef({
    required this.type,
    required this.id,
  });

  final TextMediaEmbedType type;
  final int id;

  @override
  bool operator ==(Object other) {
    return other is TextMediaEmbedRef && other.type == type && other.id == id;
  }

  @override
  int get hashCode => Object.hash(type, id);
}

sealed class TextMediaEmbed {
  const TextMediaEmbed({
    required this.ref,
    required this.pageUrl,
  });

  final TextMediaEmbedRef ref;
  final String pageUrl;
}

class TextMediaImageEmbed extends TextMediaEmbed {
  const TextMediaImageEmbed({
    required super.ref,
    required super.pageUrl,
    required this.imageUrl,
    required this.width,
    required this.height,
  });

  final String imageUrl;
  final int width;
  final int height;
}

class TextMediaUnavailableEmbed extends TextMediaEmbed {
  const TextMediaUnavailableEmbed({
    required super.ref,
    required super.pageUrl,
    this.reason,
  });

  final String? reason;
}

final _textMediaEmbedPattern = RegExp(
  r'^(?:\* )?!(post|asset) #(\d+)(?::[ \t]+[^\n]*)?[ \t]*$',
  multiLine: true,
);

Set<TextMediaEmbedRef> extractTextMediaEmbedRefs(String value) {
  final refs = <TextMediaEmbedRef>{};

  for (final match in _textMediaEmbedPattern.allMatches(value)) {
    final typeValue = match.group(1);
    final idValue = match.group(2);
    if (typeValue == null || idValue == null) continue;

    final type = TextMediaEmbedType.parse(typeValue);
    final id = int.tryParse(idValue);
    if (type == null || id == null || id <= 0) continue;

    refs.add(TextMediaEmbedRef(type: type, id: id));
  }

  return Set.unmodifiable(refs);
}
