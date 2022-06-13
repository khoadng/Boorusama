// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class WebView extends HookWidget {
  const WebView({
    Key? key,
    required this.url,
  }) : super(key: key);

  final String url;

  @override
  Widget build(BuildContext context) {
    final loadProgress = useState<double>(0);

    return SafeArea(
      child: Column(
        children: [
          Container(
              child: loadProgress.value < 1.0
                  ? LinearProgressIndicator(
                      value: loadProgress.value,
                    )
                  : const SizedBox.shrink()),
          Expanded(
            child: InAppWebView(
              initialUrlRequest: URLRequest(url: Uri.parse(url)),
              onProgressChanged: (controller, progress) =>
                  loadProgress.value = progress / 100,
            ),
          ),
        ],
      ),
    );
  }
}
