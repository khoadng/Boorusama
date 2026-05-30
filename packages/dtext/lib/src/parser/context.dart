import '../ast.dart';
import '../document_builder.dart';
import '../options.dart';
import '../scanner.dart';

abstract class DTextParserContext {
  DTextOptions get options;
  SourceScanner get scanner;
  DTextDocumentBuilder get renderer;
  Set<String> get wikiPages;
  List<String> get containerTags;

  DTextParserContext childParser(String input);

  void parseBlocks({String? untilTag});
  bool parseBlock({String? untilTag});
  void parseParagraph({String? untilTag});
  void parseInline({required bool stopAtBlockBoundary, String? untilTag});

  bool parseHeading();
  bool parseHr();
  bool parseCodeFence();
  bool parseBlockCode();
  bool parseQuote();
  bool parseSpoilerBlock();
  bool parseExpand();
  bool parseTnBlock();
  bool parseTable();
  bool parseTableTag(String dtextTag, DTextElement element, String htmlTag);
  bool parseListItem({String? untilTag});
  bool parseTagRequestEmbed();
  bool parseMediaEmbed();
  bool isParagraphBreak();
  bool nextLineStartsCloseTag(String? tag);
  bool nextLineStartsBlock();
  bool isBlockStartForParagraphBoundary();

  bool parseEntity();
  bool parseInlineTag();
  bool parseInlineCloseForContainer(String tag);
  bool parseInlineCode();
  bool parseNodtext();
  bool parseMention();
  bool parseEmoji();
  List<DTextNode> parseInlineToNodes();
  List<DTextNode> parseBasicInlineToNodes();
  void writeMention(String name);
  bool isMentionBoundary(int offset);

  bool parseWikiLink();
  bool parsePostSearchLink();
  bool parseNamedLink();
  bool parseHtmlLink();
  bool parseBbcodeLink();
  bool parseIdLink();
  bool parseRawUrl();
  bool parseDelimitedUrl();
  void writeNamedUrl(String url, String title);
  void writeUnnamedUrl(String url);
  bool writeInternalShortLink(String url);
  void writeIdLink(String title, String className, String url, String id);
  void writePagedLink(
    String titlePrefix,
    String id,
    String url,
    String pageSeparator,
    String page,
    String className,
  );
  bool isUrlLike(String value);
  bool isUrlBoundary(int offset);
  int? wikiAnchorIndex(String value);

  String? matchOpenTag(List<String> names);
  ({String lexeme, String? language})? matchOpenCodeTag();
  String? matchCloseTag(List<String> names);
  bool startsOpenTag(List<String> names);
  bool startsCloseTag(String name);
  bool startsAncestorClose(String? currentTag);
  bool consumeCloseTag(String name);
}
