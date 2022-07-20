// Dart imports:
import 'dart:convert';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:webview_flutter/webview_flutter.dart';

// Project imports:
import 'package:boorusama/core/core.dart';

class EmbeddedWebViewWebm extends StatefulWidget {
  const EmbeddedWebViewWebm({
    Key? key,
    required this.videoHtml,
  }) : super(key: key);

  final String videoHtml;

  @override
  State<EmbeddedWebViewWebm> createState() => _EmbeddedWebViewWebmState();
}

class _EmbeddedWebViewWebmState extends State<EmbeddedWebViewWebm> {
  @override
  void initState() {
    super.initState();
    // Enable virtual display.
    if (isAndroid()) WebView.platform = SurfaceAndroidWebView();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      height: MediaQuery.of(context).size.height,
      child: WebView(
        backgroundColor: Colors.black,
        allowsInlineMediaPlayback: true,
        initialUrl: 'about:blank',
        onWebViewCreated: (controller) {
          controller.loadUrl(Uri.dataFromString(
            widget.videoHtml,
            mimeType: 'text/html',
            encoding: Encoding.getByName('utf-8'),
          ).toString());
        },
      ),
    );
  }
}
