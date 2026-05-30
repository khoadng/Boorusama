sealed class DTextNode {
  const DTextNode();
}

class DTextDocument {
  const DTextDocument({
    required this.children,
    this.wikiPages = const {},
  });

  final List<DTextNode> children;
  final Set<String> wikiPages;
}

class DTextText extends DTextNode {
  const DTextText(this.text);

  final String text;
}

class DTextLineBreak extends DTextNode {
  const DTextLineBreak();
}

class DTextHorizontalRule extends DTextNode {
  const DTextHorizontalRule();
}

class DTextCodeBlock extends DTextNode {
  const DTextCodeBlock(this.code, {this.language});

  final String code;
  final String? language;
}

enum DTextElement {
  paragraph,
  quote,
  spoilerBlock,
  expand,
  unorderedList,
  listItem,
  heading1,
  heading2,
  heading3,
  heading4,
  heading5,
  heading6,
  table,
  tableHead,
  tableBody,
  tableRow,
  tableHeader,
  tableCell,
  inlineBold,
  inlineItalic,
  inlineUnderline,
  inlineStrike,
  inlineSpoiler,
  inlineCode,
  inlineTn,
}

class DTextElementNode extends DTextNode {
  const DTextElementNode({
    required this.element,
    required this.children,
    this.attributes = const {},
  });

  final DTextElement element;
  final List<DTextNode> children;
  final Map<String, String> attributes;
}

class DTextExpand extends DTextNode {
  const DTextExpand({
    required this.title,
    required this.children,
  });

  final String title;
  final List<DTextNode> children;
}

enum DTextLinkKind {
  generic,
  wiki,
  postSearch,
  id,
  userMention,
}

class DTextLink extends DTextNode {
  const DTextLink({
    required this.href,
    required this.children,
    required this.classes,
    this.kind = DTextLinkKind.generic,
    this.rel,
    this.attributes = const {},
  });

  final String href;
  final List<DTextNode> children;
  final List<String> classes;
  final DTextLinkKind kind;
  final String? rel;
  final Map<String, String> attributes;
}

class DTextTagRequestEmbed extends DTextNode {
  const DTextTagRequestEmbed({
    required this.type,
    required this.id,
  });

  final String type;
  final String id;
}

class DTextMediaEmbed extends DTextNode {
  const DTextMediaEmbed({
    required this.type,
    required this.id,
    required this.caption,
    this.isGalleryItem = false,
  });

  final String type;
  final String id;
  final List<DTextNode> caption;
  final bool isGalleryItem;
}

class DTextEmoji extends DTextNode {
  const DTextEmoji(this.name);

  final String name;
}
