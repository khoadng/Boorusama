// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:webview_flutter/webview_flutter.dart';

class EmbeddedWebViewWebm extends StatefulWidget {
  const EmbeddedWebViewWebm({
    super.key,
    required this.videoHtml,
  });

  final String videoHtml;

  @override
  State<EmbeddedWebViewWebm> createState() => _EmbeddedWebViewWebmState();
}

class _EmbeddedWebViewWebmState extends State<EmbeddedWebViewWebm> {
  final WebViewController controller = WebViewController();

  @override
  void initState() {
    super.initState();
    controller
      ..setBackgroundColor(Colors.black)
      ..loadHtmlString(widget.videoHtml);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      height: MediaQuery.of(context).size.height,
      child: WebViewWidget(controller: controller),
    );
  }
}
