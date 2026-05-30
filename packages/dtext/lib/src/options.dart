import 'ast.dart';

typedef EmojiPredicate = bool Function(String name);

class DTextOptions {
  const DTextOptions({
    this.inline = false,
    this.enableMentions = true,
    this.enableMediaEmbeds = true,
    this.baseUrl,
    this.domain,
    this.internalDomains = const {},
    this.isAllowedEmoji,
  });

  final bool inline;
  final bool enableMentions;
  final bool enableMediaEmbeds;
  final String? baseUrl;
  final String? domain;
  final Set<String> internalDomains;
  final EmojiPredicate? isAllowedEmoji;

  DTextOptions copyWith({
    bool? inline,
    bool? enableMentions,
    bool? enableMediaEmbeds,
    String? baseUrl,
    String? domain,
    Set<String>? internalDomains,
    EmojiPredicate? isAllowedEmoji,
  }) => DTextOptions(
    inline: inline ?? this.inline,
    enableMentions: enableMentions ?? this.enableMentions,
    enableMediaEmbeds: enableMediaEmbeds ?? this.enableMediaEmbeds,
    baseUrl: baseUrl ?? this.baseUrl,
    domain: domain ?? this.domain,
    internalDomains: internalDomains ?? this.internalDomains,
    isAllowedEmoji: isAllowedEmoji ?? this.isAllowedEmoji,
  );
}

class DTextParseResult {
  const DTextParseResult({
    required this.html,
    required this.wikiPages,
    required this.document,
  });

  final String html;
  final Set<String> wikiPages;
  final DTextDocument document;
}
