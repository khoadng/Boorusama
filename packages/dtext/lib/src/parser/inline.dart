import '../entity.dart';
import '../ast.dart';

import 'context.dart';

mixin DTextInlineParser on DTextParserContext {
  @override
  bool parseEntity() {
    final entity = matchEntity(scanner.rest);
    if (entity == null) return false;

    scanner.advance(
      dtextEntities.keys
          .firstWhere((key) => scanner.rest.toLowerCase().startsWith(key))
          .length,
    );
    renderer.writeEntity(entity);
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

    final delimited = scanner.matchGroups(RegExp(r'<@([^\s\n>][^\n>]*)>'));
    if (delimited != null) {
      final name = delimited.group(1)!;
      scanner.advance(delimited.group(0)!.length);
      writeMention(name);
      return true;
    }

    if (!isMentionBoundary(scanner.offset - 1)) return false;

    final match = scanner.matchGroups(
      RegExp(r'@([._]?[^\s@.,:;!?()[\]{}"<>][^\s@]*[^\s@.,:;!?()[\]{}"<>])'),
    );
    if (match == null) return false;

    final name = match.group(1)!;
    if (name.length < 2 || name.endsWith("'s") || name.endsWith("'d")) {
      return false;
    }

    scanner.advance(match.group(0)!.length);
    writeMention(name);
    return true;
  }

  @override
  bool parseEmoji() {
    final allow = options.isAllowedEmoji;
    if (allow == null) return false;

    final match = scanner.matchGroups(RegExp(r':([A-Za-z0-9_]{3,32}):'));
    if (match == null) return false;

    final name = match.group(1)!;
    if (!allow(name)) return false;

    scanner.advance(match.group(0)!.length);
    renderer.addEmoji(name);
    return true;
  }

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
