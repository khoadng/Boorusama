import '../ast.dart';
import '../document_builder.dart';
import '../html_document_renderer.dart';
import '../options.dart';
import '../scanner.dart';

import 'blocks.dart';
import 'context.dart';
import 'inline.dart';
import 'links.dart';
import 'tags.dart';

class DText {
  static String parse(
    String? input, {
    DTextOptions options = const DTextOptions(),
  }) => renderHtml(parseDocument(input, options: options));

  static DTextDocument parseDocument(
    String? input, {
    DTextOptions options = const DTextOptions(),
  }) {
    if (input == null) {
      return const DTextDocument(children: []);
    }

    final parser = DTextParser(input, options);
    return parser.parseDocument();
  }

  static String renderHtml(
    DTextDocument document, {
    DTextEmojiHtmlBuilder? emojiHtmlBuilder,
  }) => DTextHtmlDocumentRenderer(
    emojiHtmlBuilder: emojiHtmlBuilder,
  ).render(document);

  static DTextParseResult parseWithResult(
    String? input, {
    DTextOptions options = const DTextOptions(),
  }) {
    final document = parseDocument(input, options: options);
    return DTextParseResult(
      document: document,
      html: renderHtml(document),
      wikiPages: document.wikiPages,
    );
  }
}

class DTextParser extends DTextParserContext
    with DTextTagMatcher, DTextInlineParser, DTextLinkParser, DTextBlockParser {
  DTextParser(String input, this.options)
    : scanner = SourceScanner(input),
      renderer = DTextDocumentBuilder(options);

  @override
  final DTextOptions options;
  @override
  final SourceScanner scanner;
  @override
  final DTextDocumentBuilder renderer;
  @override
  final wikiPages = <String>{};
  @override
  final containerTags = <String>[];

  @override
  DTextParser childParser(String input) => DTextParser(input, options);

  DTextDocument parseDocument() {
    parseBlocks();
    renderer.closeAll();

    return renderer.document(wikiPages);
  }

  @override
  void parseBlocks({String? untilTag}) {
    if (untilTag != null) containerTags.add(untilTag);
    try {
      while (!scanner.isDone) {
        if (untilTag != null && consumeCloseTag(untilTag)) return;
        if (startsAncestorClose(untilTag)) return;

        if (scanner.isBlankLineAtOffset()) {
          renderer.closeLeafBlocks();
          renderer.closeLists();
          scanner.consumeBlankLines();
          continue;
        }

        if (parseBlock(untilTag: untilTag)) continue;

        parseParagraph(untilTag: untilTag);
      }
    } finally {
      if (untilTag != null) containerTags.removeLast();
    }
  }

  @override
  bool parseBlock({String? untilTag}) {
    if (parseHeading()) return true;
    if (parseHr()) return true;
    if (parseCodeFence()) return true;
    if (parseBlockCode()) return true;
    if (parseQuote()) return true;
    if (parseSpoilerBlock()) return true;
    if (parseExpand()) return true;
    if (parseTnBlock()) return true;
    if (parseTable()) return true;
    if (parseTagRequestEmbed()) return true;
    if (parseMediaEmbed()) return true;
    if (parseListItem(untilTag: untilTag)) return true;

    return false;
  }

  @override
  void parseParagraph({String? untilTag}) {
    renderer.closeLists();
    renderer.openParagraph();

    var wrote = false;
    while (!scanner.isDone) {
      if (untilTag != null && startsCloseTag(untilTag)) break;
      if (startsAncestorClose(untilTag)) break;
      if (scanner.current == '\n') {
        if (isParagraphBreak() ||
            nextLineStartsCloseTag(untilTag) ||
            nextLineStartsBlock()) {
          break;
        }

        scanner.advanceOne();
        renderer.addLineBreak();
        wrote = true;
        continue;
      }
      if (scanner.isAtLineStart && scanner.isBlankLineAtOffset()) break;
      if (wrote &&
          scanner.isAtLineStart &&
          isBlockStartForParagraphBoundary()) {
        break;
      }

      parseInline(stopAtBlockBoundary: true, untilTag: untilTag);
      wrote = true;
    }

    renderer.close(DTextElement.paragraph);
  }

  @override
  void parseInline({
    required bool stopAtBlockBoundary,
    String? untilTag,
  }) {
    while (!scanner.isDone) {
      if (untilTag != null && startsCloseTag(untilTag)) {
        if (parseInlineCloseForContainer(untilTag)) continue;

        return;
      }
      if (startsAncestorClose(untilTag)) return;
      if (stopAtBlockBoundary &&
          scanner.isAtLineStart &&
          scanner.isBlankLineAtOffset()) {
        return;
      }
      if (scanner.current == '\n') return;

      if (parseEntity()) continue;
      if (parseNodtext()) continue;
      if (parseInlineTag()) continue;
      if (parseInlineCode()) continue;
      if (parseWikiLink()) continue;
      if (parsePostSearchLink()) continue;
      if (parseHtmlLink()) continue;
      if (parseBbcodeLink()) continue;
      if (parseNamedLink()) continue;
      if (parseIdLink()) continue;
      if (parseDelimitedUrl()) continue;
      if (parseRawUrl()) continue;
      if (parseMention()) continue;
      if (parseEmoji()) continue;

      renderer.writeCharEscaped(scanner.advanceOne().codeUnitAt(0));
    }
  }
}
