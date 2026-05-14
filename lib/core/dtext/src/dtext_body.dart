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
import 'dtext_media_embed.dart';
import 'dtext_renderer.dart';
import 'dtext_table.dart';

class DTextBody extends StatelessWidget {
  const DTextBody({
    required this.data,
    required this.booruUrl,
    super.key,
    this.emojiMap = const {},
    this.mediaEmbedMap = const {},
    this.imageConfig,
    this.style,
    this.onLinkTap,
    this.selectable = true,
  });

  final String data;
  final String booruUrl;
  final Map<String, TextEmoji> emojiMap;
  final Map<TextMediaEmbedRef, TextMediaEmbed> mediaEmbedMap;
  final BooruConfigAuth? imageConfig;
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

      final renderContext = _DTextRenderContext.fromDocument(
        document,
        emojiMap: emojiMap,
        mediaEmbedMap: mediaEmbedMap,
        imageConfig: imageConfig,
        style: style,
        onLinkTap: onLinkTap,
        selectable: selectable,
      );

      return _DTextNodesView(
        nodes: document.children,
        renderContext: renderContext,
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

class DTextSliverBody extends StatelessWidget {
  const DTextSliverBody({
    required this.data,
    required this.booruUrl,
    super.key,
    this.emojiMap = const {},
    this.mediaEmbedMap = const {},
    this.imageConfig,
    this.style,
    this.onLinkTap,
    this.selectable = true,
  });

  final String data;
  final String booruUrl;
  final Map<String, TextEmoji> emojiMap;
  final Map<TextMediaEmbedRef, TextMediaEmbed> mediaEmbedMap;
  final BooruConfigAuth? imageConfig;
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
      final segments = _DTextSegments.fromNodes(document.children);

      if (segments.isEmpty) return const SliverToBoxAdapter();

      final renderContext = _DTextRenderContext.fromDocument(
        document,
        emojiMap: emojiMap,
        mediaEmbedMap: mediaEmbedMap,
        imageConfig: imageConfig,
        style: style,
        onLinkTap: onLinkTap,
        selectable: selectable,
      );

      return SliverList.builder(
        itemCount: segments.length,
        itemBuilder: (context, index) => segments[index].build(renderContext),
      );
    } catch (_) {
      return SliverToBoxAdapter(
        child: AppHtml(
          data: renderPlainDTextFallback(data),
          style: dTextHtmlStyle(style),
          onLinkTap: onLinkTap,
          selectable: selectable,
        ),
      );
    }
  }
}

class _DTextNodesView extends StatelessWidget {
  const _DTextNodesView({
    required this.nodes,
    required this.renderContext,
  });

  final List<DTextNode> nodes;
  final _DTextRenderContext renderContext;

  @override
  Widget build(BuildContext context) {
    final widgets = <Widget>[];
    final htmlNodes = <DTextNode>[];
    final galleryNodes = <DTextMediaEmbed>[];

    void flushHtml() {
      if (htmlNodes.isEmpty) return;

      widgets.add(
        AppHtml(
          data: renderDTextNodesHtml(
            htmlNodes,
            emojiMap: renderContext.emojiMap,
            emojiSize: renderContext.emojiSize,
            emojiImageConfig: renderContext.imageConfig,
          ),
          style: dTextHtmlStyle(renderContext.style),
          onLinkTap: renderContext.onLinkTap,
          extensions: [
            if (renderContext.imageConfig case final config?)
              ...dTextEmojiHtmlExtensions(config),
          ],
          selectable: renderContext.selectable,
        ),
      );
      htmlNodes.clear();
    }

    void flushGallery() {
      if (galleryNodes.isEmpty) return;

      widgets.add(
        DTextMediaEmbedGallery(
          nodes: List.unmodifiable(galleryNodes),
          mediaEmbedMap: renderContext.mediaEmbedMap,
          imageConfig: renderContext.imageConfig,
          emojiMap: renderContext.emojiMap,
          emojiSize: renderContext.emojiSize,
          style: renderContext.style,
          onLinkTap: renderContext.onLinkTap,
          selectable: renderContext.selectable,
        ),
      );
      galleryNodes.clear();
    }

    for (final node in nodes) {
      if (_isQuote(node)) {
        flushHtml();
        flushGallery();
        widgets.add(
          _DTextQuote(
            node: node as DTextElementNode,
            renderContext: renderContext,
          ),
        );
      } else if (_isTable(node)) {
        flushHtml();
        flushGallery();
        widgets.add(
          DTextTable(
            node: node as DTextElementNode,
            emojiMap: renderContext.emojiMap,
            emojiSize: renderContext.emojiSize,
            emojiImageConfig: renderContext.imageConfig,
            style: renderContext.style,
            onLinkTap: renderContext.onLinkTap,
            selectable: renderContext.selectable,
          ),
        );
      } else if (node is DTextMediaEmbed) {
        flushHtml();
        if (node.isGalleryItem) {
          galleryNodes.add(node);
          continue;
        }

        flushGallery();
        widgets.add(
          DTextMediaEmbedView(
            node: node,
            mediaEmbedMap: renderContext.mediaEmbedMap,
            imageConfig: renderContext.imageConfig,
            emojiMap: renderContext.emojiMap,
            emojiSize: renderContext.emojiSize,
            style: renderContext.style,
            onLinkTap: renderContext.onLinkTap,
            selectable: renderContext.selectable,
          ),
        );
      } else {
        flushGallery();
        htmlNodes.add(node);
      }
    }

    flushHtml();
    flushGallery();
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

class _DTextRenderContext {
  const _DTextRenderContext({
    required this.emojiMap,
    required this.emojiSize,
    required this.mediaEmbedMap,
    required this.imageConfig,
    required this.style,
    required this.onLinkTap,
    required this.selectable,
  });

  factory _DTextRenderContext.fromDocument(
    DTextDocument document, {
    required Map<String, TextEmoji> emojiMap,
    required Map<TextMediaEmbedRef, TextMediaEmbed> mediaEmbedMap,
    required BooruConfigAuth? imageConfig,
    required Map<String, Style>? style,
    required OnTap? onLinkTap,
    required bool selectable,
  }) {
    return _DTextRenderContext(
      emojiMap: emojiMap,
      emojiSize: dTextEmojiSizeForDocument(document),
      mediaEmbedMap: mediaEmbedMap,
      imageConfig: imageConfig,
      style: style,
      onLinkTap: onLinkTap,
      selectable: selectable,
    );
  }

  final Map<String, TextEmoji> emojiMap;
  final double emojiSize;
  final Map<TextMediaEmbedRef, TextMediaEmbed> mediaEmbedMap;
  final BooruConfigAuth? imageConfig;
  final Map<String, Style>? style;
  final OnTap? onLinkTap;
  final bool selectable;
}

sealed class _DTextSegment {
  const _DTextSegment();

  Widget build(_DTextRenderContext context);
}

class _DTextHtmlSegment extends _DTextSegment {
  const _DTextHtmlSegment(this.nodes);

  final List<DTextNode> nodes;

  @override
  Widget build(_DTextRenderContext context) {
    final child = AppHtml(
      data: renderDTextNodesHtml(
        nodes,
        emojiMap: context.emojiMap,
        emojiSize: context.emojiSize,
        emojiImageConfig: context.imageConfig,
      ),
      style: dTextHtmlStyle(context.style),
      onLinkTap: context.onLinkTap,
      extensions: [
        if (context.imageConfig case final config?)
          ...dTextEmojiHtmlExtensions(config),
      ],
      selectable: context.selectable,
    );

    return context.selectable ? child : ExcludeSemantics(child: child);
  }
}

class _DTextQuoteSegment extends _DTextSegment {
  const _DTextQuoteSegment(this.node);

  final DTextElementNode node;

  @override
  Widget build(_DTextRenderContext context) {
    return _DTextQuote(
      node: node,
      renderContext: context,
    );
  }
}

class _DTextTableSegment extends _DTextSegment {
  const _DTextTableSegment(this.node);

  final DTextElementNode node;

  @override
  Widget build(_DTextRenderContext context) {
    return DTextTable(
      node: node,
      emojiMap: context.emojiMap,
      emojiSize: context.emojiSize,
      emojiImageConfig: context.imageConfig,
      style: context.style,
      onLinkTap: context.onLinkTap,
      selectable: context.selectable,
    );
  }
}

class _DTextMediaSegment extends _DTextSegment {
  const _DTextMediaSegment(this.node);

  final DTextMediaEmbed node;

  @override
  Widget build(_DTextRenderContext context) {
    return DTextMediaEmbedView(
      node: node,
      mediaEmbedMap: context.mediaEmbedMap,
      imageConfig: context.imageConfig,
      emojiMap: context.emojiMap,
      emojiSize: context.emojiSize,
      style: context.style,
      onLinkTap: context.onLinkTap,
      selectable: context.selectable,
    );
  }
}

class _DTextExpandSegment extends _DTextSegment {
  const _DTextExpandSegment(this.node);

  final DTextExpand node;

  @override
  Widget build(_DTextRenderContext context) {
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      childrenPadding: EdgeInsets.zero,
      title: Text(node.title),
      children: [
        _DTextNodesView(
          nodes: node.children,
          renderContext: context,
        ),
      ],
    );
  }
}

class _DTextGallerySegment extends _DTextSegment {
  const _DTextGallerySegment(this.nodes);

  final List<DTextMediaEmbed> nodes;

  @override
  Widget build(_DTextRenderContext context) {
    return DTextMediaEmbedGallery(
      nodes: nodes,
      mediaEmbedMap: context.mediaEmbedMap,
      imageConfig: context.imageConfig,
      emojiMap: context.emojiMap,
      emojiSize: context.emojiSize,
      style: context.style,
      onLinkTap: context.onLinkTap,
      selectable: context.selectable,
    );
  }
}

class _DTextSegments {
  static List<_DTextSegment> fromNodes(List<DTextNode> nodes) {
    final segments = <_DTextSegment>[];
    final galleryNodes = <DTextMediaEmbed>[];

    void flushGallery() {
      if (galleryNodes.isEmpty) return;

      segments.add(_DTextGallerySegment(List.unmodifiable(galleryNodes)));
      galleryNodes.clear();
    }

    for (final node in nodes) {
      if (node is DTextMediaEmbed && node.isGalleryItem) {
        galleryNodes.add(node);
        continue;
      }

      flushGallery();
      if (_isQuoteNode(node)) {
        segments.add(_DTextQuoteSegment(node as DTextElementNode));
      } else if (_isTableNode(node)) {
        segments.add(_DTextTableSegment(node as DTextElementNode));
      } else if (node is DTextExpand) {
        segments.add(_DTextExpandSegment(node));
      } else if (node is DTextMediaEmbed) {
        segments.add(_DTextMediaSegment(node));
      } else {
        segments.add(_DTextHtmlSegment([node]));
      }
    }

    flushGallery();
    return List.unmodifiable(segments);
  }

  static bool _isQuoteNode(DTextNode node) =>
      node is DTextElementNode && node.element == DTextElement.quote;

  static bool _isTableNode(DTextNode node) =>
      node is DTextElementNode && node.element == DTextElement.table;
}

class _DTextQuote extends StatelessWidget {
  const _DTextQuote({
    required this.node,
    required this.renderContext,
  });

  final DTextElementNode node;
  final _DTextRenderContext renderContext;

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
        renderContext: renderContext,
      ),
    );
  }
}
