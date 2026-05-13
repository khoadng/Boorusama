import 'context.dart';

mixin DTextTagMatcher on DTextParserContext {
  @override
  String? matchOpenTag(List<String> names) {
    for (final name in names) {
      final bracket = '[$name]';
      final angle = '<$name>';
      if (scanner.startsWith(bracket, caseSensitive: false)) return bracket;
      if (scanner.startsWith(angle, caseSensitive: false)) return angle;
    }

    return null;
  }

  @override
  ({String lexeme, String? language})? matchOpenCodeTag() {
    final match = scanner.matchGroups(
      RegExp(
        r'(?:\[code(?:\s*=\s*([A-Za-z0-9]+))?\]|<code(?:\s*=\s*([A-Za-z0-9]+))?>)',
        caseSensitive: false,
      ),
    );
    if (match == null) return null;

    return (
      lexeme: match.group(0)!,
      language: match.group(1) ?? match.group(2),
    );
  }

  @override
  String? matchCloseTag(List<String> names) {
    for (final name in names) {
      final bracket = '[/$name]';
      final angle = '</$name>';
      if (scanner.startsWith(bracket, caseSensitive: false)) return bracket;
      if (scanner.startsWith(angle, caseSensitive: false)) return angle;
    }

    return null;
  }

  @override
  bool startsOpenTag(List<String> names) => matchOpenTag(names) != null;

  @override
  bool startsCloseTag(String name) => matchCloseTag([name]) != null;

  @override
  bool startsAncestorClose(String? currentTag) {
    for (final tag in containerTags.reversed) {
      if (tag == currentTag) continue;
      if (startsCloseTag(tag)) return true;
    }

    return false;
  }

  @override
  bool consumeCloseTag(String name) {
    final tag = matchCloseTag([name]);
    if (tag == null) return false;

    scanner.advance(tag.length);
    return true;
  }
}
