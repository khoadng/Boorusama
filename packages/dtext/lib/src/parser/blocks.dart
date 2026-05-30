import '../ast.dart';
import '../url_normalizer.dart';

import '../characters.dart';
import 'context.dart';

mixin DTextBlockParser on DTextParserContext {
  @override
  bool parseHeading() {
    final heading = _matchHeading();
    if (heading == null) return false;

    scanner.advance(heading.length);
    final level = heading.level;
    final id = heading.id;
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
    final length = _matchHrLength();
    if (length == null) return false;

    renderer.closeLeafBlocks();
    renderer.addHorizontalRule();
    scanner.advance(length);
    return true;
  }

  @override
  bool parseCodeFence() {
    final fence = _matchCodeFence();
    if (fence == null) return false;

    scanner.advance(fence.length);
    final language = fence.language;
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
    final expand = _matchExpand();
    if (expand == null) return false;

    renderer.closeLeafBlocks();
    scanner.advance(expand.length);
    scanner.consumeNewline();
    renderer.openExpand(expand.title);
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
    final list = _matchListItem();
    if (list == null) return false;

    scanner.advance(list.length);
    renderer.openList(list.depth);
    parseInline(stopAtBlockBoundary: false, untilTag: untilTag);
    scanner.consumeNewline();
    return true;
  }

  @override
  bool parseTagRequestEmbed() {
    final embed = _matchTagRequestEmbed();
    if (embed == null) return false;

    final type = switch (embed.kind) {
      'ta' => 'tag-alias',
      'ti' => 'tag-implication',
      _ => 'bulk-update-request',
    };
    scanner.advance(embed.length);

    renderer.closeLeafBlocks();
    renderer.addTagRequestEmbed(type, embed.id);
    scanner.consumeNewline();
    return true;
  }

  @override
  bool parseMediaEmbed() {
    if (!options.enableMediaEmbeds) return false;

    final media = _matchMediaEmbed();
    if (media == null) return false;

    scanner.advance(media.length);

    renderer.closeLeafBlocks();
    final captionNodes = media.caption == null || media.caption!.isEmpty
        ? const <DTextNode>[]
        : childParser(media.caption!).parseInlineToNodes();
    renderer.addMediaEmbed(
      media.type,
      media.id,
      captionNodes,
      isGalleryItem: media.isGalleryItem,
    );
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

    return scanner.startsWithAt(index, '[/$tag]', caseSensitive: false) ||
        scanner.startsWithAt(index, '</$tag>', caseSensitive: false);
  }

  @override
  bool nextLineStartsBlock() {
    if (scanner.current != '\n') return false;

    final previousOffset = scanner.offset;
    scanner.offset++;
    final startsMediaEmbed = _startsMediaEmbed();
    while (!scanner.isDone &&
        (scanner.current == ' ' || scanner.current == '\t')) {
      scanner.offset++;
    }
    final startsBlock = startsMediaEmbed || isBlockStartForParagraphBoundary();
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

    return _matchCodeFence() != null ||
        _matchHeading() != null ||
        _matchListItem() != null ||
        _matchHrLength() != null ||
        _matchTagRequestEmbed() != null;
  }

  bool _startsMediaEmbed() {
    if (!options.enableMediaEmbeds) return false;

    return _matchMediaEmbed() != null;
  }

  ({int level, String? id, int length})? _matchHeading() {
    final start = scanner.offset;
    if (start + 3 > scanner.source.length ||
        !asciiEqualsIgnoreCase(scanner.source.codeUnitAt(start), asciiLowerH)) {
      return null;
    }

    final levelUnit = scanner.source.codeUnitAt(start + 1);
    if (levelUnit < asciiDigit1 || levelUnit > asciiDigit6) return null;

    var index = start + 2;
    String? id;
    if (index < scanner.source.length && scanner.source[index] == '#') {
      final idStart = index + 1;
      index = idStart;
      while (index < scanner.source.length &&
          _isHeadingIdCodeUnit(scanner.source.codeUnitAt(index))) {
        index++;
      }
      if (index == idStart) return null;
      id = scanner.source.substring(idStart, index);
    }

    if (index >= scanner.source.length || scanner.source[index] != '.') {
      return null;
    }
    index++;

    while (index < scanner.source.length &&
        isSpaceTab(scanner.source.codeUnitAt(index))) {
      index++;
    }

    return (level: levelUnit - asciiDigit0, id: id, length: index - start);
  }

  bool _isHeadingIdCodeUnit(int codeUnit) =>
      isAsciiAlphaNumeric(codeUnit) ||
      codeUnit == underscoreCode ||
      codeUnit == slashCode ||
      codeUnit == hashCodeUnit ||
      codeUnit == exclamationCode ||
      codeUnit == colonCode ||
      codeUnit == ampersandCode ||
      codeUnit == hyphenCode;

  int? _matchHrLength() {
    final start = scanner.offset;
    var index = start;
    while (index < scanner.source.length &&
        isSpaceTab(scanner.source.codeUnitAt(index))) {
      index++;
    }

    if (scanner.startsWithAt(index, '[hr]', caseSensitive: false)) {
      index += 4;
    } else if (scanner.startsWithAt(index, '<hr>', caseSensitive: false)) {
      index += 4;
    } else {
      return null;
    }

    while (index < scanner.source.length &&
        isSpaceTab(scanner.source.codeUnitAt(index))) {
      index++;
    }
    if (index == scanner.source.length) return index - start;
    if (scanner.source.codeUnitAt(index) != lineFeedCode) return null;

    return index + 1 - start;
  }

  ({String language, int length})? _matchCodeFence() {
    if (!scanner.startsWith('```')) return null;

    final start = scanner.offset;
    var index = start + 3;
    while (index < scanner.source.length &&
        isSpaceTab(scanner.source.codeUnitAt(index))) {
      index++;
    }

    final languageStart = index;
    while (index < scanner.source.length &&
        isAsciiAlphaNumeric(scanner.source.codeUnitAt(index))) {
      index++;
    }
    final language = scanner.source.substring(languageStart, index);

    while (index < scanner.source.length &&
        isSpaceTab(scanner.source.codeUnitAt(index))) {
      index++;
    }
    if (index >= scanner.source.length ||
        scanner.source.codeUnitAt(index) != lineFeedCode) {
      return null;
    }

    return (language: language, length: index + 1 - start);
  }

  ({String title, int length})? _matchExpand() {
    final start = scanner.offset;
    final open = scanner.current;
    if (open != '[' && open != '<') return null;
    if (!scanner.startsWithAt(start + 1, 'expand', caseSensitive: false)) {
      return null;
    }

    final close = open == '[' ? ']' : '>';
    var index = start + 7;
    var title = 'Show';
    if (index < scanner.source.length && scanner.source[index] == close) {
      return (title: title, length: index + 1 - start);
    }

    if (index >= scanner.source.length) return null;
    final separator = scanner.source.codeUnitAt(index);
    if (separator == equalsCode) {
      index++;
      while (index < scanner.source.length &&
          isSpaceTab(scanner.source.codeUnitAt(index))) {
        index++;
      }
    } else if (isSpaceTab(separator)) {
      while (index < scanner.source.length &&
          isSpaceTab(scanner.source.codeUnitAt(index))) {
        index++;
      }
    } else {
      return null;
    }

    final titleStart = index;
    while (index < scanner.source.length) {
      final codeUnit = scanner.source.codeUnitAt(index);
      if (codeUnit == lineFeedCode) return null;
      if (scanner.source[index] == close) {
        final parsedTitle = scanner.source.substring(titleStart, index).trim();
        if (parsedTitle.isNotEmpty) title = parsedTitle;
        return (title: title, length: index + 1 - start);
      }
      index++;
    }

    return null;
  }

  ({int depth, int length})? _matchListItem() {
    final start = scanner.offset;
    var index = start;
    while (index < scanner.source.length && scanner.source[index] == '*') {
      index++;
    }
    final starsEnd = index;

    if (index == start ||
        index >= scanner.source.length ||
        !isSpaceTab(scanner.source.codeUnitAt(index))) {
      return null;
    }

    while (index < scanner.source.length &&
        isSpaceTab(scanner.source.codeUnitAt(index))) {
      index++;
    }

    return (depth: starsEnd - start, length: index - start);
  }

  ({String kind, String id, int length})? _matchTagRequestEmbed() {
    final start = scanner.offset;
    if (start + 6 > scanner.source.length || scanner.source[start] != '[') {
      return null;
    }

    final kindStart = start + 1;
    var kindLength = 0;
    if (scanner.startsWithAt(kindStart, 'bur', caseSensitive: false)) {
      kindLength = 3;
    } else if (scanner.startsWithAt(kindStart, 'ta', caseSensitive: false) ||
        scanner.startsWithAt(kindStart, 'ti', caseSensitive: false)) {
      kindLength = 2;
    } else {
      return null;
    }

    var index = kindStart + kindLength;
    if (index >= scanner.source.length || scanner.source[index] != ':') {
      return null;
    }
    index++;

    final idStart = index;
    while (index < scanner.source.length &&
        isAsciiDigit(scanner.source.codeUnitAt(index))) {
      index++;
    }
    if (index == idStart ||
        index >= scanner.source.length ||
        scanner.source[index] != ']') {
      return null;
    }

    return (
      kind: scanner.source
          .substring(kindStart, kindStart + kindLength)
          .toLowerCase(),
      id: scanner.source.substring(idStart, index),
      length: index + 1 - start,
    );
  }

  ({String type, String id, String? caption, bool isGalleryItem, int length})?
  _matchMediaEmbed() {
    final start = scanner.offset;
    var index = start;
    var isGalleryItem = false;
    if (scanner.startsWithAt(index, '* ')) {
      isGalleryItem = true;
      index += 2;
    }

    if (index >= scanner.source.length || scanner.source[index] != '!') {
      return null;
    }
    index++;

    String type;
    if (scanner.startsWithAt(index, 'post')) {
      type = 'post';
      index += 4;
    } else if (scanner.startsWithAt(index, 'asset')) {
      type = 'asset';
      index += 5;
    } else {
      return null;
    }

    if (index + 2 > scanner.source.length ||
        scanner.source[index] != ' ' ||
        scanner.source[index + 1] != '#') {
      return null;
    }
    index += 2;

    final idStart = index;
    while (index < scanner.source.length &&
        isAsciiDigit(scanner.source.codeUnitAt(index))) {
      index++;
    }
    if (index == idStart) return null;
    final id = scanner.source.substring(idStart, index);

    String? caption;
    if (index < scanner.source.length && scanner.source[index] == ':') {
      var captionStart = index + 1;
      if (captionStart >= scanner.source.length ||
          !isSpaceTab(scanner.source.codeUnitAt(captionStart))) {
        return null;
      }
      while (captionStart < scanner.source.length &&
          isSpaceTab(scanner.source.codeUnitAt(captionStart))) {
        captionStart++;
      }
      index = captionStart;
      while (index < scanner.source.length &&
          scanner.source.codeUnitAt(index) != lineFeedCode) {
        index++;
      }
      var captionEnd = index;
      while (captionEnd > captionStart &&
          isSpaceTab(scanner.source.codeUnitAt(captionEnd - 1))) {
        captionEnd--;
      }
      caption = scanner.source.substring(captionStart, captionEnd);
    }

    while (index < scanner.source.length &&
        isSpaceTab(scanner.source.codeUnitAt(index))) {
      index++;
    }
    if (index < scanner.source.length) {
      if (scanner.source.codeUnitAt(index) != lineFeedCode) return null;
      index++;
    }

    return (
      type: type,
      id: id,
      caption: caption,
      isGalleryItem: isGalleryItem,
      length: index - start,
    );
  }
}
