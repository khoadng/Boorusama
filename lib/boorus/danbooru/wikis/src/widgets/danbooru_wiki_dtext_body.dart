// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../core/configs/config/providers.dart';
import '../../../text_markup/widgets.dart';
import '../routes/route_utils.dart';

class DanbooruWikiDTextBody extends ConsumerWidget {
  const DanbooruWikiDTextBody({
    required this.data,
    super.key,
  });

  final String data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfigAuth;

    return DefaultTextStyle.merge(
      style: const TextStyle(fontSize: 15),
      child: DanbooruDTextBody(
        data: data,
        config: config,
        onLinkTap: (url, _, _) => openDanbooruWikiLink(ref, url),
        style: _wikiDTextStyle(context),
      ),
    );
  }
}

Map<String, Style> _wikiDTextStyle(BuildContext context) {
  final colorScheme = Theme.of(context).colorScheme;
  final codeBackground = colorScheme.surfaceContainerHighest.withValues(
    alpha: 0.75,
  );

  Style headingStyle({
    required double fontSize,
    required double top,
    required double bottom,
  }) => Style(
    fontSize: FontSize(fontSize),
    fontWeight: FontWeight.w800,
    lineHeight: const LineHeight(1.15),
    margin: Margins.only(top: top, bottom: bottom),
  );

  return {
    'body': Style(
      fontSize: FontSize(15),
      lineHeight: const LineHeight(1.35),
    ),
    'p': Style(
      margin: Margins.only(bottom: 12),
    ),
    'a': Style(
      textDecoration: TextDecoration.none,
    ),
    'h1': headingStyle(fontSize: 30, top: 26, bottom: 12),
    'h2': headingStyle(fontSize: 28, top: 24, bottom: 12),
    'h3': headingStyle(fontSize: 26, top: 22, bottom: 10),
    'h4': headingStyle(fontSize: 24, top: 22, bottom: 10),
    'h5': headingStyle(fontSize: 20, top: 18, bottom: 8),
    'h6': headingStyle(fontSize: 17, top: 16, bottom: 6),
    'ul': Style(
      margin: Margins.only(left: 14, bottom: 14),
      padding: HtmlPaddings.zero,
      listStylePosition: ListStylePosition.outside,
    ),
    'ol': Style(
      margin: Margins.only(left: 18, bottom: 14),
      padding: HtmlPaddings.zero,
      listStylePosition: ListStylePosition.outside,
    ),
    'li': Style(
      margin: Margins.only(bottom: 4),
      padding: HtmlPaddings.zero,
    ),
    'ul > li': Style(
      marker: Marker(
        content: const Content('• '),
        style: Style(
          fontSize: FontSize(16),
          fontWeight: FontWeight.w900,
        ),
      ),
    ),
    'blockquote': Style(
      margin: Margins.only(left: 4, top: 8, bottom: 12),
      padding: HtmlPaddings.only(left: 8),
      border: Border(
        left: BorderSide(
          color: colorScheme.outlineVariant,
          width: 3,
        ),
      ),
    ),
    'pre': Style(
      margin: Margins.only(bottom: 12),
      padding: HtmlPaddings.all(8),
      backgroundColor: codeBackground,
    ),
    'code': Style(
      fontFamily: 'monospace',
      backgroundColor: codeBackground,
    ),
    'table': Style(
      margin: Margins.only(bottom: 14),
    ),
  };
}
