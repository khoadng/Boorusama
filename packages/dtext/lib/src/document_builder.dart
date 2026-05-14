import 'dart:convert';

import 'ast.dart';
import 'characters.dart';
import 'options.dart';

class DTextDocumentBuilder {
  DTextDocumentBuilder(this.options);

  final DTextOptions options;

  final _root = <DTextNode>[];
  final _stack = <_DTextStackFrame>[];

  bool get hasOpenParagraph => isOpen(DTextElement.paragraph);

  List<DTextNode> get nodes => List.unmodifiable(_root);

  DTextDocument document(Set<String> wikiPages) => DTextDocument(
    children: nodes,
    wikiPages: Set.unmodifiable(wikiPages),
  );

  void write(String value) => _writeText(value);

  void writeEntity(String value) {
    _writeText(switch (value) {
      '&amp;' => '&',
      '&lt;' => '<',
      '&gt;' => '>',
      '&quot;' => '"',
      _ => value,
    });
  }

  void writeEscaped(String value) => _writeText(value);

  void writeCharEscaped(int codeUnit) {
    _writeText(String.fromCharCode(codeUnit));
  }

  void writeBlock(String value) {
    if (!options.inline) _writeText(value);
  }

  void writeBlockEscaped(String value) {
    if (!options.inline) _writeText(value);
  }

  void addLineBreak() {
    _append(const DTextLineBreak());
  }

  void addHorizontalRule() {
    if (!options.inline) _append(const DTextHorizontalRule());
  }

  void addCodeBlock(String code, {String? language}) {
    if (!options.inline) {
      _append(DTextCodeBlock(code, language: language));
    }
  }

  void addTagRequestEmbed(String type, String id) {
    if (!options.inline) {
      _append(DTextTagRequestEmbed(type: type, id: id));
    }
  }

  void addMediaEmbed(
    String type,
    String id,
    List<DTextNode> caption, {
    bool isGalleryItem = false,
  }) {
    if (!options.inline) {
      _append(
        DTextMediaEmbed(
          type: type,
          id: id,
          caption: caption,
          isGalleryItem: isGalleryItem,
        ),
      );
    }
  }

  void addEmoji(String name) {
    _append(DTextEmoji(name.toLowerCase()));
  }

  void addLink({
    required String href,
    required List<DTextNode> children,
    required List<String> classes,
    DTextLinkKind kind = DTextLinkKind.generic,
    String? rel,
    Map<String, String> attributes = const {},
  }) {
    _append(
      DTextLink(
        href: href,
        children: List.unmodifiable(children),
        classes: List.unmodifiable(classes),
        kind: kind,
        rel: rel,
        attributes: Map.unmodifiable(attributes),
      ),
    );
  }

  void open(DTextElement element, [String? legacyHtml]) {
    if (options.inline && !_isInline(element)) return;

    final attributes = _attributesFor(element, legacyHtml);
    final children = <DTextNode>[];
    final node = DTextElementNode(
      element: element,
      children: children,
      attributes: attributes,
    );

    _append(node);
    _stack.add(_DTextStackFrame(element, children));
  }

  void openHeading(int level, {String? id}) {
    final element = switch (level) {
      1 => DTextElement.heading1,
      2 => DTextElement.heading2,
      3 => DTextElement.heading3,
      4 => DTextElement.heading4,
      5 => DTextElement.heading5,
      _ => DTextElement.heading6,
    };

    open(
      element,
      id == null ? null : '<h$level id="$id">',
    );
  }

  void openInlineCode({String? language}) {
    open(
      DTextElement.inlineCode,
      language == null ? null : '<code class="language-$language">',
    );
  }

  void openExpand(String title) {
    if (options.inline) return;

    final children = <DTextNode>[];
    _append(DTextExpand(title: title, children: children));
    _stack.add(_DTextStackFrame.expand(children));
  }

  void close(DTextElement element) {
    if (_stack.isEmpty) return;

    final index = _stack.lastIndexWhere((frame) => frame.element == element);
    if (index < 0) return;

    while (_stack.length > index) {
      rewind();
    }
  }

  void rewind() {
    if (_stack.isEmpty) return;

    _stack.removeLast();
  }

  void closeLeafBlocks() {
    while (_stack.isNotEmpty &&
        !isTop(DTextElement.quote) &&
        !isTop(DTextElement.spoilerBlock) &&
        !isTop(_DTextStackFrame.expandElement)) {
      rewind();
    }
  }

  void closeAll() {
    while (_stack.isNotEmpty) {
      rewind();
    }
  }

  bool isOpen(DTextElement element) =>
      _stack.any((frame) => frame.element == element);

  bool isTop(DTextElement element) =>
      _stack.isNotEmpty && _stack.last.element == element;

  int count(DTextElement element) =>
      _stack.where((entry) => entry.element == element).length;

  void openParagraph({String? className}) {
    if (!hasOpenParagraph) {
      open(
        DTextElement.paragraph,
        className == null ? null : '<p class="$className">',
      );
    }
  }

  void openList(int depth) {
    if (isOpen(DTextElement.listItem)) {
      close(DTextElement.listItem);
    } else {
      closeLeafBlocks();
    }

    while (count(DTextElement.unorderedList) < depth) {
      open(DTextElement.unorderedList);
    }

    while (count(DTextElement.unorderedList) > depth) {
      close(DTextElement.unorderedList);
    }

    open(DTextElement.listItem);
  }

  void closeLists() {
    while (isOpen(DTextElement.unorderedList)) {
      close(DTextElement.unorderedList);
    }
  }

  String relativeUrl(String value) {
    final baseUrl = options.baseUrl;
    if (baseUrl != null &&
        baseUrl.isNotEmpty &&
        (value.startsWith('/') || value.startsWith('#'))) {
      return '$baseUrl$value';
    }

    return value;
  }

  String uriEscape(String value) {
    const hex = '0123456789ABCDEF';
    final buffer = StringBuffer();

    for (final byte in utf8.encode(value)) {
      final isUnreserved =
          isAsciiAlphaNumeric(byte) ||
          byte == hyphenCode ||
          byte == underscoreCode ||
          byte == periodCode ||
          byte == tildeCode;

      if (isUnreserved) {
        buffer.writeCharCode(byte);
      } else {
        buffer
          ..write('%')
          ..write(hex[byte >> 4])
          ..write(hex[byte & hexLowNibbleMask]);
      }
    }

    return buffer.toString();
  }

  void _append(DTextNode node) {
    final target = _stack.isEmpty ? _root : _stack.last.children;
    if (node case DTextText(:final text)) {
      if (text.isEmpty) return;
      if (target.isNotEmpty) {
        final previous = target.last;
        if (previous case DTextText(text: final previousText)) {
          target[target.length - 1] = DTextText('$previousText$text');
          return;
        }
      }
    }

    target.add(node);
  }

  void _writeText(String value) {
    if (value.isEmpty) return;
    _append(DTextText(value));
  }

  Map<String, String> _attributesFor(
    DTextElement element,
    String? legacyHtml,
  ) {
    final attributes = <String, String>{};

    switch (element) {
      case DTextElement.spoilerBlock || DTextElement.inlineSpoiler:
        attributes['class'] = 'spoiler';
      case DTextElement.table:
        attributes['class'] = 'striped';
      case DTextElement.inlineTn:
        attributes['class'] = 'tn';
      case DTextElement.paragraph:
        if (legacyHtml == '<p class="tn">') attributes['class'] = 'tn';
      case DTextElement.inlineCode:
        final language = _extractClassLanguage(legacyHtml);
        if (language != null) attributes['class'] = 'language-$language';
      case DTextElement.heading1 ||
          DTextElement.heading2 ||
          DTextElement.heading3 ||
          DTextElement.heading4 ||
          DTextElement.heading5 ||
          DTextElement.heading6:
        final id = _extractId(legacyHtml);
        if (id != null) attributes['id'] = id;
      case DTextElement.quote ||
          DTextElement.expand ||
          DTextElement.unorderedList ||
          DTextElement.listItem ||
          DTextElement.tableHead ||
          DTextElement.tableBody ||
          DTextElement.tableRow ||
          DTextElement.tableHeader ||
          DTextElement.tableCell ||
          DTextElement.inlineBold ||
          DTextElement.inlineItalic ||
          DTextElement.inlineUnderline ||
          DTextElement.inlineStrike:
        break;
    }

    return Map.unmodifiable(attributes);
  }

  String? _extractClassLanguage(String? html) {
    if (html == null) return null;
    final className = _extractQuotedAttribute(html, 'class');
    const prefix = 'language-';
    if (className == null || !className.startsWith(prefix)) return null;

    return className.substring(prefix.length);
  }

  String? _extractId(String? html) {
    if (html == null) return null;
    return _extractQuotedAttribute(html, 'id');
  }

  String? _extractQuotedAttribute(String html, String name) {
    var index = 0;
    while (index < html.length) {
      final found = html.indexOf(name, index);
      if (found < 0) return null;
      final before = found == 0 ? spaceCode : html.codeUnitAt(found - 1);
      final afterIndex = found + name.length;
      final after = afterIndex >= html.length
          ? spaceCode
          : html.codeUnitAt(afterIndex);
      if (!_isAttributeBoundary(before) || after != equalsCode) {
        index = found + 1;
        continue;
      }

      final valueStart = afterIndex + 1;
      if (valueStart >= html.length ||
          html.codeUnitAt(valueStart) != doubleQuoteCode) {
        index = found + 1;
        continue;
      }

      final valueEnd = html.indexOf('"', valueStart + 1);
      if (valueEnd < 0) return null;

      return html.substring(valueStart + 1, valueEnd);
    }

    return null;
  }

  bool _isAttributeBoundary(int codeUnit) =>
      codeUnit == spaceCode ||
      codeUnit == horizontalTabCode ||
      codeUnit == lineFeedCode ||
      codeUnit == lessThanCode;

  bool _isInline(DTextElement element) => switch (element) {
    DTextElement.inlineBold ||
    DTextElement.inlineItalic ||
    DTextElement.inlineUnderline ||
    DTextElement.inlineStrike ||
    DTextElement.inlineSpoiler ||
    DTextElement.inlineCode ||
    DTextElement.inlineTn => true,
    _ => false,
  };
}

class _DTextStackFrame {
  const _DTextStackFrame(this.element, this.children);

  const _DTextStackFrame.expand(this.children) : element = expandElement;

  static const expandElement = DTextElement.expand;

  final DTextElement element;
  final List<DTextNode> children;
}
