// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_html/flutter_html.dart';

// Project imports:
import 'package:boorusama/core/utils.dart';
import 'package:boorusama/foundation/theme/theme.dart';

class Quote extends StatelessWidget {
  const Quote({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceVariant,
        border: Border.all(
          color: context.theme.hintColor,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6),
      margin: const EdgeInsets.only(
        top: 3,
        bottom: 6,
      ),
      child: SelectableHtml(
        style: {
          'body': Style(
            fontSize: FontSize.medium,
            margin: EdgeInsets.zero,
            padding: EdgeInsets.zero,
          ),
        },
        data: text,
        onLinkTap: (url, context, attributes, element) {
          if (url != null) launchExternalUrl(Uri.parse(url));
        },
      ),
    );
  }
}
