// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_html/flutter_html.dart';

class AppHtml extends StatelessWidget {
  const AppHtml({
    super.key,
    required this.data,
    this.style,
    this.onLinkTap,
  });

  final String data;
  final Map<String, Style>? style;
  final OnTap? onLinkTap;

  @override
  Widget build(BuildContext context) {
    return Html(
      data: data,
      style: _mergeStyle(context, style),
      onLinkTap: onLinkTap,
    );
  }

  Map<String, Style> _mergeStyle(
    BuildContext context,
    Map<String, Style>? style,
  ) {
    final effectiveStyle = {
      ...{
        'body': Style(
          margin: Margins.zero,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      },
    };

    if (style == null) return effectiveStyle;

    for (final entry in style.entries) {
      effectiveStyle[entry.key] =
          effectiveStyle[entry.key]?.merge(entry.value) ?? entry.value;
    }

    return effectiveStyle;
  }
}
