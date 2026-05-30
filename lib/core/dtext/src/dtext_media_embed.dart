// Dart imports:
import 'dart:math' as math;

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:dtext/dtext.dart';
import 'package:flutter_html/flutter_html.dart';

// Project imports:
import '../../configs/config/types.dart';
import '../../images/booru_image.dart';
import '../../text_markup/types.dart';
import '../../../foundation/html.dart';
import 'dtext_emoji_renderer.dart';
import 'dtext_html.dart';

class DTextMediaEmbedView extends StatelessWidget {
  const DTextMediaEmbedView({
    required this.node,
    required this.mediaEmbedMap,
    required this.imageConfig,
    required this.emojiMap,
    required this.emojiSize,
    required this.style,
    required this.onLinkTap,
    required this.selectable,
    super.key,
    this.maxImageWidth,
    this.padding = const EdgeInsets.symmetric(vertical: 8),
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.captionTextAlign,
    this.imageFrameSize,
  });

  final DTextMediaEmbed node;
  final Map<TextMediaEmbedRef, TextMediaEmbed> mediaEmbedMap;
  final BooruConfigAuth? imageConfig;
  final Map<String, TextEmoji> emojiMap;
  final double emojiSize;
  final Map<String, Style>? style;
  final OnTap? onLinkTap;
  final bool selectable;
  final double? maxImageWidth;
  final EdgeInsetsGeometry padding;
  final CrossAxisAlignment crossAxisAlignment;
  final TextAlign? captionTextAlign;
  final Size? imageFrameSize;

  @override
  Widget build(BuildContext context) {
    final ref = _refForNode(node);
    if (ref == null) return const SizedBox.shrink();

    final embed = mediaEmbedMap[ref];
    final captionStyle = captionTextAlign == null
        ? style
        : {
            ...?style,
            'body': (style?['body'] ?? Style()).merge(
              Style(textAlign: captionTextAlign),
            ),
          };
    final body = switch (embed) {
      TextMediaImageEmbed() when imageConfig != null => _ImageEmbed(
        embed: embed,
        config: imageConfig!,
        onLinkTap: onLinkTap,
        maxWidth: maxImageWidth,
        frameSize: imageFrameSize,
      ),
      TextMediaEmbed(:final pageUrl) => _UnavailableEmbed(
        label: '${node.type} #${node.id}',
        pageUrl: pageUrl,
        onLinkTap: onLinkTap,
      ),
      null => _UnavailableEmbed(
        label: '${node.type} #${node.id}',
        pageUrl: null,
        onLinkTap: onLinkTap,
      ),
    };

    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: crossAxisAlignment,
        mainAxisSize: MainAxisSize.min,
        children: [
          body,
          if (node.caption.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: SizedBox(
                width: double.infinity,
                child: AppHtml(
                  data: renderDTextNodesHtml(
                    node.caption,
                    emojiMap: emojiMap,
                    emojiSize: emojiSize,
                    emojiImageConfig: imageConfig,
                  ),
                  style: dTextHtmlStyle(captionStyle),
                  onLinkTap: onLinkTap,
                  extensions: [
                    if (imageConfig case final config?)
                      ...dTextEmojiHtmlExtensions(config),
                  ],
                  selectable: selectable,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class DTextMediaEmbedGallery extends StatelessWidget {
  const DTextMediaEmbedGallery({
    required this.nodes,
    required this.mediaEmbedMap,
    required this.imageConfig,
    required this.emojiMap,
    required this.emojiSize,
    required this.style,
    required this.onLinkTap,
    required this.selectable,
    super.key,
  });

  final List<DTextMediaEmbed> nodes;
  final Map<TextMediaEmbedRef, TextMediaEmbed> mediaEmbedMap;
  final BooruConfigAuth? imageConfig;
  final Map<String, TextEmoji> emojiMap;
  final double emojiSize;
  final Map<String, Style>? style;
  final OnTap? onLinkTap;
  final bool selectable;

  @override
  Widget build(BuildContext context) {
    if (nodes.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : 360.0;
        const spacing = 12.0;
        final columns = availableWidth >= 560
            ? 3
            : availableWidth >= 340
            ? 2
            : 1;
        final tileWidth = math
            .min<num>(
              180,
              (availableWidth - (spacing * (columns - 1))) / columns,
            )
            .toDouble();

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Wrap(
            spacing: spacing,
            runSpacing: spacing,
            children: [
              for (final node in nodes)
                SizedBox(
                  width: tileWidth,
                  child: DTextMediaEmbedView(
                    node: node,
                    mediaEmbedMap: mediaEmbedMap,
                    imageConfig: imageConfig,
                    emojiMap: emojiMap,
                    emojiSize: emojiSize,
                    style: style,
                    onLinkTap: onLinkTap,
                    selectable: selectable,
                    maxImageWidth: tileWidth,
                    padding: EdgeInsets.zero,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    captionTextAlign: TextAlign.center,
                    imageFrameSize: Size.square(tileWidth),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _ImageEmbed extends StatelessWidget {
  const _ImageEmbed({
    required this.embed,
    required this.config,
    required this.onLinkTap,
    required this.maxWidth,
    required this.frameSize,
  });

  final TextMediaImageEmbed embed;
  final BooruConfigAuth config;
  final OnTap? onLinkTap;
  final double? maxWidth;
  final Size? frameSize;

  @override
  Widget build(BuildContext context) {
    final width = embed.width > 0 ? embed.width.toDouble() : 1.0;
    final height = embed.height > 0 ? embed.height.toDouble() : 1.0;
    final aspectRatio = width / height;
    final image = InkWell(
      onTap: onLinkTap == null
          ? null
          : () => onLinkTap!(embed.pageUrl, const {}, null),
      child: BooruImage(
        imageUrl: embed.imageUrl,
        config: config,
        aspectRatio: aspectRatio,
        imageWidth: width,
        imageHeight: height,
        fit: BoxFit.contain,
        borderRadius: const BorderRadius.all(Radius.circular(4)),
      ),
    );

    if (frameSize case final size?) {
      return SizedBox(
        width: size.width,
        height: size.height,
        child: Center(
          child: AspectRatio(
            aspectRatio: aspectRatio,
            child: image,
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : 720.0;
        final displayWidth = math.min(
          width,
          math.min(maxWidth, this.maxWidth ?? maxWidth),
        );
        final displayHeight = displayWidth / aspectRatio;

        return SizedBox(
          width: displayWidth,
          height: displayHeight,
          child: image,
        );
      },
    );
  }
}

class _UnavailableEmbed extends StatelessWidget {
  const _UnavailableEmbed({
    required this.label,
    required this.pageUrl,
    required this.onLinkTap,
  });

  final String label;
  final String? pageUrl;
  final OnTap? onLinkTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: pageUrl == null || onLinkTap == null
          ? null
          : () => onLinkTap!(pageUrl, const {}, null),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: colorScheme.outlineVariant),
          borderRadius: const BorderRadius.all(Radius.circular(4)),
        ),
        child: Text(label),
      ),
    );
  }
}

TextMediaEmbedRef? _refForNode(DTextMediaEmbed node) {
  final type = TextMediaEmbedType.parse(node.type);
  final id = int.tryParse(node.id);
  if (type == null || id == null || id <= 0) return null;

  return TextMediaEmbedRef(type: type, id: id);
}
