import 'ast.dart';

class DTextHtmlDocumentRenderer {
  const DTextHtmlDocumentRenderer();

  String render(DTextDocument document) => renderNodes(document.children);

  String renderNodes(Iterable<DTextNode> nodes) {
    final buffer = StringBuffer();
    for (final node in nodes) {
      buffer.write(renderNode(node));
    }

    return buffer.toString();
  }

  String renderNode(DTextNode node) => switch (node) {
    DTextText(:final text) => _escapeText(text),
    DTextLineBreak() => '<br>',
    DTextHorizontalRule() => '<hr>',
    DTextCodeBlock(:final code, :final language) =>
      '<pre${_languageClass(language)}>${_escapeText(code)}</pre>',
    DTextElementNode(:final element, :final attributes, :final children) =>
      _renderElement(element, attributes, children),
    DTextExpand(:final title, :final children) =>
      '<details><summary>${_escapeText(title)}</summary><div>${renderNodes(children)}</div></details>',
    DTextLink(
      :final href,
      :final children,
      :final classes,
      :final rel,
      :final attributes,
    ) =>
      _renderLink(
        href: href,
        children: children,
        classes: classes,
        rel: rel,
        attributes: attributes,
      ),
    DTextTagRequestEmbed(:final type, :final id) =>
      '<tag-request-embed data-type="${_escapeAttribute(type)}" data-id="${_escapeAttribute(id)}"></tag-request-embed>',
    DTextMediaEmbed(:final type, :final id, :final caption) =>
      '<media-embed data-type="${_escapeAttribute(type)}" data-id="${_escapeAttribute(id)}">${renderNodes(caption)}</media-embed>',
    DTextEmoji(:final name) =>
      '<emoji data-name="${_uriEscape(name)}" data-mode="inline"></emoji>',
  };

  String _renderElement(
    DTextElement element,
    Map<String, String> attributes,
    List<DTextNode> children,
  ) {
    final (tag, defaultAttributes) = switch (element) {
      DTextElement.paragraph => ('p', const <String, String>{}),
      DTextElement.quote => ('blockquote', const <String, String>{}),
      DTextElement.spoilerBlock => (
        'div',
        const <String, String>{'class': 'spoiler'},
      ),
      DTextElement.unorderedList => ('ul', const <String, String>{}),
      DTextElement.listItem => ('li', const <String, String>{}),
      DTextElement.heading1 => ('h1', const <String, String>{}),
      DTextElement.heading2 => ('h2', const <String, String>{}),
      DTextElement.heading3 => ('h3', const <String, String>{}),
      DTextElement.heading4 => ('h4', const <String, String>{}),
      DTextElement.heading5 => ('h5', const <String, String>{}),
      DTextElement.heading6 => ('h6', const <String, String>{}),
      DTextElement.table => (
        'table',
        const <String, String>{'class': 'striped'},
      ),
      DTextElement.tableRow => ('tr', const <String, String>{}),
      DTextElement.tableHeader => ('th', const <String, String>{}),
      DTextElement.tableCell => ('td', const <String, String>{}),
      DTextElement.inlineBold => ('strong', const <String, String>{}),
      DTextElement.inlineItalic => ('em', const <String, String>{}),
      DTextElement.inlineUnderline => ('u', const <String, String>{}),
      DTextElement.inlineStrike => ('s', const <String, String>{}),
      DTextElement.inlineSpoiler => (
        'span',
        const <String, String>{'class': 'spoiler'},
      ),
      DTextElement.inlineCode => ('code', const <String, String>{}),
      DTextElement.inlineTn => (
        'span',
        const <String, String>{'class': 'tn'},
      ),
      DTextElement.expand => ('div', const <String, String>{}),
    };
    final mergedAttributes = {...defaultAttributes, ...attributes};

    return '<$tag${_renderAttributes(mergedAttributes)}>${renderNodes(children)}</$tag>';
  }

  String _renderLink({
    required String href,
    required List<DTextNode> children,
    required List<String> classes,
    required String? rel,
    required Map<String, String> attributes,
  }) {
    final buffer = StringBuffer('<a');
    if (rel != null && rel.isNotEmpty) {
      buffer.write(' rel="${_escapeAttribute(rel)}"');
    }
    if (classes.isNotEmpty) {
      buffer.write(' class="${_escapeAttribute(classes.join(' '))}"');
    }
    for (final entry in attributes.entries) {
      buffer.write(
        ' ${entry.key}="${_escapeAttribute(entry.value)}"',
      );
    }
    buffer
      ..write(' href="${_escapeAttribute(href)}">')
      ..write(renderNodes(children))
      ..write('</a>');

    return buffer.toString();
  }

  String _renderAttributes(Map<String, String> attributes) {
    if (attributes.isEmpty) return '';

    final buffer = StringBuffer();
    for (final entry in attributes.entries) {
      buffer.write(' ${entry.key}="${_escapeAttribute(entry.value)}"');
    }

    return buffer.toString();
  }

  String _languageClass(String? language) {
    if (language == null || language.isEmpty) return '';

    return ' class="language-${_escapeAttribute(language)}"';
  }

  String _escapeText(String value) => value
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;');

  String _escapeAttribute(String value) => _escapeText(value);

  String _uriEscape(String value) => Uri.encodeComponent(value).replaceAll(
    RegExp('%7E', caseSensitive: false),
    '~',
  );
}
