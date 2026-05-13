// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:dtext/dtext.dart';
import 'package:flutter_html/flutter_html.dart';

// Project imports:
import '../../configs/config/types.dart';
import '../../text_markup/types.dart';
import '../../themes/theme/types.dart';
import '../../../foundation/html.dart';
import 'dtext_emoji_renderer.dart';
import 'dtext_html.dart';
import 'dtext_renderer.dart';
import 'dtext_table.dart';

class DTextBody extends StatelessWidget {
  const DTextBody({
    required this.data,
    required this.booruUrl,
    super.key,
    this.emojiMap = const {},
    this.emojiImageConfig,
    this.style,
    this.onLinkTap,
    this.selectable = true,
  });

  final String data;
  final String booruUrl;
  final Map<String, TextEmoji> emojiMap;
  final BooruConfigAuth? emojiImageConfig;
  final Map<String, Style>? style;
  final OnTap? onLinkTap;
  final bool selectable;

  @override
  Widget build(BuildContext context) {
    try {
      final options = dtextOptionsForBooruUrl(booruUrl).copyWith(
        isAllowedEmoji: emojiMap.isEmpty
            ? null
            : (name) => emojiMap.containsKey(name.toLowerCase()),
      );
      final document = DText.parseDocument(
        data,
        options: options,
      );

      return _DTextNodesView(
        nodes: document.children,
        emojiMap: emojiMap,
        emojiSize: dTextEmojiSizeForDocument(document),
        emojiImageConfig: emojiImageConfig,
        style: style,
        onLinkTap: onLinkTap,
        selectable: selectable,
      );
    } catch (_) {
      return AppHtml(
        data: renderPlainDTextFallback(data),
        style: dTextHtmlStyle(style),
        onLinkTap: onLinkTap,
        selectable: selectable,
      );
    }
  }
}

class _DTextNodesView extends StatelessWidget {
  const _DTextNodesView({
    required this.nodes,
    required this.emojiMap,
    required this.emojiSize,
    required this.emojiImageConfig,
    required this.style,
    required this.onLinkTap,
    required this.selectable,
  });

  final List<DTextNode> nodes;
  final Map<String, TextEmoji> emojiMap;
  final double emojiSize;
  final BooruConfigAuth? emojiImageConfig;
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
          data: renderDTextNodesHtml(
            htmlNodes,
            emojiMap: emojiMap,
            emojiSize: emojiSize,
            emojiImageConfig: emojiImageConfig,
          ),
          style: dTextHtmlStyle(style),
          onLinkTap: onLinkTap,
          extensions: [
            if (emojiImageConfig case final config?)
              ...dTextEmojiHtmlExtensions(config),
          ],
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
            emojiMap: emojiMap,
            emojiSize: emojiSize,
            emojiImageConfig: emojiImageConfig,
            style: style,
            onLinkTap: onLinkTap,
            selectable: selectable,
          ),
        );
      } else if (_isTable(node)) {
        flushHtml();
        widgets.add(
          DTextTable(
            node: node as DTextElementNode,
            emojiMap: emojiMap,
            emojiSize: emojiSize,
            emojiImageConfig: emojiImageConfig,
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

  bool _isTable(DTextNode node) =>
      node is DTextElementNode && node.element == DTextElement.table;
}

class _DTextQuote extends StatelessWidget {
  const _DTextQuote({
    required this.node,
    required this.emojiMap,
    required this.emojiSize,
    required this.emojiImageConfig,
    required this.style,
    required this.onLinkTap,
    required this.selectable,
  });

  final DTextElementNode node;
  final Map<String, TextEmoji> emojiMap;
  final double emojiSize;
  final BooruConfigAuth? emojiImageConfig;
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
        emojiMap: emojiMap,
        emojiSize: emojiSize,
        emojiImageConfig: emojiImageConfig,
        style: style,
        onLinkTap: onLinkTap,
        selectable: selectable,
      ),
    );
  }
}
