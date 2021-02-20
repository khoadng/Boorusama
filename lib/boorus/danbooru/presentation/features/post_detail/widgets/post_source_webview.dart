// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class PostSourceWebView extends HookWidget {
  const PostSourceWebView({
    Key key,
    @required this.url,
  }) : super(key: key);

  final String url;

  @override
  Widget build(BuildContext context) {
    final loadProgress = useState(0.0);

    return SafeArea(
      child: Column(
        children: [
          Container(
              child: loadProgress.value < 1.0
                  ? LinearProgressIndicator(
                      value: loadProgress.value,
                    )
                  : SizedBox.shrink()),
          Expanded(
            child: InAppWebView(
              initialUrl: url,
              onProgressChanged: (controller, progress) =>
                  loadProgress.value = progress / 100,
            ),
          ),
        ],
      ),
    );
  }
}
