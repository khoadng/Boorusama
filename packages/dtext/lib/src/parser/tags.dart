import 'context.dart';
import '../characters.dart';

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
    if (!scanner.startsWith('[code', caseSensitive: false) &&
        !scanner.startsWith('<code', caseSensitive: false)) {
      return null;
    }

    final close = scanner.current == '[' ? ']' : '>';
    final start = scanner.offset;
    var index = start + 5;
    var languageStart = -1;
    var languageEnd = -1;

    while (index < scanner.source.length &&
        isSpaceTab(scanner.source.codeUnitAt(index))) {
      index++;
    }

    if (index < scanner.source.length && scanner.source[index] == '=') {
      index++;
      while (index < scanner.source.length &&
          isSpaceTab(scanner.source.codeUnitAt(index))) {
        index++;
      }

      languageStart = index;
      while (index < scanner.source.length &&
          isAsciiAlphaNumeric(scanner.source.codeUnitAt(index))) {
        index++;
      }
      languageEnd = index;
    }

    if (languageStart >= 0 && languageStart == languageEnd) return null;
    if (index >= scanner.source.length || scanner.source[index] != close) {
      return null;
    }

    return (
      lexeme: scanner.source.substring(start, index + 1),
      language: languageStart < 0
          ? null
          : scanner.source.substring(languageStart, languageEnd),
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
