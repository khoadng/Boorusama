// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:coreutils/coreutils.dart';
import 'package:i18n/i18n.dart';
import 'package:webview_cookie_manager/webview_cookie_manager.dart';
import 'package:webview_flutter/webview_flutter.dart';

class CookieAccessWebViewPage extends StatefulWidget {
  const CookieAccessWebViewPage({
    required this.url,
    required this.onGet,
    super.key,
  });

  final String url;
  final void Function(List<Cookie> cookies) onGet;

  @override
  State<CookieAccessWebViewPage> createState() =>
      _CookieAccessWebViewPageState();
}

class _CookieAccessWebViewPageState extends State<CookieAccessWebViewPage> {
  final controller = WebViewController();

  @override
  void initState() {
    super.initState();

    controller
      ..loadRequest(Uri.parse(widget.url))
      ..setJavaScriptMode(JavaScriptMode.unrestricted);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Login'.hc),
      ),
      body: Column(
        children: [
          _buildBanner('Press the button below after you logged in.'.hc),
          FilledButton(
            onPressed: () async {
              final cookies = await WebviewCookieManager().getCookies(
                widget.url,
              );
              widget.onGet(cookies);
            },
            child: Text('Access Cookie'.hc),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: WebViewWidget(
              controller: controller,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBanner(String text) {
    return Container(
      margin: const EdgeInsets.symmetric(
        vertical: 16,
        horizontal: 24,
      ),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(4)),
        border: Border.all(
          color: Colors.white,
        ),
      ),
      width: MediaQuery.sizeOf(context).width,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
