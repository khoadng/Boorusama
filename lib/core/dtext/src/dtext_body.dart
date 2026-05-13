// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:dtext/dtext.dart';
import 'package:flutter_html/flutter_html.dart';

// Project imports:
import '../../themes/theme/types.dart';
import '../../../foundation/html.dart';
import 'dtext_renderer.dart';

class DTextBody extends StatelessWidget {
  const DTextBody({
    required this.data,
    required this.booruUrl,
    super.key,
    this.style,
    this.onLinkTap,
    this.selectable = true,
  });

  final String data;
  final String booruUrl;
  final Map<String, Style>? style;
  final OnTap? onLinkTap;
  final bool selectable;

  @override
  Widget build(BuildContext context) {
    try {
      final document = DText.parseDocument(
        data,
        options: dtextOptionsForBooruUrl(booruUrl),
      );

      return _DTextNodesView(
        nodes: document.children,
        style: style,
        onLinkTap: onLinkTap,
        selectable: selectable,
      );
    } catch (_) {
      return AppHtml(
        data: renderPlainDTextFallback(data),
        style: _dtextHtmlStyle(style),
        onLinkTap: onLinkTap,
        selectable: selectable,
      );
    }
  }
}

class _DTextNodesView extends StatelessWidget {
  const _DTextNodesView({
    required this.nodes,
    required this.style,
    required this.onLinkTap,
    required this.selectable,
  });

  final List<DTextNode> nodes;
  final Map<String, Style>? style;
  final OnTap? onLinkTap;
  final bool selectable;

  @override
  Widget build(BuildContext context) {
    final widgets = <Widget>[];
    final htmlNodes = <DTextNode>[];

    void flushHtml() {
      if (htmlNodes.isEmpty) return;

      widgets.add(
        AppHtml(
          data: DText.renderHtml(
            DTextDocument(children: List.of(htmlNodes)),
          ),
          style: _dtextHtmlStyle(style),
          onLinkTap: onLinkTap,
          selectable: selectable,
        ),
      );
      htmlNodes.clear();
    }

    for (final node in nodes) {
      if (_isQuote(node)) {
        flushHtml();
        widgets.add(
          _DTextQuote(
            node: node as DTextElementNode,
            style: style,
            onLinkTap: onLinkTap,
            selectable: selectable,
          ),
        );
      } else {
        htmlNodes.add(node);
      }
    }

    flushHtml();
    if (widgets.isEmpty) return const SizedBox.shrink();
    if (widgets.length == 1) return widgets.single;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  bool _isQuote(DTextNode node) =>
      node is DTextElementNode && node.element == DTextElement.quote;
}

class _DTextQuote extends StatelessWidget {
  const _DTextQuote({
    required this.node,
    required this.style,
    required this.onLinkTap,
    required this.selectable,
  });

  final DTextElementNode node;
  final Map<String, Style>? style;
  final OnTap? onLinkTap;
  final bool selectable;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        border: Border.all(
          color: colorScheme.hintColor,
        ),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: _DTextNodesView(
        nodes: node.children,
        style: style,
        onLinkTap: onLinkTap,
        selectable: selectable,
      ),
    );
  }
}

Map<String, Style> _dtextHtmlStyle(Map<String, Style>? baseStyle) => {
  ...?baseStyle,
  'body': Style(
    fontSize: FontSize.medium,
    margin: Margins.zero,
    whiteSpace: WhiteSpace.pre,
  ).merge(baseStyle?['body'] ?? Style()),
  'p': Style(
    margin: Margins.zero,
  ).merge(baseStyle?['p'] ?? Style()),
};
