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
