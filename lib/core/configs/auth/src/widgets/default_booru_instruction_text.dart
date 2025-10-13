// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../../foundation/html.dart';
import '../../../../themes/theme/types.dart';

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
      style: AppHtml.hintStyle(colorScheme),
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
