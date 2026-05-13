import '../ast.dart';
import '../url_normalizer.dart';

import 'context.dart';

mixin DTextBlockParser on DTextParserContext {
  @override
  bool parseHeading() {
    final match = scanner.matchGroups(
      RegExp(r'h([1-6])(?:#([A-Za-z0-9_/#!:&-]+))?\.\s*'),
    );
    if (match == null) return false;

    scanner.advance(match.group(0)!.length);
    final level = int.parse(match.group(1)!);
    final id = match.group(2);
    final element = switch (level) {
      1 => DTextElement.heading1,
      2 => DTextElement.heading2,
      3 => DTextElement.heading3,
      4 => DTextElement.heading4,
      5 => DTextElement.heading5,
      _ => DTextElement.heading6,
    };

    renderer.openHeading(level, id: id == null ? null : normalizeAnchor(id));

    parseInline(stopAtBlockBoundary: false);
    renderer.close(element);
    scanner.consumeNewline();
    return true;
  }

  @override
  bool parseHr() {
    final match = scanner.match(
      RegExp(r'[ \t]*(?:\[hr\]|<hr>)[ \t]*(?:\n|$)', caseSensitive: false),
    );
    if (match == null) return false;

    renderer.closeLeafBlocks();
    renderer.addHorizontalRule();
    scanner.advance(match.length);
    return true;
  }

  @override
  bool parseCodeFence() {
    final match = scanner.matchGroups(
      RegExp(r'```[ \t]*([A-Za-z0-9]*)[ \t]*\n'),
    );
    if (match == null) return false;

    scanner.advance(match.group(0)!.length);
    final language = match.group(1)!;
    final code = scanner.readUntil('\n```');
    if (scanner.startsWith('\n```')) {
      scanner.advanceOne();
      scanner.advance(3);
      scanner.readUntilNewline();
      scanner.consumeNewline();
    }

    renderer.closeLeafBlocks();
    renderer.addCodeBlock(code, language: language.isEmpty ? null : language);
    return true;
  }

  @override
  bool parseBlockCode() {
    final tag = matchOpenCodeTag();
    if (tag == null) return false;

    scanner.advance(tag.lexeme.length);
    scanner.consumeNewline();
    final code = scanner.readUntilCloseTag('code');
    consumeCloseTag('code');

    renderer.closeLeafBlocks();
    renderer.addCodeBlock(code, language: tag.language);
    scanner.consumeNewline();
    return true;
  }

  @override
  bool parseQuote() {
    final tag = matchOpenTag(['quote', 'blockquote']);
    if (tag == null) return false;

    renderer.closeLeafBlocks();
    scanner.advance(tag.length);
    scanner.consumeNewline();
    renderer.open(DTextElement.quote, '<blockquote>');
    parseBlocks(
      untilTag: tag.startsWith('<blockquote') ? 'blockquote' : 'quote',
    );
    renderer.close(DTextElement.quote);
    scanner.consumeNewline();
    return true;
  }

  @override
  bool parseSpoilerBlock() {
    final tag = matchOpenTag(['spoiler', 'spoilers']);
    if (tag == null) return false;

    renderer.closeLeafBlocks();
    scanner.advance(tag.length);
    scanner.consumeNewline();
    renderer.open(DTextElement.spoilerBlock, '<div class="spoiler">');
    parseBlocks(
      untilTag: tag.toLowerCase().contains('spoilers') ? 'spoilers' : 'spoiler',
    );
    renderer.close(DTextElement.spoilerBlock);
    scanner.consumeNewline();
    return true;
  }

  @override
  bool parseExpand() {
    final match = scanner.matchGroups(
      RegExp(
        r'(?:\[expand(?:\s*=\s*|\s+)([^\]\n]*)\]|\[expand\]|<expand(?:\s*=\s*|\s+)([^>\n]*)>|<expand>)',
        caseSensitive: false,
      ),
    );
    if (match == null) return false;

    final title = match.group(1) ?? match.group(2) ?? 'Show';
    renderer.closeLeafBlocks();
    scanner.advance(match.group(0)!.length);
    scanner.consumeNewline();
    renderer.openExpand(title);
    parseBlocks(untilTag: 'expand');
    renderer.close(DTextElement.expand);
    scanner.consumeNewline();
    return true;
  }

  @override
  bool parseTnBlock() {
    final tag = matchOpenTag(['tn']);
    if (tag == null) return false;

    renderer.closeLeafBlocks();
    scanner.advance(tag.length);
    renderer.openParagraph(className: 'tn');

    while (!scanner.isDone && !startsCloseTag('tn')) {
      parseInline(stopAtBlockBoundary: false, untilTag: 'tn');
      if (!scanner.isDone && scanner.current == '\n') {
        scanner.advanceOne();
        renderer.addLineBreak();
      }
    }

    consumeCloseTag('tn');
    renderer.close(DTextElement.paragraph);
    scanner.consumeNewline();
    return true;
  }

  @override
  bool parseTable() {
    final tag = matchOpenTag(['table']);
    final hasExplicitTable = tag != null;
    if (!hasExplicitTable && !_startsTableContent()) return false;

    renderer.closeLeafBlocks();
    if (tag != null) scanner.advance(tag.length);
    renderer.open(DTextElement.table, '<table class="striped">');

    while (!scanner.isDone) {
      _consumeTableWhitespace();
      if (hasExplicitTable && startsCloseTag('table')) break;
      if (!hasExplicitTable && !_startsTableContent()) break;

      if (_parseTableSection('thead', DTextElement.tableHead)) continue;
      if (_parseTableSection('tbody', DTextElement.tableBody)) continue;
      if (parseTableTag('tr', DTextElement.tableRow, 'tr')) continue;
      if (parseTableTag('th', DTextElement.tableHeader, 'th')) continue;
      if (parseTableTag('td', DTextElement.tableCell, 'td')) continue;
      if (parseEntity()) continue;
      renderer.writeCharEscaped(scanner.advanceOne().codeUnitAt(0));
    }

    if (hasExplicitTable) consumeCloseTag('table');
    renderer.close(DTextElement.table);
    scanner.consumeNewline();
    return true;
  }

  bool _parseTableSection(String dtextTag, DTextElement element) {
    final tag = matchOpenTag([dtextTag]);
    if (tag == null) return false;

    scanner.advance(tag.length);
    renderer.open(element, '<$dtextTag>');

    while (!scanner.isDone && !startsCloseTag(dtextTag)) {
      _consumeTableWhitespace();
      if (startsCloseTag(dtextTag)) break;
      if (parseTableTag('tr', DTextElement.tableRow, 'tr')) continue;
      if (parseTableTag('th', DTextElement.tableHeader, 'th')) continue;
      if (parseTableTag('td', DTextElement.tableCell, 'td')) continue;
      if (parseEntity()) continue;
      renderer.writeCharEscaped(scanner.advanceOne().codeUnitAt(0));
    }

    consumeCloseTag(dtextTag);
    renderer.close(element);
    return true;
  }

  @override
  bool parseTableTag(String dtextTag, DTextElement element, String htmlTag) {
    final tag = matchOpenTag([dtextTag]);
    if (tag == null) return false;

    scanner.advance(tag.length);
    renderer.open(element, '<$htmlTag>');

    while (!scanner.isDone && !startsCloseTag(dtextTag)) {
      if (dtextTag == 'tr') {
        _consumeTableWhitespace();
        if (startsCloseTag(dtextTag)) break;
        if (parseTableTag('th', DTextElement.tableHeader, 'th')) continue;
        if (parseTableTag('td', DTextElement.tableCell, 'td')) continue;
        if (parseEntity()) continue;
        renderer.writeCharEscaped(scanner.advanceOne().codeUnitAt(0));
      } else {
        parseInline(stopAtBlockBoundary: false, untilTag: dtextTag);
        if (!scanner.isDone && scanner.current == '\n') {
          scanner.advanceOne();
          renderer.addLineBreak();
        }
      }
    }

    consumeCloseTag(dtextTag);
    renderer.close(element);
    return true;
  }

  bool _startsTableContent() =>
      startsOpenTag(['thead', 'tbody', 'tr', 'th', 'td']);

  void _consumeTableWhitespace() {
    while (!scanner.isDone &&
        (scanner.current == ' ' ||
            scanner.current == '\t' ||
            scanner.current == '\n')) {
      scanner.advanceOne();
    }
  }

  @override
  bool parseListItem({String? untilTag}) {
    final match = scanner.matchGroups(RegExp(r'(\*+)[ \t]+'));
    if (match == null) return false;

    final depth = match.group(1)!.length;
    scanner.advance(match.group(0)!.length);
    renderer.openList(depth);
    parseInline(stopAtBlockBoundary: false, untilTag: untilTag);
    scanner.consumeNewline();
    return true;
  }

  @override
  bool parseTagRequestEmbed() {
    final match = scanner.matchGroups(
      RegExp(r'\[(ta|ti|bur):(\d+)\]', caseSensitive: false),
    );
    if (match == null) return false;

    final type = switch (match.group(1)!.toLowerCase()) {
      'ta' => 'tag-alias',
      'ti' => 'tag-implication',
      _ => 'bulk-update-request',
    };
    final id = match.group(2)!;
    scanner.advance(match.group(0)!.length);

    renderer.closeLeafBlocks();
    renderer.addTagRequestEmbed(type, id);
    scanner.consumeNewline();
    return true;
  }

  @override
  bool parseMediaEmbed() {
    if (!options.enableMediaEmbeds) return false;

    final match = scanner.matchGroups(
      RegExp(
        r'(\* )?!((?:post)|(?:asset)) #(\d+)(?::[ \t]+([^\n]+))?[ \t]*(?:\n|$)',
        caseSensitive: false,
      ),
    );
    if (match == null) return false;

    final type = match.group(2)!.toLowerCase();
    final id = match.group(3)!;
    final caption = match.group(4);
    scanner.advance(match.group(0)!.length);

    renderer.closeLeafBlocks();
    final captionNodes = caption == null || caption.isEmpty
        ? const <DTextNode>[]
        : childParser(caption).parseInlineToNodes();
    renderer.addMediaEmbed(type, id, captionNodes);
    return true;
  }

  @override
  bool isParagraphBreak() {
    if (scanner.current != '\n') return false;

    var index = scanner.offset + 1;
    if (index >= scanner.source.length) return true;

    while (index < scanner.source.length) {
      final char = scanner.source[index];
      if (char == '\n') return true;
      if (char != ' ' && char != '\t') return false;
      index++;
    }

    return true;
  }

  @override
  bool nextLineStartsCloseTag(String? tag) {
    if (tag == null || scanner.current != '\n') return false;

    var index = scanner.offset + 1;
    while (index < scanner.source.length &&
        (scanner.source[index] == ' ' || scanner.source[index] == '\t')) {
      index++;
    }

    final rest = scanner.source.substring(index).toLowerCase();
    return rest.startsWith('[/${tag.toLowerCase()}]') ||
        rest.startsWith('</${tag.toLowerCase()}>');
  }

  @override
  bool nextLineStartsBlock() {
    if (scanner.current != '\n') return false;

    final previousOffset = scanner.offset;
    scanner.offset++;
    while (!scanner.isDone &&
        (scanner.current == ' ' || scanner.current == '\t')) {
      scanner.offset++;
    }
    final startsBlock = isBlockStartForParagraphBoundary();
    scanner.offset = previousOffset;
    return startsBlock;
  }

  @override
  bool isBlockStartForParagraphBoundary() {
    if (startsOpenTag([
      'quote',
      'blockquote',
      'expand',
      'code',
      'table',
      'thead',
      'tbody',
      'tr',
    ])) {
      return true;
    }
    if (startsOpenTag(['spoiler', 'spoilers', 'tn'])) {
      final tag = matchOpenTag(['spoiler', 'spoilers', 'tn']);
      if (tag == null) return false;

      final restOfLine = scanner.source.substring(scanner.offset + tag.length);
      final newline = restOfLine.indexOf('\n');
      final lineTail = newline < 0
          ? restOfLine
          : restOfLine.substring(0, newline);
      return lineTail.trim().isEmpty;
    }

    return scanner.startsWith('```') ||
        scanner.match(RegExp(r'h[1-6](?:#[A-Za-z0-9_/#!:&-]+)?\.\s*')) !=
            null ||
        scanner.match(RegExp(r'\*+[ \t]+')) != null ||
        scanner.match(RegExp(r'[ \t]*(?:\[hr\]|<hr>)', caseSensitive: false)) !=
            null ||
        scanner.match(RegExp(r'\[(?:ta|ti|bur):\d+\]', caseSensitive: false)) !=
            null;
  }
}
