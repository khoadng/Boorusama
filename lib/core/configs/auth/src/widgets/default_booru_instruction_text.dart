// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

// Project imports:
import '../../../../../foundation/html.dart';
import '../../../../theme.dart';

class DefaultBooruInstructionText extends StatelessWidget {
  const DefaultBooruInstructionText(
    this.text, {
    super.key,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
        color: Theme.of(context).colorScheme.hintColor,
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
    );
  }
}

class DefaultBooruInstructionHtmlText extends StatelessWidget {
  const DefaultBooruInstructionHtmlText(
    this.text, {
    super.key,
    this.onApiLinkTap,
  });

  final String text;
  final void Function()? onApiLinkTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppHtml(
      data: text,
      style: {
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
      },
      onLinkTap: onApiLinkTap != null
          ? (url, attributes, element) {
              if (url == 'api-credentials') {
                onApiLinkTap!();
              }
            }
          : null,
    );
  }
}
