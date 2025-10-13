// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_html/flutter_html.dart';

// Project imports:
import '../core/themes/theme/types.dart';

class AppHtml extends StatefulWidget {
  const AppHtml({
    required this.data,
    super.key,
    this.style,
    this.onLinkTap,
    this.selectable = true,
  });

  final String data;
  final Map<String, Style>? style;
  final OnTap? onLinkTap;
  final bool selectable;

  static Map<String, Style> hintStyle(ColorScheme colorScheme) => {
    'a': Style(
      textDecoration: TextDecoration.none,
      color: colorScheme.primary,
      fontSize: FontSize(12),
    ),
    'b': Style(
      textDecoration: TextDecoration.underline,
      textDecorationColor: colorScheme.hintColor,
      fontWeight: FontWeight.bold,
      fontSize: FontSize(12),
    ),
    'body': Style(
      margin: Margins.zero,
      color: colorScheme.hintColor,
      fontSize: FontSize(12),
    ),
  };

  @override
  State<AppHtml> createState() => _AppHtmlState();
}

class _AppHtmlState extends State<AppHtml> {
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final html = Html(
      data: widget.data,
      style: _mergeStyle(context, widget.style),
      onLinkTap: widget.onLinkTap,
    );

    return widget.selectable
        ? SelectableRegion(
            focusNode: _focusNode,
            selectionControls: materialTextSelectionControls,
            child: html,
          )
        : html;
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
        'a': Style(
          color: Theme.of(context).colorScheme.primary,
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
