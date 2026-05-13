// Package imports:
import 'package:dtext/dtext.dart';
import 'package:flutter_html/flutter_html.dart';

// Project imports:
import '../../configs/config/types.dart';
import '../../text_markup/types.dart';
import 'dtext_emoji_renderer.dart';

Map<String, Style> dTextHtmlStyle(Map<String, Style>? baseStyle) => {
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

String renderDTextNodesHtml(
  List<DTextNode> nodes, {
  required Map<String, TextEmoji> emojiMap,
  required double emojiSize,
  required BooruConfigAuth? emojiImageConfig,
}) {
  return DText.renderHtml(
    DTextDocument(children: List.of(nodes)),
    emojiHtmlBuilder: (emoji) => renderDTextEmojiHtml(
      emoji,
      emojiMap,
      emojiSize,
      supportsImageEmoji: emojiImageConfig != null,
    ),
  );
}
