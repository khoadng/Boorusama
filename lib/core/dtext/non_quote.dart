// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_html/flutter_html.dart';

// Project imports:
import '../../foundation/html.dart';
import '../../foundation/url_launcher.dart';

class NonQuote extends StatelessWidget {
  const NonQuote({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return AppHtml(
      style: {
        'body': Style(
          fontSize: FontSize.medium,
          margin: Margins.zero,
          whiteSpace: WhiteSpace.pre,
        ),
      },
      data: text,
      onLinkTap: (url, attributes, element) {
        if (url != null) launchExternalUrl(Uri.parse(url));
      },
    );
  }
}
