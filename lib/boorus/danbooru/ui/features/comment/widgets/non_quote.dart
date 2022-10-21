// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_html/flutter_html.dart';

// Project imports:
import 'package:boorusama/core/core.dart';

class NonQuote extends StatelessWidget {
  const NonQuote({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return SelectableHtml(
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
    );
  }
}
