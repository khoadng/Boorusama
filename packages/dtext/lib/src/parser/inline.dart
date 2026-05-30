import '../entity.dart';
import '../ast.dart';

import '../characters.dart';
import 'context.dart';

mixin DTextInlineParser on DTextParserContext {
  @override
  bool parseEntity() {
    final entity = matchEntityAt(scanner.source, scanner.offset);
    if (entity == null) return false;

    scanner.advance(entity.length);
    renderer.writeEntity(entity.value);
    return true;
  }

  @override
  bool parseInlineTag() {
    final openTags = <String, (DTextElement, String)>{
      'b': (DTextElement.inlineBold, '<strong>'),
      'strong': (DTextElement.inlineBold, '<strong>'),
      'i': (DTextElement.inlineItalic, '<em>'),
      'em': (DTextElement.inlineItalic, '<em>'),
      'u': (DTextElement.inlineUnderline, '<u>'),
      's': (DTextElement.inlineStrike, '<s>'),
      'tn': (DTextElement.inlineTn, '<span class="tn">'),
      'spoiler': (DTextElement.inlineSpoiler, '<span class="spoiler">'),
      'spoilers': (DTextElement.inlineSpoiler, '<span class="spoiler">'),
    };

    for (final entry in openTags.entries) {
      final closeTag = matchCloseTag([entry.key]);
      if (closeTag != null) {
        scanner.advance(closeTag.length);
        renderer.close(entry.value.$1);
        return true;
      }

      final openTag = matchOpenTag([entry.key]);
      if (openTag != null) {
        scanner.advance(openTag.length);
        renderer.open(entry.value.$1, entry.value.$2);
        return true;
      }
    }

    final br = matchOpenTag(['br']);
    if (br != null) {
      scanner.advance(br.length);
      renderer.addLineBreak();
      return true;
    }

    return false;
  }

  @override
  bool parseInlineCloseForContainer(String tag) {
    final normalized = tag.toLowerCase();
    final isSpoiler = normalized == 'spoiler' || normalized == 'spoilers';
    if (isSpoiler && renderer.isOpen(DTextElement.inlineSpoiler)) {
      final close = matchCloseTag([tag]);
      if (close == null) return false;

      scanner.advance(close.length);
      renderer.close(DTextElement.inlineSpoiler);
      return true;
    }

    if (normalized == 'tn' && renderer.isOpen(DTextElement.inlineTn)) {
      final close = matchCloseTag([tag]);
      if (close == null) return false;

      scanner.advance(close.length);
      renderer.close(DTextElement.inlineTn);
      return true;
    }

    return false;
  }

  @override
  bool parseInlineCode() {
    final tag = matchOpenCodeTag();
    if (tag == null) return false;

    scanner.advance(tag.lexeme.length);
    final code = scanner.readUntilCloseTag('code');
    consumeCloseTag('code');
    if (tag.language == null) {
      renderer.openInlineCode();
    } else {
      renderer.openInlineCode(language: tag.language);
    }
    renderer.writeEscaped(code);
    renderer.close(DTextElement.inlineCode);
    return true;
  }

  @override
  bool parseNodtext() {
    final tag = matchOpenTag(['nodtext']);
    if (tag == null) return false;

    scanner.advance(tag.length);
    final text = scanner.readUntilCloseTag('nodtext');
    consumeCloseTag('nodtext');
    renderer.writeEscaped(text);
    return true;
  }

  @override
  bool parseMention() {
    if (!options.enableMentions ||
        !scanner.startsWith('@') && !scanner.startsWith('<@')) {
      return false;
    }

    final delimitedName = _matchDelimitedMention();
    if (delimitedName != null) {
      scanner.advance(delimitedName.length + 3);
      writeMention(delimitedName);
      return true;
    }

    if (!isMentionBoundary(scanner.offset - 1)) return false;

    final name = _matchMentionName();
    if (name == null) return false;
    if (name.length < 2 || name.endsWith("'s") || name.endsWith("'d")) {
      return false;
    }

    scanner.advance(name.length + 1);
    writeMention(name);
    return true;
  }

  String? _matchDelimitedMention() {
    if (!scanner.startsWith('<@')) return null;

    var index = scanner.offset + 2;
    if (index >= scanner.source.length) return null;
    final first = scanner.source.codeUnitAt(index);
    if (isWhitespace(first) || first == greaterThanCode) return null;

    final nameStart = index;
    while (index < scanner.source.length) {
      final codeUnit = scanner.source.codeUnitAt(index);
      if (codeUnit == lineFeedCode) return null;
      if (codeUnit == greaterThanCode) {
        return scanner.source.substring(nameStart, index);
      }
      index++;
    }

    return null;
  }

  String? _matchMentionName() {
    if (!scanner.startsWith('@')) return null;

    var index = scanner.offset + 1;
    if (index >= scanner.source.length) return null;

    final first = scanner.source.codeUnitAt(index);
    if (first == periodCode || first == underscoreCode) index++;
    if (index >= scanner.source.length ||
        _isMentionEdgeTerminator(scanner.source.codeUnitAt(index))) {
      return null;
    }

    index++;
    while (index < scanner.source.length) {
      final codeUnit = scanner.source.codeUnitAt(index);
      if (isWhitespace(codeUnit) || codeUnit == atSignCode) break;
      index++;
    }

    if (_isMentionEdgeTerminator(scanner.source.codeUnitAt(index - 1))) {
      return null;
    }

    return scanner.source.substring(scanner.offset + 1, index);
  }

  bool _isMentionEdgeTerminator(int codeUnit) {
    if (isWhitespace(codeUnit)) return true;

    return codeUnit == atSignCode ||
        codeUnit == periodCode ||
        codeUnit == commaCode ||
        codeUnit == colonCode ||
        codeUnit == semicolonCode ||
        codeUnit == exclamationCode ||
        codeUnit == questionCode ||
        codeUnit == leftParenthesisCode ||
        codeUnit == rightParenthesisCode ||
        codeUnit == leftBracketCode ||
        codeUnit == rightBracketCode ||
        codeUnit == leftBraceCode ||
        codeUnit == rightBraceCode ||
        codeUnit == doubleQuoteCode ||
        codeUnit == lessThanCode ||
        codeUnit == greaterThanCode;
  }

  @override
  bool parseEmoji() {
    final allow = options.isAllowedEmoji;
    if (allow == null || !scanner.startsWith(':')) return false;

    var index = scanner.offset + 1;
    final nameStart = index;
    while (index < scanner.source.length &&
        _isEmojiNameCodeUnit(scanner.source.codeUnitAt(index))) {
      index++;
    }

    final nameLength = index - nameStart;
    if (nameLength < 3 ||
        nameLength > 32 ||
        index >= scanner.source.length ||
        scanner.source[index] != ':') {
      return false;
    }

    final name = scanner.source.substring(nameStart, index);
    if (!allow(name)) return false;

    scanner.advance(nameLength + 2);
    renderer.addEmoji(name);
    return true;
  }

  bool _isEmojiNameCodeUnit(int codeUnit) =>
      isAsciiAlphaNumeric(codeUnit) || codeUnit == underscoreCode;

  @override
  List<DTextNode> parseInlineToNodes() {
    parseInline(stopAtBlockBoundary: false);
    renderer.closeAll();
    return renderer.nodes;
  }

  @override
  List<DTextNode> parseBasicInlineToNodes() {
    while (!scanner.isDone) {
      if (parseEntity()) continue;
      if (parseInlineTag()) continue;
      renderer.writeCharEscaped(scanner.advanceOne().codeUnitAt(0));
    }
    renderer.closeAll();
    return renderer.nodes;
  }

  @override
  void writeMention(String name) {
    renderer.addLink(
      href:
          '${renderer.relativeUrl('/users?name=')}${renderer.uriEscape(name)}',
      children: [DTextText('@$name')],
      classes: const ['dtext-link', 'dtext-user-mention-link'],
      kind: DTextLinkKind.userMention,
      attributes: {'data-user-name': name},
    );
  }

  @override
  bool isMentionBoundary(int offset) {
    if (offset < 0) return true;

    return switch (scanner.source[offset]) {
      '\r' ||
      '\n' ||
      ' ' ||
      '/' ||
      '"' ||
      "'" ||
      '(' ||
      ')' ||
      '[' ||
      ']' ||
      '{' ||
      '}' => true,
      _ => false,
    };
  }
}
