// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:dtext/dtext.dart';
import 'package:flutter_html/flutter_html.dart';

// Project imports:
import '../../configs/config/types.dart';
import '../../images/booru_image.dart';
import '../../text_markup/types.dart';

const _inlineEmojiSize = 20.0;
const _jumboSingleEmojiSize = 48.0;
const _jumboFewEmojiSize = 40.0;
const _jumboManyEmojiSize = 28.0;

double dTextEmojiSizeForDocument(DTextDocument document) {
  final stats = _emojiOnlyStats(document.children);
  if (!stats.isEmojiOnly) return _inlineEmojiSize;

  return switch (stats.count) {
    1 => _jumboSingleEmojiSize,
    <= 3 => _jumboFewEmojiSize,
    _ => _jumboManyEmojiSize,
  };
}

String renderDTextEmojiHtml(
  DTextEmoji emoji,
  Map<String, TextEmoji> emojiMap,
  double emojiSize, {
  required bool supportsImageEmoji,
}) {
  final textEmoji = emojiMap[emoji.name.toLowerCase()];

  return switch (textEmoji) {
    TextEmojiText(:final text) =>
      '<span style="font-size: ${emojiSize}px; line-height: 1">${_escapeHtmlText(text)}</span>',
    TextEmojiImage(:final url, :final width, :final height)
        when supportsImageEmoji =>
      '<dtext-emoji data-src="${_escapeHtmlAttribute(url)}" data-name="${_escapeHtmlAttribute(emoji.name)}"${_dimensionAttribute('data-width', _scaledEmojiDimension(width, emojiSize))}${_dimensionAttribute('data-height', _scaledEmojiDimension(height, emojiSize))}></dtext-emoji>',
    TextEmojiImage() => ':${_escapeHtmlText(emoji.name)}:',
    null => '',
  };
}

List<HtmlExtension> dTextEmojiHtmlExtensions(BooruConfigAuth config) => [
  TagExtension.inline(
    tagsToExtend: {'dtext-emoji'},
    builder: (context) {
      final url = context.attributes['data-src'];
      if (url == null || url.isEmpty) return const TextSpan();

      final width =
          double.tryParse(context.attributes['data-width'] ?? '') ??
          _inlineEmojiSize;
      final height =
          double.tryParse(context.attributes['data-height'] ?? '') ??
          _inlineEmojiSize;

      return WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: DTextEmojiImageView(
          url: url,
          config: config,
          width: width,
          height: height,
        ),
      );
    },
  ),
];

class DTextEmojiImageView extends StatelessWidget {
  const DTextEmojiImageView({
    required this.url,
    required this.config,
    required this.width,
    required this.height,
    super.key,
  });

  final String url;
  final BooruConfigAuth config;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final safeWidth = width > 0 ? width : _inlineEmojiSize;
    final safeHeight = height > 0 ? height : _inlineEmojiSize;

    return SizedBox(
      width: safeWidth,
      height: safeHeight,
      child: BooruImage(
        imageUrl: url,
        config: config,
        aspectRatio: safeWidth / safeHeight,
        imageWidth: safeWidth,
        imageHeight: safeHeight,
        fit: BoxFit.contain,
        borderRadius: BorderRadius.zero,
        placeholderWidget: const SizedBox.shrink(),
      ),
    );
  }
}

({bool isEmojiOnly, int count}) _emojiOnlyStats(List<DTextNode> nodes) {
  var emojiCount = 0;

  for (final node in nodes) {
    switch (node) {
      case DTextEmoji():
        emojiCount++;
      case DTextText(:final text):
        if (text.trim().isNotEmpty) {
          return (isEmojiOnly: false, count: 0);
        }
      case DTextLineBreak():
        break;
      case DTextElementNode(
        element: DTextElement.paragraph,
        :final children,
      ):
        final childStats = _emojiOnlyStats(children);
        if (!childStats.isEmojiOnly) {
          return (isEmojiOnly: false, count: 0);
        }
        emojiCount += childStats.count;
      default:
        return (isEmojiOnly: false, count: 0);
    }
  }

  return (isEmojiOnly: emojiCount > 0, count: emojiCount);
}

int _scaledEmojiDimension(int? original, double emojiSize) {
  if (original == null || original <= 0) return emojiSize.round();

  final inlineScale = emojiSize / _inlineEmojiSize;

  return (original * inlineScale).round();
}

String _dimensionAttribute(String name, int? value) {
  if (value == null || value <= 0) return '';

  return ' $name="$value"';
}

String _escapeHtmlText(String value) => value
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;');

String _escapeHtmlAttribute(String value) => _escapeHtmlText(value);
